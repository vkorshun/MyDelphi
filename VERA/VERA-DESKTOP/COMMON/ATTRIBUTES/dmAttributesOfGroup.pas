unit dmAttributesOfGroup;

interface

uses
  System.SysUtils, System.Classes, fib.dmDoc, MemTableDataEh, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  DataDriverEh, MemTableEh,VkVariableBinding, VkVariableBindingDialog, frameAttributes,
   FIBDataSet, pFIBDataSet, pFIBDataSetVk,
  FIBQuery, pFIBQuery, pFIBQueryVk;

type
  TAttributesOfGroupDm = class(TDocDm)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FIdGroup: Integer;
    procedure SetIdGroup(const Value: Integer);
    procedure DoOnInitVariables(ASender: TObject; AInsert: Boolean);
  public
    { Public declarations }
    property IdGroup: Integer read FIdGroup write SetIdGroup;
    class function GetDm:TDocDm; override;
    procedure OnDocStruInitialize(Sender: TObject);
    procedure Open;
    procedure InitBeforeSelect(Sender: TObject);
  end;

var
  AttributesOfGroupDm: TAttributesOfGroupDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses fib.docbinding,fmVkDocDialog, Vcl.Controls, fib.dmmain, uDocDescription;
{ TAttributesOfGroupDm }

procedure TAttributesOfGroupDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  SqlManager.InitCommonParams('ATTRIBUTESOFGROUP','IDGROUP;IDATTRIBUTE','');
  SqlManager.SelectSQL.Add('SELECT ag.*, gr.name as group_name, a.name as attribute_name, s.name as set_name');
  SqlManager.SelectSQL.Add('FROM attributesofgroup ag ');
  SqlManager.SelectSQL.Add('LEFT OUTER JOIN objects gr ON gr.idobject=ag.idgroup');
  SqlManager.SelectSQL.Add('LEFT OUTER JOIN attributelist a ON a.idattribute=ag.idattribute');
  SqlManager.SelectSQL.Add('LEFT OUTER JOIN attributeset s ON s.idset=ag.idset');
  SqlManager.SelectSQL.Add('WHERE ag.idgroup=:idgroup');
  SqlManager.SelectSQL.Add('ORDER BY numberedit, set_name');

//  SqlManager.SelectSQL.Add('ORDER BY name');

  DocStruDescriptionList.Add('idgroup','','idgroup','idgroup',4,'',4,False,True,nil);
  DocStruDescriptionList.Add('set_name','idset','������ ���������','������ ���������',40,'',40,False,False,
    TDocMEditBoxBindingDescription.GetDocMEditBoxBindingDescription('TAttributesSetFrame',nil));
  DocStruDescriptionList.Add('attribute_name','idattribute','�������','�������',40,'',40,False,False,
    TDocMEditBoxBindingDescription.GetDocMEditBoxBindingDescription('TAttributesFrame',InitBeforeSelect));
  DocStruDescriptionList.Add('NUMBEREDIT','','���. ����� (���.)','���������� ����� ��� ���.',10,'',10,True,False,
   TBindingDescription.GetBindingDescription(TNumberMaskEditVariableBinding));
  DocStruDescriptionList.Add('NUMBERVIEW','','���. ����� (��.)','���������� ����� ��� �����.',10,'',10,True,False,
   TBindingDescription.GetBindingDescription(TNumberMaskEditVariableBinding));

  DocStruDescriptionList.Add('ISONFULLGROUP','ISONFULLGROUP','��� ���� ������','��� ���� ������',10,'',10,False,False,
   TBindingDescription.GetBindingDescription(TCheckBoxVkVariableBinding));
  DocStruDescriptionList.Add('ISHIDDEN','ISHIDDEN','�������','�������',10,'',10,False,False,
   TBindingDescription.GetBindingDescription(TCheckBoxVkVariableBinding));
//  DocStruDescriptionList.Add('ISUNIQUE','ISUNIQUE','����������','����������',10,'',10,False,False,
//   TBindingDescription.GetBindingDescription(TCheckBoxVkVariableBinding));
  DocStruDescriptionList.OnInitialize := OnDocStruInitialize;
  OnInitVariables := DoOnInitvariables;


//  DocStruDescriptionList.Add('ISUNIQUE','ISUNIQUE','����������','����������',10,'',10,False,False,
//   TCheckBoxVkVariableBinding);

//  OnInitVariables := DoOnInitvariables;
//  OnFillKeyFields := DoOnFillKeyFields;
//  OnWriteVariables := DoWritevariables;

end;

procedure TAttributesOfGroupDm.DoOnInitVariables(ASender: TObject; AInsert: Boolean);
begin
  if AInsert then
  begin
    DocVariableList.VarByName('idgroup').AsLargeInt := FIdGroup;
    DocVariableList.VarByName('idset').AsLargeInt := 0;
  end;
end;

class function TAttributesOfGroupDm.getDm: TDocDm;
begin
  Result :=  TAttributesOfGroupDm.Create(MainDm);
end;

procedure TAttributesOfGroupDm.InitBeforeSelect(Sender: TObject);
var fm: TVkDocDialogFm;
begin
  fm := TVkDocDialogFm.GetParrentForm((TWinControl(Sender).Parent));
  if (Sender= TCustomDocFmVkVariableBinding(fm.BindingList['idattribute']).DocMEditBox) then
    with TCustomDocFmVkVariableBinding(fm.BindingList['idattribute']).DocMEditBox do
    begin
      TAttributesFrame(DocFm.FrameDoc).Id := DmMain.GetTypeGroup(FIdGroup);
    end;
end;

procedure TAttributesOfGroupDm.OnDocStruInitialize(Sender: TObject);
var _Item: TVkVariableBinding;
begin
  Assert(Sender is TVkVariableBinding,'Invalid type');
  _Item := TVkVariableBinding(Sender);
{  if SameText(_Item.Name, 'set_name') then
  begin
    TCustomDocFmVkVariableBinding(_Item).DocMEditBox.Prepare('TAttributesSetFrame');
  end;
  if SameText(_Item.Name, 'attribute_name') then
  begin
    TCustomDocFmVkVariableBinding(_Item).DocMEditBox.Prepare('TAttributesFrame');
    TCustomDocFmVkVariableBinding(_Item).DocMEditBox.OnInitBeforeSelect := InitBeforeSelect;
  end; }
  if SameText(_Item.Name,'NUMBEREDIT') or SameText(_Item.Name,'NUMBERVIEW') then
    TItemNumberMaskEdit(TNumberMaskEditVariableBinding(_Item).GetControl).DecimalPlaces := 0;
end;

procedure TAttributesOfGroupDm.Open;
begin
  pFIBDataSetVkDoc.Close;
  pFIBDataSetVkDoc.SelectSQL.Clear;
  pFIBDataSetVkDoc.SelectSQL.Text := SqlManager.SelectSQL.Text;
  pFIBDataSetVkDoc.ParamByName('idgroup').AsInt64 := FIdGroup;
  MemTableEhDoc.Open;
end;

procedure TAttributesOfGroupDm.SetIdGroup(const Value: Integer);
begin
  FIdGroup := Value;
  Open;
end;

end.
