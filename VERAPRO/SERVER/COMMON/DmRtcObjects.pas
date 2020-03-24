unit DmRtcObjects;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, commoninterface, ServerDocSqlManager,
  Dialogs, rtcFunction, rtcSrvModule, rtcInfo, rtcConn, rtcDataSrv, uib, DmRtcCustom,FB30Statement, fbapidatabase, fbapiquery,
  VkVariable, QueryUtils, DmRtcCommonFunctions, DmMain, System.Contnrs;

const
  _VARATTR = 'f_';
  _VARATTR2 = 'fname_';
  FLD_IDATTRIBUTE = 'idattribute';
  FLD_NUMBERVIEW = 'numberview';
  FLD_NUMBEREDIT = 'numberedit';
  FLD_ATTRIBUTETYPE = 'attributetype';
  FLD_ATTRIBUTENAME = 'attribute_name';
  FLD_IDGROUP = 'idgroup';
  FLD_IDOBJECT = 'idobject';
  FLD_VAL = 'val';
  FLD_SET_NAME = 'set_name';
  TBL_ATTRIBUTESOFOBJECT = 'ATTRIBUTESOFOBJECT';


type
  TAttributeDescr = class(TObject)
  private
    FId: Int64;
    FName: String;
  public
    property Name:String read FName write FName;
    property Id:Int64 read FId write FId;
  end;


  TAttributesDocSqlManager = class(TServerDocSqlManager)
  private
    FFieldList: TStringList;
    FObjectList: TObjectList;
  public
    constructor Create;override;
    destructor Destroy;override;
    property FieldList: TStringList read FFieldList;
    property ObjectList:TObjectList read FObjectList;
  end;

  TRtcObjectsDm = class(TRtcCommonFunctionsDm)
    RtcDataServerLinkObjects: TRtcDataServerLink;
    RtcServerModuleObjects: TRtcServerModule;
    RtcFunctionGroupObjects: TRtcFunctionGroup;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    function GetDefaultGroup: TRtcFunctionGroup;override;
    function GetAttributesDocSqlManager(ADmMain: TMainDm): TAttributesDocSqlManager;
    procedure prepareAttributesOfGroup(ADmMain: TMainDm;sqlManager: TAttributesDocSqlManager; idgroup:LargeInt);
  public
    { Public declarations }
    procedure RtcGetRootKodg(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcEditGrPar(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcObjectEdit(Sender: TRtcConnection; FnParams: TRtcFunctionInfo; Result: TRtcValue);
  end;

var
  RtcObjectsDm: TRtcObjectsDm;

implementation

{$R *.dfm}

{ TDmRtcObjects }

procedure TRtcObjectsDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  TUtils.CloneComponent(RtcCommonFunctionsDm.RtcServerModuleCommon, self.RtcServerModuleObjects);
//  RtcServerModuleObjects.ModuleFileName := '/objects';
  RtcServerModuleObjects.FunctionGroup := RtcFunctionGroupObjects;
  RtcServerModuleObjects.Link := RtcDataServerLinkObjects;

  RegisterRtcFunction('RtcGetRootKodg',RtcGetRootKodg);
  RegisterRtcFunction('RtcEditGrPar',RtcEditGrPar);
//  RegisterRtcFunction('RtcObjectEdit',RtcObjectEdit);
end;

function TRtcObjectsDm.GetAttributesDocSqlManager(ADmMain: TMainDm): TAttributesDocSqlManager;
begin
  Result := TAttributesDocSqlManager.Create;
  ADmMain.GetSQLTableProperties(TBL_ATTRIBUTESOFOBJECT, Result.SQLTableProperties);
end;

function TRtcObjectsDm.GetDefaultGroup: TRtcFunctionGroup;
begin
  Result := RtcFunctionGroupObjects;
end;

procedure TRtcObjectsDm.prepareAttributesOfGroup(ADmMain: TMainDm;sqlManager: TAttributesDocSqlManager; idgroup:LargeInt);
var
  fbQuery: TFbApiQuery;
  id_attr: LargeInt;
  _adescr : TAttributeDescr;
  i: Integer;
begin
  fbQuery := ADmMain.GetNewQuery;
  try
    i:=1;
    sqlManager.FieldList.Clear;
    sqlManager.ObjectList.Clear;
    with fbQuery do
    begin
      SQL.Clear;
      SQL.Add('SELECT ag.*, gr.name as group_name, al.name as attribute_name, s.name as set_name,');
      SQL.Add('al.attributetype, al.nlen, al.ndec, al.isunique, al.notempty, ua.iduavalue');
      SQL.Add('FROM attributesofgroup ag');
      SQL.Add('LEFT OUTER JOIN objects gr ON gr.idobject=ag.idgroup');
      SQL.Add('LEFT OUTER JOIN attributelist al ON al.idattribute=ag.idattribute');
      SQL.Add('LEFT OUTER JOIN attributeset s ON s.idset=ag.idset');
      SQL.Add('LEFT JOIN usersaccess ua ON  ua.iduatype = :iduatype AND ua.iduser=:iduser AND ua.iditem = al.idattribute');
      SQL.Add('WHERE ag.idgroup=:idgroup AND ( pkg_common.IsUserAdmin(:iduser) or ua.iduavalue>0)');
      SQL.Add('ORDER BY numberedit, set_name');
      ParamByName('idgroup').AsInt64 := idgroup;
      ParamByName('iduser').AsInt64 := ADmMain.CurrentUser.id_user;
      ParamByName('iduatype').AsInt64 := ADmMain.CurrentUser.idgroup;
      ExecQuery;
      while not Eof do
      begin
        id_attr := FieldByName('idattribute').AsInt64;
        _adescr := TAttributeDescr.Create;
        _adescr.Id := id_attr;
        _adescr.Name := _VARATTR+IntToStr(i);
        SqlManager.ObjectList.Add(_adescr);
        SqlManager.FieldList.AddObject(_VARATTR+IntToStr(i),_adescr);
        Next;
        Inc(i);
      end;
    end;
  finally
    FreeAndNil(fbQuery);
  end;
end;

procedure TRtcObjectsDm.RtcEditGrPar(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
  mDmMain: TMainDm;
  nKodobj: Integer;
begin
  mDmMain := TRtcCommonFunctionsDm(Owner).GetDmMainUib(Sender,mUserName,mPassword);
  {with mDmMain.UIBQueryUpdate do
  begin
    Close;
    Transaction := mDmMain.UIBTransactionSS;
    SQL.Clear;
    SQL.Add(' UPDATE OR INSERT INTO gr_par ');
    SQL.Add('(kodg, kodpar, typpar, number, numberview, hidden)');
    SQL.Add('VALUES');
    SQL.Add('(:kodg, :kodpar, :typpar, :number, :numberview, :hidden)');
    Params.ByNameAsInteger['kodg']  := Param.asInteger['kodg'];
    Params.ByNameAsInteger['kodpar'] := Param.asInteger['kodpar'];
    if Trim(Param.asString['typpar'])='' then
      Params.ByNameAsString['typpar'] := '1'
    else
      Params.ByNameAsString['typpar'] := Trim(Param.asString['typpar']);
    if Trim(Param.asString['number'])='' then
      Params.ByNameAsString['number'] := '0'
    else
      Params.ByNameAsString['number'] := Trim(Param.asString['number']);
    Params.ByNameAsInteger['numberview'] := Param.asInteger['numberview'];
    Params.ByNameAsInteger['hidden'] := Param.asInteger['hidden'];
    Transaction.StartTransaction;
    try
      Execute;
      Close(etmCommit);
    except
      Close(etmRollback);
      Raise;
    end;
  end;}
//    UIBQueryEx.SQL.Add('MATCHING (kodg, kodpar)');
    Result.asInteger := 0;

end;

procedure TRtcObjectsDm.RtcGetRootKodg(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
  mDmMain: TMainDm;
  nKodobj: Integer;
begin
  mUserName := Param.AsString['username'];
  mPassword := Param.AsString['password'];
  nKodobj     := Param.asInteger['kodobj'];
  mDmMain := TRtcCommonFunctionsDm(Owner).GetDmMainUib(Sender,mUserName,mPassword);
{  with mDmMain do
  begin
    UIBQuerySelect.SQL.Clear;
    UIBQuerySelect.SQL.Add(' SELECT * FROM objects WHERE kodobj=:kodobj');
    UIBQuerySelect.Params.ByNameAsInteger['kodobj'] := nKodobj;
    UIBQuerySelect.Open(True);
    while UIBQuerySelect.Fields.ByNameAsInteger['kodg']<>0 do
    begin
      nKodobj := UIBQuerySelect.Fields.ByNameAsInteger['kodg'];
      UIBQuerySelect.Close();
      UIBQuerySelect.Params.ByNameAsInteger['kodobj'] := nKodobj;
      UIBQuerySelect.Open(True);
    end;
    UIBQuerySelect.Close(etmCommit);
  end;}
  Result.asInteger := nKodobj;
end;

procedure TRtcObjectsDm.RtcObjectEdit(Sender: TRtcConnection; FnParams: TRtcFunctionInfo; Result: TRtcValue);
var fbQuery: TFbApiQuery;
    fbQueryLock: TFbApiQuery;
    tr: TFbApiTransaction;
    objectsSqlManager: TServerDocSqlManager;
    attributesSqlManager: TAttributesDocSqlManager;
    tablename: String;
    new_params: TVkVariableCollection;
    old_params: TVkVariableCollection;
    key_params: TVkVariableCollection;
    operation: TDocOperation;
    i:Integer;
    AMainDm: TMainDm;
    mUserName: String;
    mPassword: String;
    idgroup: LargeInt;
    idobject: LargeInt;
    isEmpty: Boolean;

    procedure LockDoc(sqlManager: TServerDocSqlManager);
    begin
      if operation <> docInsert then
      begin
        fbQueryLock := AMainDm.GetNewQuery(tr);
        fbQueryLock.SQL.Text := sqlManager.GenerateLockSQL;
        TQueryUtils.SetQueryParams(fbQueryLock, key_params);
        fbQueryLock.ExecQuery;
      end;
    end;

    procedure UnLockDoc;
    begin
      if (operation <> docInsert) and Assigned(fbQueryLock)  then
      begin
        fbQueryLock.Close;
        fbQueryLock.Free;
      end;
    end;

    {*procedure docAction(sqlManager: TServerDocSqlManager; new_params );
    begin

    end;*}
    procedure UpdateAttributes(idobject: LargeInt);
    var qr: TFbApiQuery;
        i: Integer;
        idattr: LargeInt;
        val: String;
    begin

      idgroup := new_params.VarByName('IDGROUP').AsLargeInt;
      prepareAttributesOfGroup(AMainDm, attributesSqlManager, idgroup);
      qr := AMainDm.GetNewQuery(tr);
      try
        qr.SQL.Text := 'UPDATE OR INSERT INTO '+TBL_ATTRIBUTESOFOBJECT+
        ' (IDOBJECT, IDATTRIBUTE, VAL) '+
        ' VALUES  (:IDOBJECT, :IDATTRIBUTE, :VAL)'+
        'MATCHING (IDOBJECT,IDATTRIBUTE)';
        qr.ParamByName('IDOBJECT').AsInt64 := idobject;
        for I := 0 to new_params.count-1 do
        begin
          if attributesSqlManager.FieldList.IndexOf(new_params.Items[i].Name)>-1 then
          begin
            idattr := TAttributeDescr(attributesSqlManager.FieldList.Objects[i]).Id;
            val := new_params.Items[i].AsString;
            qr.ExecQuery;
          end;
        end;
      finally
        qr.Free;
      end;

    end;

begin
  mUserName := FnParams.AsString['username'];
  mPassword := FnParams.AsString['password'];
//  tableName := FnParams.AsString['TABLENAME'];
  AMainDm := GetDmMainUib(Sender, mUserName, mPassword);

  tr := AMainDm.GetNewTransaction(AMainDm.StabilityTransactionOptions);
  fbQuery := AMainDm.GetNewQuery(tr);
  tablename:= FnParams.asString['TABLENAME'];
  operation := TUtils.getDocOperation(FnParams.asString['COMMAND']);
  objectsSqlManager := AMainDm.GetServerDocSqlManager('OBJECTS');
  attributesSqlManager := GetAttributesDocSqlManager(AMainDm);
  new_params := TVkVariableCollection.Create(self);
  old_params := TVkVariableCollection.Create(self);
  key_params := TVkVariableCollection.Create(self);
  try
    try
      if (operation = docUpdate) then
      begin
        TUtils.RtcToVkVariableColections(FnParams.asRecord['PARAMS'].asRecord['NEW'], new_params);
        TUtils.RtcToVkVariableColections(FnParams.asRecord['PARAMS'].asRecord['OLD'], old_params);
        TUtils.RtcToVkVariableColections(FnParams.asRecord['PARAMS'].asRecord['KEY'], key_params);
      end else
      if (operation = docDelete) then
      begin
        //TUtils.RtcToVkVariableColections(FnParams.asRecord['PARAMS'].asRecord['OLD'], old_params);
        TUtils.RtcToVkVariableColections(FnParams.asRecord['PARAMS'].asRecord['KEY'], key_params);
      end
      else
        TUtils.RtcToVkVariableColections(FnParams.asRecord['PARAMS'].asRecord['NEW'], new_params);

      idobject := new_params.VarByName('IDOBJECT').AsLargeInt;
      isEmpty := true;
      fbQuery.SQL.Text := objectsSqlManager.GenerateSQL(operation, new_params, @isEmpty);
      if not isEmpty then
      begin
        LockDoc(objectsSqlManager);
        TQueryUtils.SetQueryParams(fbQuery, new_params);
        TQueryUtils.SetQueryParams(fbQuery, key_params);
        fbQuery.ExecQuery;
        if Assigned(fbQuery.Current) then
        begin
          result.NewRecord.NewRecord('RESULT');
          for i := 0 to fbQuery.Current.Count-1 do
          begin
            Result.asRecord.asRecord['RESULT'].asValue[fbQuery.Current.Data[i].Name] := fbQuery.Current.Data[i].AsVariant;
          end;
        end;
        if (operation = docInsert) then
        begin
          AMainDm.WriteEventLog(objectsSqlManager, tr, operation, FnParams.asRecord['PARAMS'].asRecord['NEW'],
            FnParams.asRecord['PARAMS'].asRecord['OLD'],
             Result.asRecord.asRecord['RESULT']);
        end
        else
        begin
          AMainDm.WriteEventLog(objectsSqlManager, tr, operation, FnParams.asRecord['PARAMS'].asRecord['NEW'],
            FnParams.asRecord['PARAMS'].asRecord['OLD'],
            FnParams.asRecord['PARAMS'].asRecord['KEY']);
        end;

      end;
      updateAttributes(idobject);
      tr.Commit;

      UnLockDoc;
    except
      on ex:Exception do
      begin
        if tr.Active then
          tr.Rollback;
        AMainDm.registerError(fbQuery.SQL.Text, ex.Message);
        raise;
      end;
    end;
  finally
    FreeAndNil(objectsSqlManager);
    FreeAndNil(attributesSqlManager);
    FreeAndNil(fbQuery);
    FreeAndNil(tr);
    FreeAndNil(new_params);
    FreeAndNil(old_params);
  end;

end;

{ TAttributesDocSqlManager }

constructor TAttributesDocSqlManager.Create;
begin
  inherited;
  FFieldList:= TStringList.Create;
  FObjectList:= TObjectList.Create;

end;

destructor TAttributesDocSqlManager.Destroy;
begin
  inherited;
  FreeAndNil(FFieldList);
  FreeAndNil(FObjectList);
end;

end.
