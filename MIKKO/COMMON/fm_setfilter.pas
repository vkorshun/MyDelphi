unit fm_setfilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFmSetFilter = class(TForm)
    ListBox1: TListBox;
    procedure ListBox1DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    bSet: Boolean;
  public
    FCurrentIndex: Integer;
    Description: String;
    { Public declarations }
    procedure SetForm(Sender: TObject);
    function GetCurrentFilterKod:Integer;
  end;

var
  FmSetFilter: TFmSetFilter;

implementation

{$R *.dfm}
procedure TFmSetFilter.FormShow(Sender: TObject);
begin
  if not bSet then
    SetForm(Sender);
end;

function TFmSetFilter.GetCurrentFilterKod: Integer;
begin
   if (FCurrentIndex>-1) and (FCurrentIndex<ListBox1.Items.Count) then
     Result := Integer(ListBox1.Items.Objects[FCurrentIndex])
   else
     Result := -1;
end;

procedure TFmSetFilter.ListBox1DblClick(Sender: TObject);
begin
  FCurrentIndex := ListBox1.ItemIndex;
  ModalResult := mrOk;
end;

procedure TFmSetFilter.SetForm(Sender: TObject);
var w,h, i: Integer;
    Rect: TRect;
begin
  if FCurrentIndex > -1 then
    Exit;
  Rect := Self.GetClientRect;
  w:= ListBox1.Canvas.TextWidth(Caption)+84;
  for i:=0 to Pred(ListBox1.Count) do
  begin
    if (ListBox1.Canvas.TextWidth(ListBox1.Items[i])+84)>w then
      w:= ListBox1.Canvas.TextWidth(ListBox1.Items[i])+84;
  end;

  if ListBox1.Items.Count>0 then
  begin
    ListBox1.Canvas.TextHeight(ListBox1.Items[0]);
    h:= Rect.Bottom - Rect.Top;
//    h:= h-(ListBox1.Items.Count+3)*(ListBox1.Canvas.TextHeight(ListBox1.Items[0])+1);
    h:= h-((ListBox1.Items.Count)*ListBox1.ItemHeight+6);
    Height:= Height-h;
    if Height>400 then
      Height := 400;
    Width:= w;
    if Position <> poOwnerFormCenter then
      Position := poOwnerFormCenter;
    bSet := True;
    if ListBox1.ItemIndex=-1 then
      ListBox1.ItemIndex := 0;
  end;
end;

procedure TFmSetFilter.FormCreate(Sender: TObject);
begin
  FCurrentIndex := -1;
  bset := False;
end;

procedure TFmSetFilter.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_RETURN then
    ListBox1DblClick(self);
  if Key=VK_ESCAPE then
    ModalResult := mrNo;

end;


end.
