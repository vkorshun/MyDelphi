unit DmRtcCustom;

interface

uses
  SysUtils, Classes, rtcFunction, rtcSrvModule, rtcInfo, rtcConn, rtcDataSrv,
  Generics.Collections, SQLTableProperties, Variants,
  uRtcDmList, DB, rtcSyncObjs, fbApiQuery, IB;

type

  TRtcCustomDm = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    // FUserList: TRemoteUserList;
    FCs: TRtcCritSec;
  protected
    class var FRtcServer: TRtcDataServer;
    procedure RegisterRtcFunction(const aname: String;
      FExecute: TRtcFunctionCallEvent);
    function GetDefaultGroup: TRtcFunctionGroup; virtual;
  public
    { Public declarations }
    function GetDmMainUib(AConnection: TRtcConnection): TDataModule;
    // procedure AddUser(const AUserInfo:PUserInfo; ARtcConnect:TRtcConnection);virtual;
    // procedure DeleteUser(ARtcConnect:TRtcConnection);virtual;
    property CriticalSection: TRtcCritSec read FCs;
    procedure CsLock;
    procedure CsUnlock;
    function RTC_FBAPI2FIELD_TYPE(nType: Cardinal; nSubType: Integer; Scale: Integer): TRtcFieldTypes;
    procedure QueryToRtc(AQuery: TFbApiQuery; rtcDS: TRtcDataSet;
        ClearFieldDefs: boolean = True; OnlyDataFields: boolean = True);
//    procedure bindRtcServer(const Value: TRtcDataServer);virtual;
    procedure SetRtcServer(const Value: TRtcDataServer);virtual;


  end;

  // function GetDataSetFieldType(AResult:TSQlResult; AIndex: Integer):TFieldType;

var
  RtcCustomDm: TRtcCustomDm;

implementation

{$R *.dfm}
{ TDmRtcCustom }

{ procedure TDmRtcCustom.AddUser(const AUserInfo:PUserInfo; ARtcConnect: TRtcConnection);
  var p:PUserListItem;
  begin
  FCs.Acquire;
  try
  New(p);
  p.RtcConnect := ArtcConnect;
  p.UserInfo := AUserInfo;
  FUserList.Add(p);
  finally
  FCs.Release;
  end;
  end;

  procedure TDmRtcCustom.DeleteUser(ARtcConnect:TRtcConnection);
  var i: Integer;
  begin
  for I := 0 to FUserList.Count-1 do
  begin
  if FUserList[i].RtcConnect=ARtcConnect then
  begin
  Dispose(FUserList[i].UserInfo);
  FUserList.Delete(i);
  Break;
  end;
  end;

  end;
}

procedure TRtcCustomDm.CsLock;
begin
  FCs.Acquire;
end;

procedure TRtcCustomDm.CsUnlock;
begin
  FCs.Release;
end;

procedure TRtcCustomDm.DataModuleCreate(Sender: TObject);
begin
  FCs := TRtcCritSec.Create;
  if Assigned(FRtcServer)  then
    SetRtcServer(FRtcServer);
end;

procedure TRtcCustomDm.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FCs);
  Inherited;
end;

function TRtcCustomDm.GetDefaultGroup: TRtcFunctionGroup;
var component: TComponent;
    i: Integer;
begin
  Result := nil;
  for i:=0 to ComponentCount-1 do
  begin
    component := Components[i];
    if component is TRtcFunctionGroup then
    begin
      Result := TRtcFunctionGroup(component);
      Exit;
    end;
  end;
end;

function TRtcCustomDm.GetDmMainUib(AConnection: TRtcConnection): TDataModule;
begin
  Result := RtcDmList.GetDmOnRtc(AConnection, TDataModule);
end;

procedure TRtcCustomDm.RegisterRtcFunction(const aname: String;
  FExecute: TRtcFunctionCallEvent);
var
  mRtcFunction: TRtcFunction;
begin
  mRtcFunction := TRtcFunction.Create(self);
  with mRtcFunction do
  begin
    FunctionName := aname;
    Group := GetDefaultGroup;
    OnExecute := FExecute;
  end;
end;

function TRtcCustomDm.RTC_FBAPI2FIELD_TYPE(nType: Cardinal; nSubType: Integer; Scale: Integer ): TRtcFieldTypes;
begin
  case nType of
    SQL_VARYING, SQL_TEXT:
      Result := ft_String;
    SQL_DOUBLE, SQL_FLOAT:
      Result := ft_Float;
    SQL_LONG:
      Result := ft_Integer;
    SQL_SHORT:
      Result := ft_Smallint;
    SQL_TIMESTAMP:
      Result := ft_DateTime;
    SQL_BLOB:
      if nSubType=1 then
        Result := ft_Memo
      else
        Result := ft_Blob;
    SQL_D_FLOAT:
      Result := ft_BCD;
    SQL_ARRAY:
      Result := ft_Array;
    SQL_QUAD:
      Result := ft_Largeint;
    SQL_TYPE_TIME:
      Result := ft_Time;
    SQL_TYPE_DATE:
      Result := ft_Date;
    SQL_INT64:
      case Scale of
        0: Result := ft_Largeint;
        -2: Result := ft_Currency;
        else
          Result := ft_Float;
      end;
    SQL_BOOLEAN:
      Result := ft_Boolean;
    // SQL_DATE: Result := ftDateTime;
    SQL_DECFLOAT16:
      Result := ft_BCD;
    SQL_DECFLOAT34:
      Result := ft_BCD;
  end;
end;

procedure TRtcCustomDm.SetRtcServer(const Value: TRtcDataServer);
var i: Integer;
begin
  if not Assigned(FRtcServer) then
    FRtcServer := Value;
  for i := 0 to ComponentCount-1 do
  begin
    if (Components[i] is TRtcDataServerLink) and (Components[i] <> self) then
      TRtcDataServerLink(Components[i]).Server := FRtcServer;
  end;

end;

procedure TRtcCustomDm.QueryToRtc(AQuery: TFbApiQuery; rtcDS: TRtcDataSet;
  ClearFieldDefs: boolean = True; OnlyDataFields: boolean = True);
var
  flds: integer;
  fldname: string;
  //field: ISQLData;
  fstream: TStream;
  fbtype: Cardinal;
  FldType: TRtcFieldTypes;
  scale: Integer;
begin
  if ClearFieldDefs then
  begin
    rtcDS.Clear;
    for flds := 0 to AQuery.FieldCount - 1 do
    begin
      fbtype := AQuery.FieldsMetadata[flds].SQLType;
      fldname := AQuery.FieldsMetadata[flds].Name;
//      field := AQuery.Fields[flds];
      if fldname <> '' then
      begin
        FldType := RTC_FBAPI2FIELD_TYPE(fbtype, AQuery.FieldsMetadata[flds].SQLSubtype, AQuery.FieldsMetadata[flds].Scale);
        rtcDS.SetField(fldname, FldType, AQuery.FieldsMetadata[flds].Size);
      end;
    end;
  end;

  while not AQuery.EOF do
  begin
    rtcDS.Append;
    for flds := 0 to rtcDS.FieldCount - 1 do
    begin
      fbtype := AQuery.Fields[flds].SQLType;
      fldname := AQuery.Fields[flds].Name;
      scale := AQuery.Fields[flds].Scale;
      if (AQuery.Fields[flds].isNull) then
        rtcDS.asValue[fldname] := null
      else
      begin
      case fbtype of

        SQL_VARYING, SQL_TEXT:
          rtcDS.asWideString[fldname]:= AQuery.Fields[flds].AsString;
        SQL_DOUBLE, SQL_FLOAT:
          rtcDS.asFloat[fldname] := AQuery.Fields[flds].AsFloat;
        SQL_LONG:
          rtcDS.asInteger[fldname] := AQuery.Fields[flds].AsInteger;
        SQL_SHORT:
          rtcDS.asInteger[fldname] := AQuery.Fields[flds].AsShort;
        SQL_TIMESTAMP:
          rtcDS.asDatetime[fldname] := AQuery.Fields[flds].AsDateTime;
        SQL_BLOB:
          //if AQuery.Fields[flds].SQLSubtype = 1 then
          rtcDS.AsWideString[fldname] := AQuery.Fields[flds].AsBlob.AsString;
        // SQL_D_FLOAT: rtcDS.Value[fldName].AsBCD := AQuery.Fields[flds].AsBCD;
//        SQL_ARRAY:
//          rtcDS.asArray[fldname] := AQuery.Fields[flds].AsArray;
        SQL_QUAD:
          rtcDS.asLargeInt[fldname] := AQuery.Fields[flds].AsInt64;
        SQL_TYPE_TIME:
          rtcDS.asDateTime[fldname] := AQuery.Fields[flds].AsTime;
        SQL_TYPE_DATE:
          rtcDS.asDateTime[fldname] := AQuery.Fields[flds].AsDate;
        SQL_INT64:
           case Scale of
             0: rtcDS.asLargeInt[fldname] := AQuery.Fields[flds].AsInt64;
             -2: rtcDS.asCurrency[fldname] := AQuery.Fields[flds].AsCurrency;
           else
              rtcDS.asFloat[fldname] := AQuery.Fields[flds].AsFloat;
           end;


        SQL_BOOLEAN:
          rtcDS.asBoolean[fldname] := AQuery.Fields[flds].AsBoolean;
        // SQL_DATE: Result := ftDateTime;
        // SQL_DECFLOAT16: rtcDS.Value[fldName].AsBCD := AQuery.Fields[flds].AsBCD;
        // SQL_DECFLOAT34: rtcDS.Value[fldName].AsBCD := AQuery.Fields[flds].AsBCD;
      end;
      end;
    end;
    AQuery.Next;
  end;
end;

end.

  procedure UIBQueryToRtc
(AUibQuery: TUIBQuery; rtcDS: TRtcDataSet; ClearFieldDefs: boolean = True;
  OnlyDataFields: boolean = True);

var
  flds: integer;
  fldname: string;
  field: TSQLDA;
  fstream: TStream;
  uibtype: TUIBFieldType;

begin
  if ClearFieldDefs then
  begin
    rtcDS.Clear;
    for flds := 0 to AUibQuery.Fields.FieldCount - 1 do
    begin
      uibtype := AUibQuery.Fields.FieldType[flds];
      fldname := AUibQuery.Fields.AliasName[flds];
      if fldname <> '' then
      begin
        rtcDS.SetField(fldname, RTC_UIB2FIELD_TYPE(GetDataSetFieldType(uibtype)
          ), field.Size, field.Required);
      end;
    end;

    while not AUibQuery.EOF do
    begin
      rtcDS.Append;
      for flds := 0 to rtcDS.FieldCount - 1 do
      begin
        fldname := rtcDS.FieldName[flds];
        if AUibQuery.Fields.isBlob[flds] then
        begin
          { begin
            fstream:=DelphiDS.CreateBlobStream(field,bmRead);
            try
            ( (field.DataType = ftGraphic) or
            (field.DataType = ftTypedBinary) ) then
            RtcSkipGraphicFieldHeader(fstream);
            rtcDS.NewByteStream(fldname).CopyFrom(fstream,fstream.Size-fstream.Position);
            finally
            fstream.Free;
            end;
            end
            else }
        end
        else
        begin
          case RTC_FIELD2VALUE_TYPES[rtcDS.FieldType[fldname]] of
            rtc_Currency:
              rtcDS.asCurrency[fldname] := AUibQuery.Fields.asCurrency[flds];
            rtc_DateTime:
              rtcDS.AsDateTime[fldname] := AUibQuery.Fields.AsDateTime[flds];
            rtc_String:
              rtcDS.AsString[fldname] :=
                RtcString(AUibQuery.Fields.AsString[flds]);
            // rtc_Text: rtcDS.asText[fldname]:=field.AsWideString;
          else
            rtcDS.Value[fldname] := AUibQuery.Fields.AsVariant[flds];

          end;
        end;
      end;
    end;
    AUibQuery.Next;
  end;
end;

procedure DelphiFieldsToRtc(const DelphiDS: TDataSet; const rtcDS: TRtcDataSet);
var
  flds: integer;
  fldname: string;
  field: TField;
begin
  for flds := 0 to DelphiDS.Fields.Count - 1 do
  begin
    field := DelphiDS.Fields[flds];
    if assigned(field) then
    begin
      fldname := field.FieldName;
      if field.FieldKind = fkData then
        rtcDS.SetField(fldname, RTC_DB2FIELD_TYPE(field.DataType), field.Size,
          field.Required);
    end;
  end;
end;

procedure DelphiRowToRtc(const DelphiDS: TDataSet; const rtcDS: TRtcDataSet);
var
  flds: integer;
  fldname: string;
  field: TField;
  fstream: TStream;
begin
  rtcDS.Append;
  for flds := 0 to rtcDS.FieldCount - 1 do
  begin
    fldname := rtcDS.FieldName[flds];
    field := DelphiDS.FindField(fldname);
    if assigned(field) then
      if (field.FieldKind = fkData) and not field.IsNull then
        if field.isBlob then
        begin
          fstream := DelphiDS.CreateBlobStream(field, bmRead);
          try
            if {$IFNDEF FPC} TBlobField(field).GraphicHeader and {$ENDIF}
              ((field.DataType = ftGraphic) or (field.DataType = ftTypedBinary))
            then
              RtcSkipGraphicFieldHeader(fstream);
            rtcDS.NewByteStream(fldname).CopyFrom(fstream,
              fstream.Size - fstream.Position);
          finally
            fstream.Free;
          end;
        end
        else
          case RTC_FIELD2VALUE_TYPES[rtcDS.FieldType[fldname]] of
            rtc_Currency:
              rtcDS.asCurrency[fldname] := field.asCurrency;
            rtc_DateTime:
              rtcDS.AsDateTime[fldname] := field.AsDateTime;
            rtc_String:
              rtcDS.AsString[fldname] := RtcString(field.AsString);
            // rtc_Text: rtcDS.asText[fldname]:=field.AsWideString;
          else
            rtcDS.Value[fldname] := field.Value;
          end;
  end;
end;

function GetDataSetFieldType(AResult: TSQlResult; AIndex: integer): TFieldType;
var
  i: integer;
  DataType: TFieldType;
begin

  case AResult.FieldType[AIndex] of
    uftNumeric:
      begin
        case AResult.SQLType[i] of
          SQL_SHORT:
            begin
              DataType := ftBCD;
            end;
          SQL_LONG:
            begin
              DataType := ftFMTBcd
            end;
          SQL_INT64, SQL_QUAD:
            begin
              DataType := ftFMTBcd
            else
              // DataType := ftBCD;
          end;
          SQL_D_FLOAT, SQL_DOUBLE:
            DataType := ftFloat; // possible
        end;
      end;
    uftChar, uftCstring, uftVarchar:
      begin
        DataType := ftWideString;
      end;
    uftSmallint:
      DataType := ftSmallint;
    uftInteger:
      DataType := ftInteger;
    uftFloat, uftDoublePrecision:
      DataType := ftFloat;
    uftTimestamp:
      DataType := ftDateTime;
    uftBlob, uftBlobId:
      begin
        if AResult.IsBlobText[AIndex] then
          DataType := ftWideMemo
        else
          DataType := ftBlob;
      end;
    uftDate:
      DataType := ftDate;
    uftTime:
      DataType := ftTime;
    uftInt64:
      DataType := ftLargeint;
    uftBoolean:
      DataType := ftBoolean;
  else
    DataType := ftUnknown;
  end;

end;
finally
end;


end;
