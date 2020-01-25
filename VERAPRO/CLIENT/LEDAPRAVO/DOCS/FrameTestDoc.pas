unit FrameTestDoc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, rtc.framedoc, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, System.Actions,
  Vcl.ActnList, Vcl.Menus, Vcl.ImgList, Data.DB, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, DBGridEhVk, Vcl.ToolWin, Vcl.ActnMan,
  Vcl.ActnCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, rtc.DmDoc, DmTestDoc, DmMainRtc;

type
  TTestDocFrame = class(TDocFrame)
  private
    { Private declarations }
  public
    { Public declarations }
    class function GetDmDoc:TDocDm;override;
    function GetCaption: String; override;
  end;

var
  TestDocFrame: TTestDocFrame;

implementation

{$R *.dfm}

{ TTestDocFrame }

function TTestDocFrame.GetCaption: String;
begin
  Result := 'Тестовый документ';
end;

class function TTestDocFrame.GetDmDoc: TDocDm;
begin
  Result := TTestDocDm.Create(MainRtcDm);
end;

initialization
  RegisterClass(TTestDocFrame);


end.
