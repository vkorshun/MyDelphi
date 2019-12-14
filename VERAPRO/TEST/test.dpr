program test;

uses
  Vcl.Forms,
  FmTest in 'FmTest.pas' {Form5},
  fbdatabase in '..\COMPONENTS\FIBPROVIDER\fbdatabase.pas',
  FIbLib in '..\COMPONENTS\FIBPROVIDER\FIbLib.pas',
  fbresultset in '..\COMPONENTS\FIBPROVIDER\fbresultset.pas',
  DmFibApi in '..\COMPONENTS\DmFibApi.pas' {FibApiDm: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TFibApiDm, FibApiDm);
  Application.Run;
end.
