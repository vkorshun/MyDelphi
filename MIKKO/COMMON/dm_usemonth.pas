unit dm_usemonth;

interface

uses
  SysUtils, Classes, DB, adsdata, adsfunc, adstable;

type
  TDmUseMonth = class(TDataModule)
    AdsQuery1: TAdsQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure pFIBDataSetUsemonthAfterOpen(DataSet: TDataSet);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FFirstYm: String;
    FLastYm: String;
    FPInterface: Pointer;
//    FmStartData: TFmEdit;
    function GetFirstYm: String;
    function GetLastYm: String;
    procedure SetFirstYm(aYm: String);
    procedure SetLastYm(aYm: String);

    procedure GetYM(Sender: TField; var Text: String; DisplayText: Boolean) ;
    function GetWorkdate:TDateTime;
    function GetMaxdate:TDateTime;
    function GetMinDate:TDateTime;
    procedure SetPInterface(const aP:Pointer);
    function GetPInterface:Pointer;
//    procedure SetMaxDate(aDate: TDateTime);
//    procedure SetLastYm(aDate: TDateTime);
//    function GetStartYM(var s:String ):Boolean;
  public
    { Public declarations }
    procedure FillItems(const aItems: TStrings; bCurrent:Boolean = False);
    function GetYMwithFullMonth(const sym:String):String;
    property LastYm: String read FLastYm;
    property FirstYm:String read fFirstYm;
    property WorkDate:tDateTime read GetWorkDate;
    property PInterface:Pointer read GetPInterface write SetPInterface;
  end;

var
  DmUseMonth: TDmUseMonth;

implementation

uses datevk, Forms, dm_mikkoads, fm_calendar;
{$R *.dfm}

procedure TDmUseMonth.DataModuleCreate(Sender: TObject);
begin

  with AdsQuery1 do
  begin
    AdsConnection := DmMikkoAds1.AdsConnection1;
    DatabaseName  := 'DmMikkoAds.AdsConnection1';
    SQL.Clear;
    SQL.Add(' SELECT * FROM usemonth ORDER BY  yearmonth');
    Open;
    if not IsEmpty then
    begin
      First;
      FFirstYm := FieldByName('yearmonth').AsString;
      Last;
      FLastYm  := FieldByName('yearmonth').AsString;
    end
    else
    begin
      FFirstYm := Copy(DTOS(Date),1,6);
      FLastYm  := Copy(DTOS(Date),1,6);
    end;
  end;

end;

procedure TDmUsemonth.FillItems(const aItems: TStrings; bCurrent:Boolean = False);
var bk: TBookMark;
    cym_current:String;
begin
  cym_current := YearMonth(now);
  aItems.Clear;
  with AdsQuery1 do
  begin
    bk := GetBookmark;
    DisableControls;
    try
      First;
      while not Eof do
      begin
        if bCurrent then
          if FieldByName('yearmonth').AsString> cym_current then
            Break;
        aItems.Add(FieldByName('yearmonth').AsString);
        Next;
      end;
    finally
      GotoBookmark(bk);
      FreeBookmark(bk);
      EnableControls;
    end;
  end;

end;


procedure TDmUsemonth.GetYM(Sender: TField; var Text: String;
  DisplayText: Boolean);
begin
  if Not VisEmpty(Sender.Value) then
    Text := GetYMwithFullMonth(Sender.Value)
  else
    Text:='';
end;

function TDmUsemonth.GetYMwithFullMonth(const sym: String): String;
var  month: word;
     year:string;
begin
  year := Copy(sym,1,4);
  month := StrToInt(Copy(sym,5,2));
  case month of
    1: Result := 'Январь' ;
    2: Result := 'Февраль';
    3: Result := 'Март'   ;
    4: Result := 'Апрель' ;
    5: Result := 'Май'    ;
    6: Result := 'Июнь'   ;
    7: Result := 'Июль'   ;
    8: Result := 'Август' ;
    9: Result := 'Сентябрь';
    10: Result := 'Октябрь';
    11: Result := 'Ноябрь' ;
    12: Result := 'Декабрь';
  end;
  Result := Padr(Result,10)+Copy(year,1,4)+'г.';
end;

procedure TDmUsemonth.pFIBDataSetUsemonthAfterOpen(DataSet: TDataSet);
begin
{  with pFIBDataSetUseMonth.FieldByName('ym') do
  begin
    DisplayLabel := 'Рабочий месяц';
    DisplayWidth := 60;
    OnGetText  := GetYM;
    ReadOnly := True;
  end;
  with pFIBDataSetUseMonth.FieldByName('closed') do
  begin
    DisplayLabel := 'Закрытие';
    DisplayWidth := 10;
    ReadOnly := True;
  end;
 }
end;

procedure TDmUseMonth.DataModuleDestroy(Sender: TObject);
begin
  if Assigned(FPInterface) then
    FPInterface := nil;
  Inherited;
end;


function TDmUseMonth.GetFirstYm: String;
begin
  Result := FFirstYm;
end;

function TDmUseMonth.GetLastYm: String;
begin
  Result := FLastYm;
end;

procedure TDmUseMonth.SetFirstYm(aYm: String);
begin
  FFirstYm := aYm;
end;

procedure TDmUseMonth.SetLastYm(aYm: String);
begin
  FLastYm := aYm;
end;

procedure TDmUseMonth.SetPInterface(const aP: Pointer);
begin
  FPInterface := aP;
end;

function TDmUsemonth.GetMaxDate: TDateTime;
begin
  Result := LastDateMonth(StrToDate('01.'+Copy(FLastYm,5,2)+'.'+Copy(FLastYm,1,4)));
end;

function TDmUsemonth.GetMinDate: TDateTime;
begin
  if FFirstYm ='' then
    Result := F_D_Month(Now,0)
  else
    Result := StrToDate('01.'+Copy(FFirstYm,5,2)+'.'+Copy(FFirstYm,1,4));
end;

function TDmUseMonth.GetPInterface: Pointer;
begin
  Result := FPInterface;
end;

function TDmUsemonth.GetWorkdate: TDateTime;
begin
  Result := DmMikkoAds1.FmCalendar.GetCurDate;
end;


end.
