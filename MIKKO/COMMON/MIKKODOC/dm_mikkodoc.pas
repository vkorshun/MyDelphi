unit dm_mikkodoc;

interface

uses
  SysUtils, Classes, Dm_mikkoads, DB, adsdata, adsfunc, adstable,
  MemTableDataEh, MemTableEh, doc.variablelist, doc.mikkodoc,
  DataDriverEh, docdialog.fm_docdialog, fm_setfilter, Forms;

type

  TDmMikkoDoc = class(TDataModule)
    AdsQuery1: TAdsQuery;
    AdsQueryDoc: TAdsQuery;
    MemTableEhDoc: TMemTableEh;
    DataSetDriverEh1: TDataSetDriverEh;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataSetDriverEh1UpdateRecord(DataDriver: TDataDriverEh;
      MemTableData: TMemTableDataEh; MemRec: TMemoryRecordEh);
  private
    { Private declarations }
//    FVarListDoc: TDocVariableList;
  protected
    FDmMikkoads: TDmMikkoads;
    FDoc: TMikkoDoc;
    bPrepared: Boolean;
 //   FFmSetFilter: TFmSetFilter;
  public
    { Public declarations }
    constructor Create(aOwner:TComponent);override;
    procedure LinkWithDmMikkoads(var aQuery:TAdsQuery);
    procedure Prepare(aObject:TObject);virtual;
    procedure SetFilter(nIndex:Integer;Sender:TObject);virtual;

    property  DmMikkoAds: TDmMikkoAds read FDmMikkoads ;
//    property  FmSetFilter:TFmSetFilter read FFmSetFilter;
    property  Doc: TMikkoDoc read FDoc write FDoc;
  end;

var
  DmMikkoDoc: TDmMikkoDoc;

implementation

{$R *.dfm}

{ TDmMikkoDoc }

constructor TDmMikkoDoc.Create(aOwner: TComponent);
begin
  if (aOwner is TDmMikkoAds) then
    FDmMikkoAds := TDmMikkoAds(aOwner)
  else
    FDmMikkoAds := TDmMikkoAds.GetDmMikkoAds(aOwner);
  //FFmSetFilter := nil;
  inherited Create(aOwner);
  bPrepared := False;
  Prepare(self);
end;

procedure TDmMikkoDoc.DataModuleDestroy(Sender: TObject);
begin
//  FDocDescription.Free;
end;


procedure TDmMikkoDoc.DataSetDriverEh1UpdateRecord(DataDriver: TDataDriverEh;
  MemTableData: TMemTableDataEh; MemRec: TMemoryRecordEh);
begin
  Exit;
end;

procedure TDmMikkoDoc.LinkWithDmMikkoads(var aQuery: TAdsQuery);
begin
  aQuery.DatabaseName  := 'FDmMikkoAds.AdsConnection1';
  aQuery.AdsConnection := FDmMikkoAds.AdsConnection1;
  aQuery.AdsTableOptions.AdsCharType := OEM;
  aQuery.SourceTableType := ttAdsCdx;
end;

procedure TDmMikkoDoc.Prepare(aObject:TObject);
begin
  if bPrepared then
    Exit;
  LinkWithDmMikkoAds(AdsQuery1);
  LinkWithDmMikkoAds(AdsQueryDoc);
  if Assigned(FDoc) then
    FDoc.MemTableEhDoc := MemTableEhDoc;
  bPrepared := true;
//    FDoc.DmMikkoAds := FDmMikkoAds;
end;

procedure TDmMikkoDoc.SetFilter(nIndex: Integer; Sender: TObject);
begin
  if Assigned(FDoc.OnSetFilter) then
    FDoc.OnSetFilter(nIndex,Sender)
end;

end.
