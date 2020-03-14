unit frameAttributesOfGroup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, rtc.framedoc, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls,
  DynVarsEh, System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.ImgList, Data.DB, GridsEh, DBAxisGridsEh, DBGridEh,
  DBGridEhVk, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  dmAttributesOfGroup, vkvariable,rtc.dmDoc, EhLibVCL;

type
  TAttributesOfGroupFrame = class(TDocFrame)
  private
    { Private declarations }
    FDmAttributesOfGroup: TAttributesOfGroupDm;
//    FIdGroup: LargeInt;
//    FIdGroup: Integer;
    function GetIdGroup:LargeInt;
//    procedure SetIdGroup(const Value: Integer);
  public
    { Public declarations }
    class function GetSelectedCaption(AVar: TVkVariableCollection):String;override;
    class function GetDmDoc:TDocDm;override;
    constructor Create(AOwner: TComponent; ADocDm:TDocDm);override;
//    function CheckIdObject(AIdObject:TObject):Boolean;override;
    function getCaption:String; override;

    property IdGroup:LargeInt read GetIdGroup ;
  end;

var
  AttributesOfGroupFrame: TAttributesOfGroupFrame;

implementation

{$R *.dfm}
uses DmMainRtc, VariantUtils;

{ TAttributesOfGroupFrame }

{*function TAttributesOfGroupFrame.CheckIdObject(AIdObject: TObject): Boolean;
var _var: TVkVariable;
begin
  _var := TVkVariable(AIdObject);
  Result := IdGroup = _var.AsLargeInt;
  if not Result then
  begin
    IdGroup := _var.AsLargeInt;
    GetParentForm.Caption := Format('Атрибуты группы (%s)',[
    ifVarEmpty(MainRtcDm.QueryValue('SELECT name FROM objects WHERE idobject=:idobject',
   [IdGroup]),'')]);
  end;
end;*}

constructor TAttributesOfGroupFrame.Create(AOwner: TComponent; ADocDm: TDocDm);
begin
  inherited;
  //FIdGroup := ADocDm;
  FDmAttributesOfGroup := TAttributesOfGroupDm(DocDm);
end;

function TAttributesOfGroupFrame.getCaption: String;
begin
  Result := Format('Атрибуты группы (%s)',[
    ifVarEmpty(MainRtcDm.QueryValue('SELECT name FROM objects WHERE idobject=:idobject',
   [IdGroup]),'')]);
end;

class function TAttributesOfGroupFrame.GetDmDoc: TDocDm;
begin
  Result := TAttributesOfGroupDm.GetDm;
end;

function TAttributesOfGroupFrame.GetIdGroup: LargeInt;
begin
  if Assigned(FDmAttributesOfGroup) then
    Result := FDmAttributesOfGroup.IdGroup
  else
    Result := -1;
end;

{procedure TAttributesOfGroupFrame.SetIdGroup(const Value: Integer);
begin
  FIdGroup := Value;
  if not Prepared then
  begin
    FDmAttributesOfGroup.IdGroup := FIdGroup;
    ConfigureEdit;
  end;
end;}

class function TAttributesOfGroupFrame.GetSelectedCaption(AVar: TVkVariableCollection): String;
begin
  Result := 'Select attribute';
end;
initialization
  RegisterClass(TAttributesOfGroupFrame);
end.
