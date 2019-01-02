unit AppManager;

interface

uses
  SysUtils, Classes, Windows,Rtti, Variants, Types, TypInfo, Dialogs, Forms;

type
  TApplicationManager = class(TObject)
  private
  public
    class procedure ShowMDIForm(const AClassName: String);
    class function FindForm(const AClassName: String):TForm;
    class procedure SetMDIPosition(AForm: TForm);
  end;

implementation

uses MDITab;

{ TApplicationManager }

class function TApplicationManager.FindForm(const AClassName: String): TForm;
var    i: Integer;
begin
  Result := nil;
  for I := 0 to Application.MainForm.MDIChildCount do
    if Application.MainForm.MDIChildren[i].ClassName = AClassName then
    begin
      Result := Application.MainForm.MDIChildren[i];
      Break;
    end;
end;

class procedure TApplicationManager.SetMDIPosition(AForm: TForm);
var R:TRect;
    _mditab: TMDITab;
begin
  if not Assigned(AForm) then
   Exit;
  Application.MainForm.VertScrollBar.Visible := False;
  Application.MainForm.HorzScrollBar.Visible := False;

  _mditab := TMDITab(Application.MainForm.FindComponent('mditab1'));
  if Assigned(_mditab) then
    _mditab.addtab(AForm,10);
  if AForm.WindowState = wsMaximized then
    Exit;

  GetClientRect(Application.MainForm.ClientHandle,R);
  AForm.BoundsRect := R;

end;

class procedure TApplicationManager.ShowMDIForm(const AClassName: String);
var _Form: TForm;
    _ClassForm: TFormClass;
begin
  _Form := FindForm(AClassName);
  if not Assigned(_Form) then
  begin
    _ClassForm := TFormClass(FindClass(AClassName));
    _Form := _ClassForm.Create(Application);
  end;
  _Form.Show;
  SetMDIPosition(_Form);
end;

end.
