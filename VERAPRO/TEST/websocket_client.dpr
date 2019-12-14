program websocket_client;

uses
  Vcl.Forms,
  FmWebSocketTest in 'FmWebSocketTest.pas' {MainFnWSTest};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFnWSTest, MainFnWSTest);
  Application.Run;
end.
