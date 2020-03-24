unit QueryUtils;

interface

uses
  System.SysUtils, System.Classes, rtcFunction, rtcInfo,ServerDocSqlmanager,FB30Statement, fbapidatabase, fbapiquery,
  commoninterface, vkvariable;

type
  TQueryUtils = class
    class procedure SetQueryParams(AQuery:TFBApiQuery; AParams: TVkVariableCollection);
    class function getTableKeyAsJSON(sqlManager: TServerDocSqlManager; new: TVkVariableCollection):String;
    class function containsParam(AQuery: TFBApiQuery; AParams: TVkVariableCollection): Boolean;
  end;

implementation

{ TQueryUtils }

class function TQueryUtils.getTableKeyAsJSON(sqlManager: TServerDocSqlManager; new: TVkVariableCollection): String;
var json: TRtcRecord;
    i: Integer;
begin
  json := TRtcRecord.Create;
  try
    for I := 0 to sqlManager.SQLTableProperties.KeyFieldsList.Count-1 do
    begin
       json.Value[sqlManager.SQLTableProperties.KeyFieldsList[i]] := new.VarByName(sqlManager.SQLTableProperties.KeyFieldsList[i]).Value;
    end;
    Result := json.toJSON;
  finally
    json.Free;
  end;
end;

class procedure TQueryUtils.SetQueryParams(AQuery: TFBApiQuery; AParams: TVkVariableCollection);
var i: Integer;
    pname: String;
begin
  with AQuery do
  begin
    for I := 0 to (Params.Count-1) do
    begin
      pname := String(Params[i].Name);
      if Assigned(AParams.VarByName(pname)) then
      begin
        Params[i].Value := AParams.VarByName(pname).Value;
      end;
    end;
  end;

end;

class function TQueryUtils.containsParam(AQuery: TFBApiQuery; AParams: TVkVariableCollection): Boolean;
var i: Integer;
    pname: String;
begin
  Result := false;
  with AQuery do
  begin
    for I := 0 to (Params.Count-1) do
    begin
      pname := String(Params[i].Name);
      if Assigned(AParams.VarByName(pname)) then
      begin
        Result := true;
        break;
      end;
    end;
  end;

end;


end.
