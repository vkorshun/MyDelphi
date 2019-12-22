program test;

uses
  Vcl.Forms,
  FmTest in 'FmTest.pas' {Form5},
  fbapidatabase in '..\COMPONENTS\FIBPROVIDER\fbapidatabase.pas',
  FIbLib in '..\COMPONENTS\FIBPROVIDER\FIbLib.pas',
  fbresultset in '..\COMPONENTS\FIBPROVIDER\fbresultset.pas',
  DmFibApi in '..\COMPONENTS\DmFibApi.pas' {FibApiDm: TDataModule},
  VkUIBDataset in '..\COMPONENTS\FIBPROVIDER\VkUIBDataset.pas',
  VkUib in '..\COMPONENTS\FIBPROVIDER\VkUib.pas',
  fbapitransaction in '..\COMPONENTS\FIBPROVIDER\fbapitransaction.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TFibApiDm, FibApiDm);
  Application.Run;
end.
