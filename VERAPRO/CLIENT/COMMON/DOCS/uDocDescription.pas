unit uDocDescription;

interface

uses
  SysUtils, Classes, Rtti, Db, Variants, TypInfo, dateVk,
  Dialogs, vkvariable, Windows, Controls, VkVariableBinding, fmVkDocDialog;

type
  TBindingDescription = class(TObject)
  private
    FTypeClassItemBinding: TVkVariableBindingClass;
  public
    property TypeClassItemBinding: TVkVariableBindingClass read FTypeClassItemBinding write FTypeClassItemBinding;
    class function GetBindingDescription(ABindingClass:TVkVariableBindingClass):TBindingDescription;
  end;

  PDocStruDescriptionItem = ^RDocStruDescriptionItem;
  RDocStruDescriptionItem = record
    name: String;
    name_owner: String; // Если поле есть наименоваие объекта из owner
    GridLabel: String;
    DialogLabel: String;
    DisplayWidth: Integer;
    DisplayFormat: String;
    EditWidth: Integer;
    bEditInGrid: boolean;
    bNotInGrid: boolean;
    bNotEmpty: boolean;
    bHide: Boolean;
    BindingDescription: TBindingDescription;
    PageName: String;
    IsVariable: Boolean;
  end;

  TDocStruDescriptionList = class(TObject)
  private
    FList: TList;
    FPageCaptionList: TStringList;
    FOnInitialize: TNotifyEvent;
    procedure CheckIndexOf(AItem: PDocStruDescriptionItem);
    procedure SetOnInitialize(const Value: TNotifyEvent);
  public
    constructor Create;
    destructor Destroy;override;
    function GetDocStruDescriptionItem(AIndex:Integer):PDocStruDescriptionItem;overload;
    function GetDocStruDescriptionItem(const Aname: String):PDocStruDescriptionItem;overload;
    function IndexOfName(const Aname:String): Integer;
    procedure Add(const AName,AName_owner, AGridLabel, ADialogLabel: String; ADisplayWidth: Integer;
      const ADisplayFormat: String; AEditWidth:Integer; AEditInGrid, ANotInGrid:Boolean;
       ABindingDescription:TBindingDescription;const APageName: String = ''; AIsVariable:Boolean = false);
    procedure AddField(AField: TField);
    procedure FillFields(ADataSet: TDataSet);
//    const AName,AName_owner, AGridLabel, ADialogLabel: String; ADisplayWidth: Integer;
//      const ADisplayFormat: String; AEditWidth:Integer; AEditInGrid, ANotInGrid:Boolean;
//       ATypeClassItemBinding: TVkVariableBindingClass);
    procedure Clear;
    function Count: Integer;
    procedure Delete(AIndex:Integer);
    procedure Initialize(AObject: TObject);
    property OnInitialize: TNotifyEvent read FOnInitialize write SetOnInitialize;
    property PageCaptionList: TStringList read FPageCaptionList;
  end;

implementation

{ TDocStruDescriptionList }

procedure TDocStruDescriptionList.Add(const AName, AName_owner, AGridLabel, ADialogLabel: String;
  ADisplayWidth: Integer; const ADisplayFormat: String; AEditWidth: Integer; AEditInGrid, ANotInGrid: Boolean;
  ABindingDescription: TBindingDescription;const APageName: String = ''; AIsVariable: Boolean = false);
var
  _p: PDocStruDescriptionItem;
begin
  New(_p);
  _p.name := Aname;
  _p.name_owner := AName_owner;
  _p.GridLabel := AGridLabel;
  _p.DialogLabel := ADialogLabel;
  _p.DisplayWidth := ADisplayWidth;
  _p.DisplayFormat := ADisplayFormat;
  _p.EditWidth :=AEditWidth;
  _p.bEditInGrid := AEditInGrid;
  _p.bNotInGrid := ANotInGrid;
  _p.BindingDescription := ABindingDescription;
  _p.PageName := APageName;
  _p.IsVariable := AIsVariable;
  CheckIndexOf(_p);
  FList.Add(_p);
  if FPageCaptionList.IndexOf(_p.PageName)=-1 then
    FPageCaptionList.AddObject(_p.PageName,Pointer(1));
end;

procedure TDocStruDescriptionList.AddField(AField: TField);
var
  _p: PDocStruDescriptionItem;
begin
  if IndexOfName(AField.FieldName)=-1 then
  begin
    New(_p);
    _p.name := AField.FieldName;
    _p.name_owner := '';
    _p.GridLabel := AField.FieldName;
    _p.DialogLabel := AField.FieldName;
    _p.DisplayWidth := AField.DisplayWidth;
    _p.DisplayFormat := '';
    _p.EditWidth := AField.DisplayWidth;
    _p.bEditInGrid := False;
    _p.bNotInGrid := True;
    _p.BindingDescription := nil;
    FList.Add(_p);
  end;
end;

procedure TDocStruDescriptionList.CheckIndexOf(AItem: PDocStruDescriptionItem);
begin
  if IndexOfName(AItem.name)>-1 then
    raise Exception.CreateFmt('Dublicate name %s',[AItem.name]);
end;

procedure TDocStruDescriptionList.Clear;
begin
  while FList.Count>0 do
    Delete(0);
end;

function TDocStruDescriptionList.Count: Integer;
begin
  Result := FList.Count;
end;

constructor TDocStruDescriptionList.Create;
begin
  FList := TList.Create;
  FPageCaptionList:= TStringList.Create;
end;

procedure TDocStruDescriptionList.Delete(AIndex: Integer);
var _p: PDocStruDescriptionItem;
begin
  _p := GetDocStruDescriptionItem(AIndex);
  _p.BindingDescription.Free;
  Dispose(_p);
  FList.Delete(AIndex);
end;

destructor TDocStruDescriptionList.Destroy;
begin
  Clear;
  FreeAndNil(FList);
  FreeAndNil(FPageCaptionList);
  inherited;
end;

procedure TDocStruDescriptionList.FillFields(ADataSet: TDataSet);
var fld: TField;
begin
  for fld in ADataSet.Fields do
    AddField(fld);
end;

function TDocStruDescriptionList.GetDocStruDescriptionItem(const Aname: String): PDocStruDescriptionItem;
var I: Integer;
begin
  Result := nil;
  i := IndexOfname(Aname);
  if i>-1 then
    Result := GetDocStruDescriptionItem(i);
end;

function TDocStruDescriptionList.GetDocStruDescriptionItem(AIndex: Integer): PDocStruDescriptionItem;
begin
  Result := PDocStruDescriptionItem(FList[AIndex]);
end;

function TDocStruDescriptionList.IndexOfName(const Aname: String): Integer;
var I : Integer;
    _p: PDocStruDescriptionItem;
begin
  Result := -1;
  for I := 0 to FList.Count-1 do
  begin
    _p := GetDocStruDescriptionItem(i);
    if SameText(_p.name,Aname) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TDocStruDescriptionList.Initialize(AObject: TObject);
var _Item: TVkVariableBinding;
    i: Integer;
begin
  if Assigned(FOnInitialize) then
    if AObject is TVkVariableBindingCollection  then
    begin
      for i:=0 to TVkVariableBindingCollection(AObject).Count-1 do
      begin
        _Item := TVkVariableBindingCollection(AObject).Items[i];
        FOnInitialize(_Item);
      end;
    end
    else
      FOnInitialize(AObject);
end;

procedure TDocStruDescriptionList.SetOnInitialize(const Value: TNotifyEvent);
begin
  FOnInitialize := Value;
end;

{ TBindingDescription }

class function TBindingDescription.GetBindingDescription(
  ABindingClass: TVkVariableBindingClass): TBindingDescription;
begin
  Result := self.Create;
  Result.FTypeClassItemBinding := ABindingClass;
end;

end.
