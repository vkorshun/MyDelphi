unit ServerDocSqlManager;

interface

uses
  SysUtils, Classes,  rtcLog, DB, variants, vkvariable, System.Generics.Collections, SQLTableProperties, CommonInterface;

type
  TServerDocSqlManager = class(TObject)
  private
    FSQLTableProperties: TSQLTableProperties;
  public
    constructor Create;
    destructor Destroy;override;
    function GenerateDeleteSQL:String;
    function GenerateLockSQL:String;
    function GenerateInsertSQL(AParams: TVkVariableCollection):String;
    function GenerateUpdateSQL(AParams: TVkVariableCollection):String;

    function GenerateSQL(operation:TDocOperation; AParams: TVkVariableCollection):String;
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
    sb.Append(' DELETE FROM ').Append(FSQLTableProperties.TableName)
  finally
    sb.Free;
  end;

end;

function TServerDocSqlManager.GenerateInsertSQL(AParams: TVkVariableCollection): String;
var bFirst: Boolean;
    i: Integer;
    sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try
    sb.Append(' INSERT INTO ' + FSQLTableProperties.TableName);
    sb.AppendLine;
    sb.Append(' (');
    bFirst := true;
    for i := 0 to AParams.Count - 1 do
    begin
      if (FSQLTableProperties.FieldNameList.IndexOf(AParams.Items[i].Name) > -1) and
        (FSQLTableProperties.InsertExclude.IndexOf(AParams.Items[i].Name) = -1) and
        (IndexOfInAdditionalFields(AParams.Items[i].Name) = -1) then
      begin
        if not bFirst then
          sb.Append(',');
        sb.AppendLine;
        sb.Append(AParams.Items[i].Name);
        bFirst := False;
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

function TServerDocSqlManager.GenerateSQL(operation: TDocOperation; AParams: TVkVariableCollection): String;
begin
  case operation of
    docInsert: Result := GenerateInsertSQL(AParams);
    docUpdate: Result := GenerateUpdateSQL(AParams);
    docDelete: Result := GenerateDeleteSQL;
  end;
end;

function TServerDocSqlManager.GenerateUpdateSQL(AParams: TVkVariableCollection): String;
var
  i: Integer;
  _UpdateList: TStringList;
  bFirst: Boolean;
  sb: TStringBuilder;
begin
  _UpdateList := TStringList.Create;
  sb := TStringBuilder.Create;
  bFirst := true;
  try
    AParams.GetChangedList(_UpdateList);
//    bChanged := False; // _UpdateList.Count > 0;
    with sb do
    begin
      Append(' UPDATE ' + FSQLTableProperties.TableName);
      Append(' SET');
      for i := 0 to _UpdateList.Count - 1 do
      begin
        if (FSQLTableProperties.FieldNameList.IndexOf(_UpdateList[i]) > -1) and
          (IndexOfInAdditionalFields(_UpdateList[i]) = -1) then
        begin
          if not bFirst then
            Append(',')
          else
          begin
            bFirst := False;
            //bChanged := true;
          end;
          if AParams.VarByName(_UpdateList[i]).IsDelta then
            Append(_UpdateList[i] + ' = ' + _UpdateList[i] + '+:' + _UpdateList[i])
          else
            Append(_UpdateList[i] + ' = :' + _UpdateList[i]);
        end;
      end;
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
