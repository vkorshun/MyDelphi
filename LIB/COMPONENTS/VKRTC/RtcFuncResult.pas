unit RtcFuncResult;

interface
uses
  System.SysUtils, System.Classes, rtcInfo;

type
  IRtcFuncResult = interface(IInterface)
    ['{98FE58D3-7918-4032-977A-83FDDCE8A8C4}']
    function getRtcValue: TRtcValue;
    property RtcValue: TRtcValue read getRtcValue;
  end;

  TRtcFuncResult = class (TInterfacedObject,IRtcFuncResult)
  private
    FRtcValue: TRtcValue;
    function getRtcValue: TRtcValue;
  public
    constructor Create(AValue: TRtcValue);
    destructor Destroy; override;
    property RtcValue: TRtcValue read getRtcValue;
  end;


implementation

{ TRtcFuncResult }

constructor TRtcFuncResult.Create(AValue: TRtcValue);
begin
  inherited create;
  FRtcValue := AValue;
end;

destructor TRtcFuncResult.Destroy;
begin
  FreeAndNil(FRtcValue);
  inherited;
end;

function TRtcFuncResult.getRtcValue: TRtcValue;
begin
  Result := FRtcValue;
end;

end.
