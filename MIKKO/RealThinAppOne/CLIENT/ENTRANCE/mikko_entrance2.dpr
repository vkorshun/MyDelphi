program mikko_entrance2;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Windows,
  Forms,
  SysUtils,
  IniFiles,
  fm_mikko_entrance in 'fm_mikko_entrance.pas' {FmMikko_Entrance: TFmMikko_Entrance},
  fm_waitbarcode in 'fm_waitbarcode.pas' {FmWaitBarcode},
  fasapi in '..\FUTRONIC\fasapi.pas',
  ftrapi in '..\FUTRONIC\ftrapi.pas',
  ftrscanapi in '..\FUTRONIC\ftrscanapi.pas',
  fm_registerfingerprint in 'fm_registerfingerprint.pas' {FmRegisterFingerPrint},
  fm_registration in 'fm_registration.pas' {FmRegistration},
  dm_registerfingerprint in 'dm_registerfingerprint.pas' {DmRegisterFingerPrint: TDataModule},
  dm_mikkoserver in '..\MIKKOSERVER\dm_mikkoserver.pas' {DmMikkoServer: TDataModule},
  fingerprintreader in '..\READ_FINGERPRINT\fingerprintreader.pas',
  dm_entrancemikkoclient in '..\MIKKOSERVER\dm_entrancemikkoclient.pas' {DmEntranceMikkoClient: TDataModule},
  SoundPlayerEntrance in 'SOUNDS\SoundPlayerEntrance.pas',
  sotrudinfo in 'sotrudinfo.pas',
  FmAdditionalTest in 'FmAdditionalTest.pas' {AdditionalTestFm};

{$R *.res}
var
  h: Integer;
begin
  bDelphi :=FindWindow('TAppBuilder',nil)>0;

  begin
    h := FindWindow('TFmMikko_Entrance',nil);
    if bDelphi or (h=0) then
    begin
      Application.Initialize;
      //if DmMikkoServer.nInterface<>2 then
//      Application.CreateForm(TDmMikkoServer, DmMikkoServer);
      Application.CreateForm(TFmmikko_entrance, Fmmikko_entrance);
  {else
      begin
        Application.CreateForm(TDmRegisterFingerPrint, DmRegisterFingerPrint);
        Application.CreateForm(TFmRegisterFingerPrint, FmRegisterFingerPrint);
      end; }
      Application.Run;
    end
    else
      SetForegroundWindow(h);
  end;
end.
