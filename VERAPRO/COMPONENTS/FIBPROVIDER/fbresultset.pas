unit fbresultset;

interface

uses System.SysUtils, System.Variants, System.Classes, IB;

type
  TFBResultSet = class(tcomponent, IResultset)
  private
    FResultSet : IResultSet  ;
  public
    property ResultSet:IResultSet read FResultSet implements IResultSet;
    constructor create(AOwner: TComponent; rs: IResultSet);
    destructor destroy;
    function AsString(const idx:String):String;
  end;

implementation

{ TFBResultSet }

function TFBResultSet.AsString(const idx: String): String;
begin
  Result := UTF8String(FResultSet.ByName(idx).AsString);
end;

constructor TFBResultSet.create(AOwner: TComponent; rs: IResultSet);
begin
  FResultSet := rs;
end;

destructor TFBResultSet.destroy;
begin
  FResultSet := nil;
end;

end.
