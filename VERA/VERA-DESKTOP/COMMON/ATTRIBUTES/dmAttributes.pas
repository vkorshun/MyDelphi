unit dmAttributes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, fib.dmdoc, MemTableDataEh, Db, DataDriverEh, MemTableEh,  FireDAC.Comp.Client,
  VkVariable, VkVariableBinding, VkVariableBindingDialog, uDocDescription, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, pFIBquery, pFIBdataset,
  pFIBdatasetVk, FIBDataSet, FIBQuery, pFIBQueryVk;

type
  TAttributesDm = class(TDocDm)
    procedure DataModuleCreate(Sender: TObject);
    procedure MemTableEhDocAfterOpen(DataSet: TDataSet);
    procedure MemTableEhDocBeforePost(DataSet: TDataSet);
  private
    { Private declarations }
    procedure LocalOnChangeVariable(Sender: TObject);
  protected
    procedure DoOnInitVariables(ASender: TObject; AInsert: Boolean);
    procedure DoStoreVariables(Sender: TObject; AStatus: TUpdateStatus);
  public
    { Public declarations }
    class function GetDm: TDocDm;override;
    procedure Open(AId: LargeInt);
    procedure OnDocStruInitialize(Sender: TObject);
    procedure DoOnFillKeyFields(Sender: TObject);
    function ValidFmEditItems(Sender:TObject):Boolean;override;
  end;

var
  AttributesDm: TAttributesDm;

implementation

uses fib.dmmain, uLog, systemconsts, fib.docBinding, frameObjectsGr;

{$R *.dfm}

{ TDmAttributes }

procedure TAttributesDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  SqlManager.InitCommonParams('ATTRIBUTELIST','IDATTRIBUTE','GEN_ATTRIBUTELIST_ID');
  SqlManager.SelectSQL.Add('SELECT al.*,  attl.name as typename ');
  SqlManager.SelectSQL.Add('FROM attributelist al');
  SqlManager.SelectSQL.Add('LEFT OUTER JOIN  attributetypelist attl ON attl.idtypeattribute = al.attributetype');
  SqlManager.SelectSQL.Add('WHERE al.id=:id');

  DocStruDescriptionList.Add('id','','ID','ID',4,'',4,False,True,nil);
  DocStruDescriptionList.Add('idattribute','','IDATTRIBUTE','IDATTRIBUTE',4,'',4,False,True,nil);
  DocStruDescriptionList.Add('name','','Наименование','Наименование',60,'',60,True,False,
    TBindingDescription.GetBindingDescription(TEditVkVariableBinding));
  DocStruDescriptionList.Add('attributetype','','Тип','Тип',40,'',40,False,True,
    TBindingDescription.GetBindingDescription(TComboBoxVkVariableBinding));
  DocStruDescriptionList.Add('typename','','Тип','Тип',40,'',40,True,False,
    nil);
  DocStruDescriptionList.Add('nlen','','Размер','Размер',10,'',10,True,False,
    TBindingDescription.GetBindingDescription(TEditVkVariableBinding));
  DocStruDescriptionList.Add('ndec','','Точность','Точность',10,'',10,True,False,
    TBindingDescription.GetBindingDescription(TEditVkVariableBinding));
  DocStruDescriptionList.Add('idgroup','','Группа','Группа',60,'',60,True,False,
    TDocMEditBoxBindingDescription.GetDocMEditBoxBindingDescription('TObjectsGrFrame',nil));
  DocStruDescriptionList.Add('isunique','','Уник.','Признак уникальности',10,'',10,True,False,
    TBindingDescription.GetBindingDescription(TCheckBoxVkVariableBinding));
  DocStruDescriptionList.Add('notempty','','Зап.','Обязательно к заполнению',10,'',10,True,False,
    TBindingDescription.GetBindingDescription(TCheckBoxVkVariableBinding));
  DocStruDescriptionList.OnInitialize := OnDocStruInitialize;
  DocStruDescriptionList.GetDocStruDescriptionItem('name').bNotEmpty := True;
  DocStruDescriptionList.GetDocStruDescriptionItem('attributetype').bNotEmpty := True;
  DocStruDescriptionList.GetDocStruDescriptionItem('nlen').bNotEmpty := True;
  DocValidator.NotNullList.Add('name');
  DocValidator.NotNullList.Add('attributetype');
  OnInitVariables := DoOnInitvariables;
//  OnFillKeyFields := DoOnFillKeyFields;
  OnStoreVariables := DoStorevariables;
//  DocVariableList.VarByName('ctype').OnChangeVariable := LocalOnChangeVariable;
end;

procedure TAttributesDm.DoOnFillKeyFields(Sender: TObject);
begin
  if DocvariableList.VarByName('idattribute').AsLargeInt=0 then
    DocvariableList.VarByName('idattribute').AslargeInt := DmMain.GenId('IDATTRIBUTE');
end;

procedure TAttributesDm.DoOnInitVariables(ASender: TObject; AInsert: Boolean);
begin
  if AInsert then
  begin
    DocVariableList.VarByName('id').AsLargeInt := pFIBDataSetVkDoc.ParamByName('ID').AsInt64;
    DocVariableList.VarByName('isunique').AsBoolean := False;
    DocVariableList.VarByName('notempty').AsBoolean := False;
    DocVariableList.VarByName('idgroup').AsLargeInt := 0;
    DocVariableList.VarByName('attributetype').AsLargeInt := 0;
  end
end;

procedure TAttributesDm.DoStoreVariables(Sender: TObject; AStatus: TUpdateStatus);
begin
  if AStatus= usInserted then
  begin
    DocVariableList.VarByName('IDATTRIBUTE').AsLargeInt := MainDm.GenId('IDATTRIBUTE');
  end;
end;

class function TAttributesDm.GetDm: TDocDm;
begin
  Result := TAttributesDm.Create(MainDm);
end;

procedure TAttributesDm.LocalOnChangeVariable(Sender: TObject);
begin
  if Sender = DocVariableList.VarByName('attributetype') then
  begin
    case DocVariableList.VarByName('attributetype').AsLargeInt of
      TA_STRING :
        begin
          DocvariableList.VarByName('nlen').AsInteger := 10;
          DocvariableList.VarByName('ndec').AsInteger := 0;
        end;
      TA_NUMERIC :
        begin
          DocvariableList.VarByName('nlen').AsInteger := 15;
          DocvariableList.VarByName('ndec').AsInteger := 2;
        end;
      else
        DocvariableList.VarByName('nlen').AsInteger := 4;
        DocvariableList.VarByName('ndec').AsInteger := 0;
    end;
  end;
end;

procedure TAttributesDm.MemTableEhDocAfterOpen(DataSet: TDataSet);
begin
  inherited;
  DocVariableList.VarByName('attributetype').OnChangeVariable := LocalOnChangeVariable;
end;

procedure TAttributesDm.MemTableEhDocBeforePost(DataSet: TDataSet);
begin
  if DataSet.FieldByName('ID').AsLargeInt=0 then
  begin
    DataSet.FieldByName('ID').ReadOnly := False;
    DataSet.FieldByName('ID').AslargeInt := MainDm.GenId('IDATTRIBUTE');
  end;
  inherited;
end;

procedure TAttributesDm.OnDocStruInitialize(Sender: TObject);
var _Item: TVkVariableBinding;
    _proc: TOnRequest;
begin
{  _Item := DocStruDescriptionList.GetDocStruDescriptionItem(DocStruDescriptionList.IndexOfName('ctype'));
  _Item. }
  Assert(Sender is TVkVariableBinding,'Invalid type');
  _Item := TVkVariableBinding(Sender);
  if SameText(_Item.Name, 'attributetype') then
  begin
    _proc := procedure (AQuery: TpFIBQuery)
    begin
       while not AQuery.Eof  do
       begin
         TItemComboBox(_Item.oControl).Items.Add(AQuery.FieldByName('name').AsString);
         AQuery.Next;
       end;
    end;
    DmMain.DoRequest(' SELECT * FROM attributetypelist ORDER BY idtypeattribute',[],nil,_proc);
  end;

  if SameText(_Item.Name, 'idgroup') then
  begin
    TObjectsGrFrame(TCustomDocFmVkVariableBinding(_Item).DocMEditBox.DocFm.FrameDoc).RootIdGroup :=
      pFIBDataSetVkDoc.ParamByName('ID').AsInt64;
  end;
end;

procedure TAttributesDm.Open(AId: largeInt);
begin
  pFIBDataSetVkDoc.Close;
  pFIBDataSetVkDoc.SelectSQL.Clear;
  pFIBDataSetVkDoc.SelectSQL.Text := SqlManager.SelectSQL.Text;
  try
    pFIBDataSetVkDoc.ParamByName('id').AsInt64 := AId;
    MemTableEhDoc.Open;
  except
    on E: Exception do
    begin
      LogMessage(' DmAttributes:'+#13#10+E.Message+#13#10+pFIBDataSetVkDoc.SelectSQL.Text);
    end;
  end;
end;

function TAttributesDm.ValidFmEditItems(Sender: TObject): Boolean;
var _Items: TVkVariableBindingCollection;
begin
{  _Items :=
  if True then}
  Result := Inherited;

end;

end.
