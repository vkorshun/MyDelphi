program flexoprint_dt;

uses
  Vcl.Forms,
  FmMain in 'FmMain.pas' {Form3},
  menustructure in '..\..\..\..\LIB\menustructure.pas',
  SettingsStorage in '..\..\..\..\LIB\SettingsStorage.pas',
  uLog in '..\..\..\..\LIB\uLog.pas',
  fmhopedialogform in '..\..\..\..\LIB\FORMS\fmhopedialogform.pas' {HopeDialogFormFm},
  fmLogin in '..\..\..\..\LIB\FORMS\fmLogin.pas' {LoginFm},
  FmSelectDbAlias in '..\..\..\..\LIB\FORMS\FmSelectDbAlias.pas' {SelectDbAliasFm},
  fmhopeform in '..\..\..\..\LIB\FORMS\fmhopeform.pas' {HopeFormFm},
  DocSqlManager in '..\..\COMMON\DOCS\DocSqlManager.pas',
  uDocDescription in '..\..\COMMON\DOCS\uDocDescription.pas',
  vkdocinstance in '..\..\COMMON\DOCS\vkdocinstance.pas',
  AppManager in '..\..\COMMON\AppManager.pas',
  fmSetupForm in '..\..\COMMON\DOCS\fmSetupForm.pas' {SetUpFormFm},
  tabManagerPanel in '..\..\COMMON\TABS\tabManagerPanel.pas',
  dmAttributes in '..\..\COMMON\ATTRIBUTES\dmAttributes.pas' {AttributesDm: TDataModule},
  dmAttributesOfGroup in '..\..\COMMON\ATTRIBUTES\dmAttributesOfGroup.pas' {AttributesOfGroupDm: TDataModule},
  dmAttributesSet in '..\..\COMMON\ATTRIBUTES\dmAttributesSet.pas' {AttributesSetDm: TDataModule},
  frameAttributes in '..\..\COMMON\ATTRIBUTES\frameAttributes.pas' {AttributesFrame: TFrame},
  frameAttributesOfGroup in '..\..\COMMON\ATTRIBUTES\frameAttributesOfGroup.pas' {AttributesOfGroupFrame: TFrame},
  frameAttributesSet in '..\..\COMMON\ATTRIBUTES\frameAttributesSet.pas' {AttributesSetFrame: TFrame},
  dmObjects in '..\..\COMMON\OBJECTS\dmObjects.pas' {ObjectsDm: TDataModule},
  frameobjectsgr in '..\..\COMMON\OBJECTS\frameobjectsgr.pas' {ObjectsGrFrame: TFrame},
  frameObjectsItems in '..\..\COMMON\OBJECTS\frameObjectsItems.pas' {ObjectsItemsFrame: TFrame},
  systemconsts in '..\..\COMMON\systemconsts.pas',
  fdac.dmDoc in '..\..\COMMON\DOCS\FDAC\fdac.dmDoc.pas' {DocDm: TDataModule},
  fdac.docbinding in '..\..\COMMON\DOCS\FDAC\fdac.docbinding.pas',
  fdac.fmCustomDoc in '..\..\COMMON\DOCS\FDAC\fdac.fmCustomDoc.pas' {CustomDocFm},
  fdac.framedoc in '..\..\COMMON\DOCS\FDAC\fdac.framedoc.pas' {DocFrame: TFrame},
  fdac.dmmain in '..\..\COMMON\DOCS\FDAC\fdac.dmmain.pas' {MainDm: TDataModule},
  dmMenuStru in '..\..\COMMON\MENUSTRU\dmMenuStru.pas' {MenuStruDm: TDataModule},
  frameMenuStru in '..\..\COMMON\MENUSTRU\frameMenuStru.pas' {MenuStruFrame: TFrame},
  EhLibMTE in 'C:\THIRDLIB.XE260\Eh\Lib\EhLibMTE.pas',
  DBGridFilterDropDownFormsEh in 'C:\THIRDLIB.XE260\Eh\Lib\DBGridFilterDropDownFormsEh.pas' {DBGridFilterDropDownForm: TFrame},
  FilterDropDownFormsEh in 'C:\THIRDLIB.XE260\Eh\Lib\FilterDropDownFormsEh.pas' {FilterDropDownForm: TCustomDropDownFormEh},
  DBGridEh in 'C:\THIRDLIB.XE260\Eh\Lib\DBGridEh.pas',
  fdsqlquery in '..\..\COMMON\DOCS\FDAC\fdsqlquery.pas',
  DmWorkRange in '..\..\COMMON\WORKRANGE\DmWorkRange.pas' {WorkRangeDm: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainDm, MainDm);
  if MainDm.selectAlias and TLoginFm.Login then
    Application.CreateForm(TMainFm, MainFm);
  Application.Run;
end.
