unit DmMenuStru;

interface

uses
  System.SysUtils, System.Classes, rtc.dmDoc, MemTableDataEh, Data.DB, DataDriverEh, MemTableEh,
  VkVariable, VkVariableBinding, VkVariableBindingDialog, rtc.docbinding, uDocDescription, systemconsts;

type
  TMenuStruDm = class(TDocDm)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    procedure DoOnInitVariables(ASender: TObject; AInsert: Boolean);
    procedure DoStoreVariables(Sender: TObject; AStatus: TUpdateStatus);
    procedure DoOnFillKeyFields(Sender: TObject);
  public
    { Public declarations }
    function getNextNumLevel(const AIdMenu,AIdLevel: Integer): Integer;
    procedure setNumLevel(id_item, id_level, num_level: Integer);
  end;

var
  MenuStruDm: TMenuStruDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
uses DmMainRtc;
{$R *.dfm}

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
  InitClientSqlManager('MENUSTRU');
  SqlManager.SelectSQL.Clear;
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

//  DocStruDescriptionList.OnInitialize := OnDocStruInitialize;
  DocStruDescriptionList.GetDocStruDescriptionItem('namemenu').bNotEmpty := True;

  DocValidator.NotNullList.Add('namemenu');
  OnInitVariables := DoOnInitvariables;
  OnStoreVariables := DoStoreVariables;
  OnFillKeyFields := DoOnFillKeyFields;
//  DocStruDescriptionList.OnInitialize := DoDocStruInitialize;

end;

procedure TMenuStruDm.DoOnInitVariables(ASender: TObject; AInsert: Boolean);
begin
  if AInsert then
  begin
  end
  else
  begin
    DocVariableList.VarByName('mi_id').AsLargeInt := GetIndexOf_mi_id(DocVariableList.VarByName('mi_id').AsLargeInt);
  end

end;

procedure TMenuStruDm.DoStoreVariables(Sender: TObject; AStatus: TUpdateStatus);
begin
    DocVariableList.VarByName('mi_id').AsLargeInt := Get_mi_id(DocVariableList.VarByName('mi_id').AsLargeInt);
end;

procedure TMenuStruDm.DoOnFillKeyFields(Sender: TObject);
begin
  if DocvariableList.VarByName('id_item').AsLargeInt=0 then
    DocvariableList.VarByName('id_item').AslargeInt := DmMain.Gen_ID('GEN_MENUSTRU_ID');
end;

function TMenuStruDm.getNextNumLevel(const AIdMenu,AIdLevel: Integer): Integer;
var bk: TBookMark;
begin
  Result := MainRtcDm.QueryValue('SELECT coalesce(MAX(num_level),0) FROM MENUSTRU WHERE id_menu=:id_menu AND id_level=:id_level',[AIdMenu, AIdLevel]).RtcValue.asInteger;
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

end.
