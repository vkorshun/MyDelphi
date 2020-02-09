unit DmRtcUseMonth;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DmRtcCustom, rtcFunction, rtcSrvModule, rtcInfo, rtcConn, rtcDataSrv;

type
  TRtcUseMonthDm = class(TRtcCustomDm)
    RtcDataServerLinkUseMonth: TRtcDataServerLink;
    RtcServerModuleUseMonth: TRtcServerModule;
    RtcFunctionGroupUseMonth: TRtcFunctionGroup;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    function GetDefaultGroup: TRtcFunctionGroup;override;
  public
    { Public declarations }
    procedure RtcUsemonthEdit(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);

  end;

var
  RtcUseMonthDm: TRtcUseMonthDm;

implementation

{$R *.dfm}
uses DmMain, DmRtcCommonFunctions, DateVk;

{ TDmRtcUseMonth }

procedure TRtcUseMonthDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  RegisterRtcFunction('RtcUsemonthEdit',RtcUsemonthEdit);
end;

function TRtcUseMonthDm.GetDefaultGroup: TRtcFunctionGroup;
begin
  Result := RtcFunctionGroupUseMonth;
end;

procedure TRtcUseMonthDm.RtcUsemonthEdit(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
  mDmMain: TMainDm;
  i: Integer;
  nTrOption: Integer;
  mYm: String;
  nType: Integer;
  nClosed: Integer;
begin
  mUserName := Param.AsString['username'];
  mPassword := Param.AsString['password'];
  nType     := Param.asInteger['nType'];
  mDmMain := TRtcCommonFunctionsDm(Owner).GetDmMainUib(Sender,mUserName,mPassword);
  with mDmMain do
  begin
    // Стартовая дата
    case nType of
      0:
      begin
        mYm := Param.asString['ym'];
        //Execute('INSERT INTO usemonth(ym,closed) VALUES(:ym,:closed)',[mYm,0],UIBTransactionStability);
      end;
      1:
      begin
        //mYm := CoalEsce(QueryValue('SELECT max(ym) FROM usemonth',[]),'');
        mYm := GetNextYearMonth(mYm,1);
        //Execute('INSERT INTO usemonth(ym,closed) VALUES(:ym,:closed)',[mYm,0],UIBTransactionStability);
      end;
      2:
      begin
        mYm := Param.asString['ym'];
        nClosed := Param.asInteger['closed'];
        //Execute('UPDATE usemonth SET closed=:closed WHERE ym=:ym',[nClosed,mYm],UIBTransactionStability);
      end;
      3:
      begin
        //mYm := CoalEsce(QueryValue('SELECT min(ym) FROM usemonth',[]),'');
        //Execute('DELETE usemonth WHERE ym=:ym',[mYm],UIBTransactionStability);
      end;
    end;
  end;
end;

end.
