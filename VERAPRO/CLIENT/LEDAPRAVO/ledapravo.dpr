program ledapravo;

uses
  Vcl.Forms,
  FmMain in 'FmMain.pas' {MainFm},
  menustructure in '..\..\..\LIB\menustructure.pas',
  SettingsStorage in '..\..\..\LIB\SettingsStorage.pas',
  uLog in '..\..\..\LIB\uLog.pas',
  commoninterface in '..\..\SERVER\COMMON\INTERFACE\commoninterface.pas',
  DmMainRtc in '..\COMMON\DmMainRtc.pas' {MainRtcDm: TDataModule},
  RtcQueryDataSet in '..\COMMON\RTC\RtcQueryDataSet.pas',
  RtcSqlQuery in '..\COMMON\RTC\RtcSqlQuery.pas',
  FrameTab in '..\COMMON\TABS\FrameTab.pas' {TabFrame: TFrame},
  tabManagerPanel in '..\COMMON\TABS\tabManagerPanel.pas',
  systemconsts in '..\COMMON\systemconsts.pas',
  rtc.dmDoc in '..\COMMON\DOCS\RTC\rtc.dmDoc.pas' {DocDm: TDataModule},
  rtc.docbinding in '..\COMMON\DOCS\RTC\rtc.docbinding.pas',
  rtc.fmCustomDoc in '..\COMMON\DOCS\RTC\rtc.fmCustomDoc.pas',
  rtc.framedoc in '..\COMMON\DOCS\RTC\rtc.framedoc.pas' {DocFrame: TFrame},
  fmhopedialogform in '..\..\..\LIB\FORMS\fmhopedialogform.pas' {HopeDialogFormFm},
  fmhopeform in '..\..\..\LIB\FORMS\fmhopeform.pas' {HopeFormFm},
  fmLoginRtc in '..\..\..\LIB\FORMS\fmLoginRtc.pas' {LoginFm},
  FmSelectDbAlias in '..\..\..\LIB\FORMS\FmSelectDbAlias.pas',
  vkdocinstance in '..\COMMON\DOCS\vkdocinstance.pas',
  DocSqlManager in '..\COMMON\DOCS\DocSqlManager.pas',
  uDocDescription in '..\COMMON\DOCS\uDocDescription.pas',
  fmSetupForm in '..\COMMON\DOCS\fmSetupForm.pas' {SetUpFormFm},
  RtcFuncResult in '..\COMMON\RTC\RtcFuncResult.pas',
  docManagerPanel in '..\COMMON\DOCS\docManagerPanel.pas',
  DmTestDoc in 'DOCS\DmTestDoc.pas' {TestDocDm: TDataModule},
  FrameTestDoc in 'DOCS\FrameTestDoc.pas' {TestDocFrame: TFrame},
  ClientDocSqlManager in '..\..\SERVER\COMMON\INTERFACE\ClientDocSqlManager.pas',
  frameMenuStru in 'DOCS\MENUSTRU\frameMenuStru.pas' {MenuStruFrame: TFrame},
  DmMenuStru in 'DOCS\MENUSTRU\DmMenuStru.pas' {MenuStruDm: TDataModule},
  dmAttributes in '..\COMMON\DOCS\ATTRIBUTES\dmAttributes.pas' {AttributesDm: TDataModule},
  dmAttributesOfGroup in '..\COMMON\DOCS\ATTRIBUTES\dmAttributesOfGroup.pas' {AttributesOfGroupDm: TDataModule},
  dmAttributesSet in '..\COMMON\DOCS\ATTRIBUTES\dmAttributesSet.pas' {AttributesSetDm: TDataModule},
  frameAttributes in '..\COMMON\DOCS\ATTRIBUTES\frameAttributes.pas' {AttributesFrame: TFrame},
  frameAttributesOfGroup in '..\COMMON\DOCS\ATTRIBUTES\frameAttributesOfGroup.pas' {AttributesOfGroupFrame: TFrame},
  frameAttributesSet in '..\COMMON\DOCS\ATTRIBUTES\frameAttributesSet.pas' {AttributesSetFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainRtcDm, MainRtcDm);
  Application.CreateForm(TMainFm, MainFm);
  //  Application.CreateForm(TTestDocDm, TestDocDm);
  if TLoginFm.Login then
  begin
  //  Application.CreateForm(TDocDm, DocDm);
  //  Application.CreateForm(THopeFormFm, HopeFormFm);
  //  Application.CreateForm(TSetUpFormFm, SetUpFormFm);
    Application.Run;
  end;
end.
