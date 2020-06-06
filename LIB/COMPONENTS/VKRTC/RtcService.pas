unit RtcService;

interface

uses
  System.SysUtils, System.Classes, rtcDataCli, rtcInfo, rtcConn, rtcHttpCli,
  System.SyncObjs, rtcSyncObjs, Dialogs, RtcResult;

type

  PRtcServiceUser = ^TRtcServiceUser;

  TRtcServiceUser = record
    userName: String;
    password: String;
  end;

  TRtcServiceResponse = class(TObject)
  private
    FId: Int64;
    FText: String;
    FResponse: TRtcValue;
    function GetText: String;
    function GetError: String;
    procedure SetError(const Value: String);
  public
    constructor create(AId: Int64; const AText: String);
    procedure Clear;
    procedure checkError;
    class procedure checkResponse(AResponse:TRtcValue);

    property id: Int64 read FId write FId;
    property Text: String read GetText write FText;
    property Response: TRtcValue read FResponse;
    property Error: String read GetError write SetError;

  end;

{*  IRtcValue = interface
    function GetResult: TRtcValue;
    procedure SetResult(val:TRtcValue);
    property Result:TRtcValue read GetResult write SetResult;
  end;

  TRtcServiceResult = class(TInterfacedObject, IRtcValue)
  private
    FResult: TRtcValue;
  public
    constructor Create;
    destructor Destroy; override;
    procedure checkError;
    function GetResult: TRtcValue;
    procedure SetResult(val:TRtcValue);
    property Result:TRtcValue read GetResult write SetResult;
  end;
*}
  TOnRtcServiceResponse = reference to procedure(const Data: IRtcResult);

  TRtcService = class(TComponent)
  private
    FEvent: TEvent;
//    FResult: TRtcserviceResult;
    FRtcDataRequest: TRtcDataRequest;
    FOnResponse: TOnRtcServiceResponse;
    FUser: PRtcServiceUser;
    FResp: TRtcServiceResponse;
    FParams: TRtcRecord;
    class var FCs: TRtcCritSec;
    // FhttpClient: TRtcHttpClient;

    procedure prepareRequest(const user: PRtcServiceUser);
    procedure SethttpClient(const Value: TRtcDataClient);
    function getHttpClient: TRtcDataClient;
    procedure DefaultRtcDataRequestResponseDone(Sender: TRtcConnection);
    procedure RtcDataRequestDataReceived(Sender: TRtcConnection);
    procedure RtcDataRequestBeginRequest(Sender: TRtcConnection);
    procedure RtcDataRequestConnectionLost(Sender: TRtcConnection);
    procedure RtcDataRequestResponseReject(Sender: TRtcConnection);
    procedure RtcDataRequestResponseAbort(Sender: TRtcConnection);
    procedure RtcDataRequestSessionClose(Sender: TRtcConnection);
    procedure SetOnResponse(const Value: TOnRtcServiceResponse);
    procedure SetUser(const Value: PRtcServiceUser);
    class var id_event: Int64;
    class function getEventName(): String;
  public
    constructor create(AOwner: TComponent); override;
    destructor Destroy; override;
    property user: PRtcServiceUser read FUser write SetUser;
    property httpClient: TRtcDataClient read getHttpClient write SethttpClient;
    property Datarequest: TRtcDataRequest read FRtcDataRequest
      write FRtcDataRequest;
    property params: TRtcRecord read FParams;
    property OnResponse: TOnRtcServiceResponse read FOnResponse write SetOnResponse;
    function execute(const path, type_request:String): IRtcResult;
    function executeGet(const path, query: String): IRtcResult;
    function executePost(const path: String): IRtcResult;
  end;

implementation

{ TRtcService }

constructor TRtcService.create(AOwner: TComponent);
begin
  inherited;
  //FResult := TRtcServiceResult.Create;
  FRtcDataRequest := TRtcDataRequest.create(AOwner);
  FRtcDataRequest.OnResponseDone := DefaultRtcDataRequestResponseDone;
  // FRtcDataRequest.OnBeginRequest :=
  if (AOwner is TRtcDataClient) then
    FRtcDataRequest.Client := TRtcDataClient(AOwner);
  FUser := new(PRtcServiceUser);
  FEvent := TEvent.create(nil, true, false, getEventName());
  FResp := TRtcServiceResponse.create(0, '');
  FParams := TRtcRecord.create;
  //FResponse := TRtcValue.create;

  FRtcDataRequest.OnBeginRequest := RtcDataRequestBeginRequest;
  FRtcDataRequest.OnResponseReject := RtcDataRequestResponseReject;
  FRtcDataRequest.OnResponseAbort := RtcDataRequestResponseAbort;
  FRtcDataRequest.OnConnectLost := RtcDataRequestConnectionLost;
  FRtcDataRequest.OnSessionClose := RtcDataRequestSessionClose;
end;

procedure TRtcService.DefaultRtcDataRequestResponseDone(Sender: TRtcConnection);
var
  r: String;
  _result: IRtcResult;
begin
  with TRtcDataClient(Sender) do
  begin
    FResp.Clear;
    FResp.Text := UTF8Decode(Read);
    FResp.checkError;
    if Assigned(FOnResponse) then
    begin
      _result := TRtcResult.Create;
      _result.Result := TRtcValue.FromJSON(r);
      //TRtcServiceResponse.checkResponse();
      FOnResponse(_result);
    end;
  end;
  FEvent.SetEvent;
end;

destructor TRtcService.Destroy;
begin
  inherited;
  // FRtcDataRequest.Free;
  FResp.Free;
  FEvent.Free;
  Dispose(FUser);
  FParams.Free;
//  FResult.Free;
end;

function TRtcService.execute(const path, type_request:String): IRtcResult;
begin
  FRtcDataRequest.Request.Method := type_request;
  prepareRequest(FUser);
  FEvent.ResetEvent;
  with FRtcDataRequest do
  begin
    Request.FileName := path;
    Request.AutoLength := true;
    Post;
  end;
  if not Assigned(FOnResponse) then
  begin
    if FResp.Text.IsEmpty then
    begin
      FEvent.WaitFor(12000);
      FEvent.ResetEvent;
    end;
    Result := TRtcResult.Create;
    Result.Result := TRtcValue.FromJSON(FResp.Text);
    FResp.checkResponse(Result.Result);
  end;

end;

function TRtcService.executeGet(const path, query: String): IRtcResult;
begin
  Result := execute(path + '?' + query, 'GET');
end;

function TRtcService.executePost(const path: String): IRtcResult;
begin
  Result := execute(path, 'POST');

end;

class function TRtcService.getEventName: String;
begin
  FCs.Acquire;
  inc(id_event);
  Result := 'doRtcRequest' + IntToStr(id_event);
  FCs.Release;

end;

function TRtcService.getHttpClient: TRtcDataClient;
begin
  Result := FRtcDataRequest.Client;
end;

procedure TRtcService.prepareRequest(const user: PRtcServiceUser);
begin
  with FRtcDataRequest do
  begin
    Request.AutoLength := true;
    Request.HeaderText := '';
    Request.HeaderText := Request.HeaderText +
      'Accept: application/json; charset=UTF-8' + #13#10;
    Request.HeaderText := Request.HeaderText + 'Content-Type: text/xml'
      + #13#10;
    Request.HeaderText := Request.HeaderText + 'Authorization: Basic ' +
      StringReplace(Mime_Encode(user.userName + ':' + user.password),
      #13#10, '', []);
  end;
end;

procedure TRtcService.RtcDataRequestBeginRequest(Sender: TRtcConnection);
begin
  with TRtcDataClient(Sender) do
  begin
    Request.AutoLength := true;
    Request.HeaderText := Request.HeaderText +
      'Accept: application/json; charset=UTF-8' + #13#10;
    Request.HeaderText := Request.HeaderText +
      'Content-Type: application/json' + #13#10;

    try
      Request.AutoLength := true;

      // Request.FileName := Fpath;
      if (Request.Method = 'GET') then
      begin
        Write();
      end
      else
      begin
        Request.AutoLength := true;
        Write(Utf8Encode(FParams.toJSon));
      end;
    finally
      // FreeAndNil(req);
    end;
  end;

end;

procedure TRtcService.RtcDataRequestConnectionLost(Sender: TRtcConnection);
begin
  FResp.Error := 'Connection LOST';
  FEvent.SetEvent;
end;

procedure TRtcService.RtcDataRequestDataReceived(Sender: TRtcConnection);
begin

end;

procedure TRtcService.RtcDataRequestResponseAbort(Sender: TRtcConnection);
begin
  FResp.Error := 'Connection error';
  FEvent.SetEvent;

end;

procedure TRtcService.RtcDataRequestResponseReject(Sender: TRtcConnection);
begin
  FResp.Error := 'Response REJECT';
  FEvent.SetEvent;
end;

procedure TRtcService.RtcDataRequestSessionClose(Sender: TRtcConnection);
begin
  FResp.Error := 'Session close';
  FEvent.SetEvent;
end;

procedure TRtcService.SethttpClient(const Value: TRtcDataClient);
begin
  FRtcDataRequest.Client := Value;
end;

procedure TRtcService.SetOnResponse(const Value: TOnRtcServiceResponse);
begin
  FOnResponse := Value;
end;

procedure TRtcService.SetUser(const Value: PRtcServiceUser);
begin
  FUser.userName := Value.userName;
  FUser.password := Value.password;
end;

{ TRtcServiceResponse }

procedure TRtcServiceResponse.checkError;
begin
  if Assigned(FResponse) and (FResponse.isType = rtc_Exception) then
    raise Exception.create(FResponse.asException);
end;

class procedure TRtcServiceResponse.checkResponse(AResponse: TRtcValue);
begin
  if (AResponse.isType = rtc_Record) then
  begin
    try
      if (AResponse.asRecord.asString['result'] = 'ERROR') then
        raise Exception.Create(AResponse.asRecord.asRecord['content'].asString['errorMessage']);
    except
       raise Exception.Create('Incorrect Response format ');
    end;
  end;
end;

procedure TRtcServiceResponse.Clear;
begin
  FResponse.Clear;
  FText := '';
end;

constructor TRtcServiceResponse.create(AId: Int64; const AText: String);
begin
  FId := AId;
  FText := AText;
  FResponse := TRtcValue.create;
end;

function TRtcServiceResponse.GetError: String;
begin
  if Assigned(FResponse) and (FResponse.isType = rtc_Exception) then
    Result := FResponse.asException;
end;

function TRtcServiceResponse.GetText: String;
begin
  if GetError.IsEmpty then
    Result := FText
  else
    Result := FResponse.asException;
end;

procedure TRtcServiceResponse.SetError(const Value: String);
begin
  FResponse.NewException;
  FResponse.asException := Value;
end;

{ TRtcServiceResult }
{*
procedure TRtcServiceResult.checkError;
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

constructor TRtcServiceResult.Create;
begin
  inherited;
  FResult := TRtcValue.Create;
end;

destructor TRtcServiceResult.Destroy;
begin
  if Assigned(FResult) then
    FreeAndNil(FResult);
  inherited;
end;

function TRtcServiceResult.GetResult: TRtcValue;
begin
  Result := FResult;
end;

procedure TRtcServiceResult.SetResult(val: TRtcValue);
begin
  if Assigned(FResult) then
    FResult.Free;
  fResult := Val;
end;
  *}
initialization

TRtcService.id_event := 0;
TRtcService.FCs := TRtcCritSec.create;

finalization

TRtcService.FCs.Release;
TRtcService.FCs.Free;

end.
