unit fm_login;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IniFiles;

type
  TFmLogin = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    EdUserName: TEdit;
    EdPassword: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FIni: TIniFile;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FmLogin: TFmLogin;

implementation

{$R *.dfm}

procedure TFmLogin.FormCreate(Sender: TObject);
begin
  FIni := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  EdUserName.Text := FIni.ReadString('SET','Username','');
  EdPassword.Text := FIni.ReadString('SET','Password','');
  Caption := 'Connection to ClientManager'
end;

procedure TFmLogin.FormDestroy(Sender: TObject);
begin
  FIni.WriteString('SET','Username',EdUserName.Text);
end;

end.
