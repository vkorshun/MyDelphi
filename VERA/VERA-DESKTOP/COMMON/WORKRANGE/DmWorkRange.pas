unit DmWorkRange;

interface

uses
  System.SysUtils, System.Classes, fdac.dmDoc, MemTableDataEh, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  DataDriverEh, MemTableEh;

type
  TWorkRangeDm = class(TDocDm)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WorkRangeDm: TWorkRangeDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TWorkRangeDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  SqlManager.InitCommonParams('WORKRANGE','ym','');
  SqlManager.SelectSQL.Add('SELECT * FROM workrange ORDER BY ym');
end;

end.
