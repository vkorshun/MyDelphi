unit fmLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, DmMain,AppEvnts, fmhopedialogform;

type
  TLoginFm = class(THopeDialogFormFm)
    Label1: TLabel;
    Label2: TLabel;
    edUserName: TEdit;
    edPassword: TEdit;
    Image1: TImage;
    lbCapsLock: TLabel;
    ApplicationEvents1: TApplicationEvents;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    class function Login:Boolean;
  end;

var
  LoginFm: TLoginFm;

implementation

{$R *.dfm}

procedure TLoginFm.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
begin
  inherited;
  if Odd(GetKeyState(VK_CAPITAL)) then
    lbCapsLock.Caption := 'Caps Lock включен'
  else
    lbCapsLock.Caption := '';
end;

procedure TLoginFm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited;
  if ModalResult = mrOk then
    CanClose := MainDm.Login(edUserName.Text,edPassword.Text);
end;

class function TLoginFm.Login: Boolean;
begin
  with Self.Create(Application) do
  try
    if ParamCount>= 2 then
    begin
      Result := MainDm.Login(ParamStr(1),ParamStr(2));
      if Result then
        Exit;
    end;
    Result := ShowModal = mrOk;
  finally
    Free;
  end;

end;

end.
