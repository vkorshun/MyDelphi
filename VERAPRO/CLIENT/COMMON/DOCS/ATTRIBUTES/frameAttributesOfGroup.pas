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
    FIdGroup: Integer;
    procedure SetIdGroup(const Value: Integer);
  public
    { Public declarations }
//    class function GetSelectedCaption(AVar: TVkVariableCollection):String;override;
    class function GetDmDoc:TDocDm;override;
    constructor Create(AOwner: TComponent; ADocDm:TDocDm);override;
    function CheckIdObject(AIdObject:TObject):Boolean;override;

    property IdGroup:Integer read FIdGroup write SetIdGroup;
  end;

var
  AttributesOfGroupFrame: TAttributesOfGroupFrame;

implementation

{$R *.dfm}
uses DmMainRtc, VariantUtils;

{ TAttributesOfGroupFrame }

function TAttributesOfGroupFrame.CheckIdObject(AIdObject: TObject): Boolean;
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
end;

constructor TAttributesOfGroupFrame.Create(AOwner: TComponent; ADocDm: TDocDm);
begin
  inherited;
  FIdGroup := -1;
  FDmAttributesOfGroup := TAttributesOfGroupDm(DocDm);
end;

class function TAttributesOfGroupFrame.GetDmDoc: TDocDm;
begin
  Result := TAttributesOfGroupDm.GetDm;
end;

procedure TAttributesOfGroupFrame.SetIdGroup(const Value: Integer);
begin
  FIdGroup := Value;
  if not Prepared then
  begin
    FDmAttributesOfGroup.IdGroup := FIdGroup;
    ConfigureEdit;
  end;
end;

{class function TAttributesOfGroupFrame.GetSelectedCaption(AVar: TVkVariableCollection): String;
begin

end;}
initialization
  RegisterClass(TAttributesOfGroupFrame);
end.
