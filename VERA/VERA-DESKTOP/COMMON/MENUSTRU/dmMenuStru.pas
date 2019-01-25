unit dmMenuStru;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, fdac.dmdoc, MemTableDataEh, Db, DataDriverEh, MemTableEh,  FireDAC.Comp.Client,
  VkVariable, VkVariableBinding, VkVariableBindingDialog, uDocDescription, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.StdCtrls;

type
  TMenuStruDm = class(TDocDm)
    procedure DataModuleCreate(Sender: TObject);
    procedure MemTableEhDocAfterOpen(DataSet: TDataSet);
    procedure MemTableEhDocBeforePost(DataSet: TDataSet);
  private
    { Private declarations }
    procedure LocalOnChangeVariable(Sender: TObject);
    procedure MyOnGetText(Field:TField;var text:String; DisplayText: Boolean);
  protected
    procedure DoOnInitVariables(ASender: TObject; AInsert: Boolean);
    procedure DoStoreVariables(Sender: TObject; AStatus: TUpdateStatus);
    procedure DoDocStruInitialize(Sender:TObject);
  public
    { Public declarations }
    class function GetDm: TDocDm;override;
    procedure Open;
    procedure OnDocStruInitialize(Sender: TObject);
    procedure DoOnFillKeyFields(Sender: TObject);
    function ValidFmEditItems(Sender:TObject):Boolean;override;
    function getNextNumLevel(AIdLevel:Integer):Integer;
  end;

var
  MenuStruDm: TMenuStruDm;

implementation

uses fdac.dmmain, uLog, systemconsts, fdac.docBinding, frameObjectsGr;

{$R *.dfm}

{ TDmAttributes }

procedure TMenuStruDm.DataModuleCreate(Sender: TObject);
const
  query: String =  'WITH RECURSIVE allmenu AS ( SELECT ml.id_menu, ml.id_menu as id_item, 0 as id_level,CAST(-1 AS INTEGER) as num_level,CAST( name as TNAME) as namemenu, '''+''' as funcmenu, CAST(0 AS INTEGER) as mi_id '+
 ' , 1 as COUNT_SOD   from menulist ml'+
 ' UNION ALL '+
 ' SELECT ml.id_menu,ms.id_item, iif(ms.id_level=0,ml.id_menu,ms.id_level) as id_level,ms.num_level, ms.namemenu, ms.funcmenu, ms.mi_id '+
 ', ( SELECT count(ms2.id_item) FROM menustru ms2 WHERE ms2.id_level=ms.id_item) AS COUNT_SOD'+
 ' FROM menustru ms, allmenu ml '+
 ' WHERE ml.id_menu=ms.id_menu and  iif(ms.id_level=0,ml.id_menu,ms.id_level)=ml.id_item) '+
 ' SELECT * FROM allmenu '+
 ' ORDER BY id_level, num_level ';

begin
  inherited;
  SqlManager.InitCommonParams('MENUSTRU','ID_ITEM','GEN_MENUSTRU_ID');
  SqlManager.SelectSQL.Add(query);

  DocStruDescriptionList.Add('id_menu','','ID_MENU','ID_MENU',4,'',4,False,True,nil);
  DocStruDescriptionList.Add('id_item','','ID_ITEM','ID_ITEM',4,'',4,False,True,nil);
  DocStruDescriptionList.Add('id_level','','ID_LEVEL','ID_LEVEL',4,'',4,False,True,nil);
  DocStruDescriptionList.Add('num_level','','NUM_LEVEL','NUM_LEVEL',4,'',4,False,True,nil);
  DocStruDescriptionList.Add('namemenu','','Наименование','Наименование',60,'',60,True,False,
    TBindingDescription.GetBindingDescription(TEditVkVariableBinding));
  DocStruDescriptionList.Add('mi_id','','Событие','Событие',14,'',14,False,False,
    TBindingDescription.GetBindingDescription(TComboBoxVkVariableBinding));
  DocStruDescriptionList.Add('funcmenu','','FUNC_MENU','FUNC_MENU',4,'',4,False,True,nil);
  DocStruDescriptionList.Add('count_sod','','COUNT_SOD','COUNT_SOD',4,'',4,False,True,nil);

  DocStruDescriptionList.OnInitialize := OnDocStruInitialize;
  DocStruDescriptionList.GetDocStruDescriptionItem('namemenu').bNotEmpty := True;

  DocValidator.NotNullList.Add('namemenu');
  OnInitVariables := DoOnInitvariables;
  OnStoreVariables := DoStorevariables;
  OnFillKeyFields := DoOnFillKeyFields;
  DocStruDescriptionList.OnInitialize := DoDocStruInitialize;

end;

procedure TMenuStruDm.DoDocStruInitialize(Sender: TObject);
var _Item: TVkVariableBinding;
    oCombo: TComboBox;
    k: Integer;
begin
  Assert(Sender is TVkVariableBinding,'Invalid type');
  _Item := TVkVariableBinding(Sender);
  if SameText(_Item.Name,'mi_id') then
  begin
    oCombo := TItemComboBox(_item.GetControl);
    for k := 0 to miList.Count-1 do
       oCombo.Items.Add(miList.Items[k].Name);

  end;
end;

procedure TMenuStruDm.DoOnFillKeyFields(Sender: TObject);
begin
  if DocvariableList.VarByName('id_item').AsLargeInt=0 then
    DocvariableList.VarByName('id_item').AslargeInt := DmMain.GenId('GEN_MENUSTRU_ID');
end;

procedure TMenuStruDm.DoOnInitVariables(ASender: TObject; AInsert: Boolean);
begin
  if AInsert then
  begin
    {DocVariableList.VarByName('id').AsLargeInt := FDQueryDoc.ParamByName('ID').AsLargeInt;
    DocVariableList.VarByName('isunique').AsBoolean := False;
    DocVariableList.VarByName('notempty').AsBoolean := False;
    DocVariableList.VarByName('idgroup').AsLargeInt := 0;
    DocVariableList.VarByName('attributetype').AsLargeInt := 0;
    }
  end
end;

procedure TMenuStruDm.DoStoreVariables(Sender: TObject; AStatus: TUpdateStatus);
begin
  if AStatus= usInserted then
  begin
//    DocVariableList.VarByName('IDATTRIBUTE').AsLargeInt := MainDm.GenId('IDATTRIBUTE');
  end;
end;

class function TMenuStruDm.GetDm: TDocDm;
begin
  Result := TMenuStruDm.Create(MainDm);
end;

function TMenuStruDm.getNextNumLevel(AIdLevel: Integer): Integer;
var bk: TBookMark;
begin
  bk := MemTableEhDoc.GetBookmark;
  try
    MemTableEhDoc.Filter := Format('ID_LEVEL=%d',[AIdLevel]);
    MemTableEhDoc.Filtered := true;
    MemTableEhDoc.Last;
    if MemTableEhDoc.IsEmpty then
      Result := 1
    else
      Result := MemTableEhDoc.FieldByName('NUM_LEVEL').AsInteger +1;

  finally
    MemTableEhDoc.Filtered := false;
    MemTableEhDoc.Filter := '';
    MemTableEhDoc.GotoBookmark(bk);
  end;
end;

procedure TMenuStruDm.LocalOnChangeVariable(Sender: TObject);
begin
{  if Sender = DocVariableList.VarByName('attributetype') then
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
  end;}
end;

procedure TMenuStruDm.MemTableEhDocAfterOpen(DataSet: TDataSet);
begin
  inherited;
  {if not MemTableEhDoc.TreeList.Active then
  begin
    MemTableEhDoc.TreeList.KeyFieldName := 'id_item';
    MemTableEhDoc.TreeList.RefParentFieldName := 'id_level';
    MemTableEhDoc.TreeList.Active := true;
  end;}
  with MemTableEhDoc.FieldByName('MI_ID') do
  begin
    OnGetText := MyOnGetText;
    DisplayWidth := 20;
  end;
//  DocVariableList.VarByName('attributetype').OnChangeVariable := LocalOnChangeVariable;
end;

procedure TMenuStruDm.MemTableEhDocBeforePost(DataSet: TDataSet);
begin
{  if DataSet.FieldByName('ID').AsLargeInt=0 then
  begin
    DataSet.FieldByName('ID').ReadOnly := False;
    DataSet.FieldByName('ID').AslargeInt := MainDm.GenId('IDATTRIBUTE');
  end;}
  inherited;
end;

procedure TMenuStruDm.MyOnGetText(Field: TField; var text: String;
  DisplayText: Boolean);
begin
  if Field.FieldName='MI_ID' then
  begin
    text := miList.Items[GetIndexOf_mi_id(Field.value)].Name;
  end;
end;

procedure TMenuStruDm.OnDocStruInitialize(Sender: TObject);
var _Item: TVkVariableBinding;
    _proc: TOnRequest;
begin
{  Assert(Sender is TVkVariableBinding,'Invalid type');
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
  end;}
end;

procedure TMenuStruDm.Open;
begin
  FDQueryDoc.Close;
  FDQueryDoc.SQL.Clear;
  FDQueryDoc.SQL.Text := SqlManager.SelectSQL.Text;
  try
    //FDQueryDoc.ParamByName('id').AsLargeInt := AId;
    MemTableEhDoc.Open;
  except
    on E: Exception do
    begin
      LogMessage(' DmMenuStru:'+#13#10+E.Message+#13#10+FDQueryDoc.SQL.Text);
    end;
  end;
end;

function TMenuStruDm.ValidFmEditItems(Sender: TObject): Boolean;
//var _Items: TVkVariableBindingCollection;
begin
{  _Items :=
  if True then}
  Result := Inherited;

end;

end.
