unit dm_registerfingerprint;

interface

uses
  SysUtils, Classes,  DB,  IniFiles,  Forms,Dialogs,  windows, RtcDb, RtcInfo,  MemTableDataEh,
  MemTableEh;

type
  TPlace = (tpMikko,tpBelgorod);

  TDmRegisterFingerPrint = class(TDataModule)
    MemTableEhDc167: TMemTableEh;
    procedure ClientDataSetDc167AfterOpen(DataSet: TDataSet);
  private
    { Private declarations }
    procedure OpenDc167;
  public
    { Public declarations }
    procedure Registration;
    procedure UnRegistration;
    procedure Refresh167;
  end;



var
  DmRegisterFingerPrint: TDmRegisterFingerPrint;

implementation

{$R *.dfm}
uses datevk, fm_registerfingerprint, Dm_MikkoServer;

procedure TDmRegisterFingerPrint.ClientDataSetDc167AfterOpen(DataSet: TDataSet);
var i: Integer;
begin
  for i := 0 to DataSet.FieldCount - 1 do
    DataSet.Fields[i].Visible := False;

  with DataSet.FieldByName('name') do
  begin
    Index := 0;
    DisplayLabel := 'Сотрудник';
    Visible := true;
  end;

  with DataSet.FieldByName('isfinger') do
  begin
    Index := 1;
    DisplayLabel := 'Р';
    Visible := true;
  end;

end;



procedure TDmRegisterFingerPrint.OpenDc167;
var mResult: TRtcValue;
begin

  mResult := DmMikkoServer.Server.GetClientDataSetDc167;
  try
    RtcDataSetFieldsToDelphi(mResult.asDataSet, MemTableEhDc167);
    MemTableEhDc167.CreateDataSet;
    // Copy all data Rows from RTC DataSet to out in-memory Client DataSet
    RtcDataSetRowsToDelphi(mResult.asDataSet, MemTableEhDc167);
  finally
    FreeAndNil(mResult);
  end;


end;

procedure TDmRegisterFingerPrint.Refresh167;
var    bk: TBookMark;
begin
  with MemTableEhDc167 do
  begin
    DisableControls;
    if Active then
      bk := GetBookMark
    else
      bk := nil;
    try
      OpenDc167;
      //Open;
      if Assigned(bk)  then
        GoToBookMark(bk);
    finally
      EnableControls;
      FreeBookMark(bk);
    end;
  end;
//  FmRegisterFingerPrint.SetDbgColumns;
end;

procedure TDmRegisterFingerPrint.registration;
begin
  Refresh167;
end;




procedure TDmRegisterFingerPrint.UnRegistration;
begin
  Refresh167;

end;

end.
