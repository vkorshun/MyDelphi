unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TForm1 = class(TForm)
  private
    { Private declarations }
    FText: String;
    FIsActive: Boolean;
    procedure SetIsActive(const Value: Boolean);
    procedure SetText(const Value: String);
  public
    { Public declarations }
    property Text: String read FText write SetText;
    property IsActive: Boolean read FIsActive write SetIsActive;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ TForm1 }

procedure TForm1.SetIsActive(const Value: Boolean);
begin
  FIsActive := Value;
end;

procedure TForm1.SetText(const Value: String);
begin
  FText := Value;
end;

end.
