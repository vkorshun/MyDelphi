unit DmSrvDoc;

interface

uses
  System.SysUtils, System.Classes, rtcFunction, rtcInfo,ServerDocSqlmanager,FB30Statement, fbapidatabase, fbapiquery,
  commoninterface, vkvariable, QueryUtils, DmMain;

type
  TSrvDocDm = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FEventLogSqlManager: TServerDocSqlManager;
//    FMainDm: TMainDm;
//    procedure SetMainDm(const Value: TMainDm);
  public
    { Public declarations }
    procedure WriteEventLog(AMainDm:TMainDm;sqlManager: TServerDocSqlManager; ATr: TFbApiTransaction; operation: TDocOperation;
       new, old:TVkVariableCollection);
    procedure RtcDocEdit(AMainDm:TMainDm;FnParams: TRtcFunctionInfo; Result: TRtcValue);
  //  property MainDm: TMainDm  read FMainDm write SetMainDm;
  end;

var
  SrvDocDm: TSrvDocDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TSrvDocDm.DataModuleCreate(Sender: TObject);
begin
  //FEventLogSqlManager := MainDm.ServerDocSqlManager['EVENTLOG'];
end;

procedure TSrvDocDm.RtcDocEdit(AMainDm:TMainDm;FnParams: TRtcFunctionInfo; Result: TRtcValue);
var fbQuery: TFbApiQuery;
    fbQueryLock: TFbApiQuery;
    tr: TFbApiTransaction;
    sqlmanager: TServerDocSqlManager;
    tablename: String;
    new_params: TVkVariableCollection;
    old_params: TVkVariableCollection;
    operation: TDocOperation;
    i:Integer;

    procedure LockDoc;
    begin
      if operation <> docInsert then
      begin
        fbQueryLock := AMainDm.GetNewQuery(tr);
        fbQueryLock.SQL.Text := sqlManager.GenerateLockSQL;
        TQueryUtils.SetQueryParams(fbQueryLock, new_params);
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
begin
  tr := AMainDm.GetNewTransaction(AMainDm.StabilityTransactionOptions);
  fbQuery := AMainDm.GetNewQuery(tr);
  tablename:= FnParams.asString['TABLENAME'];
  operation := TUtils.getDocOperation(FnParams.asString['COMMAND']);
  sqlmanager := AMainDm.GetServerDocSqlManager(tablename);
  new_params := TVkVariableCollection.Create(self);
  old_params := TVkVariableCollection.Create(self);
  try
    try
      if (operation = docUpdate) then
      begin
        TUtils.RtcToVkVariableColections(FnParams.asRecord['PARAMS'].asRecord['NEW'], new_params);
        TUtils.RtcToVkVariableColections(FnParams.asRecord['PARAMS'].asRecord['OLD'], old_params);
      end
      else
        TUtils.RtcToVkVariableColections(FnParams.asRecord['PARAMS'], new_params);

      fbQuery.SQL.Text := sqlManager.GenerateSQL(operation, new_params);
{      case (operation) of
        docInsert: fbQuery.SQL.Text := sqlmanager.GenerateSQLInsert(new_params);
        docUpdate: fbQuery.SQL.Text := sqlmanager.GenerateSQLUpdate(new_params);
        docDelete: fbQuery.SQL.Text := sqlmanager.GenerateSQLDelete(new_params);
      end;}
      LockDoc;
      TQueryUtils.SetQueryParams(fbQuery, new_params);
      fbQuery.ExecQuery;
      if Assigned(fbQuery.Current) then
      begin
        result.NewRecord.NewRecord('RESULT');
        for i := 0 to fbQuery.Current.Count-1 do
        begin
          Result.asRecord.asRecord['RESULT'].asValue[fbQuery.Current.Data[i].Name] := fbQuery.Current.Data[i].AsVariant;
        end;
      end;
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
    FreeAndNil(sqlManager);
    FreeAndNil(fbQuery);
    FreeAndNil(tr);
    FreeAndNil(new_params);
    FreeAndNil(old_params);
  end;

end;

{procedure TSrvDocDm.SetMainDm(const Value: TMainDm);
begin
  FMainDm := Value;
end;}

procedure TSrvDocDm.WriteEventLog(AMainDm:TMainDm;sqlManager: TServerDocSqlManager;  ATr: TFbApiTransaction; operation: TDocOperation;
       new, old:TVkVariableCollection);
var fbQuery: TFbApiQuery;
    insVars: TVkVariableCollection;
begin
//  FEventLogSqlManager.GenerateDinamicSQLInsert
  fbQuery := AMainDm.GetNewQuery(ATr);
  insVars:= TVkVariableCollection.Create(nil);
  try

    insVars.CreateVkVariable('tablename', sqlManager.SQLTableProperties.TableName);
    insvars.CreateVkVariable('tablekey', TQueryUtils.getTableKeyAsJSON(sqlManager, new));

    fbQuery.SQL.Add(FEventLogSqlManager.GenerateSQL(docInsert, insVars));
    TQueryUtils.SetQueryParams(fbQuery, insVars);
    fbQuery.ExecQuery;
  finally
    insVars.Free;
    fbQuery.Free;
  end;
//  fbQuery.ParamByName('idtransaction').AsInt64  := tr.;

  //SET PARAMS
end;

end.
