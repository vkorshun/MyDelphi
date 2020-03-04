unit dmAttributesSet;

interface

uses
  System.SysUtils, System.Classes, rtc.dmDoc, MemTableDataEh, Data.DB,
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
uses dmmainRtc, uLog, uDocDescription;

{$R *.dfm}

procedure TAttributesSetDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  InitClientSqlManager('ATTRIBUTESET');
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
    DocVariableList.VarByName('idset').AsInteger :=  MainRtcDm.Gen_Id('IDATTRIBUTESET');
end;

class function TAttributesSetDm.GetDm: TDocDm;
begin
  Result :=  TAttributesSetDm.Create(MainRtcDm);
end;

procedure TAttributesSetDm.Open;
begin
  FRtcQueryDataSet.Close;
  FRtcQueryDataSet.SQL.Clear;
  FRtcQueryDataSet.SQL.Text := SqlManager.SelectSQL.Text;
  FRtcQueryDataSet.Open;
end;

end.
