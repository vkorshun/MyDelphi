unit fm_calendar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, DateUtils;

type
  TFmCalendar = class(TForm)
    BtnOk: TButton;
    BtnCancel: TButton;
    MonthCalendar: TMonthCalendar;
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure MonthCalendarKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FPInterface: Pointer;
    CurrentDate: TDate;
    function GetYm:String;
    procedure MoveFirst;
    procedure MoveLast;
    procedure MoveNext;
    procedure MovePrior;
    function GetPInterface:Pointer;
    procedure SetPInterface(const aP:Pointer);
  public
    { Public declarations }
    function GetCurDate:TDateTime;
    function GetDataBegin:TDateTime;
    function GetDataEnd:TDateTime;
    property CurrentYm:String read GetYm;
    property DataBegin:TDateTime read GetDataBegin;
    property DataEnd:TDateTime read GetDataEnd;
    property PInterface:Pointer read GetPInterface write SetPInterface;
    procedure ShowCalendar;
  end;

var
  FmCalendar: TFmCalendar;

implementation
uses  datevk, dm_mikkoads;
{$R *.dfm}


procedure TFmCalendar.FormCreate(Sender: TObject);
begin
  Caption := 'Календарь';
  BtnOk.Caption := 'Ok';
  BtnCancel.Caption := 'Отменить';
{  MonthCalendar.MaxDate := DmMikkoAds.GetMaxDate;
  MonthCalendar.MinDate := DmMikkoAds.GetMinDate;
  if Now > DmMikkoAds.GetMaxDate then
    MonthCalendar.Date := DmMikkoAds.GetMaxDate
  else
    MonthCalendar.Date := Now;
 }
end;

procedure TFmCalendar.BtnOkClick(Sender: TObject);
begin
  CurrentDate := MonthCalendar.Date;
  ModalResult := MrOk;
//  PostMessage(Application.MainFormHandle,WM_CALENDAR,0,0);
end;

procedure TFmCalendar.BtnCancelClick(Sender: TObject);
begin
  MonthCalendar.Date := CurrentDate;
  ModalResult := MrCancel;
end;

procedure TFmCalendar.ShowCalendar;
var i: Integer;
begin
  CurrentDate:=MonthCalendar.Date;
  if ShowModal=MrOk then
  begin
{    for i:=0 to Pred(Screen.CustomFormCount) do
    begin
      if Screen.CustomForms[i] is TFmHopeChild then
        with TFmHopeChild(Screen.CustomForms[i]) do
        begin
          //if Assigned(OnChangeWorkDate) then
          //  OnChangeWorkDate(Self);
          PostMessage(Handle,WM_CALENDARCHANGED,0,0);
        end
    end; }
  end;
end;

function TFmCalendar.GetYm: String;
begin
  Result := Copy(Dtos(MonthCalendar.Date),1,6);
end;

procedure TFmCalendar.MonthCalendarKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift=[] then
  begin
    case Key of
      VK_PRIOR: begin
           MovePrior;
           Key:=0;
           end;
      VK_NEXT:  MoveNext;
      VK_HOME:  MoveFirst;
      VK_END:   MoveLast;
    end;
  end;

end;

procedure TFmCalendar.MoveFirst;
var d: word;
begin
  d:= DaysInMonth(MonthCalendar.MinDate);
  if d<= DayOf(MonthCalendar.date) then
    MonthCalendar.date := MonthCalendar.MinDate
  else
    MonthCalendar.date := MonthCalendar.MinDate
//    +(DayOf(MonthCalendar.date)-1);

end;

procedure TFmCalendar.MoveLast;
var d: word;
begin
  d:= DaysInMonth(MonthCalendar.MaxDate);
  if d<= DayOf(MonthCalendar.date) then
    MonthCalendar.date := MonthCalendar.MaxDate
  else
    MonthCalendar.date := MonthCalendar.MaxDate-(d- DayOf(MonthCalendar.date));

end;

procedure TFmCalendar.MoveNext;
var m: word;
begin
  m:= MonthOf(MonthCalendar.Date);
  MonthCalendar.Date:=MonthCalendar.Date+DaysInMonth(m);
end;

procedure TFmCalendar.MovePrior;
var m: word;
begin
  m:= MonthOf(MonthCalendar.Date);
  case m of
    1: MonthCalendar.Date:=MonthCalendar.Date-DaysInMonth(12);
    else
     MonthCalendar.Date:=MonthCalendar.Date-DaysInMonth(m-1);
  end;
end;

function TFmCalendar.GetCurDate: TDateTime;
begin
  Result := MonthCalendar.Date;
end;

function TFmCalendar.GetDataBegin: TDateTime;
begin
  Result := F_D_Month(MonthCalendar.Date,0)
end;

function TFmCalendar.GetDataEnd: TDateTime;
begin
  Result := F_D_Month(MonthCalendar.Date,1)-1;
end;

function TFmCalendar.GetPInterface:Pointer;
begin
  Result := FPInterface;
end;

procedure TFmCalendar.SetPInterface(const aP:Pointer);
begin
  FPInterface := aP;
end;



end.
