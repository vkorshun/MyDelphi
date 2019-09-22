unit fm_appone;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, rtcInfo, rtcConn, rtcDataSrv, rtcHttpSrv, Generics.Collections, rtcLog, StdCtrls,
  dm_mikkoads,SuperObject, hostdate;

type

  TFmAppOne = class(TForm)
    HttpServerMikko: TRtcHttpServer;
    RtcDataProvider1: TRtcDataProvider;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure HttpServerMikkoClientDisconnect(Sender: TRtcConnection);
    procedure HttpServerMikkoListenLost(Sender: TRtcConnection);
    procedure HttpServerMikkoRequestAccepted(Sender: TRtcConnection);
    procedure HttpServerMikkoListenStart(Sender: TRtcConnection);
    procedure HttpServerMikkoRequestNotAccepted(Sender: TRtcConnection);
    procedure RtcDataProvider1DataReceived(Sender: TRtcConnection);
    procedure RtcDataProvider1CheckRequest(Sender: TRtcConnection);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    dm: TDataModule;
  public
    { Public declarations }
  end;

var
  FmAppOne: TFmAppOne;

implementation

{$R *.dfm}
uses IniFiles, Dm_EntranceMethodsMikko, dm_personalentrance;

procedure TFmAppOne.Button1Click(Sender: TObject);
var dm: TDmMikkoAds;
   obj: ISuperObject;
   _item: ISuperObject;
   d: tDateTime;
   i: Integer;
begin
//  dm := TDmMikkoAds.Create(self);
//  dm.SpCrypt('vk123','vkorshun2','');
// obj := SO('{}');
// obj.O['test'] := SA([]);
// _item := SO('{}');
// _item.I['id'] := 1;
// _item.S['name'] := 'asdfg\';
// obj.A['test'].Add(_item);
// ShowMessage(obj.AsJSon());
  for i:=0 to 24 do
  begin
    d :=  DtToSysDt(Now+i/24);
    ShowMessage(DateTimeToStr(d)+ '  ' +DateTimeToStr(SysDtToLocalTimeZone(d)));
  end;
end;

procedure TFmAppOne.FormCreate(Sender: TObject);
var FIni: TIniFile;
//   dm: TDmEntranceMethodsMikko;
begin

//  FList := TList<PConnectListItem>.Create;

  FIni := TIniFile.Create(ChangeFileExt(AppFilename,'.ini')  );
  dm := TDmEntranceMethodsMikko.Create(self);
  TDmEntranceMethodsMikko(dm).RtcDataServerLink1.Server := HTTPServerMikko;

  //txtMonitor(FIni.ReadString('SET','PORT',''));
  with HTTPServerMikko do
  begin
    ServerPort := AnsiString(FIni.ReadString('SET','PORT',''));
    FIni.Free;
  end;
  HTTPServerMikko.Listen();

end;

procedure TFmAppOne.HttpServerMikkoClientDisconnect(Sender: TRtcConnection);
begin
  TDmEntranceMethodsMikko(Dm).DeleteDmEntrance(Sender);
end;

procedure TFmAppOne.HttpServerMikkoListenLost(Sender: TRtcConnection);
begin
  TDmEntranceMethodsMikko(Dm).DeleteDmEntrance(Sender);
end;

procedure TFmAppOne.HttpServerMikkoListenStart(Sender: TRtcConnection);
begin
  RTC_LOGS_LIVE_DAYS := 7;
  StartLog;
end;

procedure TFmAppOne.HttpServerMikkoRequestAccepted(Sender: TRtcConnection);
begin
  with TRtcDataServer(Sender) do
  begin
    XLog(Request.Method+' , params count ='+IntToStr(Request.Params.ItemCount)+' '+Request.Params.Text);
  end;
end;

procedure TFmAppOne.HttpServerMikkoRequestNotAccepted(Sender: TRtcConnection);
begin

  with TRtcDataServer(Sender) do
  begin
    Request.Params.AddText(TRtcDataServer(Sender).Read);
    XLog(   Request.Method+' , params count ='+IntToStr(Request.Params.ItemCount)+' '+Request.Params.Text);
  end;

end;

procedure TFmAppOne.RtcDataProvider1CheckRequest(Sender: TRtcConnection);
begin
  with TRtcDataServer(Sender) do
  begin
    Xlog('QUERY - '+Request.Query.Text);
      XLog( 'File name - '+  Request.Filename+' '+IntToStr(Request.ItemCount)+' '+Request.ItemValue[0]);
    Xlog('AAQUERY - '+Request.Method+' '+Request.Params.Text);

     if UpperCase(Request.FileName)='/PERSONALENTRANCE'  then
       Accept; // Ac
  end;
end;

procedure TFmAppOne.RtcDataProvider1DataReceived(Sender: TRtcConnection);
var i: integer;
    _func: String;
    _user : String;
    _password: String;
    _dm: TDmPersonalEntrance;
    _body: String;
    _obj: ISuperObject;
begin
  with TRtcDataServer(Sender) do
  begin
    if UpperCase(Request.FileName)='/PERSONALENTRANCE'  then
    begin
      _body := Read;
      _obj := SO(_body);

      _func := _obj.S['func'];
      _user := _obj.S['username'];
      _password := MIME_Decode(_obj.S['password']);
      if SameText(_func,'getCurrentState') then
      begin
        _dm := TDmPersonalEntrance.Create(self);
        try
          Write(_dm.GetCurrentState(_user,_password).AsJson());
        finally
          _dm.Free;
        end;
      end;
      if SameText(_func,'getCurrentStatus') then
      begin
        _dm := TDmPersonalEntrance.Create(self);
        try
          Write(_dm.GetCurrentStatus(_user,_password).AsJson());
        finally
          _dm.Free;
        end;
      end;
      if SameText(_func,'setCurrentStatus') then
      begin
        _dm := TDmPersonalEntrance.Create(self);
        try
          Write(_dm.SetCurrentStatus(_user,_password,True).AsJson());
        finally
          _dm.Free;
        end;
      end;
    end;
  end;

end;

end.
