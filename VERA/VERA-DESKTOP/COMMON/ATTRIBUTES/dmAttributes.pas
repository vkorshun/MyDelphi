unit dmAttributes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, fdac.dmdoc, MemTableDataEh, Db, DataDriverEh, MemTableEh,  FireDAC.Comp.Client,
  VkVariable, VkVariableBinding, VkVariableBindingDialog, uDocDescription, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

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

uses fdac.dmmain, uLog, systemconsts, fdac.docBinding, frameObjectsGr;

{$R *.dfm}

{ TDmAttributes }

procedure TAttributesDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  SqlManager.InitCommonParams('ATTRIBUTELIST','IDATTRIBUTE','GEN_ATTRIBUTELIST_ID');
  SqlManager.SelectSQL.Add('SELECT al.*,  attl.name as typename, obj.name as groupname ');
  SqlManager.SelectSQL.Add('FROM attributelist al');
  SqlManager.SelectSQL.Add('LEFT OUTER JOIN  attributetypelist attl ON attl.idtypeattribute = al.attributetype');
  SqlManager.SelectSQL.Add('LEFT OUTER JOIN  objects obj ON obj.idobject = al.idgroup');
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
  DocStruDescriptionList.Add('groupname','idgroup','Группа','Группа',60,'',60,True,False,
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
    DocVariableList.VarByName('id').AsLargeInt := FDQueryDoc.ParamByName('ID').AsLargeInt;
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
    if DocVariableList.VarByName('attributetype').InitValue = DocVariableList.VarByName('attributetype').AsLargeInt then
    begin
      DocvariableList.VarByName('nlen').AsInteger := DocvariableList.VarByName('nlen').InitValue;
      DocvariableList.VarByName('ndec').AsInteger := DocvariableList.VarByName('ndec').InitValue;
    end
    else
    begin
      case DocVariableList.VarByName('attributetype').AsLargeInt of
        TA_STRING :
          begin
            DocvariableList.VarByName('nlen').AsInteger := 100;
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
    _proc := procedure (AQuery: TFDQuery)
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
      FDQueryDoc.ParamByName('ID').AsLargeInt;
  end;
end;

procedure TAttributesDm.Open(AId: largeInt);
begin
  FDQueryDoc.Close;
  FDQueryDoc.SQL.Clear;
  FDQueryDoc.SQL.Text := SqlManager.SelectSQL.Text;
  try
    FDQueryDoc.ParamByName('id').AsLargeInt := AId;
    MemTableEhDoc.Open;
  except
    on E: Exception do
    begin
      LogMessage(' DmAttributes:'+#13#10+E.Message+#13#10+FDQueryDoc.SQL.Text);
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
