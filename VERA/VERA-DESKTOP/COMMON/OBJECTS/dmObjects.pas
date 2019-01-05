unit dmObjects;

interface

uses
  System.SysUtils, System.Classes, fdac.dmdoc, MemTableDataEh, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  DataDriverEh, MemTableEh, VkVariableBinding, VkVariableBindingDialog, Generics.Collections, vkvariable,
  DateVk, SystemConsts, Math, DocSqlManager, FIBQuery, pFIBQuery, pFIBQueryVk;

const
  _VARATTR = 'f_';
  _VARATTR2 = 'fname_';
  FLD_IDATTRIBUTE = 'idattribute';
  FLD_NUMBERVIEW = 'numberview';
  FLD_NUMBEREDIT = 'numberedit';
  FLD_ATTRIBUTETYPE = 'attributetype';
  FLD_ATTRIBUTENAME = 'attribute_name';
  FLD_IDGROUP = 'idgroup';
  FLD_IDOBJECT = 'idobject';
  FLD_VAL = 'val';
  FLD_SET_NAME = 'set_name';
  TBL_ATTRIBUTESOFOBJECT = 'ATTRIBUTESOFOBJECT';
type
  TAttributeDescr = class(TObject)
  private
    FId: Int64;
    FName: String;
  public
    property Name:String read FName write FName;
    property Id:Int64 read FId write FId;
  end;

  TTypeDmObjects = (tdmoGroups, tdmoObjects);
  TObjectsDm = class(TDocDm)
    FDQueryAttributesOfGroup: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure MemTableEhDocAfterOpen(DataSet: TDataSet);
    procedure MemTableEhDocBeforeClose(DataSet: TDataSet);
    procedure MemTableEhDocAfterPost(DataSet: TDataSet);
  private
    { Private declarations }
    FObjectsTypeDm : TTypeDmObjects;
    FExpandedList: TList<LargeInt>;
    FBranchedNode: TMemRecViewEh;
    FAdditionalSqlManager: TAdditionalSqlManager;
    procedure AddAttributesToDocStru;
    function  GetSelectFromObjects(AIdGroup:TLargeInt;bOnlyView:Boolean = True):String; //< Формирует SQL для выбора из объектов
    procedure SetTypeDmObjects(const Value: TTypeDmObjects);
    procedure OnDocStruInitialize(Sender: TObject);
    procedure Prepare(AIdGroup: LargeInt);
    procedure CheckExpandedParentGroup;
    procedure SetBranchedNode(const Value: TMemRecViewEh);
    procedure MyInsertAdditionalFields(Sender: TObject);
    procedure MyUpdateAdditionalFields(Sender: TObject);
  protected
    procedure DoOnInitVariables(ASender: TObject; AInsert: Boolean);
    procedure DoStoreVariables(Sender: TObject; AStatus: TUpdateStatus);
    procedure GrMemTableEhDocAfterOpen(DataSet: TDataSet);
    procedure GrMemTableEhDocBeforeClose(DataSet: TDataSet);
  public
    { Public declarations }
    procedure DoWriteVariables(Sender: TObject; AInsert: Boolean);
    procedure Open(AIdGroup: LargeInt);
    class function GetDm: TDocDm;override;
    property ObjectsTypeDm : TTypeDmObjects read FObjectsTypeDm write SetTypeDmObjects;
    property BranchedNode: TMemRecViewEh read FBranchedNode write SetBranchedNode;
  end;

var
  ObjectsDm: TObjectsDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses uLog, fdac.DmMain, uDocDescription, sqldescription, fdac.DocBinding, frameObjectsGr;
{$R *.dfm}

procedure TObjectsDm.AddAttributesToDocStru;
var i: Integer;
  _attr_name: String;
  _var_name: String;
  _var_name2: String;
  _set_name: String;
  _bView: Boolean;
begin
  with FDQueryAttributesOfGroup do
  begin
    First;
    i := 1;
    while not Eof  do
    begin
      {while (FDQueryAttributesOfGroup.FieldByName('numberview').AsInteger=0) do
      begin
        FDQueryAttributesOfGroup.Next;
        Inc(i);
        if FDQueryAttributesOfGroup.Eof then
          Break;
      end;

      if FDQueryAttributesOfGroup.Eof then
          Break; }
      _attr_name := FieldByName(FLD_ATTRIBUTENAME).AsString;
      _var_name := _VARATTR+IntToStr(i);
      _var_name2 := _VARATTR2+ IntToStr(i);
      _bView := FieldByName(FLD_NUMBERVIEW).AsInteger > 0;
      _set_name := FieldByName(FLD_SET_NAME).AsString;
      case FDQueryAttributesOfGroup.FieldByName(FLD_ATTRIBUTETYPE).AsInteger of
        TA_STRING:
          begin
            DocStruDescriptionList.Add(_var_name,'',_attr_name,_attr_name,FieldByName('nlen').AsInteger,'',
              Min(60,FieldByName('nlen').AsInteger+1),_bView,not _bView,
               TBindingDescription.GetBindingDescription(TEditVkVariableBinding),_set_name);
          end;
        TA_NUMERIC:
          begin
            DocStruDescriptionList.Add(_var_name,'',_attr_name,_attr_name,FieldByName('nlen').AsInteger,'',
              Min(20,FieldByName('nlen').AsInteger),_bView,not _bView,
               TBindingDescription.GetBindingDescription(TNumberMaskEditVariableBinding),_set_name);
          end;
        TA_DATE:
          begin
            DocStruDescriptionList.Add(_var_name,'',_attr_name,_attr_name,FieldByName('nlen').AsInteger,'',
              Min(16,FieldByName('nlen').AsInteger),_bView,not _bView,
               TBindingDescription.GetBindingDescription(TDbDateTimeEditEhVkVariableBinding),_set_name);
          end;
        TA_LOGICAL:
            DocStruDescriptionList.Add(_var_name,'',_attr_name,_attr_name,FieldByName('nlen').AsInteger,'',
              Min(10,FieldByName('nlen').AsInteger),_bView,not _bView,
               TBindingDescription.GetBindingDescription(TCheckBoxVkVariableBinding),_set_name);
        TA_TIME:
          begin
            DocStruDescriptionList.Add(_var_name,'',_attr_name,_attr_name,FieldByName('nlen').AsInteger,'',
              Min(16,FieldByName('nlen').AsInteger),_bView,not _bView,
               TBindingDescription.GetBindingDescription(TDbDateTimeEditEhVkVariableBinding),_set_name);
          end;
        TA_TIMESTAMP:
          begin
            DocStruDescriptionList.Add(_var_name,'',_attr_name,_attr_name,FieldByName('nlen').AsInteger,'',
              Min(16,FieldByName('nlen').AsInteger),_bView,not _bView,
               TBindingDescription.GetBindingDescription(TDbDateTimeEditEhVkVariableBinding),_set_name);
          end;
        TA_CURRENCY:
          begin
            DocStruDescriptionList.Add(_var_name,'',_attr_name,_attr_name,FieldByName('nlen').AsInteger,'',
              Min(20,FieldByName('nlen').AsInteger),_bView,not _bView,
               TBindingDescription.GetBindingDescription(TNumberMaskEditVariableBinding),_set_name);
          end;

        TA_OBJECT,TA_GROUP:
        begin
            DocStruDescriptionList.Add(_var_name2,_var_name,_attr_name,_attr_name,60,'',
              60,_bView,not _bView,
          TDocMEditBoxBindingDescription.GetDocMEditBoxBindingDescription('TObjectsGrFrame',nil),_set_name);
        end;
        TA_ACCOUNT:
        begin
        end;
{      else
        cAliasParam  := 'attr'+IntToStr(i);
        SQLSelect.Add(','+cAliasParam+'.'+s+' as f_'+IntToStr(i));
        SQLLeftJoin.Add(' LEFT JOIN attributesofobject '+cAliasParam+' ON '+cAliasParam+'.idobject= obj.idobject AND '
          +cAliasParam+'.idattribute='+IntToStr(FDQueryAttributesOfGroup.FieldByName('idattribute').AsInteger));}
      end;
      FDQueryAttributesOfGroup.Next;
      Inc(i);
    end;
  end;
  DocStruDescriptionList.OnInitialize := OnDocStruInitialize;
end;

procedure TObjectsDm.CheckExpandedParentGroup;
begin
  if Assigned(FBranchedNode) and not FBranchedNode.NodeExpanded then
    FBranchedNode.NodeExpanded := true;
end;

procedure TObjectsDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  MainDm.LinkWithQuery(FDQueryAttributesOfGroup,DmMain.FDTransactionRead);
  with FDQueryAttributesOfGroup do
  begin
    SQL.Clear;
    SQL.Add('SELECT ag.*, gr.name as group_name, al.name as attribute_name, s.name as set_name,');
    SQL.Add('al.attributetype, al.nlen, al.ndec, al.isunique, al.notempty, ua.iduavalue');
    SQL.Add('FROM attributesofgroup ag');
    SQL.Add('LEFT OUTER JOIN objects gr ON gr.idobject=ag.idgroup');
    SQL.Add('LEFT OUTER JOIN attributelist al ON al.idattribute=ag.idattribute');
    SQL.Add('LEFT OUTER JOIN attributeset s ON s.idset=ag.idset');
    SQL.Add('LEFT JOIN usersaccess ua ON  ua.iduatype = :iduatype AND ua.iduser=:iduser AND ua.iditem = al.idattribute');
    SQL.Add('WHERE ag.idgroup=:idgroup AND ( pkg_common.IsUserAdmin(:iduser) or ua.iduavalue>0)');
    SQL.Add('ORDER BY numberedit, set_name');

{    SQL.Add('SELECT ag.*, gr.name as group_name, al.name as attribute_name, s.name as set_name,');
    SQL.Add('al.attributetype, al.nlen, al.ndec, al.isunique, al.notempty, ua.iduavalue ');
    SQL.Add('FROM attributesofgroup ag ');
    SQL.Add('LEFT OUTER JOIN objects gr ON gr.idobject=ag.idgroup');
    SQL.Add('LEFT OUTER JOIN attributelist al ON a.idattribute=ag.idattribute');
    SQL.Add('LEFT OUTER JOIN attributeset s ON s.idset=ag.idset');
    SQL.Add('LEFT JOIN usersaccess ua ON  ua.iduatype = :iduatype AND ua.iduser=:iduser AND ua.iditem = al.idattribute');

    SQL.Add('WHERE ag.idgroup=:idgroup AND ( pkg_common.IsUserAdmin(:iduser) or ua.iduavalue>0');
    SQL.Add('ORDER BY numberedit, set_name');}
  end;

//  FDQueryAttributesOfGroup.SQL.Add('SELECT * FROM AttributesOfGroup WHERE idgroup=:idgroup');
  FExpandedList := TList<LargeInt>.Create;
  FExpandedList.Count :=0;
  FDefineDebug := True;
  FAdditionalSqlManager := TAdditionalSqlManager.Create;
  SqlManager.AdditionalList.Add(FAdditionalSqlManager);
  FAdditionalSqlManager.TableName := TBL_ATTRIBUTESOFOBJECT;
  OnWriteVariables := DoWriteVariables;
  OnInsertAdditionalFields := MyInsertAdditionalFields;
  OnUpdateAdditionalFields := MyUpdateAdditionalFields;
end;

procedure TObjectsDm.DataModuleDestroy(Sender: TObject);
begin
  inherited;
  FExpandedList.Free;
  FreeAndNil(FAdditionalSqlManager);
end;

procedure TObjectsDm.DoOnInitVariables(ASender: TObject; AInsert: Boolean);
begin
  if AInsert then
  begin
  end
end;

procedure TObjectsDm.DoStoreVariables(Sender: TObject; AStatus: TUpdateStatus);
begin
  if AStatus= usInserted then
  begin
    DocVariableList.VarByName('ISGROUP').AsBoolean := FObjectsTypeDm = tdmoGroups;
  end;
  if ObjectsTypeDm= tdmoObjects then
  begin
    if AStatus= usInserted then
      DocVariableList.VarByName('IDGROUP').AsLargeInt := FDQueryDoc.ParamByName('idgroup').AsLargeInt;
  end;
end;

procedure TObjectsDm.DoWriteVariables(Sender: TObject; AInsert: Boolean);
var _kodg: LargeInt;
begin
  if ObjectsTypeDm= tdmoObjects then
  begin
    if AInsert then
    begin
      _kodg := FDQueryDoc.ParamByName('idgroup').AsLargeInt;
      if _kodg=0 then
        raise Exception.Create('_kodg = 0');
      DocVariableList.VarByName('idgroup').AsLargeInt :=  _kodg;
      DocVariableList.VarByName('idobject').AsLargeInt :=  MainDm.GenId('IDOBJECT');
      DocVariableList.VarByName('isgroup').AsBoolean :=  False;
    end;
  end;
end;

class function TObjectsDm.GetDm: TDocDm;
begin
  Result := TObjectsDm.Create(MainDm);
end;

function TObjectsDm.GetSelectFromObjects(AIdGroup: TLargeInt; bOnlyView: Boolean): String;
var s: String;
    cAlias: String;
    cAliasParam: String;
    i: Integer;
    _SQLDescription: TSQLDescription;
    id_attr: Int64;
   _adescr : TAttributeDescr;
begin

///  ListBoolFields.Clear;
  FAdditionalSqlManager.FieldList.Clear;
  FAdditionalSqlManager.ObjectList.Clear;
  _SQLDescription := TSQLDescription.Create;
  with _SQLDescription do
  try
    i:=1;
    SQLSelect.Clear;
    SQLSelect.Add(' SELECT obj.*');
    FDQueryAttributesOfGroup.Active := False;
    FDQueryAttributesOfGroup.ParamByName('idgroup').AsLargeInt := AIdGroup;
    FDQueryAttributesOfGroup.ParamByName('iduser').AsLargeInt := MainDm.CurrentUser.iduser;
    FDQueryAttributesOfGroup.ParamByName('iduatype').AsLargeInt := MainDm.UsersAccessType.VarByName('USERACCESS_ATTRIBUTES').AsInteger;
    FDQueryAttributesOfGroup.Open;

    while not FDQueryAttributesOfGroup.Eof do
    begin
       id_attr := FDQueryAttributesOfGroup.FieldByName('idattribute').AsLargeInt;

      {if bOnlyView then
      while (FDQueryAttributesOfGroup.FieldByName('numberview').AsInteger=0) do
      begin
        FDQueryAttributesOfGroup.Next;
        Inc(i);
        if FDQueryAttributesOfGroup.Eof then
          Break;
      end;

      if FDQueryAttributesOfGroup.Eof then
          Break;
      }
      case FDQueryAttributesOfGroup.FieldByName('attributetype').AsInteger of
        TA_STRING:  s:='val';
        TA_NUMERIC: s:='v_double ';
        TA_DATE:    s:='v_data';
        TA_LOGICAL: s:='v_boolean';
        TA_TIME: s:='v_double';
        TA_TIMESTAMP: s:='v_double';
        TA_CURRENCY: s:='v_currency';
      else
         s:='v_int';
      end;
      case FDQueryAttributesOfGroup.FieldByName('attributetype').AsInteger of
        TA_OBJECT,TA_GROUP:
        begin
          cAliasParam  := 'attr'+IntToStr(i);
          SQLLeftJoin.Add(' LEFT JOIN attributesofobject '+cAliasParam+' ON '
          +cAliasParam+'.idattribute='+IntToStr(FDQueryAttributesOfGroup.FieldByName('idattribute').AsInteger)+ ' AND '
          +cAliasParam+'.idobject= obj.idobject  ');
          cAlias := 'obj'+IntToStr(i);
          SQLLeftJoin.Add(' LEFT JOIN objects '+cAlias+' ON '+cAlias+'.idobject='+cAliasParam+'.v_int');
          SQLSelect.Add(','+cAliasParam+'.v_int as f_'+ IntToStr(i)+','+cAlias+'.name as fname_'+IntToStr(i));
        end;
        TA_ACCOUNT:
        begin
          cAliasParam  := 'attr'+IntToStr(i);
          SQLLeftJoin.Add(' LEFT JOIN attributesofobject '+cAliasParam+' ON '+cAliasParam+'.idobject= obj.idobject AND '
          +cAliasParam+'.idattribute='+IntToStr(FDQueryAttributesOfGroup.FieldByName('idattribute').AsInteger));
          cAlias := 'acc'+IntToStr(i);
          SQLLeftJoin.Add(' LEFT JOIN account '+cAlias+' ON '+cAlias+'.id_account='+cAliasParam+'.v_int');
          SQLSelect.Add(','+cAlias+'.name as f_'+IntToStr(i));
        end;
        TA_LOGICAL,TA_NUMERIC:
        begin
          cAliasParam  := 'attr'+IntToStr(i);
          SQLSelect.Add(', coalesce('+cAliasParam+'.'+s+',0) as f_'+IntToStr(i));
          SQLLeftJoin.Add(' LEFT JOIN attributesofobject '+cAliasParam+' ON '+cAliasParam+'.idobject= obj.idobject AND '
          +cAliasParam+'.idattribute='+IntToStr(FDQueryAttributesOfGroup.FieldByName('idattribute').AsInteger));
        end;
      else
        cAliasParam  := 'attr'+IntToStr(i);
        SQLSelect.Add(','+cAliasParam+'.'+s+' as f_'+IntToStr(i));
        SQLLeftJoin.Add(' LEFT JOIN attributesofobject '+cAliasParam+' ON '+cAliasParam+'.idobject= obj.idobject AND '
          +cAliasParam+'.idattribute='+IntToStr(FDQueryAttributesOfGroup.FieldByName('idattribute').AsInteger));
      end;
      FDQueryAttributesOfGroup.Next;
      _adescr := TAttributeDescr.Create;
      _adescr.Id := id_attr;
      _adescr.Name := _VARATTR+IntToStr(i);
      FAdditionalSqlManager.ObjectList.Add(_adescr);
      FAdditionalSqlManager.FieldList.AddObject(_VARATTR+IntToStr(i),_adescr);
      Inc(i);
    end;
    SQLFrom.Add(' FROM objects obj  ');
    SQLWhere.Add(' WHERE obj.idgroup=:idgroup ');
    SQLOrderBy.Add(' ORDER BY obj.name');
    Result :=  _SQLDescription.GetSelectSql ;
  finally
    FreeAndNil(_SQLDescription);
  end;
{      if FDQueryAttributesOfGroup.FieldByName('typpar').AsInteger=1 then
      begin
        case FDQueryAttributesOfGroup.FieldByName('ntype').AsInteger of
          TPAR_STRING:  s:='val';
          TPAR_NUMERIC: s:='v_double ';
          TPAR_DATE:    s:='v_data';
        else
           s:='v_int';
        end;

        case FDQueryAttributesOfGroup.FieldByName('ntype').AsInteger of
        end;
      end;
      if FDQueryAttributesOfGroup.FieldByName('ntype').AsInteger = TPAR_BOOL then
        ListBoolFields.Add('f_'+IntToStr(i));

      FDQueryAttributesOfGroup.Next;
      Inc(i)
    end;
    SQLFrom.Add(' FROM objects obj  ');
    SQLWhere.Add(' WHERE obj.kodg=:kodg ');
    SQLOrderBy.Add(' ORDER BY obj.name');
    Result :=  mSQLDescription.GetSelectSql ;
  finally
    FreeAndNil(mSQLDescription);
  end;
 }
end;

procedure TObjectsDm.GrMemTableEhDocAfterOpen(DataSet: TDataSet);
var bk: TBookMark;
begin
  Inherited;
  if ObjectsTypeDm= tdmoGroups then
  begin
    if not MemTableEhDoc.TreeList.Active then
    begin
    MemTableEhDoc.TreeList.KeyFieldName := 'idobject';
    MemTableEhDoc.TreeList.RefParentFieldName := 'idgroup';
    MemTableEhDoc.TreeList.Active := true;

    end;
    if FExpandedList.Count>0 then
    begin
      MemTableEhDoc.DisableControls;
      bk := MemTableEhDoc.GetBookmark;
      try
        MemTableEhDoc.First;
        while not MemTableEhDoc.Eof do
        begin
          MemTableEhDoc.RecView.NodeExpanded :=
            FExpandedList.IndexOf(MemTableEhDoc.FieldByName('IDOBJECT').AsLargeInt)>-1;
          MemTableEhDoc.Next;
        end;
      finally
        MemTableEhDoc.GotoBookmark(bk);
        MemTableEhDoc.EnableControls;
        MemTableEhDoc.FreeBookmark(bk);
      end;
    end
    else
      MemTableEhDoc.RecView.NodeExpanded := true;
  end;
end;

procedure TObjectsDm.GrMemTableEhDocBeforeClose(DataSet: TDataSet);
var
    bk: TBookMark;
begin
  if ObjectsTypeDm= tdmoGroups then
  begin
    MemTableEhDoc.DisableControls;
    bk := MemTableEhDoc.GetBookmark;
    FExpandedList.Clear;
    try
      MemTableEhDoc.First;
      while not MemTableEhDoc.Eof do
      begin
        if MemTableEhDoc.RecView.NodeExpanded then
          FExpandedList.Add(MemtableEhDoc.FieldByName('IDOBJECT').AsLargeInt);
        MemTableEhDoc.Next;
      end;
    finally
      MemTableEhDoc.GotoBookmark(bk);
      MemTableEhDoc.EnableControls;
      MemTableEhDoc.FreeBookmark(bk);
    end;
  end;
end;

procedure TObjectsDm.MemTableEhDocAfterOpen(DataSet: TDataSet);
begin
  inherited;
  GrMemTableEhDocAfterOpen(DataSet);
end;

procedure TObjectsDm.MemTableEhDocAfterPost(DataSet: TDataSet);
begin
  inherited;
  CheckExpandedParentGroup;
end;

procedure TObjectsDm.MemTableEhDocBeforeClose(DataSet: TDataSet);
begin
  inherited;
  GrMemTableEhDocBeforeClose(DataSet);
end;

procedure TObjectsDm.MyInsertAdditionalFields(Sender: TObject);
var _Item: TAdditionalSqlManager;
  I: Integer;
//  _RecNo: Integer;
  _id: Int64;
begin
  _Item := TAdditionalSqlManager(Sender);
  if SameText(_Item.TableName,'ATTRIBUTESOFOBJECT') then
  begin
    FDCommandUpdate.CommandText.Text := 'INSERT INTO '+_Item.TableName+'(IDOBJECT, IDATTRIBUTE, VAL)'+
      ' VALUES(:IDOBJECT, :IDATTRIBUTE, :VAL)';
    FDCommandUpdate.ParamByName('IDOBJECT').AsLargeInt := DocVariableList.VarByName('IDOBJECT').AsLargeInt;
    for I := 0 to _Item.FieldList.Count-1 do
    begin
      if Assigned(_Item.FieldList.Objects[i]) then
      begin
        _id := TAttributeDescr(_Item.FieldList.Objects[i]).Id;
        FDCommandUpdate.ParamByName('IDATTRIBUTE').AsLargeInt := _id;
        FDCommandUpdate.ParamByName('VAL').AsString := DocVariableList.VarByName(_Item.FieldList[i]).AsString;
        FDCommandUpdate.Execute();
      end;
    end;
  end;
end;

procedure TObjectsDm.MyUpdateAdditionalFields(Sender: TObject);
var _Item: TAdditionalSqlManager;
  I: Integer;
  _RecNo: Integer;
  _UpdateList: TStringList;
  _id: Int64;
begin
  _Item := TAdditionalSqlManager(Sender);
  if SameText(_Item.TableName,'ATTRIBUTESOFOBJECT') then
  begin
    FDCommandUpdate.CommandText.Text := 'UPDATE OR INSERT INTO '+_Item.TableName+
      ' (IDOBJECT, IDATTRIBUTE, VAL) '+
      ' VALUES  (:IDOBJECT, :IDATTRIBUTE, :VAL)'+
      'MATCHING (IDOBJECT,IDATTRIBUTE)';
//    FDCommandUpdate.ParamByName('IDGROUP').AsLargeInt := FDQueryDoc.ParamByName('idgroup').AsLargeInt;
    FDCommandUpdate.ParamByName('IDOBJECT').AsLargeInt := DocVariableList.VarByName('IDOBJECT').AsLargeInt;
    _UpdateList := tStringList.Create;
    DocVariableList.GetChangedList(_UpdateList,_Item.FieldList);
    for I := 0 to _UpdateList.Count-1 do
    begin
      _RecNo := _Item.FieldList.IndexOf(_UpdateList[i]);

      if (_RecNo>-1) and Assigned(_Item.FieldList.Objects[_RecNo]) then
      begin
        _id := TAttributeDescr(_Item.FieldList.Objects[_RecNo]).Id;
        FDCommandUpdate.ParamByName('IDATTRIBUTE').AsLargeInt := _id;
        FDCommandUpdate.ParamByName('VAL').AsString := DocVariableList.VarByName(_UpdateList[i]).AsString;
        FDCommandUpdate.Execute();
      end;
      {if TryStrToInt(Copy(_UpdateList[i],3,length(Trim(_UpdateList[i]))),_RecNo) then
      begin
        FDQueryAttributesOfGroup.RecNo := _RecNo;
        FDCommandUpdate.ParamByName('IDATTRIBUTE').AsLargeInt := FDQueryAttributesOfGroup.FieldByName('IDATTRIBUTE').AsLargeInt;
        FDCommandUpdate.ParamByName('VAL').AsString := DocVariableList.VarByName(_UpdateList[i]).AsString;
        FDCommandUpdate.Execute();
      end;}
    end;
  end;
end;

procedure TObjectsDm.OnDocStruInitialize(Sender: TObject);
var _Item: TVkVariableBinding;
    _RecNo: Integer;
//    i: Integer;
begin
  Assert(Sender is TVkVariableBinding,'Invalid type');
  _Item := TVkVariableBinding(Sender);
  if (pos('f_',_Item.name)>0) and TryStrToInt(Copy(_Item.name,3,length(Trim(_Item.name))),_RecNo) then
  begin
    with FDQueryAttributesOfGroup do
    begin
      RecNo := _RecNo;
      case FDQueryAttributesOfGroup.FieldByName(FLD_ATTRIBUTETYPE).AsInteger of
        TA_STRING:
          begin
          end;
        TA_NUMERIC:
          begin
            TItemNumberMaskEdit(TNumberMaskEditVariableBinding(_Item).oControl).DecimalPlaces :=
              FieldByName('ndec').AsInteger;
            TItemNumberMaskEdit(TNumberMaskEditVariableBinding(_Item).oControl).MaxLength :=
              FieldByName('nlen').AsInteger;
          end;
{        TA_DATE:
          begin
            DocStruDescriptionList.Add(_var_name,'',_attr_name,_attr_name,FieldByName('nlen').AsInteger,'',
              Min(16,FieldByName('nlen').AsInteger),_bView,not _bView,
               TBindingDescription.GetBindingDescription(TDbDateTimeEditEhVkVariableBinding));
          end;
        TA_LOGICAL:
            DocStruDescriptionList.Add(_var_name,'',_attr_name,_attr_name,FieldByName('nlen').AsInteger,'',
              Min(10,FieldByName('nlen').AsInteger),_bView,not _bView,
               TBindingDescription.GetBindingDescription(TCheckBoxVkVariableBinding));
        TA_TIME:
          begin
            DocStruDescriptionList.Add(_var_name,'',_attr_name,_attr_name,FieldByName('nlen').AsInteger,'',
              Min(16,FieldByName('nlen').AsInteger),_bView,not _bView,
               TBindingDescription.GetBindingDescription(TDbDateTimeEditEhVkVariableBinding));
          end;
        TA_TIMESTAMP:
          begin
            DocStruDescriptionList.Add(_var_name,'',_attr_name,_attr_name,FieldByName('nlen').AsInteger,'',
              Min(16,FieldByName('nlen').AsInteger),_bView,not _bView,
               TBindingDescription.GetBindingDescription(TDbDateTimeEditEhVkVariableBinding));
          end; }
        TA_CURRENCY:
          begin
            TItemNumberMaskEdit(TNumberMaskEditVariableBinding(_Item).oControl).DecimalPlaces := 2;
//              FieldByName('ndec').AsInteger;
            TItemNumberMaskEdit(TNumberMaskEditVariableBinding(_Item).oControl).MaxLength := 15;
//              FieldByName('nlen').AsInteger;
          end;
        TA_OBJECT,TA_GROUP:
        begin
          TObjectsGrFrame(TCustomDocFmVkVariableBinding(_Item).DocMEditBox.DocFm.FrameDoc).RootIdGroup :=
            CoalEsce(MainDm.QueryValue('SELECT idgroup FROM attributelist WHERE idattribute=:idattribute',
            [FieldByName(FLD_IDATTRIBUTE).AsLargeInt]),0);
        end;
        TA_ACCOUNT:
        begin
        end;
{      else
        cAliasParam  := 'attr'+IntToStr(i);
        SQLSelect.Add(','+cAliasParam+'.'+s+' as f_'+IntToStr(i));
        SQLLeftJoin.Add(' LEFT JOIN attributesofobject '+cAliasParam+' ON '+cAliasParam+'.idobject= obj.idobject AND '
          +cAliasParam+'.idattribute='+IntToStr(FDQueryAttributesOfGroup.FieldByName('idattribute').AsInteger));}
      end;

    end;
  end;
  if SameText(_Item.Name,'NUMBEREDIT') or SameText(_Item.Name,'NUMBERVIEW') then
    TItemNumberMaskEdit(TNumberMaskEditVariableBinding(_Item).GetControl).DecimalPlaces := 0;

end;

procedure TObjectsDm.Open(AIdGroup: LargeInt);
begin
  MemTableEhDoc.Close;
  DocVariableList.Clear;
  Prepare(AIdGroup);
  FDQueryDoc.Close;
  FDQueryDoc.SQL.Clear;
  try
    if ObjectsTypeDm=tdmoGroups then
    begin
      FDQueryDoc.SQL.Text := SqlManager.SelectSQL.Text;
      FDQueryDoc.ParamByName('idobject').AsLargeInt := AIdGroup;
    end
    else
    begin
      //SqlManager.SelectSQL.Text := GetSelectFromObjects(AIdGroup);
      FDQueryDoc.SQL.Text := SqlManager.SelectSQL.Text;
      FDQueryDoc.ParamByName('idgroup').AsLargeInt := AIdGroup;
    end;
    MemTableEhDoc.Open;
    if ObjectsTypeDm=tdmoGroups then
      MemTableEhDoc.RecView.NodeExpanded := true;
  except
    on E: Exception do
    begin
      LogMessage(' DmObjects:'+#13#10+E.Message+#13#10+FDQueryDoc.SQL.Text);
    end;
  end;
end;

procedure TObjectsDm.Prepare(AIdGroup: LargeInt);
begin
  FGridOrderList.Clear;
  FEditOrderList.Clear;
  DocStruDescriptionList.Clear;
  MemTableEhDoc.Active := False;
  SqlManager.SelectSQL.Clear;
  if FObjectsTypeDm= tdmoGroups then
  begin
    SqlManager.InitCommonParams('OBJECTS','IDOBJECT','GEN_OBJECTS_ID');
    SqlManager.SelectSQL.Add('WITH RECURSIVE groups(lv,idgroup, idobject, NAME, isgroup)  as ');
    SqlManager.SelectSQL.Add('( select 0 as lv,o1.idgroup, o1.idobject, o1.NAME, o1.isgroup from objects o1 where o1.isgroup=true and idobject=:idobject');
    SqlManager.SelectSQL.Add('UNION ALL');
    SqlManager.SelectSQL.Add(' SELECT groups.lv+1 as lv,o1.idgroup, o1.idobject, o1.NAME, o1.isgroup FROM OBJECTS o1 ');
    SqlManager.SelectSQL.Add(' INNER JOIN groups  ON groups.idobject= o1.idgroup where o1.isgroup=true)');
    SqlManager.SelectSQL.Add('SELECT * FROM groups ORDER BY  lv,name ');

    DocStruDescriptionList.Add('idgroup','','IDGROUP','IDGROUP',4,'',4,False,True,nil);
    DocStruDescriptionList.Add('idobject','','IDOBJECT','IDOBJECT',4,'',4,False,True,nil);
    DocStruDescriptionList.Add('name','','Наименование','Наименование',60,'',60,True,False,
      TBindingDescription.GetBindingDescription(TEditVkVariableBinding));
    DocValidator.NotNullList.Add('name');
    DocStruDescriptionList.Add('isgroup','','ISGROUP','ISGROUP',4,'',4,False,True,nil);
  end
  else
  begin
    SqlManager.InitCommonParams('OBJECTS','IDOBJECT','GEN_OBJECTS_ID');
//    SqlManager.SelectSQL.Add('SELECT * FROM objects WHERE idgroup=:idgroup ORDER BY name ');
    SqlManager.SelectSQL.Text := GetSelectFromObjects(AIdGroup);
    DocStruDescriptionList.Clear;
    DocStruDescriptionList.Add('idgroup','','IDGROUP','IDGROUP',4,'',4,False,True,nil);
    DocStruDescriptionList.Add('idobject','','IDOBJECT','IDOBJECT',4,'',4,False,True,nil);
    DocStruDescriptionList.Add('name','','Наименование','Наименование',60,'',60,False,False,
      TBindingDescription.GetBindingDescription(TEditVkVariableBinding));
    DocValidator.NotNullList.Add('name');
    DocStruDescriptionList.Add('isgroup','','ISGROUP','ISGROUP',4,'',4,False,True,nil);
    AddAttributesToDocStru;
  end;
end;

procedure TObjectsDm.SetBranchedNode(const Value: TMemRecViewEh);
begin
  FBranchedNode := Value;
end;

procedure TObjectsDm.SetTypeDmObjects(const Value: TTypeDmObjects);
begin
  FObjectsTypeDm := Value;
{  if FDmObjectsType = DmoTypeGroups then
  begin
    OnDocAfterOpen := GrMemTableEhDocAfterOpen;
    OnDocBeforeClose := GrMemTableEhDocBeforeClose;
  end;}
end;

end.
