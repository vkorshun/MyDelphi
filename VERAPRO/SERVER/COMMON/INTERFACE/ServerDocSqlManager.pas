unit ServerDocSqlManager;

interface

uses
  SysUtils, Classes,  rtcLog, DB, variants, vkvariable, System.Generics.Collections, SQLTableProperties, CommonInterface;

type
  TServerDocSqlManager = class(TObject)
  private
    FSQLTableProperties: TSQLTableProperties;
  public
    constructor Create;virtual;
    destructor Destroy;override;
    function GenerateDeleteSQL:String;
    function GenerateLockSQL:String;
    function GenerateInsertSQL(AParams: TVkVariableCollection; AIsEmpty:PBoolean):String;
    function GenerateUpdateSQL(AParams: TVkVariableCollection; AIsEmpty:PBoolean):String;

    function GenerateSQL(operation:TDocOperation; AParams: TVkVariableCollection; AIsEmpty:PBoolean  = nil):String;
    function GetWhereOnKeyFields: String;
    function GetReturningOnKeyFields: String;
    function IndexOfInAdditionalFields(const AFieldName:String):Integer;
    property SQLTableProperties:TSQLTableProperties read FSQLTableProperties;
  end;

implementation

{ TServerDocSqlManager }

constructor TServerDocSqlManager.Create;
begin
  FSQLTableProperties:= TSQLTableProperties.Create;

end;

destructor TServerDocSqlManager.Destroy;
begin
  FSQLTableProperties.Free;
  inherited;
end;

function TServerDocSqlManager.GenerateDeleteSQL: String;
var
  sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try
    sb.Append(' DELETE FROM ').Append(FSQLTableProperties.TableName);
    sb.Append(GetWhereOnKeyFields);
    Result := sb.toString();
  finally
    sb.Free;
  end;

end;

function TServerDocSqlManager.GenerateInsertSQL(AParams: TVkVariableCollection; AIsEmpty:PBoolean): String;
var bFirst: Boolean;
    i: Integer;
    sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try
    sb.Append(' INSERT INTO ' + FSQLTableProperties.TableName);
    sb.AppendLine;
    sb.Append(' (');
    AIsEmpty^ := true;
    for i := 0 to AParams.Count - 1 do
    begin
      if (FSQLTableProperties.FieldNameList.IndexOf(AParams.Items[i].Name) > -1) and
        (FSQLTableProperties.InsertExclude.IndexOf(AParams.Items[i].Name) = -1) and
        (IndexOfInAdditionalFields(AParams.Items[i].Name) = -1) then
      begin
        if not AIsEmpty^ then
          sb.Append(',')
        else
          AIsEmpty^ := False;
        sb.AppendLine;
        sb.Append(AParams.Items[i].Name);
      end;
    end;
    sb.Append(')');
    sb.AppendLine;
    sb.Append(' VALUES (');
    bFirst := true;
    for i := 0 to AParams.Count - 1 do
    begin
      if (FSQLTableProperties.FieldNameList.IndexOf(AParams.Items[i].Name) > -1) and
        (IndexOfInAdditionalFields(AParams.Items[i].Name) = -1) then
      begin
        if not bFirst then
          sb.Append(',');
        sb.AppendLine;
        sb.Append(':' + AParams.Items[i].Name);
        bFirst := False;
      end;
    end;
    sb.Append(')');
    if FSQLTableProperties.KeyFieldsList.Count > 0 then
    begin
      sb.AppendLine;
      sb.Append(GetReturningOnKeyFields);
    end;
    Result := sb.toString;
  finally
    sb.Free;
  end;
end;

function TServerDocSqlManager.GenerateLockSQL: String;
var
  sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try
    sb.Append(' SELECT * FROM ' + FSQLTableProperties.TableName);
    sb.Append(GetWhereOnKeyFields);
    sb.Append(' WITH LOCK ');
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TServerDocSqlManager.GenerateSQL(operation: TDocOperation; AParams: TVkVariableCollection; AIsEmpty: PBoolean): String;
var isEmpty: Boolean;
begin
  isEmpty := true;
  case operation of
    docInsert: Result := GenerateInsertSQL(AParams, @IsEmpty);
    docUpdate: Result := GenerateUpdateSQL(AParams, @IsEmpty);
    docDelete: Result := GenerateDeleteSQL;
  end;
  if Assigned(AIsEmpty) then
    AIsEmpty^ := IsEmpty;
end;

function TServerDocSqlManager.GenerateUpdateSQL(AParams: TVkVariableCollection; AIsEmpty: PBoolean): String;
var
  i: Integer;
  _UpdateList: TStringList;
  sb: TStringBuilder;
begin
  _UpdateList := TStringList.Create;
  sb := TStringBuilder.Create;
  AIsEmpty^ := true;
  try
    AParams.GetChangedList(_UpdateList);
//    bChanged := False; // _UpdateList.Count > 0;
    with sb do
    begin
      Append(' UPDATE ' + FSQLTableProperties.TableName);
      AppendLine;
      Append(' SET');
      AppendLine;
      for i := 0 to _UpdateList.Count - 1 do
      begin
        if (FSQLTableProperties.FieldNameList.IndexOf(_UpdateList[i]) > -1) and
          (IndexOfInAdditionalFields(_UpdateList[i]) = -1) then
        begin
          if not AIsEmpty^ then
          begin
            Append(',');
            AppendLine;
          end
          else
          begin
            AIsEmpty^ := False;
            //bChanged := true;
          end;
          if AParams.VarByName(_UpdateList[i]).IsDelta then
            Append(_UpdateList[i] + ' = ' + _UpdateList[i] + '+:' + _UpdateList[i])
          else
            Append(_UpdateList[i] + ' = :' + _UpdateList[i]);
        end;
      end;
      AppendLine;
      Append(GetWhereOnKeyFields);
      Result := sb.ToString;
    end;
  finally
    FreeandNil(_UpdateList);
    sb.Free;
  end;
end;

function TServerDocSqlManager.GetReturningOnKeyFields: String;
var
  i: Integer;
  sb: TStringBuilder;
begin
  sb := tStringBuilder.Create;
  try
    if FSQLTableProperties.KeyFieldsList.Count = 0 then
      sb.append('')
    //else if FSQLTableProperties.KeyFieldsList.Count = 1 then
    //  sb.append(' RETURNING ').append( FSQLTableProperties.KeyFieldsList[0]).append(' INTO :').Append( FSQLTableProperties.KeyFieldsList[0])
    else
    begin
      sb.Append(' RETURNING ');
      for i := 0 to FSQLTableProperties.KeyFieldsList.Count - 1 do
      begin
        sb.append(FSQLTableProperties.KeyFieldsList[i]);
        if i < FSQLTableProperties.KeyFieldsList.Count - 1 then
          sb.append(', ');
      end;
      //sb.append(' INTO ');
      //for i := 0 to FSQLTableProperties.KeyFieldsList.Count - 1 do
      //begin
      //  sb.append(':'+FSQLTableProperties.KeyFieldsList[i]);
      //  if i < FSQLTableProperties.KeyFieldsList.Count - 1 then
      //    sb.append(', ');
      //end;
    end;
    Result := sb.toString();
  finally
    sb.free;
  end;
end;

function TServerDocSqlManager.GetWhereOnKeyFields: String;
var
  i: Integer;
  sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try
    if FSQLTableProperties.KeyFieldsList.Count = 0 then
      sb.Append('')
    else if FSQLTableProperties.KeyFieldsList.Count = 1 then
      sb.Append(' WHERE ').Append( FSQLTableProperties.KeyFieldsList[0]).Append(' = :').Append( FSQLTableProperties.KeyFieldsList[0])
    else
    begin
      sb.Append(' WHERE ');
      for i := 0 to FSQLTableProperties.KeyFieldsList.Count - 1 do
      begin
        sb.Append( FSQLTableProperties.KeyFieldsList[i]).Append(' = :').Append(FSQLTableProperties.KeyFieldsList[i]);
        if i < FSQLTableProperties.KeyFieldsList.Count - 1 then
          sb.Append(' AND ');
      end;
    end;
    Result := sb.toString();
  finally
    sb.free;
  end;

end;

function TServerDocSqlManager.IndexOfInAdditionalFields(const AFieldName: String): Integer;
begin
  Result := -1;
end;

end.
