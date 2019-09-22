program AppOneRtc;

uses
  Forms,
  fm_appone in 'fm_appone.pas' {FmAppOne},
  dm_entrance in 'dm_entrance.pas' {DmEntrance: TDataModule},
  dm_EntranceMethodsMikko in 'dm_EntranceMethodsMikko.pas' {DmEntranceMethodsMikko: TDataModule},
  fasapi in '..\CLIENT\FUTRONIC\fasapi.pas',
  ftrapi in '..\CLIENT\FUTRONIC\ftrapi.pas',
  ftrscanapi in '..\CLIENT\FUTRONIC\ftrscanapi.pas',
  dm_client in '..\..\COMMON\dm_client.pas' {DmClient: TDataModule},
  dm_mikkoads in '..\..\COMMON\dm_mikkoads.pas' {DmMikkoAds: TDataModule},
  mikko_consts in '..\..\COMMON\mikko_consts.pas',
  fm_login in '..\..\COMMON\fm_login.pas' {FmLogin},
  dm_personalentrance in 'dm_personalentrance.pas' {DmPersonalEntrance: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFmAppOne, FmAppOne);
  Application.CreateForm(TDmPersonalEntrance, DmPersonalEntrance);
  //  Application.CreateForm(TDmEntrance, DmEntrance);
//  Application.CreateForm(TDmEntranceMethodsMikko, DmEntranceMethodsMikko);
//  Application.CreateForm(TDmClient, DmClient);
//  Application.CreateForm(TFmLogin, FmLogin);
  Application.Run;
end.
