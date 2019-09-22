unit ruskursxml;

interface

uses
  Classes, Controls, SysUtils, StdCtrls, Forms, Dialogs, Menus, Windows,
  // NativeXml component
  NativeXml, sdStringTable, sdDebug, RusKursList;

type

  TRusKursXml = class
  private
    FXml: TNativeXml;
    FDate: TDateTime;
    FList: TRusKursList;
    procedure parseXml;
  public
    constructor create(const text:String);
    destructor destroy;override;
    procedure SaveToFile(const fileName: String);
    function GetData: TDateTime;


    property Xml: TNativeXml read FXml;
    property List:TRusKursList read FList;

  end;

implementation



{ TRusKursXml }

constructor TRusKursXml.create;
var stream: TMemoryStream;
begin
  FList := TRusKursList.Create;
  FXml := TNativeXml.Create(nil);
  FXml.ReadFromString(text);
  parseXml;
  {stream := TmemoryStream.Create;
  try
    stream.SetSize(length(text)+1);
    Move(text[1],stream.Memory^, length(text));
    stream.Position := 0;
    FXml.LoadFromStream(stream);
  finally
    stream.Free;
  end;}
end;

destructor TRusKursXml.destroy;
begin
  FreeAndNil(FXml);
  FreeAndNil(FList);
  inherited;
end;

function TRusKursXml.GetData: TDateTime;
begin
  Result := fDate;
end;

procedure TRusKursXml.parseXml;
var node: TsdElement;
    p: PRusKursItem;

  procedure parseElement(el: TsdElement );
  var
    curEl:TsdElement;
    i:Integer;

    function getAttribute(el: TsdElement;const name: String):String;
    var i: Integer;
        A: TsdAttribute;
    begin
      Result := '';
      for i := 0 to el.AttributeCount - 1 do
      begin
        A := el.Attributes[i];
        if SameText(A.Name,name) then
        begin
          Result := A.Value;
        end;
      end;
    end;
  begin
      if (SameText(el.Name,'ValCurs')) then
         FDate := StrToDate(getAttribute(el,'Date'));

      if (SameText(el.Name,'Valute')) then
      begin
        New(p);
        p.id := getAttribute(el,'ID');
      end;

      if (SameText(el.Name,'NumCode')) then
        p.numcode := el.Value
      else
      if (SameText(el.Name,'CharCode')) then
        p.charcode := el.Value
      else
      if (SameText(el.Name,'Nominal')) then
        p.nominal := StrToInt(el.Value)
      else
      if (SameText(el.Name,'Name')) then
        p.name := el.Value
      else
      if (SameText(el.Name,'Value')) then
      begin
        p.value := StrToFloat(el.Value);
        FList.Items.Add(p);
      end;

      if el.ElementCount>0 then
      begin
        curEl :=  el;
        for i:=0 to curEl.ElementCount-1 do
        begin
          parseElement(curEl.Elements[i])
        end;
      end
      else
      begin
//        sb.Append('"'+StringReplace(el.Value,'"','\"',[rfReplaceAll])+'"]')
      end;
   end;

begin
  if Assigned(FXml.Root) then
    parseElement(FXml.Root);
end;

procedure TRusKursXml.SaveToFile(const fileName: String);
begin
  FXml.SaveToFile(fileName);
end;

end.
