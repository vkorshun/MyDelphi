unit FmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls,
  Vcl.ActnMenus, System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList,
  Vcl.PlatformDefaultStyleActnCtrls, attabs, Vcl.ComCtrls, docManagerPanel, menustructure;

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
    procedure FormCreate(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
    procedure aViewAttributesOAUExecute(Sender: TObject);
    procedure aViewOAUExecute(Sender: TObject);
  private
    { Private declarations }
    FMenuStru: TMenuStructure;
    docManager: TDocManagerPanel;
  public
    { Public declarations }
  end;

var
  MainFm: TMainFm;

implementation

{$R *.dfm}

procedure TMainFm.aExitExecute(Sender: TObject);
begin
  Close;
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
begin
  with MainTabs do
  begin
    //TabDoubleClickPlus:= true;
  {*  OptTabWidthMinimal:= 100; //debug
    //OptAngle:= 0;
    OptTabHeight := 20;
    Height := 25;
    Color := Self.Color;
    ColorBg:= Self.Color;
    ColorArrow := Self.Color;
    //ColorDrop := Self.Color;
    ColorBorderActive := clGreen;
    ColorBorderPassive := clWhite;
    //TabShowPlus := False;

    //OnTabMove := formOnTabMove;
    //OnTabClick := formOnTabClick;
    //OnTabClose := FormOnTabClose;
    *}
    AddTab(0,'Project', nil);
    docManager := TDocManagerPanel.create(self);
    docManager.Parent := self;
    docManager.ShowDocument('TAttributesFrameOAU');
  end;
  //FRightTabs.AddTab(0,'Builds', nil);
  FMenuStru := TMenuStructure.Create;
  FMenuStru.Add('Документы');
  FMenuStru.Add('Справочники');
  FMenuStru.Add('Настройки');
  FMenuStru.Root.Items[0].Add('',aCertStore);
  FMenuStru.Root.Items[0].Add('-');
  FMenuStru.Root.Items[0].Add('',aExit);
  FMenuStru.Root.Items[1].Add('',aViewOAU);
//  FMenuStru.Root.Items[1].Add('',aViewOKU);
  FMenuStru.Root.Items[1].Add('-');
  FMenuStru.Root.Items[1].Add('',aViewAttributesOAU);
//  FMenuStru.Root.Items[1].Add('',aViewAttributesOKU);
  FMenuStru.Root.Items[2].Add('',aTest);
  FMenuStru.Root.Items[2].Add('',aSettings);

  FMenuStru.FillActionMenu(ActionManager1, ActionMainMenuBar1);

end;


end.
