unit systemconsts;

interface

uses classes, vkvariable;
const
  ATTRIBUTES_OKU = 1;
  ATTRIBUTES_OAU = 2;

const
// Access
//*******************************************************************************
//* ����� �������. ���������, ������������ �������� GetAccessRights              *
//*******************************************************************************/
//����� ������� �����������
 ACCESS_NONE =   0 ;
//������������ ����� ����� �� ������ ������
 ACCESS_READ =   1;
//������������ ����� ����� ������� �� ��������� ������
 ACCESS_EDIT =   2;
//������������ ����� ���������� ������
 ACCESS_INS  =   3;
//������������ ����� ����� ������� �� �������� ������
 ACCESS_DEL  =   4;
//������������ ����� ����� ������� �� �������� �����
 ACCESS_CLOSE =  5;

///*******************************************************************************
//* ���� ��������, ������ � ������� ����������������                             *
//*******************************************************************************/
//����
ACCESS_MENU          = 1 ;
//��������
ACCESS_DOCUMENT      = 2;
//����
ACCESS_ACCOUNT       = 3;
//������������
ACCESS_ENTERPRIZE    = 4;
//���
ACCESS_OTREE         = 5;

ACCESS_OU = 116; // ACCESS_OKU + ACCESS_OAU
//������� ����� �����
ACCESS_OKU           = 6 ;
//������� ���� �����
ACCESS_OAU           = 7 ;

ACCESS_PAR   = 118 ; // ACCESS_PAROKU + ACCESS_PAROAU
//��������� ������ ����� �����
ACCESS_PAROKU        = 8 ;
//��������� �������� ���� �����
ACCESS_PAROAU        = 9;

//������
ACCESS_OPLATA        = 10;
//�����
ACCESS_REPORT        = 11;

//������ ���  - ����� ������ ���������
ACCESS_GOKU          = 12;
//������ ���  - ����� ������ ���������
ACCESS_GOAU          = 13;

//�������� �������
ACCESS_PROPREPORT    = 14;

// ������ � �������� = ACCESS_OKUWITHGROUP + ACCESS_OAUWITHGROUP
ACCESS_OBJECTS       = 115;
//������� ����� ����� �� �������
ACCESS_OKUWITHGROUP  = 15;        // 15
//������� ���� �����  �� �������
ACCESS_OAUWITHGROUP  = 16;        // 15
//������������
ACCESS_PRICE         = 17;
//������ �� ������� � Excel
ACCESS_BAN_ALT_P     = 18;
//������ �� ������� � HTML
ACCESS_BAN_ALT_H     = 19;
//������ � OLAP
ACCESS_OLAP          = 20;
//������ � ����������
ACCESS_COMPARE       = 21;
//������ � ������������
ACCESS_CALCULATOR    = 22;
//������ � �������
ACCESS_SQLREPORT     = 23;
//������ � ��������
ACCESS_CONTOUR       = 50;
ACCESS_CONTOUR_GROUP = 51;



  TA_STRING = 0;
  TA_NUMERIC = 1;
  TA_DATE = 2;
  TA_LOGICAL = 3;
  TA_TIMESTAMP = 4;
  TA_TIME = 5;
  TA_OBJECT = 6;
  TA_GROUP = 7;
  TA_CURRENCY = 8;
  TA_ACCOUNT = 9;

  ID_EMPTY = 0;
  IDGROUP_OAU = 2;
  IDGROUP_OKU = 1;
  IDGROUP_CURRENCY = 3;
  IDGROUP_EDIZM = 4;
  IDGROUP_SYSTEM = 5;

  FLD_ATTR_VAL = 'VAL';
  FLD_ATTR_V_INT = 'V_INT';
  FLD_ATTR_V_DOUBLE = 'V_DOUBLE';
  FLD_ATTR_V_CURRENCY = 'V_CURRENCY';
  FLD_ATTR_V_DATA = 'V_DATA';
  FLD_ATTR_V_BOOLEAN = 'V_BOOLEAN';
  FLD_ATTR_V_BLOB = 'V_BLOB';

//------- MEnuItem - Event
  MI_NONE           = 0;
  MI_USERSACCESS    = 1;
  MI_OPENDOC        = 2;
  MI_VIEWACCOUNT    = 3;
  MI_VIEWOAU        = 4;
  MI_VIEWOKU        = 5;
  MI_VIEWOVU        = 6;
  MI_ATTROAU         = 7;
  MI_ATTROKU         = 8;
  MI_ATTROVU         = 9;
  MI_WORKPERIOD     = 10;
  MI_CALC           = 11;
  MI_CALENDAR       = 12;
  MI_ARC            = 13;
  MI_NORMAL         = 14;
  MI_KURS           = 15;
  MI_LISTENTERPRIZE = 16;
  MI_WINDOWS        = 17;
  MI_EXIT           = 18;
  MI_REPORT         = 19;
  MI_MENUEDITOR     = 20;

  function Get_mi_id(aIndex:Integer):Integer;
  function GetIndexOf_mi_id(aIndex:Integer):Integer;

var miList: TVkVariableCollection;
implementation

function Get_mi_id(aIndex:Integer):Integer;
begin
  Result := miList.Items[aIndex].Value;
end;

function GetIndexOf_mi_id(aIndex:Integer):Integer;
var i: Integer;
begin
  Result := -1;
  for i := 0 to miList.Count - 1 do
    if miList.Items[i].Value=aIndex then
    begin
      Result := i;
      Break;
    end;
end;

initialization
  miList := TVkVariableCollection.Create(nil);
  with miList do
  begin
    AddItem('MI_NONE',MI_NONE);
    AddItem('MI_USERSACCESS',MI_USERSACCESS);
    AddItem('MI_OPENDOC', MI_OPENDOC);
    AddItem('MI_REPORT', MI_REPORT);
    AddItem('MI_VIEWACCOUNT', MI_VIEWACCOUNT);
    AddItem('MI_VIEWOAU', MI_VIEWOAU);
    AddItem('MI_VIEWOKU',MI_VIEWOKU);
    AddItem('MI_VIEWOVU', MI_VIEWOVU);
    AddItem('MI_ATTROAU', MI_ATTROAU);
    AddItem('MI_ATTROKU', MI_ATTROKU);
    AddItem('MI_ATTROVU', MI_ATTROVU);
    AddItem('MI_WORKPERIOD', MI_WORKPERIOD);
    AddItem('MI_CALC',MI_CALC);
    AddItem('MI_CALENDAR',MI_CALENDAR);
    AddItem('MI_ARC', MI_ARC);
    AddItem('MI_NORMAL', MI_NORMAL);
    AddItem('MI_KURS', MI_KURS);
    AddItem('MI_LISTENTERPRIZE',MI_LISTENTERPRIZE);
    AddItem('MI_WINDOWS', MI_WINDOWS);
    AddItem('MI_EXIT', MI_EXIT);
    AddItem('MI_MENUEDITOR', MI_MENUEDITOR);
  end;

finalization
  miList.Free;
end.
