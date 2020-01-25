unit vkdocinstance;

interface

uses
  SysUtils, Classes, Rtti, Db, Variants, TypInfo, dateVk,
  Dialogs, vkvariable;

type
  TDataSourceInstance = record
    nTypeInstance:Integer;
    case Integer of
      0: (DataSet: TDataSet);
      1: (VarList: TVkVariableCollection);
  end;

  TInternalFieldInstance = record
   nTypeInstance:Integer;
  case Integer of
      0: (Field: TField);
      1: (VarDoc: TVkVariable);
  end;

  PFieldInstance = ^TFieldInstance;
  TFieldInstance = record
  private
    function GetAsBoolean: Boolean;
    function GetAsDateTime: TDateTime;
    function GetAsFloat: Double;
    function GetAsCurrency: Double;
    function GetAsInteger: Integer;
    function GetAsLargeInt: Int64;
    function GetAsString: String;
    function GetValue: variant;
    procedure SetAsBoolean(const Value: Boolean);
    procedure SetAsDateTime(const Value: TDateTime);
    procedure SetAsFloat(const Value: Double);
    procedure SetAsInteger(const Value: Integer);
    procedure SetAsLargeInt(const Value: Int64);
    procedure SetAsString(const Value: String);
    procedure SetValue(const Value: variant);
  public
    Data: TInternalFieldInstance;
    property AsString:String read GetAsString write SetAsString;
    property AsFloat:Double read GetAsFloat write SetAsFloat;
    property AsInteger:Integer read GetAsInteger write SetAsInteger;
    property AsBoolean:Boolean read GetAsBoolean write SetAsBoolean;
    property AsDateTime:TDateTime read GetAsDateTime write SetAsDateTime;
    property AsLargeInt:Int64 read GetAsLargeInt write SetAsLargeInt;
    procedure SetField(aObject:TObject);
    property Value:variant read GetValue write SetValue;
  end;

  TDocInstance = class (TObject)
  private
    FDataSource: TDataSourceInstance;
    FField:TFieldInstance;
//    FAsInteger: Integer;
//    FAsLargeInt: Int64;
//    FAsBoolean: Boolean;
//    FAsDateTime: TDateTime;
//    FAsFloat: Double;
//    FAsString: String;
  public
    procedure Delete;
    procedure Edit;
    function HasField(const aFieldName:String):Boolean;
    function FieldByName(const aName:String):PFieldInstance;
    procedure Insert;
    procedure Post;
    procedure Cancel;
    procedure SetDataSourceInstance( aObject:TObject);
    property DataSouce:TDataSourceInstance read FDataSource ;//write SetDataSourceInstance;
  end;

implementation


{ TDocInstance }

procedure TDocInstance.Cancel;
begin
  if (FDataSource.nTypeInstance =0) and Assigned(FDataSource.DataSet) then
    FDataSource.DataSet.Cancel;
end;

procedure TDocInstance.Delete;
begin
  if (FDataSource.nTypeInstance =0) and Assigned(FDataSource.DataSet) then
    FDataSource.DataSet.Cancel;
end;

procedure TDocInstance.Edit;
begin
  if (FDataSource.nTypeInstance =0) and Assigned(FDataSource.DataSet) then
    FDataSource.DataSet.Edit;
end;

function TDocInstance.FieldByName(const aName: String): PFieldInstance;
begin
  if (FDataSource.nTypeInstance =0) and Assigned(FDataSource.DataSet) then
    FField.SetField( FDataSource.DataSet.FieldByName(aname))
  else
    if (FDataSource.nTypeInstance =1) and Assigned(FDataSource.VarList) then
      FField.SetField( FDataSource.VarList.VarByName(aname))
    else
      Raise Exception.Create('Instance not Assigned!');
  Result := @FField;
end;

function TDocInstance.HasField(const aFieldName: String): Boolean;
begin
  Result := False;
  if (FDataSource.nTypeInstance =0) and Assigned(FDataSource.DataSet) then
    Result := Assigned(FDataSource.DataSet.FindField(aFieldName))
  else
    if (FDataSource.nTypeInstance =1) and Assigned(FDataSource.VarList) then
      Result := FDataSource.VarList.Indexof(aFieldName)>-1;

end;

procedure TDocInstance.Insert;
begin
  if (FDataSource.nTypeInstance =0) and Assigned(FDataSource.DataSet) then
    FDataSource.DataSet.Insert;

end;

procedure TDocInstance.Post;
begin
  if Assigned(FDataSource.DataSet) then
    FDataSource.DataSet.Post;

end;


procedure TDocInstance.SetDataSourceInstance(aObject: TObject);
begin
  if aObject is TDataSet then
  begin
    FDataSource.nTypeInstance := 0;
    FDataSource.DataSet := TDataSet(aObject)
  end
  else
  begin
    if aObject is TVkVariableCollection then
    begin
      FDataSource.nTypeInstance := 1;
      FDataSource.VarList := TVkVariableCollection(aObject)
    end
    else
      Raise Exception.Create('Invalid type conversion!');
  end;
end;

{ TFieldInstance }

function TFieldInstance.GetAsBoolean: Boolean;
begin
  Result := False;
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
    Result := Data.Field.AsBoolean
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Result := Data.VarDoc.AsBoolean
end;

function TFieldInstance.GetAsCurrency: Double;
begin
  Result := 0;
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
    Result := Data.Field.AsCurrency
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Result := Data.VarDoc.AsCurrency
end;

function TFieldInstance.GetAsDateTime: TDateTime;
begin
  Result := 0;
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
    Result := Data.Field.AsDateTime
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Result := Data.VarDoc.AsDateTime

end;

function TFieldInstance.GetAsFloat: Double;
begin
  Result := 0;
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
    Result := Data.Field.AsFloat
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Result := Data.VarDoc.AsFloat
end;

function TFieldInstance.GetAsInteger: Integer;
begin
  Result := 0;
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
    Result := Data.Field.AsInteger
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Result := Data.VarDoc.AsInteger

end;

function TFieldInstance.GetAsLargeInt: Int64;
begin
  Result := 0;
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
    Result := Data.Field.AsLargeInt
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Result := Trunc(Data.VarDoc.AsCurrency *100)

end;

function TFieldInstance.GetAsString: String;
begin
  Result := '';
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
    Result := Data.Field.AsString
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Result := Data.VarDoc.AsString

end;

function TFieldInstance.GetValue: variant;
begin
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
    Result := Data.Field.Value
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Result := Data.VarDoc.Value

end;


procedure TFieldInstance.SetAsBoolean(const Value: Boolean);
begin
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
     Data.Field.AsBoolean := Value
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Data.VarDoc.AsBoolean := Value

end;

procedure TFieldInstance.SetAsDateTime(const Value: TDateTime);
begin
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
     Data.Field.AsDateTime := Value
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Data.VarDoc.AsDateTime := Value

end;

procedure TFieldInstance.SetAsFloat(const Value: Double);
begin
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
     Data.Field.AsFloat := Value
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Data.VarDoc.AsFloat := Value

end;

procedure TFieldInstance.SetAsInteger(const Value: Integer);
begin
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
     Data.Field.AsInteger := Value
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Data.VarDoc.AsInteger := Value

end;

procedure TFieldInstance.SetAsLargeInt(const Value: Int64);
begin
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
     Data.Field.AsLargeInt := Value
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Data.VarDoc.AsCurrency := Value / 100;

end;

procedure TFieldInstance.SetAsString(const Value: String);
begin
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
     Data.Field.AsString := Value
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Data.VarDoc.AsString := Value

end;

procedure TFieldInstance.SetField(aObject: TObject);
begin
  if aObject is TField then
  begin
    Data.nTypeInstance :=0;
    Data.Field := TField(aObject);
  end
  else
  if aObject is TVkVariable then
  begin
    Data.nTypeInstance :=1;
    Data.VarDoc := TVkVariable(aObject);
  end
  else
    Raise Exception.Create('Invalid field typecast');

end;

procedure TFieldInstance.SetValue(const Value: variant);
begin
  if (Data.nTypeInstance=0) and Assigned(Data.Field)  then
     Data.Field.Value := Value
  else
  if (Data.nTypeInstance=1) and Assigned(Data.VarDoc)  then
    Data.VarDoc.Value := Value

end;

end.
