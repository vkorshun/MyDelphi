program kursloader;

uses
  Forms,
  fm_kursloader in 'fm_kursloader.pas' {FmKursLoader},
  sendmail_synapse in 'C:\THIRDLIB.XE\SYNAPSE\source\VK\sendmail_synapse.pas',
  ruskursxml in 'ruskursxml.pas',
  ruskurslist in 'ruskurslist.pas',
  FireDAC.Phys.ADS in 'FDAC\FireDAC.Phys.ADS.pas',
  FireDAC.Phys.ADSCli in 'FDAC\FireDAC.Phys.ADSCli.pas',
  FireDAC.Phys.ADSMeta in 'FDAC\FireDAC.Phys.ADSMeta.pas',
  FireDAC.Phys.ADSWrapper in 'FDAC\FireDAC.Phys.ADSWrapper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Загрузка курсов валют';
  Application.CreateForm(TFmKursLoader, FmKursLoader);
  //  Application.CreateForm(TFmLogin, FmLogin);
  //{$ifdef MYTEST}
     Application.Run;
  //{$else}
  //FmKursLoader.Timer1Timer(nil);
  //{$endif}
end.
