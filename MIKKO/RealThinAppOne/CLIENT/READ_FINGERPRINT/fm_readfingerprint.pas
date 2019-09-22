unit fm_readfingerprint;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, fingerprintreader, StdCtrls;

type
  TFmReaderFingerPrint = class(TForm)
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FpThread: TFingerPrintReader;
    nCount: Integer;
  public
    { Public declarations }
    procedure EnrollFingerPrint(Sender:TObject);
  end;

var
  FmReaderFingerPrint: TFmReaderFingerPrint;

implementation

{$R *.dfm}

procedure TFmReaderFingerPrint.EnrollFingerPrint(Sender: TObject);
begin
  Inc(nCount);
  Label1.Caption := IntTostr(nCount);
//  ShowMessage(IntTostr(nCount));
  if nCount=2 then nCount :=0;

end;

procedure TFmReaderFingerPrint.FormCreate(Sender: TObject);
begin
  nCount:=0;
  FpThread := TFingerPrintReader.Create(True);
  with FpThread do
  begin
    OnEnrollFingerPrint := EnrollFingerPrint;
  end;
  FpReader := FpThread;
  FpThread.Resume;
end;

end.
