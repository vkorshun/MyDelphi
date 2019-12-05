program websocket_client;

uses
  Vcl.Forms,
  FmWebSocketTest in 'FmWebSocketTest.pas' {Form6};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm6, Form6);
  Application.Run;
end.
