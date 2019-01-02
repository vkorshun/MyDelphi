program flexoprint_dt;

uses
  Vcl.Forms,
  FmMain in 'FmMain.pas' {Form3},
  fib.DmMain in '..\..\COMMON\fib.DmMain.pas' {MainDm: TDataModule},
  menustructure in '..\..\..\..\LIB\menustructure.pas',
  SettingsStorage in '..\..\..\..\LIB\SettingsStorage.pas',
  uLog in '..\..\..\..\LIB\uLog.pas',
  fmhopedialogform in '..\..\..\..\LIB\FORMS\fmhopedialogform.pas' {HopeDialogFormFm},
  fmLogin in '..\..\..\..\LIB\FORMS\fmLogin.pas' {LoginFm},
  FmSelectDbAlias in '..\..\..\..\LIB\FORMS\FmSelectDbAlias.pas' {SelectDbAliasFm},
  fmhopeform in '..\..\..\..\LIB\FORMS\fmhopeform.pas' {HopeFormFm},
  DocSqlManager in '..\..\COMMON\DOCS\DocSqlManager.pas',
  uDocDescription in '..\..\COMMON\DOCS\uDocDescription.pas',
  fib.dmDoc in '..\..\COMMON\DOCS\fib.dmDoc.pas' {DocDm: TDataModule},
  fib.docbinding in '..\..\COMMON\DOCS\fib.docbinding.pas',
  fib.fmCustomDoc in '..\..\COMMON\DOCS\fib.fmCustomDoc.pas' {CustomDocFm},
  fib.framedoc in '..\..\COMMON\DOCS\fib.framedoc.pas' {DocFrame: TFrame},
  vkdocinstance in '..\..\COMMON\DOCS\vkdocinstance.pas',
  AppManager in '..\..\COMMON\AppManager.pas',
  fmSetupForm in '..\..\COMMON\DOCS\fmSetupForm.pas' {SetUpFormFm},
  docManagerPanel in '..\..\COMMON\DOCS\docManagerPanel.pas',
  dmAttributes in '..\..\COMMON\ATTRIBUTES\dmAttributes.pas' {AttributesDm: TDataModule},
  dmAttributesOfGroup in '..\..\COMMON\ATTRIBUTES\dmAttributesOfGroup.pas' {AttributesOfGroupDm: TDataModule},
  dmAttributesSet in '..\..\COMMON\ATTRIBUTES\dmAttributesSet.pas' {AttributesSetDm: TDataModule},
  frameAttributes in '..\..\COMMON\ATTRIBUTES\frameAttributes.pas' {AttributesFrame: TFrame},
  frameAttributesOfGroup in '..\..\COMMON\ATTRIBUTES\frameAttributesOfGroup.pas' {AttributesOfGroupFrame: TFrame},
  frameAttributesSet in '..\..\COMMON\ATTRIBUTES\frameAttributesSet.pas' {AttributesSetFrame: TFrame},
  dmObjects in '..\..\COMMON\OBJECTS\dmObjects.pas' {ObjectsDm: TDataModule},
  frameobjectsgr in '..\..\COMMON\OBJECTS\frameobjectsgr.pas' {ObjectsGrFrame: TFrame},
  frameObjectsItems in '..\..\COMMON\OBJECTS\frameObjectsItems.pas' {ObjectsItemsFrame: TFrame},
  systemconsts in '..\..\COMMON\systemconsts.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainDm, MainDm);
  if MainDm.selectAlias and TLoginFm.Login then
    Application.CreateForm(TMainFm, MainFm);
  Application.Run;
end.
