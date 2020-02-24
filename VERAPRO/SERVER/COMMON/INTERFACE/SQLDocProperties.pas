unit SQLDocProperties;

interface

uses
  SysUtils, Classes, rtcLog,
   DB,  variants,   System.Generics.Collections, System.Contnrs;


implementation

type
  TSQLTableProperies = class
  private
    FTableName: String;
    FLockSQL: TStringList;
    FGenId: String;
    FKeyFieldsList: TStringList;
    function GetKeyFields: String;
    function GetKeyFieldsList: TStringList;
    procedure SetTableName(const Value: String);
  public
    property TableName: String read FTableName write SetTableName;
    property GenId: String read FGenId write FGenId;
    property KeyFields: String read GetKeyFields;
    property KeyFieldsList: TStringList read GetKeyFieldsList;

  end;

{ TSQLDocProperies }

function TSQLTableProperies.GetKeyFields: String;
begin
  FKeyFieldsList.Delimiter := ';';
  Result := FKeyFieldsList.Text;
end;

function TSQLTableProperies.GetKeyFieldsList: TStringList;
begin
  Result := FKeyFieldsList;
end;

procedure TSQLTableProperies.SetTableName(const Value: String);
begin
  FTableName := Value;
end;

end.
