unit fdsqlquery;

interface

uses
  SysUtils, Classes,  IniFiles, Forms, Variants, DB, Generics.Collections, u_xmlinit, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Phys.FB, FireDAC.Phys.IBBase, datevk, vkvariable, SettingsStorage, systemconsts,
  FireDAC.Phys.FBDef;

type
  TFDSqlQuery = class(TComponent)
  private
    FCommand: TFDCommand;
    FList: TVkVariableCollection;
    FTable : TFDDatSTable;
    FIsEmpty: Boolean;
    FEof: Boolean;
    FCurrentRow : Integer;
  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    procedure Open;
    procedure Next;
    procedure Close;
    property IsEmpty:Boolean read FIsEmpty;
    property Eof:Boolean read FEof;
//    procedure Reopen(const AParams: array of variant);
    function FieldByname(const AName:String):TVkVariable;
    property Command:TFDCommand read FCommand;
  end;

implementation
uses fdac.Dmmain;


{ TFDSqlQuery }

procedure TFDSqlQuery.Close;
begin
  Command.Close;
  FIsEmpty := True;
  FEof := True;
  FList.Clear;
  FCurrentRow := -1;
end;

constructor TFDSqlQuery.Create(AOwner: TComponent);
begin
  inherited;
  FCommand :=  TFDCommand.Create(self);
  MainDm.LinkWithCommand(Command,MainDm.FDTransactionRead);
  FIsEmpty := True;
  FEof := True;
  FList := TVkVariableCollection.Create(self);
  FCurrentRow := -1;
end;

destructor TFDSqlQuery.Destroy;
begin
  FreeAndNil(FCommand);
  FreeAndNil(FList);
  inherited;
end;

function TFDSqlQuery.FieldByname(const AName: String): TVkVariable;
begin
  Result := FList.VarByName(AName);
end;

procedure TFDSqlQuery.Next;
var I: Integer;
begin
  if (Command.RowsAffected>0) then
  begin
    Inc(FCurrentRow);
    FEof := (FCurrentRow = Command.RowsAffected) or (FCurrentRow =-1);
    if not FEof then
    for I := 0 to FTable.Columns.Count-1 do
    begin
      FList.VarByName(FTable.Columns[i].name).Value := FTable.Rows.ItemsI[FCurrentRow].GetValues(FTable.Columns[i].name)
      //GetValuesList(FTable.Columns[i].name,';','');
    end;
  end;
  //else
end;

procedure TFDSqlQuery.Open;
var I: Integer;
    _v: TVkVariable;
begin
  if Assigned(FTable) then
    FreeAndNil(FTable);
  FTable := Command.Define;
  Command.FetchOptions.RowsetSize := 1;
  Command.Open();
  Command.Fetch(FTable);
  for I := 0 to FTable.Columns.Count-1 do
  begin
     _v := TVkVariable.Create(FList);
     _v.Name := FTable.Columns[i].name;
  end;
  Next;
  if Command.RowsAffected=0 then
    FEof := true;
end;


end.
