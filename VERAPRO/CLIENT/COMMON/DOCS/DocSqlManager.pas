unit DocSqlManager;

interface

uses
  SysUtils, Classes, rtcFunction, rtcDataCli, rtcCliModule, rtcInfo, rtcConn, rtcHttpCli, rtcLog,
  rtcDB, DB, MemTableDataEh,MemTableEh, variants, DataDriverEh,
  vkvariable, Dialogs, uLog, System.Generics.Collections, System.Contnrs;

type
//  TOnFillFieldNameList = procedure(Sender:TObject);
  TAdditionalSqlManager = class
  private
    FTableName: String;
    FFieldList: TStringList;
    FObjectList: TObjectList;
  public
    constructor Create;
    destructor Destroy;override;
    property TableName: String read FTableName write FTableName;
    property FieldList: TStringList read FFieldList;
    property ObjectList:TObjectList read FObjectList;
  end;

  TDocSqlManager = class(TObject)
  private
    FTableName: String;
    FKeyFields: String;
    FKeyFieldsList: TStringList;
    FGenId: String;
    FSelectSQL: TStringList;
    FUpdateSQL: TStringList;
    FInsertSQL: TStringList;
    FDeleteSQL: TStringList;
    FLockSQL: tStringList;
    FDocVariableList: TVkVariableCollection;
    FFieldNameList: TStringList;
    FOnFillFieldNameList: TNotifyEvent;
    FAdditionalList: TList<TAdditionalSqlManager>;
    procedure SetTableName(const Value: String);
    function GetKeyFieldsList: TStringList;
  protected
    procedure FillFieldNameList; virtual;
  public
    constructor Create;
    destructor Destroy;override;
    procedure CalcVariablesOnDs(DataSet: TDataSet; AVarList: TVkVariableCollection);
    function GetKeyValues(ADataSet: TDataSet): Variant;overload;
    function GetKeyValues(AVarList: TVkVariableCollection): Variant;overload;
//    procedure GenerateDinamicSQLInsert;
//    procedure GenerateDinamicSQLUpdate(var bChanged: Boolean);
//    procedure GenerateDinamicSQLDelete;
//    procedure GenerateDinamicSQLLock;
    function GetWhereOnKeyFields:String;
    procedure InitCommonParams(const ATableName:String ='';const AKeyFields:String =''; const AGenId : String = '');
    procedure SaveVariablesInDataSet(ADataSet: TDataSet; AVarList: TVkVariableCollection);
    procedure UpdateVariablesOnDeltaDs(DataSet: TDataSet;
      AVarList: TVkVariableCollection);
    function IndexOfInAdditionalFields(const AName:String):Integer;

    property AdditionalList: TList<TAdditionalSqlManager> read FAdditionalList;
    property DocVariableList: TVkVariableCollection read FDocVariableList;
    property TableName: String read FTableName write SetTableName;
    property GenId: String read FGenId write FGenId;
    property SelectSQL: TStringList read FSelectSQL;
    property UpdateSQL: TStringList read FUpdateSQL;
    property InsertSQL: TStringList read FInsertSQL;
    property DeleteSQL: TStringList read FDeleteSQL;
    property LockSQL: TStringList read FLockSQL;
    property KeyFields:String read FKeyFields;
    property KeyFieldsList: TStringList read GetKeyFieldsList;
    property OnFillFieldNameList: TNotifyEvent read  FOnFillFieldNameList write FOnFillFieldNameList;
    property FieldNameList: TStringList read FFieldNameList;

  end;

implementation

{ TDocSqlManager }

procedure TDocSqlManager.CalcVariablesOnDs(DataSet: TDataSet; AVarList: TVkVariableCollection);
var i: Integer;
    ind: Integer;
begin
  with DataSet do
  begin
    for I := 0 to FieldCount - 1 do
    begin
      ind := AVarList.IndexOf(Fields[i].FieldName) ;
      if ind >-1 then
      begin
        case Fields[i].DataType of
          ftFMTBcd:    AVarList[Fields[i].FieldName].InitValue := Fields[i].AsFloat;
          ftBcd:       AVarList[Fields[i].FieldName].InitValue := Fields[i].AsLargeInt;
          ftBlob: AVarList[Fields[i].FieldName].InitValue := Fields[i].AsString;
        else
          try
            AVarList.Items[ind].InitValue := Fields[i].Value;
            TLogWriter.Log(Fields[i].FieldName+' = '+ Fields[i].AsString);
          except
            TLogWriter.Log(Fields[i].FieldName+' = '+ Fields[i].AsString);
            ShowMessage((' error in InitVariable i = '+IntToStr(i)));
            Raise;
          end;
        end;
      end;
    end;
  end;
end;

constructor TDocSqlManager.Create;
begin
  FSelectSQL := TStringList.Create;
  FUpdateSQL := TStringList.Create;
  FInsertSQL := TStringList.Create;
  FDeleteSQL := TStringList.Create;
  FLockSQL := TStringList.Create;
  FFieldnameList := TStringList.Create;
  FDocVariableList:= TVkVariableCollection.Create(nil);
  FKeyFieldsList := TStringList.Create;
  FAdditionalList := TList<TAdditionalSqlManager>.Create;
end;

destructor TDocSqlManager.Destroy;
begin
  FSelectSQL.Free;
  FUpdateSQL.Free;
  FInsertSQL.Free;
  FDeleteSQL.Free;
  FLockSQL.Free;
  FDocVariableList.Free;
  FKeyFieldsList.Free;
  FFieldnameList.Free;
  FAdditionalList.Free;
  inherited;
end;

procedure TDocSqlManager.FillFieldNameList;
begin
  if Assigned(FOnFillFieldNameList) then
    FOnFillFieldNameList(Self)
  else
    raise Exception.Create('Error - OnFillFieldNameList -  is not defined');
end;

{ procedure TDocSqlManager.GenerateDinamicSQlDelete;
begin
  FDeleteSQL.Clear;
  FDeleteSQL.Add(' DELETE FROM '+FTableName);
  FDeleteSQL.Add(GetWhereOnKeyFields);
end;

procedure TDocSqlManager.GenerateDinamicSQLInsert;
var i: Integer;
    bFirst: Boolean;
begin
  with FInsertSQL do
  begin
    Clear;
    Add(' INSERT INTO '+FTableName);
    Add('(');
    bFirst := true;
    for I := 0 to FDocVariableList.Count-1 do
    begin
      if (FFieldNameList.IndexOf(FDocVariableList.Items[i].Name)>-1)
        and (IndexOfInAdditionalFields(FDocVariableList.Items[i].Name)=-1) then
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
    bFirst := True;
    for I := 0 to FDocVariableList.Count-1 do
    begin
      if (FFieldNameList.IndexOf(FDocVariableList.Items[i].Name)>-1)
        and (IndexOfInAdditionalFields(FDocVariableList.Items[i].Name)=-1) then
      begin
        if not bFirst then
          Add(',');
        Add(':'+FDocVariableList.Items[i].name);
        bFirst := False;
      end;
    end;
    Add(')');
  end;
end;

procedure TDocSqlManager.GenerateDinamicSQLLock;
begin
  with FLockSQL do
  begin
    Clear;
    Add(' SELECT * FROM '+FTablename);
    Add(GetWhereOnKeyFields);
    Add(' WITH LOCK ');
  end;
end;

procedure TDocSqlManager.GenerateDinamicSQlUpdate;
var i: Integer;
    _UpdateList: TStringList;
    bFirst: Boolean;
begin

  _UpdateList := TStringList.Create;
  bFirst := True;
  try
    FDocVariableList.GetChangedList(_UpdateList);
    bChanged := False; //_UpdateList.Count > 0;
    with FUpdateSQL do
    begin
      Clear;
      Add(' UPDATE '+FTableName);
      Add(' SET');
      for I := 0 to _UpdateList.Count-1 do
      begin
        if (FFieldNameList.IndexOf(_UpdateList[i])>-1) and
          (IndexOfInAdditionalFields(_UpdateList[i])=-1)
        then
        begin
          if not bFirst then
            Add(',')
          else
          begin
            bFirst := False;
            bChanged := True;
          end;
          if FDocVariableList.VarByName(_UpdateList[i]).IsDelta then
            Add(_UpdateList[i]+' = '+_UpdateList[i]+'+:'+_UpdateList[i])
          else
            Add(_UpdateList[i]+' = :'+_UpdateList[i]);
        end;
      end;
      Add(GetWhereOnKeyFields);
    end;
  finally
    FreeandNil(_UpdateList);
  end;
end; *}

function TDocSqlManager.GetKeyFieldsList: TStringList;
begin
  FKeyFieldsList.Clear;
  FKeyFieldsList.Delimiter := ';';
  FKeyFieldsList.DelimitedText := FKeyFields;
  Result := FKeyFieldsList;
end;

function TDocSqlManager.GetKeyValues(AVarList: TVkVariableCollection): Variant;
var
  sList: TStringList;
  i: Integer;
begin
  if AVarList.Count=0 then
  begin
    Result := null;
    Exit;
  end;
  sList := TStringList.Create;
  try
    sList.Delimiter := ';';
    sList.DelimitedText := FKeyFields;
    if sList.Count = 0 then
      Result := null
    else if sList.Count = 1 then
      Result := AVarList.VarByName(sList[0]).Value
    else
    begin
      Result := VarArrayCreate([0, sList.Count-1], varvariant);
      for i := 0 to sList.Count-1 do
        Result[i] := AVarList.VarByName(sList[i ]).Value;
    end;
  finally
    sList.Free;
  end;

end;

function TDocSqlManager.GetKeyValues(ADataSet: TDataSet): Variant;
var
  sList: TStringList;
  i: Integer;
begin
  if ADataSet.isEmpty then
  begin
    Result := null;
    Exit;
  end;
  sList := TStringList.Create;
  try
    sList.Delimiter := ';';
    sList.DelimitedText := FKeyFields;
    if sList.Count = 0 then
      Result := null
    else if sList.Count = 1 then
      Result := ADataSet.FieldByName(sList[0]).Value
    else
    begin
      Result := VarArrayCreate([0, sList.Count-1], varvariant);
      for i := 0 to sList.Count-1 do
        Result[i] := ADataSet.FieldByName(sList[i ]).Value;
    end;
  finally
    sList.Free;
  end;
end;

function TDocSqlManager.GetWhereOnKeyFields: String;
var
  _List: TStringList;
  i: Integer;
begin
  _List := TStringList.Create;
  try
    _List.Delimiter := ';';
    _List.DelimitedText := FKeyFields;
    if _List.Count = 0 then
      Result := ''
    else if _List.Count = 1 then
      Result := ' WHERE '+_List[0]+' = :' +_List[0]
    else
    begin
      Result := ' WHERE ';
      for i := 0 to _List.Count-1 do
      begin
        Result := Result + _List[i]+' = :'+ _List[i];
        if i< _List.Count-1 then
          Result := Result + ' AND ';
      end;
    end;
  finally
    _List.Free;
  end;
end;

function TDocSqlManager.IndexOfInAdditionalFields(const AName: String): Integer;
var
    _Item: TAdditionalSqlManager;
begin
  Result := -1;
  for _Item in AdditionalList do
  begin
    Result := _Item.FieldList.IndexOf(AName);
    if Result> -1 then
      Break;
  end;
end;

procedure TDocSqlManager.InitCommonParams(const ATableName, AKeyFields, AGenId: String);
begin
  if ATableName<>'' then
    FTableName := UpperCase(ATableName);

  if AKeyFields<>'' then
    FKeyFields := UpperCase(AKeyFields);

  if AGenId<>'' then
    FGenId := UpperCase(AGenId);

  FillFieldNameList;
{  GenerateDinamicSQLInsert;
  GenerateDinamicSQLUpdate;
  GenerateDinamicSQLDelete;
  GenerateDinamicSQLLock; }
end;


procedure TDocSqlManager.SaveVariablesInDataSet(ADataSet: TDataSet; AVarList: TVkVariableCollection);
var i: Integer;
    _Field: TField;
    _ReadOnly: Boolean;
begin
  for I := 0 to AVarList.Count-1 do
  begin
    _Field := ADataSet.FindField(AVarList.Items[i].Name);
    if Assigned(_Field) then
    begin
      _ReadOnly := _Field.ReadOnly;
      try
        if _ReadOnly then
          _Field.ReadOnly := False;
        if AVarList.Items[i].Value = unassigned then
          _Field.Value  := null
        else
          _Field.Value := AVarList.Items[i].Value;
      finally
        _Field.ReadOnly := _ReadOnly;
      end;
    end;
  end;
end;

procedure TDocSqlManager.SetTableName(const Value: String);
begin
  FTableName := UpperCase(Value);
  FillFieldNameList;
end;

procedure TDocSqlManager.UpdateVariablesOnDeltaDs(DataSet: TDataSet; AVarList: TVkVariableCollection);
var i: Integer;
    ind: Integer;
begin
  with DataSet do
  begin
    for I := 0 to FieldCount - 1 do
    begin
      if Fields[i].NewValue<> Unassigned then
      begin
        ind := AVarList.IndexOf(Fields[i].FieldName) ;
        if ind>-1 then
        try
          AVarList.Items[ind].Value := Fields[i].Value;
        except
          ShowMessage('Name '+Fields[i].FieldName+', Index - '+IntToStr(ind));
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
