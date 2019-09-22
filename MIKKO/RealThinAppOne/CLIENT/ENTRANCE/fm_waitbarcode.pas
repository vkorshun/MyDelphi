unit fm_waitbarcode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

const
  WM_BARCODE= WM_USER +101;
  LEN_BUFFER= 13;

type
TCodeBuffer= array[0..LEN_BUFFER] of AnsiChar;

type
  TFmWaitBarcode = class(TForm)
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FBuffer: TCodeBuffer;
    iPointer: Integer;
    procedure ResetBuffer;
  public
    { Public declarations }
    FormHandle: HWND;
    property Buffer:TCodeBuffer read FBuffer;
  end;

var
  FmWaitBarcode: TFmWaitBarcode;

implementation

{$R *.dfm}

procedure TFmWaitBarcode.FormCreate(Sender: TObject);
begin
  Caption := 'Ожидание сканировани'
end;

procedure TFmWaitBarcode.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key in [48..57] then
  begin
    if iPointer=LEN_BUFFER then
       ResetBuffer;
    FBuffer[iPointer]:= AnsiChar(key);
    iPointer:= iPointer+1;
  end
  else
     if (key=13) and (iPointer=LEN_BUFFER) then
     begin
       iPointer   := 0;
       key := 0;
       Close;
       SendMessage(FormHandle,WM_BARCODE,0,0);
     end
     else
       iPointer := 0;

end;

procedure TFmWaitBarcode.ResetBuffer;
var i: Integer;
begin
  for i:=0  to LEN_BUFFER - 1 do
    FBuffer[i]:= FBuffer[i+1];
  iPointer := LEN_BUFFER - 1;
end;

end.
