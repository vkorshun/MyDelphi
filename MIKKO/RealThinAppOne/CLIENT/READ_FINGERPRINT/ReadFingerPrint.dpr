program ReadFingerPrint;

uses
  Forms,
  fm_readfingerprint in 'fm_readfingerprint.pas' {FmReaderFingerPrint},
  fingerprintreader in 'fingerprintreader.pas',
  fasapi in '..\..\FUTRONIC\fasapi.pas',
  ftrapi in '..\..\FUTRONIC\ftrapi.pas',
  ftrscanapi in '..\..\FUTRONIC\ftrscanapi.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFmReaderFingerPrint, FmReaderFingerPrint);
  Application.Run;
end.
