unit FmLedapravoSrv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, rtcInfo, rtcConn, rtcDataSrv, rtcHttpSrv;

type
  TLedaPravoSrvFm = class(TForm)
    Button1: TButton;
    RtcHttpServer1: TRtcHttpServer;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  LedaPravoSrvFm: TLedaPravoSrvFm;

implementation

{$R *.dfm}

uses DmMain;

procedure TLedaPravoSrvFm.Button1Click(Sender: TObject);
begin
{  if (MainDm.FbDatabase.IsConnected) then
    MainDm.FbDatabase.Disconnect
  else
    MainDm.FbDatabase.Connect;}

  MainDm.ValidUser('ADMIN','ADMIN');
  ShowMessage('Ok1');

end;

end.
