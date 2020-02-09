unit ClientDocSqlManager;

interface

uses
  SysUtils, Classes, rtcFunction, rtcDataCli, rtcCliModule, rtcInfo, rtcConn,
  rtcHttpCli, rtcLog,
  rtcDB, DB, MemTableDataEh, MemTableEh, variants, DataDriverEh,
  vkvariable, Dialogs, System.Generics.Collections, System.Contnrs;

type
  // TOnFillFieldNameList = procedure(Sender:TObject);
  TAdditionalSqlManager = class
  private
    FTableName: String;
    FFieldList: TStringList;
    FObjectList: TObjectList;
  public
    constructor Create;
    destructor Destroy; override;
    property TableName: String read FTableName write FTableName;
    property FieldList: TStringList read FFieldList;
    property ObjectList: TObjectList read FObjectList;
  end;

  TClientDocSQLManager = class(TObject)
  private
    FTableName: String;
    FKeyFields: String;
    FKeyFieldsList: TStringList;
    FGenId: String;
    FSelectSQL: TStringList;
    FParams: TParams;
//    FUpdateSQL: TStringList;
//    FInsertSQL: TStringList;
//    FDeleteSQL: TStringList;
//    FLockSQL: TStringList;

    FDocVariableList: TVkVariableCollection;
    FFieldNameList: TStringList;
//    FOnFillFieldNameList: TNotifyEvent;
//    FAdditionalList: TList<TAdditionalSqlManager>;
    procedure SetTableName(const Value: String);
    function GetKeyFieldsList: TStringList;
    function GetKeyFields: String;
  protected
//    procedure FillFieldNameList; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CalcVariablesOnDs(DataSet: TDataSet;
      AVarList: TVkVariableCollection);
    function GetKeyValues(ADataSet: TDataSet): Variant; overload;
    function GetKeyValues(AVarList: TVkVariableCollection): Variant; overload;
//    procedure GenerateDinamicSQLInsert;
//    procedure GenerateDinamicSQLUpdate(var bChanged: Boolean);
//    procedure GenerateDinamicSQLDelete;
//    procedure GenerateDinamicSQLLock;
//    function GenerateSQLInsert(AParams: TVkVariableCollection):String;
//    function GenerateSQLUpdate(AParams: TVkVariableCollection):String;
//    function GenerateSQLDelete(AParams: TVkVariableCollection):String;

//    function GetReturningOnKeyFields: String;
//    function GetWhereOnKeyFields: String;
    procedure InitCommonParams(const ATableName: String = '';
       const AGenId: String = '');
    procedure SaveVariablesInDataSet(ADataSet: TDataSet;
      AVarList: TVkVariableCollection);
    procedure UpdateVariablesOnDeltaDs(DataSet: TDataSet;
      AVarList: TVkVariableCollection);
//    function IndexOfInAdditionalFields(const AName: String): Integer;

//    property AdditionalList: TList<TAdditionalSqlManager> read FAdditionalList;
    property DocVariableList: TVkVariableCollection read FDocVariableList;
    property TableName: String read FTableName write SetTableName;
//    property GenId: String read FGenId write FGenId;
    property SelectSQL: TStringList read FSelectSQL;
//    property UpdateSQL: TStringList read FUpdateSQL;
//    property InsertSQL: TStringList read FInsertSQL;
//    property DeleteSQL: TStringList read FDeleteSQL;
//    property LockSQL: TStringList read FLockSQL;
    property KeyFields: String read GetKeyFields;
    property KeyFieldsList: TStringList read GetKeyFieldsList;
//    property OnFillFieldNameList: TNotifyEvent read FOnFillFieldNameList
//      write FOnFillFieldNameList;
    property FieldNameList: TStringList read FFieldNameList;
    property Params: TParams read FParams;
  end;

implementation

{ TDocSqlManager }

procedure TClientDocSQLManager.CalcVariablesOnDs(DataSet: TDataSet;
  AVarList: TVkVariableCollection);
var
  i: Integer;
  ind: Integer;
begin
  with DataSet do
  begin
    for i := 0 to FieldCount - 1 do
    begin
      ind := AVarList.IndexOf(Fields[i].FieldName);
      if ind > -1 then
      begin
        case Fields[i].DataType of
          ftFMTBcd:
            AVarList[Fields[i].FieldName].InitValue := Fields[i].AsFloat;
          ftBcd:
            AVarList[Fields[i].FieldName].InitValue := Fields[i].AsLargeInt;
          ftBlob:
            AVarList[Fields[i].FieldName].InitValue := Fields[i].AsString;
        else
          try
            AVarList.Items[ind].InitValue := Fields[i].Value;
            XLog(Fields[i].FieldName + ' = ' + Fields[i].AsString);
          except
            XLog(Fields[i].FieldName + ' = ' + Fields[i].AsString);
            ShowMessage((' error in InitVariable i = ' + IntToStr(i)));
            Raise;
          end;
        end;
      end;
    end;
  end;
end;

constructor TClientDocSQLManager.Create;
begin
  FSelectSQL := TStringList.Create;
  //FUpdateSQL := TStringList.Create;
  //FInsertSQL := TStringList.Create;
  //FDeleteSQL := TStringList.Create;
  //FLockSQL := TStringList.Create;
  FFieldNameList := TStringList.Create;
  FDocVariableList := TVkVariableCollection.Create(nil);
  FKeyFieldsList := TStringList.Create;
  //FAdditionalList := TList<TAdditionalSqlManager>.Create;
  FParams := TParams.Create(nil);
end;

destructor TClientDocSQLManager.Destroy;
begin
  FSelectSQL.Free;
  //FUpdateSQL.Free;
  //FInsertSQL.Free;
  //FDeleteSQL.Free;
  //FLockSQL.Free;
  FDocVariableList.Free;
  FKeyFieldsList.Free;
  FFieldNameList.Free;
  //FAdditionalList.Free;
  FParams.Free;
  inherited;
end;

{procedure TClientDocSQLManager.FillFieldNameList;
begin
  if Assigned(FOnFillFieldNameList) then
    FOnFillFieldNameList(Self);
//  else
//    raise Exception.Create('Error - OnFillFieldNameList -  is not defined');
end;}

{procedure TClientDocSQLManager.GenerateDinamicSQLDelete;
begin
  FDeleteSQL.Clear;
  FDeleteSQL.Add(' DELETE FROM ' + FTableName);
  FDeleteSQL.Add(GetWhereOnKeyFields);
end;

procedure TClientDocSQLManager.GenerateDinamicSQLInsert;
var
  i: Integer;
  bFirst: Boolean;
begin
  with FInsertSQL do
  begin
    Clear;
    Add(' INSERT INTO ' + FTableName);
    Add('(');
    bFirst := true;
    for i := 0 to FDocVariableList.Count - 1 do
    begin
      if (FFieldNameList.IndexOf(FDocVariableList.Items[i].Name) > -1) and
        (IndexOfInAdditionalFields(FDocVariableList.Items[i].Name) = -1) then
      begin
        if not bFirst then
          Add(',');
        Add(FDocVariableList.Items[i].Name);
        bFirst := False;
        // if i<FDocVariableList.Count-1 then
        // Add(',');
      end;
    end;
    Add(')');

    Add(' VALUES (');
    bFirst := true;
    for i := 0 to FDocVariableList.Count - 1 do
    begin
      if (FFieldNameList.IndexOf(FDocVariableList.Items[i].Name) > -1) and
        (IndexOfInAdditionalFields(FDocVariableList.Items[i].Name) = -1) then
      begin
        if not bFirst then
          Add(',');
        Add(':' + FDocVariableList.Items[i].Name);
        bFirst := False;
      end;
    end;
    Add(')');
    Add(GetReturningOnKeyFields);
  end;
end;

procedure TClientDocSQLManager.GenerateDinamicSQLLock;
begin
  with FLockSQL do
  begin
    Clear;
    Add(' SELECT * FROM ' + FTableName);
    Add(GetWhereOnKeyFields);
    Add(' WITH LOCK ');
  end;
end;

procedure TClientDocSQLManager.GenerateDinamicSQLUpdate;
var
  i: Integer;
  _UpdateList: TStringList;
  bFirst: Boolean;
begin

  _UpdateList := TStringList.Create;
  bFirst := true;
  try
    FDocVariableList.GetChangedList(_UpdateList);
    bChanged := False; // _UpdateList.Count > 0;
    with FUpdateSQL do
    begin
      Clear;
      Add(' UPDATE ' + FTableName);
      Add(' SET');
      for i := 0 to _UpdateList.Count - 1 do
      begin
        if (FFieldNameList.IndexOf(_UpdateList[i]) > -1) and
          (IndexOfInAdditionalFields(_UpdateList[i]) = -1) then
        begin
          if not bFirst then
            Add(',')
          else
          begin
            bFirst := False;
            bChanged := true;
          end;
          if FDocVariableList.VarByName(_UpdateList[i]).IsDelta then
            Add(_UpdateList[i] + ' = ' + _UpdateList[i] + '+:' + _UpdateList[i])
          else
            Add(_UpdateList[i] + ' = :' + _UpdateList[i]);
        end;
      end;
      Add(GetWhereOnKeyFields);
    end;
  finally
    FreeandNil(_UpdateList);
  end;
end;

function TClientDocSQLManager.GenerateSQLDelete(AParams: TVkVariableCollection): String;
begin
  GenerateDinamicSQLLock;
  Result := FDeleteSQL.Text;
end;

function TClientDocSQLManager.GenerateSQLInsert(AParams: TVkVariableCollection):String;
var bFirst: Boolean;
    i: Integer;
begin
  with FInsertSQL do
  begin
    Clear;
    Add(' INSERT INTO ' + FTableName);
    Add('(');
    bFirst := true;
    for i := 0 to AParams.Count - 1 do
    begin
      if (FFieldNameList.IndexOf(AParams.Items[i].Name) > -1) and
        (IndexOfInAdditionalFields(AParams.Items[i].Name) = -1) then
      begin
        if not bFirst then
          Add(',');
        Add(AParams.Items[i].Name);
        bFirst := False;
      end;
    end;
    Add(')');

    Add(' VALUES (');
    bFirst := true;
    for i := 0 to AParams.Count - 1 do
    begin
      if (FFieldNameList.IndexOf(AParams.Items[i].Name) > -1) and
        (IndexOfInAdditionalFields(AParams.Items[i].Name) = -1) then
      begin
        if not bFirst then
          Add(',');
        Add(':' + AParams.Items[i].Name);
        bFirst := False;
      end;
    end;
    Add(')');
  end;
  Result := FInsertSQL.Text;
end;

function TClientDocSQLManager.GenerateSQLUpdate(AParams: TVkVariableCollection): String;
var
  i: Integer;
  _UpdateList: TStringList;
  bFirst: Boolean;
begin
  _UpdateList := TStringList.Create;
  bFirst := true;
  try
    AParams.GetChangedList(_UpdateList);
//    bChanged := False; // _UpdateList.Count > 0;
    with FUpdateSQL do
    begin
      Clear;
      Add(' UPDATE ' + FTableName);
      Add(' SET');
      for i := 0 to _UpdateList.Count - 1 do
      begin
        if (FFieldNameList.IndexOf(_UpdateList[i]) > -1) and
          (IndexOfInAdditionalFields(_UpdateList[i]) = -1) then
        begin
          if not bFirst then
            Add(',')
          else
          begin
            bFirst := False;
            //bChanged := true;
          end;
          if FDocVariableList.VarByName(_UpdateList[i]).IsDelta then
            Add(_UpdateList[i] + ' = ' + _UpdateList[i] + '+:' + _UpdateList[i])
          else
            Add(_UpdateList[i] + ' = :' + _UpdateList[i]);
        end;
      end;
      Add(GetWhereOnKeyFields);
    end;
  finally
    FreeandNil(_UpdateList);
  end;
end;}

function TClientDocSQLManager.GetKeyFields: String;
begin
  FKeyFieldsList.Delimiter := ';';
  Result := FKeyFieldsList.Text;
end;

function TClientDocSQLManager.GetKeyFieldsList: TStringList;
begin
  // FKeyFieldsList.Clear;
  // FKeyFieldsList.Delimiter := ';';
  // FKeyFieldsList.DelimitedText := FKeyFields;
  Result := FKeyFieldsList;
end;

function TClientDocSQLManager.GetKeyValues
  (AVarList: TVkVariableCollection): Variant;
var
  i: Integer;
begin
  if AVarList.Count = 0 then
  begin
    Result := null;
    Exit;
  end;

  if KeyFieldsList.Count = 0 then
    Result := null
  else if KeyFieldsList.Count = 1 then
    Result := AVarList.VarByName(KeyFieldsList[0]).Value
  else
  begin
    Result := VarArrayCreate([0, KeyFieldsList.Count - 1], varvariant);
    for i := 0 to KeyFieldsList.Count - 1 do
      Result[i] := AVarList.VarByName(KeyFieldsList[i]).Value;
  end;

end;


{function TClientDocSQLManager.GetReturningOnKeyFields: String;
var
  i: Integer;
  sb: TStringBuilder;
begin
  sb := tStringBuilder.Create;
  try
    if KeyFieldsList.Count = 0 then
      sb.append('')
    else if KeyFieldsList.Count = 1 then
      sb.append(' RETURNING ').append( KeyFieldsList[0]).append(' INTO :').Append( KeyFieldsList[0])
    else
    begin
      Result := ' RETURNING ';
      for i := 0 to KeyFieldsList.Count - 1 do
      begin
        sb.append(KeyFieldsList[i]);
        if i < KeyFieldsList.Count - 1 then
          sb.append(', ');
      end;
      sb.append(' INTO ');
      for i := 0 to KeyFieldsList.Count - 1 do
      begin
        sb.append(':'+KeyFieldsList[i]);
        if i < KeyFieldsList.Count - 1 then
          sb.append(', ');
      end;
    end;
    Result := sb.toString();
  finally
    sb.free;
  end;
end;}

function TClientDocSQLManager.GetKeyValues(ADataSet: TDataSet): Variant;
var
  i: Integer;
begin
  if ADataSet.isEmpty then
  begin
    Result := null;
    Exit;
  end;
  if KeyFieldsList.Count = 0 then
    Result := null
  else if KeyFieldsList.Count = 1 then
    Result := ADataSet.FieldByName(KeyFieldsList[0]).Value
  else
  begin
    Result := VarArrayCreate([0, KeyFieldsList.Count - 1], varvariant);
    for i := 0 to KeyFieldsList.Count - 1 do
      Result[i] := ADataSet.FieldByName(KeyFieldsList[i]).Value;
  end;
end;

{function TClientDocSQLManager.GetWhereOnKeyFields: String;
var
  i: Integer;
  sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try
    if KeyFieldsList.Count = 0 then
      sb.Append('')
    else if KeyFieldsList.Count = 1 then
      sb.Append(' WHERE ').Append( KeyFieldsList[0]).Append(' = :').Append( KeyFieldsList[0])
    else
    begin
      sb.Append(' WHERE ');
      for i := 0 to KeyFieldsList.Count - 1 do
      begin
        sb.Append( KeyFieldsList[i]).Append(' = :').Append(KeyFieldsList[i]);
        if i < KeyFieldsList.Count - 1 then
          sb.Append(' AND ');
      end;
    end;
    Result := sb.toString();
  finally
    sb.free;
  end;
end;}

{function TClientDocSQLManager.IndexOfInAdditionalFields
  (const AName: String): Integer;
var
  _Item: TAdditionalSqlManager;
begin
  Result := -1;
  for _Item in AdditionalList do
  begin
    Result := _Item.FieldList.IndexOf(AName);
    if Result > -1 then
      Break;
  end;
  Result := -1;
end;}

procedure TClientDocSQLManager.InitCommonParams(const ATableName, AGenId: String);
begin
  if ATableName <> '' then
    FTableName := UpperCase(ATableName);

//  if AKeyFields <> '' then
//    FKeyFields := UpperCase(AKeyFields);

  if AGenId <> '' then
    FGenId := UpperCase(AGenId);

  //FillFieldNameList;
  { GenerateDinamicSQLInsert;
    GenerateDinamicSQLUpdate;
    GenerateDinamicSQLDelete;
    GenerateDinamicSQLLock; }
end;

procedure TClientDocSQLManager.SaveVariablesInDataSet(ADataSet: TDataSet;
  AVarList: TVkVariableCollection);
var
  i: Integer;
  _Field: TField;
  _ReadOnly: Boolean;
begin
  for i := 0 to AVarList.Count - 1 do
  begin
    _Field := ADataSet.FindField(AVarList.Items[i].Name);
    if Assigned(_Field) then
    begin
      _ReadOnly := _Field.ReadOnly;
      try
        if _ReadOnly then
          _Field.ReadOnly := False;
        if AVarList.Items[i].Value = unassigned then
          _Field.Value := null
        else
          _Field.Value := AVarList.Items[i].Value;
      finally
        _Field.ReadOnly := _ReadOnly;
      end;
    end;
  end;
end;

procedure TClientDocSQLManager.SetTableName(const Value: String);
begin
  FTableName := UpperCase(Value);
  //FillFieldNameList;
end;

procedure TClientDocSQLManager.UpdateVariablesOnDeltaDs(DataSet: TDataSet;
  AVarList: TVkVariableCollection);
var
  i: Integer;
  ind: Integer;
begin
  with DataSet do
  begin
    for i := 0 to FieldCount - 1 do
    begin
      if Fields[i].NewValue <> unassigned then
      begin
        ind := AVarList.IndexOf(Fields[i].FieldName);
        if ind > -1 then
          try
            AVarList.Items[ind].Value := Fields[i].Value;
          except
            ShowMessage('Name ' + Fields[i].FieldName + ', Index - ' +
              IntToStr(ind));
            Raise;
          end;
      end;
    end;
  end;
end;

{ TAdditionalSqlManager }

constructor TAdditionalSqlManager.Create;
begin
  FFieldList := TStringList.Create;
  FObjectList := TObjectList.Create;
  FObjectList.OwnsObjects := true;
end;

destructor TAdditionalSqlManager.Destroy;
begin
  FFieldList.Free;
  FObjectList.Free;
  inherited;
end;

end.
