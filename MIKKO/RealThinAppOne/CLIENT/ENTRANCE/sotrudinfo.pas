unit sotrudinfo;

interface
  uses  classes,   rtcTypes, rtcInfo;

const
  FLD_KODKLI = 'kodkli';
  FLD_NAME = 'name';
  FLD_GRTIMEOUT = 'grTimeOut';
  FLD_ISVALIDGROUP = 'isValidGroup';
  FLD_DATEFIRE = 'dateFire';
  FLD_ISBARCODEACCESS = 'isBarCodeAccess';
  FLD_INN = 'INN';

type
  TSotrudInfo = record
    kodkli: Integer;
    grTimeOut: TTime;
    name: String;
    isValidGroup: boolean;
    dateFire: TDateTime;
    isBarcodeAccess: boolean;
    inn: String;
    procedure SetKodKli(AId: Integer);
    procedure setRecord(ARec: TRtcRecord);
  end;


implementation

{ TSotrudInfo }

procedure TSotrudInfo.SetKodKli(AId: Integer);
begin
  kodkli := AId;
  grTimeOut := 0;
  name := '';
  inn := '';
  isValidGroup := false;
  dateFire := 0;
  isBarcodeAccess := false;
end;

procedure TSotrudInfo.setRecord(ARec: TRtcRecord);
begin
  kodkli := aRec.asInteger[FLD_KODKLI];
  name   := aRec.asString[FLD_NAME];
  grTimeOut := aRec.asFloat[FLD_GRTIMEOUT];
  isValidGroup := aRec.asBoolean[FLD_ISVALIDGROUP];
  dateFire := aRec.asFloat[FLD_DATEFIRE];
  isBarcodeAccess := aRec.asBoolean[FLD_ISBARCODEACCESS];
  inn := aRec.asString[FLD_INN];
end;

end.
