program ledapravo;

uses
  Vcl.Forms,
  FmMain in 'FmMain.pas' {MainFm},
  menustructure in '..\..\..\LIB\menustructure.pas',
  SettingsStorage in '..\..\..\LIB\SettingsStorage.pas',
  uLog in '..\..\..\LIB\uLog.pas',
  commoninterface in '..\..\SERVER\COMMON\INTERFACE\commoninterface.pas',
  DmMainRtc in '..\COMMON\DmMainRtc.pas' {MainRtcDm: TDataModule},
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
  docManagerPanel in '..\COMMON\DOCS\docManagerPanel.pas',
  ClientDocSqlManager in '..\..\SERVER\COMMON\INTERFACE\ClientDocSqlManager.pas',
  dmAttributes in '..\COMMON\DOCS\ATTRIBUTES\dmAttributes.pas' {AttributesDm: TDataModule},
  dmAttributesOfGroup in '..\COMMON\DOCS\ATTRIBUTES\dmAttributesOfGroup.pas' {AttributesOfGroupDm: TDataModule},
  dmAttributesSet in '..\COMMON\DOCS\ATTRIBUTES\dmAttributesSet.pas' {AttributesSetDm: TDataModule},
  frameAttributes in '..\COMMON\DOCS\ATTRIBUTES\frameAttributes.pas' {AttributesFrame: TFrame},
  frameAttributesOfGroup in '..\COMMON\DOCS\ATTRIBUTES\frameAttributesOfGroup.pas' {AttributesOfGroupFrame: TFrame},
  frameAttributesSet in '..\COMMON\DOCS\ATTRIBUTES\frameAttributesSet.pas' {AttributesSetFrame: TFrame},
  dmObjects in '..\COMMON\DOCS\OBJECTS\dmObjects.pas' {ObjectsDm: TDataModule},
  frameobjectsgr in '..\COMMON\DOCS\OBJECTS\frameobjectsgr.pas' {ObjectsGrFrame: TFrame},
  frameObjectsItems in '..\COMMON\DOCS\OBJECTS\frameObjectsItems.pas' {ObjectsItemsFrame: TFrame},
  DmTestDoc in 'DOCS\TESTDOC\DmTestDoc.pas' {TestDocDm: TDataModule},
  FrameTestDoc in 'DOCS\TESTDOC\FrameTestDoc.pas' {TestDocFrame: TFrame},
  DmMenuStru in '..\COMMON\DOCS\MENUSTRU\DmMenuStru.pas' {MenuStruDm: TDataModule},
  frameMenuStru in '..\COMMON\DOCS\MENUSTRU\frameMenuStru.pas' {MenuStruFrame: TFrame},
  DmUserList in '..\COMMON\DOCS\ACCESS\DmUserList.pas' {UserListDm: TDataModule},
  FrameUserList in '..\COMMON\DOCS\ACCESS\FrameUserList.pas' {DocFrame2: TFrame},
  RtcDataSetUtils in '..\..\..\LIB\COMPONENTS\VKRTC\RtcDataSetUtils.pas',
  RtcFuncResult in '..\..\..\LIB\COMPONENTS\VKRTC\RtcFuncResult.pas',
  RtcQueryDataSet in '..\..\..\LIB\COMPONENTS\VKRTC\RtcQueryDataSet.pas',
  RtcResult in '..\..\..\LIB\COMPONENTS\VKRTC\RtcResult.pas',
  RtcService in '..\..\..\LIB\COMPONENTS\VKRTC\RtcService.pas',
  RtcSqlQuery in '..\..\..\LIB\COMPONENTS\VKRTC\RtcSqlQuery.pas';

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
