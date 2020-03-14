unit frameAttributes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, rtc.framedoc, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, ActnList, Menus,
  ImgList, DB, GridsEh, DBAxisGridsEh, DBGridEh, DBGridEhVk, ToolWin, ActnMan, ActnCtrls, ExtCtrls, ComCtrls,
  rtc.dmdoc, dmmainRtc, dmattributes, VkVariableBinding, System.Actions, VkVariable, VariantUtils, EhLibVCL;

type
  TAttributesFrame = class(TDocFrame)
  private
    { Private declarations }
    FId: Integer;
    FDmAttributes: TAttributesDm;
    procedure SetId(const Value: Integer);
  protected
    procedure FmEditOnActionUpdate(Sender: TObject);override;
  public
    { Public declarations }
    function GetCaption: String; override;
    class function GetDmDoc:TDocDm;override;
    constructor Create(AOwner: TComponent; ADocDm:TDocDm);override;
    property Id: Integer read FId write SetId;
    class function GetSelectedCaption(AVar: TVkVariableCollection):String;override;
  end;

  TAttributesFrameOAU = class(TAttributesFrame)
  public
    function GetCaption: String; override;
    constructor Create(AOwner: TComponent; ADocDm:TDocDm); override;
  end;

  TAttributesFrameOKU = class(TAttributesFrame)
  public
    function GetCaption: String; override;
    constructor Create(AOwner: TComponent; ADocDm:TDocDm); override;
  end;

var
  AttributesFrame: TAttributesFrame;

implementation

uses systemconsts;
{$R *.dfm}

{ TFrameAttributes }

constructor TAttributesFrame.Create(AOwner: TComponent; ADocDm: TDocDm);
begin
  inherited Create(AOwner, ADocDm);
  FmEdit.OnActionUpdate := FmEditOnActionUpdate;
end;

procedure TAttributesFrame.FmEditOnActionUpdate(Sender: TObject);
var _Item: TVkVariableBinding;
  _Item2: TVkVariableBinding;
  _Item3: TVkVariableBinding;
  _ItemGroup: TVkVariableBinding;
begin
  _Item := FmEdit.BindingList.FindVkVariableBinding('attributetype');
  _Item2 := FmEdit.BindingList.FindVkVariableBinding('ndec');
  _Item3 := FmEdit.BindingList.FindVkVariableBinding('nlen');
  _ItemGroup := FmEdit.BindingList.FindVkVariableBinding('idgroup');
  if Assigned(_Item)  then
  begin
    if Assigned(_Item2) then
    begin
      if (_Item.Variable.AsLargeInt>1) then
      begin
        _Item2.oControl.Enabled := False;
        _Item3.oControl.Enabled := False
      end
      else
      begin
        _Item2.oControl.Enabled := True;
        _Item3.oControl.Enabled := True
      end;
      if Assigned(_ItemGroup) and Assigned(_ItemGroup.oControl) then
        _ItemGroup.oControl.Enabled := (_Item.Variable.AsLargeInt = TA_GROUP) or
            (_Item.Variable.AsLargeInt = TA_OBJECT);

    end;

  end;
end;

{function TFrameAttributes.GetCaption: String;
begin
  Result := 'not defined'
end; }

function TAttributesFrame.GetCaption: String;
begin
  if FId>0 then
  begin
    case MainRtcDm.GetTypeGroup(FId) of
      IDGROUP_OKU: Result := 'Атрибуты объектов количественного учета';
      IDGROUP_OAU: Result := 'Атрибуты объектов аналитического учета';
    end;
  end;
end;

class function TAttributesFrame.GetDmDoc: TDocDm;
begin
  Result := TAttributesDm.GetDm;
end;

class function TAttributesFrame.GetSelectedCaption(AVar: TVkVariableCollection): String;
begin
  if Avar.Count>1 then
    inherited
  else
  begin
    if Avar.Count=1 then
      Result := IfVarEmpty(
      MainRtcDm.QueryValue('SELECT name FROM attributelist WHERE idattribute=:idattribute',[Avar.Items[0].AsLargeInt]),'')
    else
      Result := 'not defined';
  end;
end;

procedure TAttributesFrame.SetId(const Value: Integer);
begin
  FId := Value;
  GetParentForm.Caption := GetCaption;
  FDmAttributes :=  TAttributesDm(DocDm);
  if not Prepared then
  begin
    FDmAttributes.CurrentGroupId := Value;
    FDmAttributes.Open;
    ConfigureEdit;
  end;
  DataSource1.DataSet := FDmAttributes.MemTableEhDoc;
end;

{ TFrameAttributesOAK }

constructor TAttributesFrameOKU.Create(AOwner: TComponent; ADocDm: TDocDm);
begin
  inherited;
  Id := ATTRIBUTES_OKU;
end;

{ TFrameAttributesOAU }

constructor TAttributesFrameOAU.Create(AOwner: TComponent; ADocDm: TDocDm);
begin
  inherited;
  Id := ATTRIBUTES_OAU;
end;

function TAttributesFrameOAU.GetCaption: String;
begin
  Result := 'Атрибуты объектов аналитического учета';
end;

function TAttributesFrameOKU.GetCaption: String;
begin
  Result := 'Атрибуты объектов количественного учета';
end;

initialization
  RegisterClass(TAttributesFrame);
  RegisterClass(TAttributesFrameOAU);
  RegisterClass(TAttributesFrameOKU);
end.
