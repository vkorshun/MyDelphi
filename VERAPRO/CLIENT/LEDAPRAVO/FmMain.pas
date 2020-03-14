unit FmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.ImgList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan,
  attabs, Vcl.ComCtrls, Vcl.ToolWin, Vcl.ActnCtrls, Vcl.ActnMenus, RtcInfo, Rtti, TypInfo,
   {$IFDEF VER330} System.ImageList,{$ENDIF}   menustructure, DCPcrypt2, DCPsha256, DocManagerPanel;

type
  TMainFm = class(TForm)
    ActionManager2: TActionManager;
    ImageList1: TImageList;
    ActionList1: TActionList;
    aCertStore: TAction;
    aExit: TAction;
    aViewOAU: TAction;
    aViewOKU: TAction;
    aViewAttributesOAU: TAction;
    aViewAttributesOKU: TAction;
    aTest: TAction;
    aSettings: TAction;
    aCertLoad: TAction;
    ActionMainMenuBar1: TActionMainMenuBar;
    StatusBar1: TStatusBar;
    MainTabs: TATTabs;
    ActionManager1: TActionManager;
    aTest2: TAction;
    actAttributeSet: TAction;
    procedure FormCreate(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
    procedure aViewAttributesOAUExecute(Sender: TObject);
    procedure aViewOAUExecute(Sender: TObject);
    procedure aTestExecute(Sender: TObject);
    procedure aTest2Execute(Sender: TObject);
    procedure actAttributeSetExecute(Sender: TObject);
  private
    { Private declarations }
    FMenuStru: TMenuStructure;

    docManager: TDocManagerPanel;
//    procedure CreateMenu;
    procedure OnMyActionExecute(Sender:TObject);
  public
    { Public declarations }
  end;

var
  MainFm: TMainFm;

implementation

{$R *.dfm}

uses systemconsts, DmMainRtc;

procedure TMainFm.actAttributeSetExecute(Sender: TObject);
begin
  docManager.ShowDocument('TAttributesSetFrame');
end;

procedure TMainFm.aExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainFm.aTest2Execute(Sender: TObject);
begin
  docManager.ShowDocument('TMenuStruFrame');

end;

procedure TMainFm.aTestExecute(Sender: TObject);
begin
  docManager.ShowDocument('TTestDocFrame');

end;

procedure TMainFm.aViewAttributesOAUExecute(Sender: TObject);
begin
  docManager.ShowDocument('TAttributesFrameOAU');
end;

procedure TMainFm.aViewOAUExecute(Sender: TObject);
begin
  docManager.ShowDocument('TFrameGOAU');
end;

procedure TMainFm.FormCreate(Sender: TObject);
//var _menuStruDm: TMenuStruDm;
begin
  with MainTabs do
  begin
    docManager := TDocManagerPanel.create(self);
    docManager.Parent := self;
  end;
  //FRightTabs.AddTab(0,'Builds', nil);
  //  DCP_sha2561 := TDCP_sha256.Create(self);

  FMenuStru := TMenuStructure.Create;

{  _menuStruDm := TMenuStruDm.Create(MainDm);
  _MenuStruDm.FillMenuStru(FMenuStru,OnMyActionExecute);
   }
  FMenuStru.Add('Документы',1);
  FMenuStru.Root.Items[0].Add('',10,aTest);
  FMenuStru.Root.Items[0].Add('Test MENUSTRU',11,aTest2);
  FMenuStru.Root.Items[0].Add('Attributes OAU',12,aViewAttributesOAU);
  FMenuStru.Root.Items[0].Add('Attributes gr',13,actAttributeSet);

 FMenuStru.Add('Справочники',2);
  FMenuStru.Root.Items[1].Add('',7,aViewOAU);
{  FMenuStru.Add('Настройки',3);
  FMenuStru.Root.Items[0].Add('',4,aCertStore);
  FMenuStru.Root.Items[0].Add('-',5);
  FMenuStru.Root.Items[0].Add('',6,aExit);
  FMenuStru.Root.Items[1].Add('',7,aViewOAU);
//  FMenuStru.Root.Items[1].Add('',aViewOKU);
  FMenuStru.Root.Items[1].Add('-',8);
  FMenuStru.Root.Items[1].Add('',9,aViewAttributesOAU);
//  FMenuStru.Root.Items[1].Add('',aViewAttributesOKU);
  FMenuStru.Root.Items[2].Add('',10,aTest);
  FMenuStru.Root.Items[2].Add('',11,aSettings);
 }
  FMenuStru.FillActionMenu(ActionManager1, ActionMainMenuBar1);


end;





procedure TMainFm.OnMyActionExecute(Sender: TObject);
begin
   case TAction(Sender).Tag of
     MI_EXIT: aExit.Execute;
    // MI_MENUEDITOR:     docManager.ShowDocument('TMenuStruFrame');
    // MI_VIEWOAU: docManager.ShowDocument('TFrameGOAU');
    // MI_VIEWOKU: docManager.ShowDocument('TFrameGOKU');
    // MI_ATTROAU: docManager.ShowDocument('TAttributesFrameOAU');
    // MI_ATTROKU: docManager.ShowDocument('TAttributesFrameOKU');

   end;
end;

end.
