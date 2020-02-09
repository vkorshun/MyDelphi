unit SQLTableProperties;

interface

uses
  SysUtils, Classes, rtcLog,
   DB,  variants,   System.Generics.Collections, System.Contnrs;


type
  TSQLTableProperties = class(TObject)
  private
    FTableName: String;
    FGenId: String;
    FFieldNameList: TStringList;
    FKeyFieldsList: TStringList;
    FInsertExclude: TStringList;
    function GetKeyFields: String;
    function GetKeyFieldsList: TStringList;
    procedure SetTableName(const Value: String);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;

    property TableName: String read FTableName write SetTableName;
    property GenId: String read FGenId write FGenId;
    property KeyFields: String read GetKeyFields;
    property KeyFieldsList: TStringList read GetKeyFieldsList;
    property FieldNameList: TStringList read FFieldNameList;
    property InsertExclude: TStringList read FInsertExclude;

  end;

implementation

{ TSQLDocProperies }

procedure TSQLTableProperties.Clear;
begin
  FFieldNameList.Clear;
  FKeyFieldsList.Clear;
  FInsertExclude.Clear;
end;

constructor TSQLTableProperties.Create;
begin
  FFieldNameList := TStringList.Create;
  FKeyFieldsList := TStringList.Create;
  FInsertExclude := TStringList.Create;
end;

destructor TSQLTableProperties.Destroy;
begin
  FFieldNameList.Free;
  FKeyFieldsList.Free;
  FInsertExclude.Free;
  inherited;
end;

function TSQLTableProperties.GetKeyFields: String;
begin
  FKeyFieldsList.Delimiter := ';';
  Result := FKeyFieldsList.Text;
end;

function TSQLTableProperties.GetKeyFieldsList: TStringList;
begin
  Result := FKeyFieldsList;
end;

procedure TSQLTableProperties.SetTableName(const Value: String);
begin
  FTableName := Value;
end;

end.
