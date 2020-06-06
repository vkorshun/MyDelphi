unit RtcResult;

interface
uses
  System.SysUtils, System.Classes, rtcInfo;

type
  IRtcResult = interface(IInterface)
    ['{98FE58D3-7918-4032-977A-83FDDCE8A8C4}']
    function GetResult: TRtcValue;
    procedure SetResult(val:TRtcValue);
    property Result:TRtcValue read GetResult write SetResult;
  end;

  TRtcResult = class (TInterfacedObject,IRtcResult)
  private
    FResult: TRtcValue;
    function GetResult: TRtcValue;
    procedure SetResult(val:TRtcValue);
  public
    constructor Create;
    destructor Destroy; override;
    procedure checkError;
    property Result:TRtcValue read GetResult write SetResult;
  end;


implementation

{ TRtcFuncResult }

procedure TRtcResult.checkError;
begin
  if (FResult.isType = rtc_Record) then
  begin
    try
      if (FResult.asRecord.asString['result'] = 'ERROR') then
        raise Exception.Create(fResult.asRecord.asRecord['content'].asString['errorMessage']);
    except
       raise Exception.Create('Incorrect Response format ');
    end;
  end;
end;

constructor TRtcResult.Create();
begin
  inherited create;
  FResult := TRtcValue.Create;
end;

destructor TRtcResult.Destroy;
begin
  if Assigned(FResult) then
    FreeAndNil(FResult);
  inherited;
end;

function TRtcResult.GetResult: TRtcValue;
begin
  Result := FResult;
end;


procedure TRtcResult.SetResult(val: TRtcValue);
begin
  if Assigned(FResult) then
    FResult.Free;
  FResult := Val;
end;

end.
