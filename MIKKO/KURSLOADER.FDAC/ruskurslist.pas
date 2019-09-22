unit ruskurslist;

interface

uses
  Classes, Controls, SysUtils, StdCtrls, Forms, Dialogs, Menus, Windows, Generics.Collections;

type
  PRusKursItem = ^TRusKursItem;
  TRusKursItem = record
    id: String;
    numcode: String;
    charcode:String;
    nominal:Integer;
    name:String;
    value:double;
  end;

  TRusKursList = class(TObject)
  private
    FList: TList<PRusKursItem>;
  public
    procedure Clear;
    constructor Create;
    destructor destroy;override;
    function findOnCharCode(const charCode:String):PRusKursItem;
    property Items:TList<PRusKursItem> read FList;
  end;
implementation

{ TRusKursList }

procedure TRusKursList.Clear;
var I: Integer;
begin
  for I := 0 to FList.Count-1 do
    Dispose(FList[i]);

end;

constructor TRusKursList.Create;
begin
  FList := TList<PRusKursItem>.create;
end;

destructor TRusKursList.destroy;
begin
  Clear;
  FList.Clear;
  FreeAndNil(FList);
  inherited;
end;

function TRusKursList.findOnCharCode(const charCode: String): PRusKursItem;
var p: PRusKursItem;
begin
  Result := nil;
  for p in FList do
  begin
    if SameText(p.charcode, charCode) then
    begin
      Result := p;
      break;
    end;
  end;

end;

end.
