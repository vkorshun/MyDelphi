unit FmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls,
  Vcl.ActnMenus, System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList,
  Vcl.PlatformDefaultStyleActnCtrls;

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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainFm: TMainFm;

implementation

{$R *.dfm}

end.
