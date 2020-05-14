unit FrameUserList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, rtc.framedoc, DBGridEhGrouping,
  ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, System.Actions, Vcl.ActnList,
  Vcl.Menus, Vcl.ImgList, Data.DB, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh,
  DBGridEhVk, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TDocFrame2 = class(TDocFrame)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DocFrame2: TDocFrame2;

implementation

{$R *.dfm}

end.
