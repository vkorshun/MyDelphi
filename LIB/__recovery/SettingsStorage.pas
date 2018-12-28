unit SettingsStorage;

interface

uses
  Classes, SysUtils, Variants, VariantUtils, vkvariable, inifiles, System.Generics.Collections;

type

  TSettingsStorageItem = class(TObject)
  private
    FName: String;
    FItems: TVkVariableCollection;
    procedure SetItems(const Value: TVkVariableCollection);
    procedure SetName(const Value: String);
  public
    property Name: String read FName write SetName;
    property Items: TVkVariableCollection read Fitems write SetItems;
    constructor Create(AName: String);
    destructor Destroy;override;
    function getItemValues: TStringList;
  end;

  TSettingsStorage = class(TObject)
  private
    FIni: TIniFile;
    FItems: TList<TSettingsStorageItem>;
    IsNeedToSave: boolean;
    function GetSectionIndex(const ASectionName: String):Integer;
  public
    constructor Create(AName: String);
    destructor Destroy;override;
    procedure Read;
    procedure Save;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure DeleteSection(const ASectionName:String);
    procedure DeleteVariable(const ASectionName, AVarName:String);
    procedure WriteVariable(const ASectionName, AVarName: String; Value: Variant);
    function GetSection(const SectionName: String; bCreate: boolean = false): TSettingsStorageItem;
    function GetVariable(const SectionName: String;const VarName: String; const DefValue: Variant):TVkVariable;
    class function GetDefaultStorageName:String;
  end;



implementation

{ TSettingsStorageIten }

constructor TSettingsStorageItem.Create(AName: String);
begin
  FItems := TVkVariableCollection.Create(nil);
  Name := Aname;
end;

destructor TSettingsStorageItem.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TSettingsStorageItem.getItemValues: TStringList;
var i: Integer;
begin
   Result := TStringList.Create;
   for i:=0 to items.Count-1 do
     Result.Add(self.Items.Items[i].AsString);
end;

procedure TSettingsStorageItem.SetItems(const Value: TVkVariableCollection);
begin
  FItems := Value;
end;

procedure TSettingsStorageItem.SetName(const Value: String);
begin
  if Value.IsEmpty then
    raise Exception.Create('Empty section name');
  FName := Value;
end;

{ TSettingsStorage }

procedure TSettingsStorage.Clear;
begin
  while FItems.Count>0 do Delete(0);
end;

constructor TSettingsStorage.Create(AName: String);
begin
  FIni := TIniFile.Create(AName);
  FItems := TList<TSettingsStorageItem>.Create;
end;

procedure TSettingsStorage.Delete(Index: Integer);
begin
  FItems[Index].Free;
  FItems.Delete(Index);
end;

procedure TSettingsStorage.DeleteSection(const ASectionName: String);
var _index: Integer;
    _sections: TStringList;
begin
  _sections := TStringList.Create;
  try
    FIni.ReadSections(_sections);
    if _sections.IndexOf(ASectionName)>-1 then
      FIni.EraseSection(ASectionName);
  finally
    _sections.Free;
  end;

  _index := GetSectionIndex(ASectionName);
  if _index > -1 then
  begin
    Delete(_index);
  end;
end;

procedure TSettingsStorage.DeleteVariable(const ASectionName, AVarName: String);
var _item: TSettingsStorageItem;
begin
  FIni.DeleteKey(ASectionName, AVarName);
  _item := GetSection(ASectionName);
  if Assigned(_item) then
     _item.Items.DeleteVkVariable(AVarName);
end;

destructor TSettingsStorage.Destroy;
begin
  if (IsNeedToSave) then
    Save;
  FIni.Free;
  Clear;
  FItems.Free;
  Inherited;
end;

class function TSettingsStorage.GetDefaultStorageName: String;
begin
  Result := ChangeFileExt(ParamStr(0),'.ini');
end;

function TSettingsStorage.GetSection(const SectionName: String; bCreate: boolean = false): TSettingsStorageItem;
var _item: TSettingsStorageItem;
begin
  Result := nil;
  for _item in FItems do
  begin
    if SameText(_item.Name,SectionName) then
    begin
      Result := _item;
      Break;
    end;
  end;
  if not Assigned(Result) and bCreate  then
  begin
    Result := TSettingsStorageItem.Create(SectionName);
    FItems.Add(Result);
  end;
end;

function TSettingsStorage.GetSectionIndex(const ASectionName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FItems.Count-1 do
  begin
    if SameText(FItems[i].Name,ASectionName) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TSettingsStorage.GetVariable(const SectionName, VarName: String;const DefValue: Variant): TVkVariable;
var _item: TSettingsStorageItem;
begin
  _item := GetSection(SectionName);
  if Assigned(_item)  then
  begin
    Result := _item.Items.FindVkVariable(VarName);
    if not Assigned(Result) then
    begin
      Result := _item.Items.CreateVkVariable(VarName,DefValue);
    end;
  end
  else
  begin
    _item := TSettingsStorageItem.Create(SectionName);
    _item.Items.AddItem(VarName, DefValue);
    FItems.Add(_item);
    Result := _item.Items.FindVkVariable(VarName);
    IsNeedToSave := true;
  end;
end;

procedure TSettingsStorage.Read;
var Sections: TStringList;
    VarList: TStringList;
    s, v: String;
    _item: TSettingsStorageItem;
begin
  Sections := TStringList.Create;
  VarList := TStringList.Create;
  try
    FIni.ReadSections(Sections);
    for s in Sections do
    begin
      FIni.ReadSection(s,VarList);
      _item := TSettingsStorageItem.Create(s);
      FItems.Add(_item);
      for v in VarList do
        _item.Items.AddItem(v,FIni.ReadString(s,v,''));
    end;
  finally
    VarList.Free;
    Sections.Free;
  end;
end;

procedure TSettingsStorage.Save;
var
  _item: TSettingsStorageItem;
  _v: TVkVariable;
  i: Integer;
begin
  for _item in FItems do
  begin
    for i:=0 to _item.Items.Count-1 do
    begin
      _v := _item.Items.Items[i];
      FIni.WriteString(_item.Name,_v.Name, _v.AsString);
    end;
  end;
  IsNeedToSave := false;
end;

procedure TSettingsStorage.WriteVariable(const ASectionName, AVarName: String; Value: Variant);
var v: TVkVariable;
    _Section: TSettingsStorageItem;
begin
  _Section := GetSection(ASectionName);
  if Assigned(_Section) then
  begin
    v := GetVariable(ASectionName, AVarName, Value);
    if not Assigned(v) then
      _section.Items.AddItem(AVarName, Value)
    else
      v.Value := Value;
  end
  else
  begin
    _Section := TSettingsStorageItem.Create(ASectionName);
    _Section.Items.AddItem(AVarName, Value);
    FItems.Add(_Section);
  end;
end;

end.
