unit FmLedapravoSrv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm5 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

uses DmMain;

procedure TForm5.Button1Click(Sender: TObject);
begin
{  if (MainDm.FbDatabase.IsConnected) then
    MainDm.FbDatabase.Disconnect
  else
    MainDm.FbDatabase.Connect;}
  MainDm.ValidUser('юдлхм','юдлхм');
  ShowMessage('Ok1');

end;

end.
