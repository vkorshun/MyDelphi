unit RtcService;

interface
uses
  System.SysUtils, System.Classes, rtcDataCli, rtcInfo, rtcConn, rtcHttpCli, System.SyncObjs;

type
  TOnRtcServiceResponse = reference to procedure(const Data:String);

  PRtcServiceUser = ^TRtcServiceUser;
  TRtcServiceUser = record
    userName: String;
    password: String;
  end;

  TRtcService = class(TComponent)
  private
    FEvent :TEvent;
    FResponse: String;
    FRtcDataRequest: TRtcDataRequest;
    FOnResponse: TOnRtcServiceResponse;
    FUser: PRtcServiceUser;
//    FhttpClient: TRtcHttpClient;
    procedure prepareRequest(const user:TRtcServiceUser);
    procedure SethttpClient(const Value: TRtcDataClient);
    function getHttpClient: TRtcDataClient;
    procedure DefaultRtcDataRequestDataReceived(Sender: TRtcConnection);
    procedure RtcDataRequestDataReceived(Sender: TRtcConnection);
    procedure SetOnResponse(const Value: TOnRtcServiceResponse);
    procedure SetUser(const Value: TRtcServiceUser);

  public
    constructor Create(AOwner:TComponent);override;
    destructor Destroy;override;
    property User:TRtcServiceUser  read FUser write FUser ;
    property httpClient: TRtcDataClient read getHttpClient write SetHttpClient ;
//    property OnResponse: TOnRtcServiceResponse read FOnResponse write SetOnResponse;
    function executeGet(const path, query:String; onResponse:TOnRtcServiceResponse ):String;
    function executePost(const path:String; const value:String; onResponse:TOnRtcServiceResponse ):String;
  end;

implementation

{ TRtcService }

constructor TRtcService.Create(AOwner: TComponent);
begin
  inherited;
  FRtcDataRequest := TRtcDataRequest.Create(AOwner);
  FRtcDataRequest.OnDataReceived := DefaultRtcDataRequestDataReceived;
  if (AOwner is TRtcClient) then
    FRtcDataRequest.Client := TRtcClient(AOwner);
  FUser = new(PRtcSetviceUser);
//  FEvent := TEvent.create(nil, true, false, 'DoRequest');
end;

procedure TRtcService.DefaultRtcDataRequestDataReceived(Sender: TRtcConnection);
var r: String;
begin
   with TRTCDataClient( Sender ) do
    begin
       r := UTF8Decode(Read);
       if Assigned(FOnResponse) then
         FOnResponse(r);
    end;

end;

destructor TRtcService.Destroy;
begin
  inherited;
  FRtcDataRequest.Free;
end;

function TRtcService.executeGet(const path, query: String;onResponse:TOnRtcServiceResponse): String;
begin
  FOnResponse := onResponse;
  FRtcDataRequest.Request.Method := 'GET';
  prepareRequest(FUser);
  //RtcDataRequest1.Post;
  with FRtcDataRequest do
  begin
    Request.FileName := path+'?'+query;

    Write();
    Post;
  end;

end;

function TRtcService.executePost(const path: String; const value: String;onResponse:TOnRtcServiceResponse): String;
begin
  FOnResponse := onResponse;
  FRtcDataRequest.Request.Method := 'POST';
  prepareRequest(FUser);
  //RtcDataRequest1.Post;
  with FRtcDataRequest do
  begin
//    client.Connect();
    //if not client.isConnected then
    //  raise Exception.Create('Connection Eror');
    Request.FileName := path;
    Write(UTF8Encode(value));
    Post;
  end;

end;

function TRtcService.getHttpClient: TRtcDataClient;
begin
  Result := FRtcDataRequest.Client;
end;

procedure TRtcService.prepareRequest(const user: TRtcServiceUser);
begin
  with FRtcDataRequest do
  begin
    Request.AutoLength := true;
    Request.HeaderText  := '';
    Request.HeaderText := Request.HeaderText +'Accept: application/json; charset=UTF-8'+#13#10;
    Request.HeaderText := Request.HeaderText +'Content-Type: text/xml'+#13#10;
    Request.HeaderText := Request.HeaderText +'Authorization: Basic '+
      StringReplace(Mime_Encode(user.userName+':'+user.password),#13#10, '',[]);
  end;
end;

procedure TRtcService.RtcDataRequestDataReceived(Sender: TRtcConnection);
begin

end;

procedure TRtcService.SetHttpClient(const Value: TRtcDataClient);
begin
  FRtcDataRequest.Client := Value;
end;

procedure TRtcService.SetOnResponse(const Value: TOnRtcServiceResponse);
begin
  FOnResponse := Value;
end;

procedure TRtcService.SetUser(const Value: TRtcServiceUser);
begin
  FUser := Value;
end;

end.
