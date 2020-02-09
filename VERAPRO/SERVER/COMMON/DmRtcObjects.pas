unit DmRtcObjects;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, commoninterface,
  Dialogs, rtcFunction, rtcSrvModule, rtcInfo, rtcConn, rtcDataSrv, uib, DmRtcCustom;

type
  TRtcObjectsDm = class(TRtcCustomDm)
    RtcDataServerLinkObjects: TRtcDataServerLink;
    RtcServerModuleObjects: TRtcServerModule;
    RtcFunctionGroupObjects: TRtcFunctionGroup;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    function GetDefaultGroup: TRtcFunctionGroup;override;
  public
    { Public declarations }
    procedure RtcGetRootKodg(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcEditGrPar(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);

  end;

var
  RtcObjectsDm: TRtcObjectsDm;

implementation

{$R *.dfm}
uses DmMain, DmRtcCommonFunctions;

{ TDmRtcObjects }

procedure TRtcObjectsDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  TUtils.CloneComponent(RtcCommonFunctionsDm.RtcServerModuleCommon, self.RtcServerModuleObjects);
  RtcServerModuleObjects.ModuleFileName := '/objects';
  RtcServerModuleObjects.FunctionGroup := RtcFunctionGroupObjects;
  RtcServerModuleObjects.Link := RtcDataServerLinkObjects;

  RegisterRtcFunction('RtcGetRootKodg',RtcGetRootKodg);
  RegisterRtcFunction('RtcEditGrPar',RtcEditGrPar);
end;

function TRtcObjectsDm.GetDefaultGroup: TRtcFunctionGroup;
begin
  Result := RtcFunctionGroupObjects;
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

end.
