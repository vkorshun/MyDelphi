unit dmMenuStru;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, fdac.dmdoc, MemTableDataEh, Db, DataDriverEh, MemTableEh,  FireDAC.Comp.Client,
  VkVariable, VkVariableBinding, VkVariableBindingDialog, uDocDescription, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.StdCtrls, menustructure,
  fdsqlquery;

type
  TMenuStruDm = class(TDocDm)
    FDCommandNormalLevel: TFDCommand;
    procedure DataModuleCreate(Sender: TObject);
    procedure MemTableEhDocAfterOpen(DataSet: TDataSet);
    procedure MemTableEhDocBeforePost(DataSet: TDataSet);
  private
    { Private declarations }
    FDSqlQuery: TFDSqlQuery;
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
    function getNextNumLevel(const AIdMenu,AIdLevel:Integer):Integer;
    procedure setNumLevel(id_item, id_level, num_level:Integer);
    procedure FillMenuStru(const AMenuStru:TMenuStructure; AOnExecute:TNotifyEvent);
  end;

var
  MenuStruDm: TMenuStruDm;

implementation

uses fdac.dmmain, uLog, systemconsts, fdac.docBinding, frameObjectsGr, Vcl.ActnList, Vcl.Menus;

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
  FDSqlQuery := TFDSqlQuery.Create(self);
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

  FDmMain.LinkWithCommand(FDCommandNormalLevel,FDmMain.FDTransactionUpdate);


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
  else
  begin
    DocVariableList.VarByName('mi_id').AsLargeInt := GetIndexOf_mi_id(DocVariableList.VarByName('mi_id').AsLargeInt);
  end

end;

procedure TMenuStruDm.DoStoreVariables(Sender: TObject; AStatus: TUpdateStatus);
begin
//  if AStatus= usInserted then
//  begin
    DocVariableList.VarByName('mi_id').AsLargeInt := Get_mi_id(DocVariableList.VarByName('mi_id').AsLargeInt);
//  end;
end;

procedure TMenuStruDm.FillMenuStru(const AMenuStru: TMenuStructure; AOnExecute:TNotifyEvent);
var
     CA: TAction;
    procedure FillAction(pmi:TMenuStructureItem);
    var i: Integer;
    begin

      with FDSqlQuery do
      begin
        Close;
        Command.ParamByName('id_menu').AsInteger := MainDm.CurrentUser.id_menu;
        if Assigned(pmi) and (pmi.id<>0)then
        begin
          Command.ParamByName('id_level').AsInteger := pmi.id;
        end
        else
          Command.ParamByName('id_level').AsInteger := 0;
        Open;
          //mm := pmi.Items[i];
        while not Eof do
        begin
          if FieldByName('namemenu').AsString='-' then
          begin
            if Assigned(pmi) then
            begin
              pmi.Add('-', FieldByName('id_item').AsInteger);
            end
            else
              ShowMessage('Not Assigned!') ;
          end
          else
          begin
            CA := TAction.Create(Self);
            CA.Caption := FieldByName('namemenu').AsString;
            CA.Tag     := FieldByName('mi_id').AsInteger;
            if FieldByName('shortcut').AsString<>'' then
              CA.ShortCut := TextToShortCut(FieldByName('shortcut').AsString);
            CA.OnExecute := AOnExecute;
            if (pmi = nil) then
              AMenuStru.Add(CA.Caption, FieldByName('id_item').AsInteger)
            else
              pmi.Add(CA.Caption, FieldByName('id_item').AsInteger, CA );
            //if Assigned(pmi) then
            //begin
            //  ActionManager1.AddAction(CA, nil);

            //  SomeMenu := pmi.Items.Add;
            //  SomeMenu.Action := CA;
            //  SomeMenu.Tag    := FieldByName('id_item').AsInteger;
            //end
            //else
            //begin
            // next we need to create a dummy action, we will assign to our sub menu parent items
            // and use that later on
//            CAMenu := TContainedAction.Create(Self);

            // now, for our action bar (which hold a reference to the action main menu) we need to
            // create the menu item
              // ACIMain := ABI.Items.Add;
              // ACIMain.Action := CA;
              // ACIMain.Caption := FieldByName('namemenu').AsString;
              // ACIMain.Tag     := FieldByName('id_item').AsInteger;
            //mi := ActionMainMenuBar.ActionManager.ActionBars[0].Items.Add;
          end;
          Next;
        end;
        if not Assigned(pmi) then
        begin
          pmi := AMenuStru.Root;
        end;

        begin
          for I := 0 to pmi.Items.Count - 1 do
             FillAction(pmi.Items[i]);
        end;
      end;
    end;

begin

  with FDSqlQuery do
  begin
    Close;
    Command.CommandText.Clear;
    if MainDm.CurrentUser.idgroup=1 then
    begin
      // Admin
      Command.CommandText.Add('SELECT m.* FROM menustru m');
      Command.CommandText.Add('WHERE m.id_level=:id_level and m.id_menu=:id_menu');
      Command.CommandText.Add('ORDER BY m.id_level, m.num_level ');
      Command.ParamByName('id_menu').AsInteger := MainDm.CurrentUser.id_menu;
    end
    else
    begin
      //User
      Command.CommandText.Add('SELECT m.* FROM menustru m');
      Command.CommandText.Add(' LEFT JOIN usersaccess ua ON ua.id_access=:id_access AND ua.id_user=:id_user AND ua.id_item= m.id_item ');
      Command.CommandText.Add('WHERE m.id_level=:id_level and m.id_menu=:id_menu and ua.access_value>0');
      Command.CommandText.Add('ORDER BY m.id_level, m.num_level ');
      Command.ParamByName('id_menu').AsInteger    := MainDm.CurrentUser.id_menu;
      Command.ParamByName('id_access').AsInteger := ACCESS_MENU;
      Command.ParamByName('id_user').AsInteger   := MainDm.CurrentUser.iduser;
    end;

  end;
  FillAction(nil);

  {*with FAmDescription1 do
  begin
    if oIDmMain.CurrentUser.id_group= GROUP_ADMIN then
    begin
      AddDescription('MAIN1','MI_OPENDOC','BITMAP_prodoc32','Документы','');
      AddDescription('MAIN1','MI_WORKPERIOD','BITMAP_date32','Рабочий диапазон','');
      AddDescription('MAIN1','MI_USERSACCESS','BITMAP_access32','Список пользователей','');
      AddDescription('MAIN1','MI_VIEWACCOUNT','BITMAP_ps32','План счетов','');
      AddDescription('MAIN1','SEPARATOR','EMPTY','','');
      AddDescription('MAIN2','MI_VIEWOAU','BITMAP_oau32','Объекты ан. учета','');
//    AddDescription('MAIN2','oku','BITMAP_oku32','Объекты кол. учета','');
      AddDescription('MAIN2','SEPARATOR','EMPTY','','');
      AddDescription('MAIN3','MI_PAROAU','BITMAP_poau32','Параметры объектов ан. учета','');
//    AddDescription('MAIN3','poku','BITMAP_poku32','Параметры объектов кол. учета','');
      AddDescription('MAIN3','SEPARATOR','EMPTY','','');
//    AddDescription('MAIN4','valuta','BITMAP_valuta32','Динамика курсов валют','');
      AddDescription('MAIN4','MI_LISTENTERPRIZE','BITMAP_pred32','Информация о предприятиях','');
//    AddDescription('MAIN4','jho','BITMAP_jho32','Журнал хоз. операций','');
//    AddDescription('MAIN4','j_prov','BITMAP_j_prov32','Журнал проводок','');
//    AddDescription('MAIN4','corschet','BITMAP_corschet32','Корреспонденция счетов','');
//    AddDescription('MAIN4','oplata','BITMAP_oplata32','Разноска оплаты','');
      AddDescription('MAIN4','MI_REPORT','BITMAP_reports32','Список отчетов','');
//      AddDescription('MAIN4','MI_CALENDAR','BITMAP_CALENDAR32','Календарь','CTRL+F2');
    end
    else
    begin
      AddDescription('MAIN1','MI_OPENDOC','BITMAP_prodoc32','Документы','');
      AddDescription('MAIN4','MI_REPORT','BITMAP_reports32','Список отчетов','');
      AddDescription('MAIN1','SEPARATOR','EMPTY','','');
      AddDescription('MAIN1','MI_VIEWACCOUNT','BITMAP_ps32','План счетов','');
      AddDescription('MAIN2','MI_VIEWOAU','BITMAP_oau32','Объекты ан. учета','');
      AddDescription('MAIN1','SEPARATOR','EMPTY','','');
      AddDescription('MAIN1','MI_WORKPERIOD','BITMAP_date32','Рабочий диапазон','');

    end;
    InitActionManager(ActionManager2,NIL,MainExecuteAction);}
//    ActionToolBar1.Parent := Panel1;
  end;


class function TMenuStruDm.GetDm: TDocDm;
begin
  Result := TMenuStruDm.Create(MainDm);
end;

function TMenuStruDm.getNextNumLevel(const AIdMenu,AIdLevel: Integer): Integer;
var bk: TBookMark;
begin
  Result := MainDm.QueryValue('SELECT coalesce(MAX(num_level),0) FROM MENUSTRU WHERE id_menu=:id_menu AND id_level=:id_level',[AIdMenu, AIdLevel]);
{  bk := MemTableEhDoc.GetBookmark;
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
  end;}
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

procedure TMenuStruDm.setNumLevel(id_item, id_level, num_level: Integer);
begin
  if MemTableEhDoc.locate('id_item',id_item,[]) then
  begin
    ReInitVariables;
    try
      DocVariableList.VarByName('id_level').AsInteger := id_level;
      DocVariableList.VarByName('num_level').AsInteger := num_level;
    finally
      WriteVariables(false);

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
