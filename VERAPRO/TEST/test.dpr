program test;

uses
  Vcl.Forms,
  FmTest in 'FmTest.pas' {Form5},
  fbdatabase in '..\COMPONENTS\FIBPROVIDER\fbdatabase.pas',
  FIbLib in '..\COMPONENTS\FIBPROVIDER\FIbLib.pas',
  fbresultset in '..\COMPONENTS\FIBPROVIDER\fbresultset.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.
