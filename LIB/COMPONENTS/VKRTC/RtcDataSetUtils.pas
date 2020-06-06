unit RtcDataSetUtils;

interface

uses
  System.SysUtils, System.Classes, RtcResult, RtcInfo, DB;

const
  TAG_FIELDDEFS = 'fieldDefs';
  TAG_ROWS        = 'rows';
  TAG_CONTENT     = 'content';
  TAG_NAME = 'name';
  TAG_TYPE = 'type';
  TAG_PRECISION = 'precission';
  TAG_SCALE = 'sacale';

type
  TRtcDataSetUtils = class(TObject)
  private
  public
    class procedure RtcJsonRowsToDelphi(fldDefs: TRtcArray; rtcRows: TRtcArray;
      DelphiDS: TDataSet);
    class procedure RtcJsonFieldsToDelphi(fldDefs: TRtcArray; DelphiDS: TDataSet);
    class function getFieldDefs(val:IRtcResult):TRtcArray;
    class function getDataRows(val:IRtcResult):TRtcArray;
    class function RtcJDBC2DelphiType(const rFieldDef: TRtcRecord):TFieldType;
  end;

implementation

{ TRtcDataSetUtils }

class function TRtcDataSetUtils.getDataRows(val: IRtcResult): TRtcArray;
begin
  Result := val.Result.asRecord.asRecord[TAG_CONTENT].asArray[TAG_ROWS];
end;

class function TRtcDataSetUtils.getFieldDefs(val: IRtcResult): TRtcArray;
begin
  Result := val.Result.asRecord.asRecord[TAG_CONTENT].asArray[TAG_FIELDDEFS];
end;

class function TRtcDataSetUtils.RtcJDBC2DelphiType(
  const rFieldDef: TRtcRecord): TFieldType;
var
  JDBCType: String;
  scale : Integer;
begin
  JDBCType := rFieldDef.asString[TAG_TYPE];
  scale := rFieldDef.asInteger[TAG_SCALE];
   if (JDBCType.Equals('D')) then
     Result := ftDate
   else
   if (JDBCType.Equals('TS')) then
     Result := ftDateTime
   else
   if (JDBCType.Equals('T')) then
     Result := ftTime
   else
   if (JDBCType.Equals('BINARY')) then
     Result := ftBlob
   else
   if (JDBCType.Equals('BIGINT')) then
     Result := ftLargeint
   else
   if (JDBCType.Equals('L')) then
     Result := ftBoolean
   else
   if (JDBCType.Equals('BLOB')) then
     Result := ftBlob
   else
   if (JDBCType.Equals('CLOB')) then
     Result := ftMemo
   else
   if (JDBCType.Equals('N')) then
   begin
     if (scale < 5 ) then
       Result := ftBCD
     else
       Result := ftFMTBcd;
   end
   else
   if (JDBCType.Equals('I')) then
     Result := ftInteger
   else
     Result := ftString;


end;

class procedure TRtcDataSetUtils.RtcJsonFieldsToDelphi(fldDefs: TRtcarray;
  DelphiDS: TDataSet);
var
  flds: integer;
  fldname: RtcWideString;
  rFieldDef: TRtcRecord;
  fldType: TFieldType;
begin
  DelphiDS.Active := False;
  DelphiDS.FieldDefs.Clear;
  if fldDefs = nil then
    Exit;

  for flds := 0 to fldDefs.Count - 1 do
  begin
    rFieldDef := fldDefs.asRecord[flds];
    fldname := rFieldDef.asString[TAG_NAME];
    fldType := RtcJDBC2DelphiType(rFieldDef);
    if fldType = ftString then
    begin
      DelphiDS.FieldDefs.Add(String(fldname), fldType, rFieldDef.asInteger[TAG_PRECISION], false);
    end
    else
       DelphiDS.FieldDefs.Add(String(fldname), fldType);

    if (fldType = ftBCD) or (fldType = ftFMTBcd) then
      DelphiDS.FieldDefs[DelphiDS.FieldDefs.Count-1].Precision := rFieldDef.asInteger[TAG_SCALE];
  end;
end;

class procedure TRtcDataSetUtils.RtcJsonRowsToDelphi(fldDefs: TRtcArray;
  rtcRows: TRtcArray; DelphiDS: TDataSet);
var
  flds: integer;
  fldname: String;
  field: TField;
  fstream: TStream;
  iRow: integer;
begin
  if not DelphiDS.Active then
    DelphiDS.Active := True;
  if fldDefs = nil then
    Exit;

  iRow := 0;
  while iRow < rtcRows.Count do
  begin
    DelphiDS.Append;
    for flds := 0 to fldDefs.Count - 1 do
    begin
      fldname := fldDefs.asRecord[flds].asString[TAG_NAME];
      field := DelphiDS.FindField(String(fldname));
      if assigned(field) then
        if not rtcRows.asRecord[iRow].isNull[fldname] then
          if not(field is TMemoField) and field.isBlob then
          begin
            fstream := DelphiDS.CreateBlobStream(field, bmWrite);
            try
              //fstream.CopyFrom(rtcDS.asByteStream[fldname],
              //  rtcDS.asByteStream[fldname].Size);
            finally
              fstream.Free;
            end;
          end
          else
            case field.DataType of
              ftCurrency:
                field.AsCurrency := rtcRows.asRecord[iRow].AsCurrency[fldname];
              ftDateTime:
                field.AsDateTime := rtcRows.asRecord[iRow].AsDateTime[fldname];
              ftString:
                field.AsString := String(rtcRows.asRecord[iRow].AsString[fldname]);
            else
              field.Value := rtcRows.asRecord[iRow].Value[fldname];
            end;
    end;
    DelphiDS.Post;
    Inc(iRow);
  end;

end;

{*procedure RtcDataSetFieldsToDelphi(rtcDS: TRtcDataSet; DelphiDS: TDataSet);
var
  flds: integer;
  fldname: RtcWideString;
begin
  DelphiDS.Active := False;
  DelphiDS.FieldDefs.Clear;
  if rtcDS = nil then
    Exit;

  for flds := 0 to rtcDS.FieldCount - 1 do
  begin
    fldname := rtcDS.FieldName[flds];
    if rtcDS.FieldType[fldname] = ft_String then
    begin
      DelphiDS.FieldDefs.Add(String(fldname),
        RTC_FIELD2DB_TYPE(rtcDS.FieldType[fldname]), rtcDS.FieldSize[fldname],
        rtcDS.FieldRequired[fldname]);
    end
    else
      DelphiDS.FieldDefs.Add(String(fldname),
        RTC_FIELD2DB_TYPE(rtcDS.FieldType[fldname]));
  end;
end;*}

end.
