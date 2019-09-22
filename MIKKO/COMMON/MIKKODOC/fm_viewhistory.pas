unit fm_viewhistory;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DBGridEhGrouping, GridsEh, DBGridEh, DBGridEhVk, ComCtrls, dm_mikkoads,
  MemTableDataEh,DataDriverEh, MemTableEh, adsdata, adsfunc, adstable, Db, VkSynEdit,
  ExtCtrls, SynEdit;

const
  IDTYPE_HISTORYDOC = 0;
  IDTYPE_HISTORYCLI = 1;

type
  TFmViewHistory = class(TForm)
    DBGridEhVk1: TDBGridEhVk;
    StatusBar1: TStatusBar;
    AdsQuery1: TAdsQuery;
    MemTableEh1: TMemTableEh;
    DataSetDriverEh1: TDataSetDriverEh;
    DataSource1: TDataSource;
    VkSynEdit1: TVkSynEdit;
    Splitter1: TSplitter;
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure MemTableEh1AfterOpen(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FDmMikkoads: TDmMikkoAds;
  public
    { Public declarations }
    procedure Prepare(aDm:TDmMikkoAds; aKod: Integer);
  end;

var
  FmViewHistory: TFmViewHistory;

implementation

{$R *.dfm}

{ TFmViewHistory }

procedure TFmViewHistory.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  VkSynEdit1.Text := memTableEh1.FieldByName('comment').AsString;
end;

procedure TFmViewHistory.FormCreate(Sender: TObject);
begin
  Caption := 'История изменений';
end;

procedure TFmViewHistory.MemTableEh1AfterOpen(DataSet: TDataSet);
var i: Integer;
begin
  with DataSet do
  begin
    for i := 0 to Fields.Count-1 do
      Fields[i].Visible := False;

    with FieldByName('username') do
    begin
      Index := 0;
      Visible := True;
      Displaylabel := 'Пользователь'
    end;
    with FieldByName('ALIAS') do
    begin
      Index := 1;
      Visible := True;
      Displaylabel := 'Логин'
    end;
    with FieldByName('date') do
    begin
      Index := 2;
      Visible := True;
      Displaylabel := 'Дата'
    end;
    with FieldByName('time') do
    begin
      Index := 3;
      Visible := True;
      Displaylabel := 'Время'
    end;
    with FieldByName('Action') do
    begin
      Index := 4;
      Visible := True;
      Displaylabel := 'Действие'
    end;
    with FieldByName('Comment') do
    begin
      Index := 5;
      Visible := True;
      Displaylabel := 'Комментарий';
      DisplayWidth := 30;
    end;

  end;
end;

procedure TFmViewHistory.Prepare(aDm: TDmMikkoAds;  aKod: Integer);
begin
  MemTableEh1.Active := False;
  with AdsQuery1 do
  begin
    if not Active then
    begin
      FDmMikkoAds := aDm;
      FDmMikkoAds.LinckQuery(AdsQuery1);
      SQL.Clear;
      SQL.Add('SELECT p.*, c.name as name2 FROM tools\protocol p');
      SQL.Add(' LEFT JOIN client c ON c.kodkli= p.kodkli');
      SQL.Add('WHERE kod=:kod');
    end
    else
      Active := False;
    ParamByName('kod').AsInteger := aKod;
    Open;
  end;
  memTableEh1.Open;
end;

end.
