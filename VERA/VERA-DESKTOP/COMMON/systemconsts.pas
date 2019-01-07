unit systemconsts;

interface

uses classes, vkvariable;
const
  ATTRIBUTES_OKU = 1;
  ATTRIBUTES_OAU = 2;

const
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
  MI_PAROAU         = 7;
  MI_PAROKU         = 8;
  MI_PAROVU         = 9;
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
    AddItem('MI_PAROAU', MI_PAROAU);
    AddItem('MI_PAROKU', MI_PAROKU);
    AddItem('MI_PAROVU', MI_PAROVU);
    AddItem('MI_WORKPERIOD', MI_WORKPERIOD);
    AddItem('MI_CALC',MI_CALC);
    AddItem('MI_CALENDAR',MI_CALENDAR);
    AddItem('MI_ARC', MI_ARC);
    AddItem('MI_NORMAL', MI_NORMAL);
    AddItem('MI_KURS', MI_KURS);
    AddItem('MI_LISTENTERPRIZE',MI_LISTENTERPRIZE);
    AddItem('MI_WINDOWS', MI_WINDOWS);
    AddItem('MI_EXIT', MI_EXIT);
  end;

finalization
  miList.Free;
end.
