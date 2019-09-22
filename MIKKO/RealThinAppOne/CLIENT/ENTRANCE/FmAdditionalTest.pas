unit FmAdditionalTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Dm_MikkoServer;

type
  TAdditionalTestFm = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AdditionalTestFm: TAdditionalTestFm;

implementation

{$R *.dfm}

procedure TAdditionalTestFm.FormCreate(Sender: TObject);
var d1, d2: TDateTime;
begin
   d1 := StrToDateTime('26.11.2017 08:00:00');
   d2 := StrToDateTime('26.11.2017 23:00:00');
   Memo1.Clear;
   Memo1.Lines.Add(FloatToStrF(DmMikkoServer.DtToXbase(d1),ffFixed,16,8));
   Memo1.Lines.Add(FloatToStrF(DmMikkoServer.DtToXbase(d2),ffFixed,16,8));

end;

end.
