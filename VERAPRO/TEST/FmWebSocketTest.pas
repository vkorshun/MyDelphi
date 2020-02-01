unit FmWebSocketTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, rtcInfo, rtcConn, rtcDataCli, rtcHttpCli, Vcl.StdCtrls, SynEdit,
  SuperObject;

type
  TMainFnWSTest = class(TForm)
    Client: TRtcHttpClient;
    Memo1: TSynEdit;
    SockReq: TRtcDataRequest;
    btnCheck: TButton;
    btnIncome: TButton;
    btnReconnect: TButton;
    btnCloseShift: TButton;
    btnOpen: TButton;
    procedure CheckClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SockReqConnectLost(Sender: TRtcConnection);
    procedure SockReqWSConnect(Sender: TRtcConnection);
    procedure SockReqWSDataReceived(Sender: TRtcConnection);
    procedure SockReqWSDataIn(Sender: TRtcConnection);
    procedure SockReqWSDataOut(Sender: TRtcConnection);
    procedure SockReqWSDataSent(Sender: TRtcConnection);
    procedure SockReqWSDisconnect(Sender: TRtcConnection);
    procedure btnIncomeClick(Sender: TObject);
    procedure btnReconnectClick(Sender: TObject);
    procedure btnCloseShiftClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
  private
    { Private declarations }
    procedure MemoAdd( i:Integer; s: String; obj:TObject);
    procedure OpenShift();
  public
    { Public declarations }
  end;

var
  MainFnWSTest: TMainFnWSTest;

implementation

{$R *.dfm}

procedure TMainFnWSTest.btnCloseShiftClick(Sender: TObject);
var
  _params: ISuperObject;
  _command: ISuperObject;    checkPay: ISuperObject;
  checkPayRow: ISuperObject;
  checkTotal: ISuperObject;
  list: ISuperObject;
begin




  _command := SO('{}');
  _command.S['command'] := 'closeShift';//'openShift';
//  _command.O['params'] := _params;
  Client.wSend(wf_Text,UTF8String(_command.AsJSon()));

end;

procedure TMainFnWSTest.btnIncomeClick(Sender: TObject);
var
  _params: ISuperObject;
  _command: ISuperObject;    checkPay: ISuperObject;
  checkPayRow: ISuperObject;
  checkTotal: ISuperObject;
  list: ISuperObject;

begin
  _params := SO('{}');

  checkTotal := SO('{}');
  checkTotal.D['TOTALSUM']:=10;
  _params.O['CHECKTOTAL']:= checkTotal;

  checkPay := SA([]);

  checkPayRow := SO('{}');
  checkPayRow.I['ROWNUM'] := 1;
  checkPayRow.S['PAYMENTFORM'] := '√Œ“≤¬ ¿';
  checkPayRow.D['SUM'] := 10.00;
  checkPay.AsArray.Add(checkPayRow);
  list := SO('{}');
  list.O['LIST'] := checkPay;
  _params.O['CHECKPAY']:= list;

  _command := SO('{}');
  _command.S['command'] := 'sendIncomeCheck';//'openShift';
  _command.O['params'] := _params;
  Client.wSend(wf_Text,UTF8String(_command.AsJSon()));

end;

procedure TMainFnWSTest.btnOpenClick(Sender: TObject);
begin
  OpenShift;
end;

procedure TMainFnWSTest.btnReconnectClick(Sender: TObject);
begin
  if not Client.isConnected then
  begin
    SockReq.client.Connect();
    SockReq.Request.URI:='/Universal9Assist/eReceiptHandler';
    SockReq.Request.WSUpgrade:=True;
    SockReq.PostMethod();
  end;

end;

procedure TMainFnWSTest.CheckClick(Sender: TObject);
var _params: ISuperObject;
    _command: ISuperObject;
    checkBody: ISuperObject;
    checkBodyRow: ISuperObject;
    checkTax: ISuperObject;
    checkTaxRow: ISuperObject;
    checkTotal: ISuperObject;
    _obj: ISuperObject;
    list: ISuperObject;
    checkPay: ISuperObject;
    checkPayRow: ISuperObject;

    function getCheck():String;
    var check: TRtcRecord;
        _command:TRtcRecord;
    begin
      check := TRtcRecord.Create;
      _command := TRtcRecord.Create;
      try
      check.NewRecord('CHECKTOTAL');
      check.asRecord['CHECKTOTAL'].asFloat['TOTALSUM'] := 12;

      //-------------------------------
      check.NewArray('CHECKPAY');
      check.asArray['CHECKPAY'].NewRecord(0);
//      check.asArray['CHECKPAY'].AsRecord[0].asInteger['ROWNUM'] = 1;
      check.asArray['CHECKPAY'].AsRecord[0].asInteger['PAYFORMCODE'] := 0;
      check.asArray['CHECKPAY'].AsRecord[0].asFloat['SUM'] := 12;
      check.asArray['CHECKPAY'].AsRecord[0].asFloat['SUMPROVIDED'] := 12;

{      check.asArray['CHECKPAY'].NewRecord(1);
      check.asArray['CHECKPAY'].AsRecord[1].asInteger['PAYFORMCODE'] := 1;
      check.asArray['CHECKPAY'].AsRecord[1].asFloat['SUM'] := 0;
 }
      //------------------------------- CHECKTAX
      check.NewArray('CHECKTAX');
      check.asArray['CHECKTAX'].NewRecord(0);
      check.asArray['CHECKTAX'].AsRecord[0].asInteger['TYPE'] := 0;
      check.asArray['CHECKTAX'].AsRecord[0].asString['NAME'] := 'œƒ¬';
      check.asArray['CHECKTAX'].AsRecord[0].asString['LETTER'] := '¿';
      check.asArray['CHECKTAX'].AsRecord[0].asFloat['PRC'] := 12;
      check.asArray['CHECKTAX'].AsRecord[0].asFloat['TURNOVER'] := 12;
      check.asArray['CHECKTAX'].AsRecord[0].asFloat['SUM'] := 2;

      //------------------------------- CHECKBODY
      check.NewArray('CHECKBODY');
      check.asArray['CHECKBODY'].NewRecord(0);
      check.asArray['CHECKBODY'].AsRecord[0].asString['NAME'] := 'œÓ‰ÛÍÚ';
      check.asArray['CHECKBODY'].AsRecord[0].asString['UNITNAME'] := 'Í„';
      check.asArray['CHECKBODY'].AsRecord[0].asFloat['AMOUNT'] := 2;
      check.asArray['CHECKBODY'].AsRecord[0].asFloat['PRICE'] := 6;
      check.asArray['CHECKBODY'].AsRecord[0].asFloat['COST'] := 12;
      check.asArray['CHECKBODY'].AsRecord[0].asString['LETTERS'] := '¿';

      _command.asString['command'] := 'sendCheck';
      _command.NewRecord('params').asRecord['CHECK'] := check;
      Client.wSend(wf_Text,UTF8String(_command.toJSon()));

      Result := _command.toJSON;
      finally
        _command.Free;
        check.Free;
      end;
    end;

begin
  if not Client.isConnected then
  begin
    SockReq.client.Connect();
    SockReq.Request.URI:='/Universal9Assist/eReceiptHandler';
    SockReq.Request.WSUpgrade:=True;
    SockReq.PostMethod();
  end;

  ShowMessage(getCheck);
  Exit;

  _params := SO('{}');

  checkTotal := SO('{}');
  checkTotal.D['TOTALSUM']:=10;
  _params.O['CHECKTOTAL']:= checkTotal;

  checkPay := SA([]);

  checkPayRow := SO('{}');
  checkPayRow.I['ROWNUM'] := 1;
  checkPayRow.S['PAYMENTFORM'] := '√Œ“≤¬ ¿';
  checkPayRow.D['SUM'] := 10.00;
  checkPay.AsArray.Add(checkPayRow);

  checkPayRow := SO('{}');
  checkPayRow.I['ROWNUM'] := 2;
  checkPayRow.S['PAYMENTFORM'] := ' ¿–“ ¿';
  checkPayRow.D['SUM'] := 0.0;
  checkPay.AsArray.Add(checkPayRow);
  list := SO('{}');
  list.O['LIST'] := checkPay;
  _params.O['CHECKPAY']:= list;
//  checkTaxRow := SO('{}');
//  checkTaxRow.I['ROWNUM'] := 3;
//  checkTaxRow.D['TAXPRC'] := 7.00;
//  checkTax.AsArray.Add(checkTaxRow);

  checkTax := SA([]);
  checkTaxRow := SO('{}');
  checkTaxRow.I['ROWNUM'] := 1;
  checkTaxRow.D['TAXPRC'] := 20.00;
  checkTaxRow.D['TAXSUM'] := 1.67;
  checkTax.AsArray.Add(checkTaxRow);
  list := SO('{}');
  list.O['LIST'] := checkTax;
  _params.O['CHECKTAX']:= list;


  list := SO('{}');
  list.O['LIST'] := checkPay;
  _params.O['CHECKPAY']:= list;


    checkBody := SA([]);
  checkBodyRow := SO('{}');
  checkBodyRow.I['ROWNUM'] := 1;
  checkBodyRow.S['NAME'] := ' Ûˇ˜Â ÒÚÂ„ÌÓ';
  checkBodyRow.S['UNITNAME'] := 'Í„';
  checkBodyRow.D['AMOUNT'] := 1;
  checkBodyRow.D['PRICE'] := 10.00;
  checkBodyRow.D['COST'] := 10.00;
  checkBody.AsArray.add(checkBodyRow);
  list := SO('{}');
  list.O['LIST'] := checkBody;
  _params.O['CHECKBODY']:= list;



//  _params.O['CHECkPAY']:= _obj;


  _command := SO('{}');
  _command.S['command'] := 'sendCheck';//'openShift';
  _command.O['params'] := _params;
//  _command.I['requestId'] := 0;

  Client.wSend(wf_Text,UTF8String(_command.AsJSon()));
end;

procedure TMainFnWSTest.FormCreate(Sender: TObject);
begin
  SockReq.client.Connect();
  SockReq.Request.URI:='/Universal9Assist/eReceiptHandler';
  SockReq.Request.WSUpgrade:=True;
  SockReq.PostMethod();
end;

procedure TMainFnWSTest.MemoAdd(i: Integer; s: String; obj: TObject);
begin
    Memo1.Lines.Add(s);
end;

procedure TMainFnWSTest.OpenShift;
var v: TRtcRecord;
begin
  v := tRtcRecord.Create;
  v.asString['command'] := 'openShift';
  v.NewRecord('params');
  v.asRecord['params'].asString['CASHIER'] := '“ÂÒÚ  .¿.';
  Client.wSend(wf_Text,UTF8String(v.toJSON()));

end;

procedure TMainFnWSTest.SockReqConnectLost(Sender: TRtcConnection);
begin
    Memo1.Lines.Add('Connection Lost');
end;

procedure TMainFnWSTest.SockReqWSConnect(Sender: TRtcConnection);
begin
    Memo1.Lines.Add('Connected');

end;

procedure TMainFnWSTest.SockReqWSDataIn(Sender: TRtcConnection);
begin
//  Memo1.Lines.Add('<<<< in '+IntToStr(Sender.DataIn)+' <<--');
end;

procedure TMainFnWSTest.SockReqWSDataOut(Sender: TRtcConnection);
begin
  //Memo1.Lines.Add('<<<< out '+IntToStr(Sender.DataOut)+' <<--');

end;

procedure TMainFnWSTest.SockReqWSDataReceived(Sender: TRtcConnection);
  var
    wf:TRtcWSFrame;
    s:RtcString;
begin
  wf:=Sender.wsFrameIn; // <- using the "Sender.FrameIn" property

  if wf.wfStarted and (wf.wfOpcode=wf.waOpcode) then // Started receiving a new Frame set ...
    Memo1.lines.Add('---> IN: '+wf.wfHeadInfo);

  if wf.wfFinished and (wf.wfOpcode=wf_Text) and (wf.waPayloadLength<100000) then // short text message
    begin
    if wf.wfComplete then
      begin
      s:= (wf.wfRead); // <- reading Frame "Payload" data ...

      Memo1.lines.add('IN ('+
        IntToStr(wf.wfTotalInOut)+'/'+
        IntToStr(wf.wfTotalLength)+') >>> '+
        UTF8Decode(s));
    end
  else // if ws.Complete then // -> this would buffer everything received
    begin
    s:=wf.wfRead;  // <- reading Frame "Payload" data ...
    if wf.wfOpcode=wf_Text then
      Memo1.lines.Add('IN ('+
          IntToStr(wf.wfTotalInOut)+'/'+
          IntToStr(wf.wfTotalLength)+') TXT >>> '+
          s)
    else
      Memo1.lines.Add('IN ('+
        IntToStr(wf.wfTotalInOut)+'/'+
        IntToStr(wf.wfTotalLength)+') BIN ('+IntToStr(length(s))+') >>>');
    end;

  if wf.wfDone then // <- Frame Done (all read)
    if wf.waFinal then // <- final Frame?
      Memo1.lines.add('IN DONE, '+
        IntToStr(wf.wfTotalInOut)+'/'+IntToStr(wf.wfTotalLength)+' bytes <-----')
    else // More data shoud arrive in this next Frame ...
      Memo1.lines.Add('<--- IN ... MORE --->'+wf.wfHeadInfo);
  end;

end;

procedure TMainFnWSTest.SockReqWSDataSent(Sender: TRtcConnection);
  var
    wf:TRtcWSFrame;
    bytes:int64;
    data:RtcString;
begin
  wf:=Sender.wsFrameOut;
  { If there is no Frame object, then this is just a notification
    that all been was sent (Web Socket Frames sending queue is empty). }
  if wf=nil then
    MemoAdd(4,'---> ALL SENT <---', Sender)
  { We've used "ws-file" in Send() when sending files in a single Frame with "waPayloadLength" set }
  else if wf.wfName='ws-file' then
    begin
    if wf.wfStarted then // <- we have NOT read any "Payload" data from this Frame yet ...
      MemoAdd(2,'---> OUT: '+wf.wfHeadInfo,Sender);

    if wf.wfDone then // <- Frame is done, no "Payload" data left to be read ...
      MemoAdd(2,'OUT! '+
          IntToStr(wf.wfPayloadInOut)+'/'+
          IntToStr(wf.waPayloadLength)+' bytes <-----',Sender)
    else
      begin
      MemoAdd(3,'SENT '+
              IntToStr(wf.wfPayloadInOut)+'/'+
              IntToStr(wf.waPayloadLength)+' bytes', Sender);

      { How many bytes do we have to send out in this Frame?
        PayloadLength = Payload length of the current Frame,
        PayloadInOut = Payload already read and sent }
      bytes:=wf.waPayloadLength - wf.wfPayloadInOut;

      { Limit the number of bytes copied to sending buffers and sent out at once.
        Using smaller buffers will slow down file transfer and use a bit more CPU,
        but it also reduces the amount of RAM required per Client for sending files. }
      if bytes>32*1024 then
        bytes:=32*1024; // 32 KB is relatively small

      // Read the next file chunk and add it to this Frames "PayLoad" for sending ...
      wf.wfWriteEx( Read_FileEx(wf.asText['fname'], wf.wfPayloadInOut, bytes) );

      if wf.wfComplete then // Payload complete, no more bytes can be added to this Frame ...
        MemoAdd(3,'OUT Complete, '+IntToStr(wf.waPayloadLength)+' bytes', Sender);
      end;
    end
  { We've used "ws-multi" in Send() when sending files in multiple frames with "wfTotalLength" set }
  else if wf.wfName='ws-multi' then
    begin
    if wf.wfDone then
      MemoAdd(3,'OUT! '+wf.wfHeadInfo,Sender);

    if wf.wfTotalInOut<wf.wfTotalLength then
      begin
      if wf.wfTotalInOut=0 then
        MemoAdd(2,'---> OUT Start: '+IntToStr(wf.wfTotalLength)+' bytes --->',Sender);

      { How many bytes are left to be sent from the File?
        wf.wfTotalLength = our file size (total bytes to send),
        wf.wfTotalInOut = number of bytes already sent }
      bytes:=wf.wfTotalLength - wf.wfTotalInOut;

      { Limit the number of bytes sent out at once. }
      if bytes>8*1024 then
        bytes:=8*1024; // using 8 KB here as an example

      // Read the next file chunk and add it to this Frames "PayLoad" for sending ...
      wf.wfWriteEx( Read_FileEx(wf.asText['fname'], wf.wfTotalInOut, bytes) );

      MemoAdd(3,'SENT '+
              IntToStr(wf.wfTotalInOut)+'/'+
              IntToStr(wf.wfTotalLength)+' bytes', Sender);
      end
    else // File complete
      MemoAdd(2,'OUT Complete: '+
          IntToStr(wf.wfTotalInOut)+'/'+
          IntToStr(wf.wfTotalLength)+' bytes <-----', Sender);
    end
  { We've used "ws-chunks" in Send() when sending files in multiple chunks }
  else if wf.wfName='ws-chunks' then
    begin
    if wf.wfDone then
      MemoAdd(3,'OUT! '+wf.wfHeadInfo,Sender);

    if not wf.wfFinished then
      begin
      if wf.wfTotalInOut=0 then
        MemoAdd(2,'---> OUT Start: '+IntToStr(wf.asLargeInt['total'])+' bytes --->',Sender);

      { For demonstration purposes, we will NOT be checking the size of the file
        being sent. Instead, we will try to read the next 16KB bytes from the file
        in every "OnWSDataSent" event, until we get an empty string back as a result. }
      data:=Read_File(wf.asText['fname'], wf.wfTotalInOut, 16*1024);

      if length(data)>0 then
        begin
        // We have some content, send it out ...
        wf.wfWrite(data);
        MemoAdd(3,'SENT '+
                IntToStr(wf.wfTotalInOut)+'/'+
                IntToStr(wf.wfTotalLength)+' bytes', Sender);
        end
      else
        begin
        { No content returned from Read_File, we need to set the "wfFinished"
          flag to TRUE, so the last Frame will be sent out with "waFinal=TRUE". }
        wf.wfFinished:=True;
        MemoAdd(2,'OUT Complete: '+
            IntToStr(wf.wfTotalInOut)+'/'+
            IntToStr(wf.wfTotalLength)+' bytes <-----', Sender);
        end;
      end;
    end
  else if wf.wfName='' then // all Frames without a name ...
    begin
    if wf.wfStarted then
      MemoAdd(2,'-=+> OUT: '+wf.wfHeadInfo, Sender);
    MemoAdd(3,'SENT '+IntToStr(wf.wfPayloadInOut)+'/'+IntToStr(wf.waPayloadLength), Sender);
    if wf.wfDone then
      MemoAdd(2,'OUT! '+IntToStr(wf.waPayloadLength)+' bytes <+=---', Sender);
    end;

end;


procedure TMainFnWSTest.SockReqWSDisconnect(Sender: TRtcConnection);
begin
  Memo1.Lines.Add('disconnect');
  Client.disconnect;
end;

end.
