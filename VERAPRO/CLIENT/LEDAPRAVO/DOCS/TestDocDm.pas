unit TestDocDm;

interface

uses
  System.SysUtils, System.Classes, rtc.dmDoc, MemTableDataEh, Data.DB, DataDriverEh, MemTableEh;

type
  TDocDm2 = class(TDocDm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DocDm2: TDocDm2;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
