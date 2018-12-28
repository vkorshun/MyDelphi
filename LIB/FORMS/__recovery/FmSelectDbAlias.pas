unit FmSelectDbAlias;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, fmhopedialogform, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TSelectDbAliasFm = class(THopeDialogFormFm)
    ListView1: TListView;
    procedure ListView1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    class function SelectAliasIndex(AList: TStringList):Integer;
  end;

var
  SelectDbAliasFm: TSelectDbAliasFm;

implementation

{$R *.dfm}

procedure TSelectDbAliasFm.ListView1DblClick(Sender: TObject);
begin
  inherited;
  ModalResult := mrOk;
end;

class function TSelectDbAliasFm.SelectAliasIndex(AList: TStringList): Integer;
var i: Integer;
begin
  with Self.Create(Application) do
  begin
    try
      ActiveControl := ListView1;
      for I := 0 to AList.Count-1 do
      begin
        ListView1.Items.Add;
        ListView1.Items[ListView1.Items.Count-1].Caption := AList[i];

      end;
      if ShowModal= mrOk then
        Result := ListView1.ItemIndex
      else
        Result := -1;
    finally
      Free;
    end;
  end;
end;

end.
