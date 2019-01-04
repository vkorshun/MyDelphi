unit dmAttributesSet;

interface

uses
  System.SysUtils, System.Classes, fDAC.dmDoc, MemTableDataEh, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  DataDriverEh, MemTableEh, VkVariableBinding, VkVariableBindingDialog;

type
  TAttributesSetDm = class(TDocDm)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    procedure DoWriteVariables(Sender: TObject; AInsert: Boolean);
  public
    { Public declarations }
    class function GetDm: TDocDm;override;
    procedure Open;
  end;

var
  AttributesSetDm: TAttributesSetDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
uses fdac.dmmain, uLog, uDocDescription;

{$R *.dfm}

procedure TAttributesSetDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  SqlManager.InitCommonParams('ATTRIBUTESET','IDSET','IDATTRIBUTESET');
  SqlManager.SelectSQL.Add('SELECT idset, name ');
  SqlManager.SelectSQL.Add('FROM attributeset ');
  SqlManager.SelectSQL.Add('WHERE idset>=0');
  SqlManager.SelectSQL.Add('ORDER BY name');

  DocStruDescriptionList.Add('idset','','ID','ID',4,'',4,False,True,nil);
  DocStruDescriptionList.Add('name','','Наименование','Наименование',60,'',60,True,False,
    TBindingDescription.GetBindingDescription(TEditVkVariableBinding));
  DocStruDescriptionList.GetDocStruDescriptionItem('name').bNotEmpty := True;
//  OnInitVariables := DoOnInitvariables;
//  OnFillKeyFields := DoOnFillKeyFields;
  OnWriteVariables := DoWritevariables;

end;

procedure TAttributesSetDm.DoWriteVariables(Sender: TObject; AInsert: Boolean);
begin
  if AInsert then
    DocVariableList.VarByName('idset').AsInteger :=  DmMain.GenId('IDATTRIBUTESET');
end;

class function TAttributesSetDm.GetDm: TDocDm;
begin
  Result :=  TAttributesSetDm.Create(MainDm);
end;

procedure TAttributesSetDm.Open;
begin
  FDQueryDoc.Close;
  FDQueryDoc.SQL.Clear;
  FDQueryDoc.SQL.Text := SqlManager.SelectSQL.Text;
  MemTableEhDoc.Open;
end;

end.
