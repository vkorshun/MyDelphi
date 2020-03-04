unit frameAttributesSet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, rtc.framedoc, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls,
  DynVarsEh, System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.ImgList, Data.DB, GridsEh, DBAxisGridsEh, DBGridEh,
  DBGridEhVk, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, VariantUtils,
  rtc.dmdoc, dmmainrtc, dmAttributesSet, VkVariable, VkVariableBinding, rtc.docbinding, EhLibVCL;

type
  TAttributesSetFrame = class(TDocFrame)
  private
    { Private declarations }
    FDmAttributesSet: TAttributesSetDm;
  public
    { Public declarations }
    function GetCaption:String;override;
    class function GetSelectedCaption(AVar: TVkVariableCollection):String;override;
    class function GetDmDoc:TDocDm;override;
    constructor Create(AOwner: TComponent; ADmDoc:TDocDm);override;
  end;

  TAttributesSetBinding = class(TCustomDocFmVkVariableBinding);

var
  AttributesSetFrame: TAttributesSetFrame;

implementation

{$R *.dfm}

{ TAttributesSetFrame }

constructor TAttributesSetFrame.Create(AOwner: TComponent; ADmDoc: TDocDm);
begin
  inherited;
  FDmAttributesSet :=  TAttributesSetDm(DocDm);
  if not Prepared then
  begin
    FDmAttributesSet.Open;
    ConfigureEdit;
  end;
  DataSource1.DataSet := FDmAttributesSet.MemTableEhDoc;
  DBGridEhVkDoc.AutoFitColWidths := True;
end;

function TAttributesSetFrame.GetCaption: String;
begin
  Result := 'Групы атрибутов';
end;

class function TAttributesSetFrame.GetDmDoc: TDocDm;
begin
  Result := TAttributesSetDm.GetDm;
end;

class function TAttributesSetFrame.GetSelectedCaption(AVar: TVkVariableCollection): String;
begin
  if Avar.Count>1 then
    inherited
  else
  begin
    if Avar.Count=1 then
      Result := IfVarEmpty(MainRtcDm.QueryValue(
        'SELECT name FROM attributeset WHERE idset=:idset',[AVar.Items[0].AsLargeInt]),'')
    else
      Result := 'not defined';
  end;
end;

initialization
  RegisterClass(TAttributesSetFrame);

end.
