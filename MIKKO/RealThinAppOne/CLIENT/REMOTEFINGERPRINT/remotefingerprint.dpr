program remotefingerprint;

uses
  Forms,
  fm_remotefingerprint in 'fm_remotefingerprint.pas' {FmRemoteFingerPrint},
  fingerprintreader in '..\READ_FINGERPRINT\fingerprintreader.pas',
  fasapi in '..\FUTRONIC\fasapi.pas',
  ftrapi in '..\FUTRONIC\ftrapi.pas',
  ftrscanapi in '..\FUTRONIC\ftrscanapi.pas',
  dm_remoteserver in 'dm_remoteserver.pas' {DmRemoteServer: TDataModule},
  sotrudinfo in '..\ENTRANCE\sotrudinfo.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFmRemoteFingerPrint, FmRemoteFingerPrint);
  Application.CreateForm(TDmRemoteServer, DmRemoteServer);
  Application.Run;
end.
