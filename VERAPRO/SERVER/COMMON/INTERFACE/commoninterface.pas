unit commoninterface;

interface

uses
  SysUtils, Classes, Windows, rtcInfo, rtcConn, rtcDataSrv, rtcHttpSrv,rtcHttpCli, rtti, System.TypInfo,
  vkvariable, Variants;

//const
{  TRDefault                 : TTransParams = [tpConcurrency,tpWait,tpWrite];
  TRReadOnlyTableStability  : TTransParams = [tpRead, tpConsistency];
  TRReadWriteTableStability : TTransParams = [tpWrite, tpConsistency];}
{*  TRSnapShot                : TTransParams = [tpConcurrency, tpNowait];
  TRReadCommitted           : TTransParams = [tpReadCommitted, tpRecVersion, tpNowait];
  TRReadOnly : TTransParams = [tpRead,tpReadCommitted, tpRecVersion, tpNowait];
  TRWriteTableStability: TTransParams = [tpWrite, tpConsistency,tpNowait];*}

type
  //userInfo record
  PUserInfo = ^RUserInfo;
  RUserInfo = Record
    id_group      :Integer;
    id_user       :Integer;
    id_menu       :Integer;
    user_name     :string;
    user_password :string;
    g_user_name   :string;
    g_role_name   :string;
  end;
  TDocOperation = (docInsert, docUpdate, docDelete);

  TUtils = class(TObject)
  private
  public
    class procedure CloneComponent(const aSource, aDestination: TComponent);
    class procedure ObjectToRtcValue(AObject:TObject; ARecord: TRtcRecord);
    class procedure RtcValueToObject( ARecord: TRtcRecord;AObject: TObject);
    class procedure VkVariableColectionsToRtc(AVariables: TVkVariableCollection; ARecord: TRtcRecord);
    class procedure RtcToVkVariableColections( ARecord: TRtcRecord; AVariables: TVkVariableCollection);
    class function getDocCommand(AOperation: TDocOperation):String;
    class function getDocOperation(ACommand: String):TDocOperation;
    class function RtcArrayToVarArray(const ARtcArray: TRtcArray): Variant;
  end;

  TTableAction = class(TObject)
    private
    FParams: TVkVariableCollection;
    FAction: String;
    procedure SetAction(const Value: String);
    procedure SetParams(const Value: TVkVariableCollection);
    public
      property Action: String read FAction write SetAction;
      property Params:TVkVariableCollection read FParams write SetParams;
  end;

var
  ListBpl: TStringList;

implementation


{ TUtils }

class procedure TUtils.CloneComponent(const aSource, aDestination: TComponent);
var
  ctx: TRttiContext;
  RttiType, DestType: TRttiType;
  RttiProperty: TRttiProperty;
  Buffer: TStringlist;

begin
  if aSource.ClassType <> aDestination.ClassType then
    raise Exception.Create('Source and destiantion must be the same class');

  Buffer := TStringlist.Create;
  try
    Buffer.Sorted := True;
    Buffer.Add('Name');
    Buffer.Add('Handle');

    RttiType := ctx.GetType(aSource.ClassType);
    DestType := ctx.GetType(aDestination.ClassType);
    for RttiProperty in RttiType.GetProperties do
    begin
      if not RttiProperty.IsWritable then
        continue;

      if Buffer.IndexOf(RttiProperty.Name) >= 0 then
        continue;

      DestType.GetProperty(RttiProperty.Name).SetValue(aDestination, RttiProperty.GetValue(aSource));
    end;
  finally
    Buffer.Free;
  end;

end;

class function TUtils.getDocCommand(AOperation: TDocOperation): String;
begin
    Result := 'undefined';
    if AOperation = docInsert then
      Result := 'insert'
    else if AOperation = docUpdate then
      Result := 'update'
    else if AOperation = docDelete then
      Result := 'delete'
end;

class function TUtils.getDocOperation(ACommand: String): TDocOperation;
begin
  if SameText(ACommand,'insert') then
    Result := docInsert
  else  if SameText(ACommand,'update') then
    Result := docUpdate
  else  if SameText(ACommand,'delete') then
    Result := docDelete
  else
    raise Exception.Create('Undefined command');
end;

class procedure TUtils.ObjectToRtcValue(AObject: TObject; ARecord: TRtcRecord);
var
  ctx: TRttiContext;
  RttiType, DestType: TRttiType;
  RttiProperty: TRttiProperty;
  _obj: TObject;
begin
   if Assigned(AObject) then
   begin
     ctx := TRttiContext.Create;
     try
       RttiType := ctx.GetType(AObject.ClassType);
       for RttiProperty in RttiType.GetProperties do
       begin
          case RttiProperty.PropertyType.TypeKind of
            tkInteger: ARecord.asInteger[RttiProperty.Name] := RttiProperty.GetValue(AObject).AsInteger;
            tkChar: ARecord.asString[RttiProperty.Name] := RttiProperty.GetValue(AObject).AsString;
            tkFloat: ARecord.asFloat[RttiProperty.Name] := RttiProperty.GetValue(AObject).AsExtended;
            tkString,
            tkUString,
            tkLString: ARecord.asString[RttiProperty.Name] := RttiProperty.GetValue(AObject).AsString;
            tkInt64: ARecord.asLargeInt[RttiProperty.Name] := RttiProperty.GetValue(AObject).AsInt64;
            tkVariant: ARecord.asValue[RttiProperty.Name] := RttiProperty.GetValue(AObject).AsVariant;
            tkEnumeration:
            if (RttiProperty.PropertyType.IsOrdinal and SameText('Boolean',RttiProperty.PropertyType.Name)) then
              ARecord.asBoolean[RttiProperty.Name] := RttiProperty.GetValue(AObject).AsBoolean;
            tkClass,
            tkRecord,
            tkClassRef:
              begin
                if (RttiProperty.GetValue(AObject).IsObject) then
                begin
                  _obj := RttiProperty.GetValue(AObject).AsObject;
                  if _obj is TStrings then
                  begin
                    if (TStrings(_obj).Count > 0) then
                      ARecord.asString[RttiProperty.Name] := TStrings(_obj).Text
                    else
                      ARecord.asString[RttiProperty.Name] := '';
                  end
                  else
                  begin
                    ARecord.NewRecord(RttiProperty.Name);
                    TUtils.ObjectToRtcValue(_obj, ARecord.asRecord[RttiProperty.Name])
                  end;
                end;
              end;

          end;
       end;
     finally
       ctx.Free;
     end;

   end
end;

class function TUtils.RtcArrayToVarArray(const ARtcArray: TRtcArray): Variant;
var v: Variant;
    i: Integer;
begin
  Result := VarArrayCreate([0, ARtcArray.Count-1], varVariant);
  for I := 0 to ARtcArray.Count-1 do
    Result[i] := ArtcArray.asValue[i];
end;

class procedure TUtils.RtcToVkVariableColections(ARecord: TRtcRecord; AVariables: TVkVariableCollection);
var i: Integer;
    name: String;
    vk: TVkVariable;
begin
  if Assigned(ARecord) then
  begin
    for i:=0 to ARecord.FieldCount-1 do
    begin
      name := ARecord.FieldName[i];
      vk := AVariables.FindVkVariable(name);
      if Assigned(vk) then
        vk.Value := ARecord.asValue[name]
      else
        AVariables.AddItem(name, ARecord.asValue[name]);
    end;
  end;
end;

class procedure TUtils.RtcValueToObject( ARecord: TRtcRecord;AObject: TObject);
var
  ctx: TRttiContext;
  RttiType, DestType: TRttiType;
  RttiProperty: TRttiProperty;
  _obj: TObject;
begin
   if Assigned(AObject) then
   begin
     ctx := TRttiContext.Create;
     try
       RttiType := ctx.GetType(AObject.ClassType);
       for RttiProperty in RttiType.GetProperties do
       begin
          if not ARecord.isNull[RttiProperty.Name] and (RttiProperty.IsWritable or RttiProperty.GetValue(AObject).IsObject)then
          case RttiProperty.PropertyType.TypeKind of
            tkInteger: RttiProperty.SetValue(AObject, ARecord.asInteger[RttiProperty.Name]);
            tkChar: RttiProperty.SetValue(AObject, ARecord.asString[RttiProperty.Name]) ;
            tkFloat: RttiProperty.SetValue(AObject,ARecord.asFloat[RttiProperty.Name]);
            tkString,
            tkUString,
            tkLString: RttiProperty.SetValue(AObject,ARecord.asString[RttiProperty.Name]);
            tkInt64: RttiProperty.SetValue(AObject,ARecord.asLargeInt[RttiProperty.Name]);
            tkVariant: RttiProperty.SetValue(AObject,TValue.FromVariant(ARecord.asValue[RttiProperty.Name]));
            tkEnumeration:
            if (RttiProperty.PropertyType.IsOrdinal and SameText('Boolean',RttiProperty.PropertyType.Name)) then
              RttiProperty.SetValue(AObject,ARecord.asBoolean[RttiProperty.Name]);
            tkClass,
            tkRecord,
            tkClassRef:
              begin
                if (RttiProperty.GetValue(AObject).IsObject) then
                begin
                  _obj := RttiProperty.GetValue(AObject).AsObject;
                  if _obj is TStrings then
                  begin
//                    if (TStrings(_obj).Count > 0) then
                    TStrings(_obj).Text :=  ARecord.asString[RttiProperty.Name];
//                    else
//                      ARecord.asString[RttiProperty.Name] := '';
                  end
                  else
                  begin
                    TUtils.RtcValueToObject(ARecord.asRecord[RttiProperty.Name], _obj);
                  end;
                end;
              end;

          end;
       end;
     finally
       ctx.Free;
     end;

   end
end;


class procedure TUtils.VkVariableColectionsToRtc(AVariables: TVkVariableCollection; Arecord: TRtcRecord);
var vk: TVkvariable;
    i: Integer;
begin
  for i:=0 to AVariables.Count-1 do
  begin
     vk := AVariables.Items[i];
     Arecord.asValue[vk.Name] := vk.Value;
  end;

end;

{ TTableAction }

procedure TTableAction.SetAction(const Value: String);
begin
  FAction := Value;
end;

procedure TTableAction.SetParams(const Value: TVkVariableCollection);
begin
  FParams := Value;
end;

  function getCommand(operation: TDocOperation): String;
  begin

  end;


end.
