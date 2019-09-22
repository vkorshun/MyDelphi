unit fm_kursloader;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, sTRuTILS, DB, DateVk,  ExtCtrls,
  Menus, fm_dialog, varlist, httpsend, monitor,sendmail_synapse,
  RusKursList, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Phys.ADS, FireDAC.VCLUI.Wait, FireDAC.Comp.UI;

const WM_TRAY = WM_USER +1;

const KURS_UKR  = 1;
      KURS_RUS  = 2;
      KURS_MEGB = 3;
      KURS_MEGB_SALE = 4;
      KURS_RUS_BOFM  = 5;
      KURS_KZ = 6;
      sMb = 'Ближайшие курсы есть на <a href=''arch/?10&';
      Euro_bofm = 179727;
      //'Котировки межбанковского валютного рынка Украины ';

type
  PKursMgbSale = ^RKursMgbSale;
  RKursMgbSale = record
    data: TDateTime;
    kurs: Double;
  end;

  TFmKursLoader = class(TForm)
    Button1: TButton;
    TrayIcon1: TTrayIcon;
    Timer1: TTimer;
    PopupMenu1: TPopupMenu;
    Exit1: TMenuItem;
    LoadUKR1: TMenuItem;
    LoadRUS1: TMenuItem;
    Lo1: TMenuItem;
    Re1: TMenuItem;
    N1: TMenuItem;
    LoadMegbankSale: TMenuItem;
    LoadEvroBegonofmonth1: TMenuItem;
    LoadKZ1: TMenuItem;
    FDPhysADSDriverLink1: TFDPhysADSDriverLink;
    FDAdsConnection1: TFDConnection;
    FDAdsQuery1: TFDQuery;
    FDAdsQuery2: TFDQuery;
    FDTbKurs: TFDTable;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure LoadUKR1Click(Sender: TObject);
    procedure LoadRUS1Click(Sender: TObject);
    procedure Lo1Click(Sender: TObject);
    procedure Re1Click(Sender: TObject);
    procedure LoadMegbankSaleClick(Sender: TObject);
    procedure LoadEvroBegonofmonth1Click(Sender: TObject);
    procedure LoadKZ1Click(Sender: TObject);
    procedure SaveStringToFile(const filename,s:String );
  private
    { Private declarations }
    fm: TFmDialog;
    aValKod1: TIntList;
    aValKodRus: TIntList;
    aValKodRus_bofm: TIntList;
    aValKodMb: TIntList;
    aValKodMbSale: TIntList;
    aValKodKz: TIntList;
    dLastRus: TDateTime;
    dLastRus_bofm: TDateTime;
    dLastUkr: TDateTime;
    dLastMgb: TDateTime;
    dLastMgbSale: TDateTime;
    ListKursMgbSale: TList;
    PageText: TStringList;
    MessageList: TStringList;
    sDirCommon: String;
    procedure CheckKurs(aType: Integer; dKursData:TDateTime=0; dKursData2:TDateTime=0);
    procedure CreateFmDialog;
    procedure LoadKursFromPeriod(aTypeKurs:Integer);
    procedure WmTray(var Msg:TMessage); message WM_TRAY;
    procedure WriteKurs(data:TDateTime; nKodV:Integer; nKurs:double);
    function getS_Name(kodv: Integer):String;
  public
    { Public declarations }

    List: TStringList;
    /// <summary> Test </summary>
    procedure ClearListKursMgbSale;
    function GetKursRus(akodval:Integer;const aRes:String ):Double;
    function GetKursUkr(const akodval: String; const s_name:String; const aRes: String): Double;
    function GetKursUkrMinfin(const akodval: String; const s_name:String; const aRes: String): Double;
    function getKursMegbank(akodval:Integer;const aRes:String; bSale:Boolean = False):Double;
    function getKursMegbankSale(akodval:Integer; d1,d2: TDateTime):Double;
    function GetKursRusCbr(akodval:Integer;const aRes:String ):Double;
    function GetKursKz(akodval:Integer;const aRes:String ):Double;
    function GetKursRusCbr2(akodval: Integer; AList: TRusKursList): Double;
  end;

var
  FmKursLoader: TFmKursLoader;
//  DmMikkoAds: TDmMikkoAds;

implementation

{$R *.dfm}
uses  IniFiles, ruskursxml;

procedure TFmKursLoader.CheckKurs(aType: Integer; dKursData:TDateTime=0;dKursData2:TDateTime=0);
var nKodV: Integer;
    data_ukr: TDateTime;
    data_rus: TDateTime;
    data_mgb: TDateTime;
    cdata_ukr: String;
    cdata_rus: String;
    nKurs: double;
    sUrl: String;
    d,m,y: Word;
    srus: String;
    sUkr: String;
    Stream: TStringStream;
    k: Integer;
//    i: Integer;
    xml: TRusKursXml;

  function GetEmptyKurs(d:tDateTime):String;
  begin
    Result := 'Котировки межбанковского валютного рынка Украины на '+DateToStr(d)+' отсутствуют.<br>Ближайшие курсы есть на ';
  end;
begin
  nKurs := 0;
  Stream := TStringStream.Create(srus);
  PageText.Clear;
  FDAdsConnection1.Connected := True;
  try
    try
    //TbKurs.Open;
    with FDADSQuery1 do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add(' SELECT * FROM valuta ');
      Open;

      //FDTbKurs.IndexName := 'kurs';
      if dKursData=0 then
      begin
        data_ukr := now;
        data_mgb := now-1;
        data_rus := data_ukr +1
      end
      else
      begin
        data_ukr := dKursData;
        data_rus := dKursData;
        data_mgb := dKursData-1;
      end;
      cdata_ukr := dtos(data_ukr);
      cdata_rus := dtos(data_rus);

      //==== INIT ============
      if aType=KURS_UKR then
      begin
        surl := 'http://www.bank.gov.ua/control/uk/curmetal/currency/search?formType=searchFormDate&time_step=daily&date='+
        DateToStr(data_ukr)+'&execute=%D0%92%D0%B8%D0%BA%D0%BE%D0%BD%D0%B0%D1%82%D0%B8';
//http://www.bank.gov.ua/control/uk/curmetal/currency/search?formType=searchFormDate&time_step=daily&date=09.04.2012&execute=%D0%92%D0%B8%D0%BA%D0%BE%D0%BD%D0%B0%D1%82%D0%B8

        PageText.Clear;
        if HTTPGetText(surl,PageText) then
        begin
          sUkr := UpperCase(Utf8ToString(RawByteString(PageText.Text)));
        end;

        {DecodeDate(data_ukr,y,m,d);
        surl := 'http://index.minfin.com.ua/arch/?nbu&'+IntToStr(y)+'-'+IfThen(m<10,'0')+IntToStr(m)+'-'+IfThen(d<10,'0')+IntToStr(d);
        PageText.Clear;
        if HTTPGetText(surl,PageText) then
        begin
          sUkr := PageText.Text;
          PageText.SaveToFile('d:\page.txt');
        end; }
      end;




      if (aType=KURS_MEGB) or (aType=KURS_MEGB_SALE) then
      begin
        DecodeDate(data_mgb,y,m,d);         // ?bankua& -> ?10&
        surl := 'http://index.minfin.com.ua/arch/?10&'+IntToStr(y)+'-'+IfThen(m<10,'0')+IntToStr(m)+'-'+IfThen(d<10,'0')+IntToStr(d);
        PageText.Clear;
        if HTTPGetText(surl,PageText) then
          sUkr := UTF8Decode(PageText.Text);
        k := Pos(GetEmptyKurs(data_mgb),String(sUkr));
        if k>0 then
        begin
          Stream.Clear;
          k := Pos(sMb,String(sUkr));
          if k>0 then
          begin
            surl := 'http://index.minfin.com.ua/arch/?10&'+Copy(String(sUkr),k+Length(sMb),10);
            PageText.Clear;
            if HTTPGetText(surl,PageText) then
              sUkr := UTF8Decode(PageText.Text);
          end;
        end;
      end;

      // RUS
      if aType=KURS_RUS then
      begin
        Stream.Clear;
        DecodeDate(data_rus,y,m,d);
        //---------------------- inline.ru---------------------------
        //surl :=   'http://inline.ru/cb.asp?Date='+IntToStr(d)+'&Month='+IntToStr(m-1)+'&Year='+IntToStr(y);
        surl := 'http://www.cbr.ru/scripts/XML_daily.asp?date_req='+StrZero(d,2)+'/'+StrZero(m,2)+'/'+IntToStr(y);
        //-----------------------------------------------------------
        //------------- cbr.ru

        PageText.Clear;
        if HTTPGetText(surl,PageText) then
          sRus := PageText.Text;
        PageText.saveToFile('d:\test.xml');
        xml := TRusKursXml.Create(PageText.Text);
//        xml.SaveToFile('d:\test2.xml');
//        ShowMessage(DateToStr(xml.GetData));
        // Если кривой ответ - то повторно
        if length(sRus)<=256 then
        begin
          PageText.Clear;
          if HTTPGetText(surl,PageText) then
            sRus := PageText.Text;
        end;
      end;

      // RUS_Bofm
      if aType=KURS_RUS_BOFM then
      begin
        Stream.Clear;
        DecodeDate(F_D_Month(data_rus,0),y,m,d);
        //---------------------- inline.ru---------------------------
        //        surl :=   'http://inline.ru/cb.asp?Date='+IntToStr(d)+'&Month='+IntToStr(m-1)+'&Year='+IntToStr(y);
        //-----------------------------------------------------------
        //------------- cbr.ru
        surl := 'http://www.cbr.ru/scripts/XML_daily.asp?date_req='+StrZero(d,2)+'/'+StrZero(m,2)+'/'+IntToStr(y);
        PageText.Clear;
        if HTTPGetText(surl,PageText) then
          sRus := PageText.Text;
        xml := TRusKursXml.Create(PageText.Text);

      end;

      //=======================

      if aType=KURS_KZ then
      begin
        surl := 'http://www.nationalbank.kz/rss/get_rates.cfm?fdate='+
        DateToStr(data_ukr);

        PageText.Clear;
        if HTTPGetText(surl,PageText) then
        begin
          sUkr := UpperCase(Utf8ToString(RawByteString(PageText.Text)));
        end;

      end;


      while not Eof do
      begin
        nKodV := FieldByName('kodv').AsInteger;
        if (aValKod1.IndexOf(nKodV)=-1) and
          (aValKodRus.IndexOf(nKodV)=-1) and (aType=KURS_UKR) and (aValKodMb.IndexOf(nKodV)=-1)
          and (aValKodMbSale.IndexOf(nKodV)=-1) and (nKodv<>Euro_bofm) and (aValKodKz.IndexOf(nKodV)=-1) then
        begin
          //if not TbKurs.AdsSeek(Str11(nKodV)+cdata_ukr,stHARD) then
          begin
            nKurs := GetKursUkr(IntToStr(nKodV),FieldByName('s_name').AsString,String(sUkr));
            //nKurs := GetKursUkrMinfin(IntToStr(nKodV),FieldByName('s_name').AsString,String(sUkr));
            if (date>=StrToDate('15.04.2014')) and (date<StrToDate('01.04.2014')) then
              WriteKurs(data_ukr+1,nKodV,nKurs)
            else
              WriteKurs(data_ukr,nKodV,nKurs);
          end;
        end
        else
        if (aValKodRus.IndexOf(nKodV)>-1) and (aType= KURS_RUS) then
        begin
          //if not TbKurs.AdsSeek(Str11(nKodV)+cdata_rus,stHARD) then
          begin
            nKurs := GetKursRusCbr2(nKodV,xml.List);
            if nKurs=0 then
              PageText.SaveToFile('d:\kurs_loader_page.html');
            WriteKurs(data_rus,nKodV,nKurs)
          end;
        end
        else
        if (aValKodRus_bofm.IndexOf(nKodV)>-1) and (aType= KURS_RUS_BOFM) then
        begin
          //if not TbKurs.AdsSeek(Str11(nKodV)+cdata_rus,stHARD) then
          begin
            nKurs := GetKursRusCbr2(nKodV,xml.List);
            WriteKurs(data_rus,nKodV,nKurs);
          end;
        end;
        if (aValKodMb.IndexOf(nKodV)>=0) and (aType=KURS_MEGB)  then
        begin
          nKurs := GetKursMegbank(nKodv,(sUkr),False);
          WriteKurs(data_mgb+1,nKodV,nKurs)
        end;
        if (aValKodMbSale.IndexOf(nKodV)>=0) and (aType=KURS_MEGB_SALE)  then
        begin
          nKurs := GetKursMegbank(nKodv,(sUkr),True);
          WriteKurs(data_mgb+1,nKodV,nKurs)
        end;
        if (aValKodKz.IndexOf(nKodV)>=0) and (aType=KURS_KZ)  then
        begin
          nKurs := GetKursKz(nKodv,(sUkr));
          WriteKurs(data_ukr,nKodV,nKurs)
        end;
        Next;
      end;
    end;
    case aType of
      KURS_RUS: if Assigned(xml) then
                begin
                  dLastRus  := xml.GetData;
                end;
      KURS_RUS_BOFM: if Assigned(xml) then
                       dLastRus_bofm  := xml.GetData;
      KURS_MEGB: dLastMgb := ifThen(nKurs>0, Now,dLastMgb);
      KURS_MEGB_SALE: dLastMgbSale := ifThen(nKurs>0, Now,dLastMgbSale);
      KURS_UKR: dLastUkr  := Now;
      KURS_KZ: dLastUkr  := Now;
    end;
    except
      on e:Exception do
       TxtMonitor(e.Message);
    end;
  finally
    FDTbKurs.Close;
    FDAdsConnection1.Connected := False;
    Stream.Free;
  end;
end;


procedure TFmKursLoader.ClearListKursMgbSale;
var i: Integer;
begin
  for I := 0 to ListKursMgbSale.Count - 1 do
    Dispose(Pointer(ListKursMgbSale[i]));
  ListKursMgbSale.Clear;
end;

procedure TFmKursLoader.CreateFmDialog;
begin
  Fm := TFmDialog.Create(self);
  fm.NewControl(ieDateEditEh,'Дата стартовая ',12,'dkurs1');
  fm.NewControl(ieDateEditEh,'Дата конечная ',12,'dkurs2');
  fm.Caption := 'Закачка курсов';
end;

procedure TFmKursLoader.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TFmKursLoader.FormActivate(Sender: TObject);
begin
  Windows.PostMessage(self.Handle,WM_TRAY,0,0);
end;

procedure TFmKursLoader.FormCreate(Sender: TObject);
var FIni: TIniFile;

begin


  PageText := TStringList.Create;
  ListKursMgbSale := TList.Create;
  MessageList := TStringList.Create;
  try
    try
      Caption := 'Загрузка курсов (Россия)';
      FIni := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
      sDirCommon := FIni.ReadString('VARS','DirCommon','');
//      TxtMonitor('DirCommon: '+sDirCommon);
      FDAdsConnection1.Params.Add('Database='+sDirCommon);
      //AdsConnection1.ConnectPath := sDirCommon;

      List := TStringList.Create;
      //TbKurs.AdsConnection := DmMikkoAds.AdsConnection1;
      //TbKurs.DatabaseName  := 'DmMikkoAds.AdsConnection1';

      aValKod1   := TIntList.Create;
      aValKodRus := TIntList.Create;
      aValKodMb  := TIntList.Create;
      aValKodMbSale := TIntList.Create;
      aValKodRus_bofm := TIntList.Create;
      aValKodKz := TIntList.Create;

      aValKod1.Add(10);
      aValKod1.Add(160);
      aValKod1.Add(163);

      aValKodRus.Add(51567);
      aValKodRus.Add(51568);
//      aValKodRus.Add(51568);
//179727
      aValKodMb.Add(154100);
      aValKodMb.Add(156194);

      aValKodMbSale.Add(172889);
      aValKodMbSale.Add(172890);

      aValKodRus_bofm.Add(Euro_bofm);

      aValKodKz.add(272940);

{      //====== Украина всегда ======
      CheckKurs(True);
      //====== Россия после часа =========
      DecodeTime(now,hh,mm,ss,ms);
      if hh>13 then
        CheckKurs(False);}
      CreateFmDialog;

      Button1.Caption := 'Ok';

      dLastUkr      := Now - 1;
      dLastMgb      := Now - 1;
      dLastMgbSale  := Now - 1;
      dLastRus      := Now - 1;
      dLastRus_bofm := Now - 1;
      Timer1Timer(self);
    except
      on E:Exception do
      begin
        TxtMonitor(E.Message);
        Halt;
      end;
    end;
  finally
//    PostMessage(Handle,WM_CLOSE,0,0);
  end;
end;

procedure TFmKursLoader.FormDestroy(Sender: TObject);
begin
  ClearListKursMgbSale;
  PageText.Free;
  List.Free;
  ListKursMgbSale.Free;
  aValKod1.Free;
  aValKodRus.Free;
  aValKodRus_bofm.Free;
  aValKodMb.Free;
  aValKodMbSale.Free;
  MessageList.Free;
end;

function TFmKursLoader.GetKursKz(akodval: Integer; const aRes: String): Double;
var keyValue: String;
    keyValue2: String;
    m_p, m_p2: Integer;
    m_p3: Integer;
    sammount: String;
    old_separator: Char;
begin
  keyValue := getS_name(akodval)+'</TITLE><DESCRIPTION>';
  keyValue2 := '</DESCRIPTION>';
  old_separator := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    m_p := pos(keyvalue, aRes);
    m_p2 := m_p+ length(keyValue);
    if (m_p > 0) then
    begin
      sammount := Copy(aRes,m_p2,100);
      m_p3 := pos(keyValue2, sammount);
      sammount := Copy(sammount,0,m_p3-1);
      Result := StrToFloat(sammount);
    end;
  finally
    FormatSettings.DecimalSeparator := old_separator;
  end;
end;

function TFmKursLoader.getKursMegbank(akodval: Integer;const aRes:String; bSale:Boolean = False): Double;
const
  cRightS =  'right>';
var
    sKeyVal: String;
    s, s2: String;
//    old_separator: Char;
    m_p, m_p2: Integer;
    i: Integer;
    _List: tstringList;
begin
//  Result := 0;
//  old_separator := FormatSettings.DecimalSeparator;
{  _List := tstringList.Create;
  _List.add(aRes);
  _List.saveToFile('D:\test1.txt');
  _List.Clear;
  _List.add(UTF8Decode(aRes));
  _List.saveToFile('D:\test2.txt');
 }

  if bSale then
  begin
    if akodval=172889 then
      sKeyVal := '>доллар США<';
    if akodval=172890 then
      sKeyVal := '>Евро<';

  end
  else
  begin
    if akodval=154100 then
      sKeyVal := '>доллар США<';
    if akodval=156194 then
      sKeyVal := '>Евро<';
  end;

  try
    m_p := PosEx(sKeyVal,aRes);
    m_p := PosEx(cRightS,aRes,m_p);
    if m_p>0 then
    begin
      m_p2:= PosEx('<',aRes,m_p);
      s := Copy(aRes,m_p+6,m_p2-7-m_p+1);
    end;
    for I := 0 to 2 do
      m_p := PosEx(cRightS,aRes,m_p+1);
    if m_p>0 then
    begin
      m_p2:= PosEx('<',aRes,m_p);
      s2 := Copy(aRes,m_p+6,m_p2-7-m_p+1);
    end;

  finally
    try
      if bSale then
      begin
        if  (length(s2)>0) then
          Result := StrToFloat(s2)
        else
          Result := 0;
      end
      else
        if (length(s)>0) and (length(s2)>0) then
          Result := (StrToFloat(String(s2))+strToFloat(String(s)))/2
        else
          Result := 0;
    except
      on E:Exception do
      begin
        TxtMonitor(E.Message);
        Result := 0;
      end;
    end;
  end;
end;

function TFmKursLoader.getKursMegbankSale(akodval: Integer; d1,d2:TDateTime): Double;
var sUrl: String;
    data: TDateTime;
    sd: String;
    d,m,y: Word;
    cCharId: String;
    sRes, sKey, sKeyKurs: String;
    sKeyEndKurs: String;
    nCountDay : Integer;
    m_Pos, m_Pos2 : Integer;
    sKurs: string;
    pKurs: PKursMgbSale;
//    Stream: TStringStream;
    old_DecimalSeparator: Char;
    old_thousandseparator: Char;

    function CalcKurs(d3: TDateTime):Double;
    begin
      Result := 0;
      sKey  := '<td align="center"><font class="blfnt">'+DateToStr(d3)+'</td>';
      sKurs := '';
      m_pos := PosEx(sKey,sres);
      if m_pos>0 then
      begin
        // -1 -
        m_pos := PosEx(sKeyEndKurs,sres,m_pos);
        // -2 -
        if m_pos>0 then
           m_pos := PosEx(sKeyEndKurs,sres,m_pos+1);
        // -3 -
        if m_pos>0 then
           m_pos := PosEx(sKeyKurs,sres,m_pos+1);
        if m_pos>0 then
           m_pos2 := PosEx(sKeyEndKurs,sres,m_pos+1);
        if m_pos2>0 then
           sKurs := Copy(sres,m_pos+Length(sKeyKurs),m_pos2-m_pos-length(sKeyKurs))
      end;
      if Length(sKurs)>0 then
        Result := StrToFloat(ReplaceStr(sKurs,' ',''))
      else
      begin
        if d3>=(d1-3) then
          Result := CalcKurs(d3-1);
      end;
    end;
begin
  ClearListKursMgbSale;
  if akodval=172889 then
     cCharId := 'USD';
  if akodval=172890 then
     cCharId := 'EUR';

  old_decimalseparator  := FormatSettings.DecimalSeparator;
  old_thousandseparator := FormatSettings.ThousandSeparator;
  FormatSettings.DecimalSeparator  := '.';
  FormatSettings.ThousandSeparator := ' ';
  try
    data:= Now;
    nCountDay := (Trunc(data- d1)   + 3);
    if nCountDay<=30 then
      nCountDay := 30
    else
      if nCountDay<=90 then
        nCountDay := 90;


    DecodeDate(data,y,m,d);
    sd   := IntToStr(y)+'-'+StrZero(m,2)+'-'+IntToStr(d);
    sUrl := 'http://ufs.com.ua/ports/curforex.php?CharID='+cCharId+'&Amount='+IntToStr(nCountDay);

    PageText.Clear;
    HttpGetText(sUrl,PageText);
    sres := (PageText.Text);

    //Stream:= TStringStream.Create(sres);
//  Stream.WriteString(sRes);
   { Stream.WriteString(sUrl);
    Stream.SaveToFile('d:\mgb_sale.txt');
    Stream.Free; }

    sKeyKurs    := '<td align="right"><font class="bkfnt">';
    sKeyEndKurs := '&nbsp;';
    Result := 0;
    while d2>=d1 do
    begin
      Result := CalcKurs(d2)/100;
      New(pKurs);
      pKurs.data := d2;
      pKurs.kurs := Result;
      ListKursMgbSale.Add(pKurs);
      d2 := d2 -1;
    end;
  finally
    FormatSettings.DecimalSeparator := old_decimalseparator;
    FormatSettings.Thousandseparator := old_thousandseparator;
  end;
end;

function TFmKursLoader.GetKursRus(akodval: Integer; const aRes: String): Double;
var a,a2, mashtab:Word;
    sKeyVal,s: String;
    old_separator: Char;
    sResult: String;
//    fStream: TFileStream;
//    Wr: TWriter;
begin
  Result := 0;
  old_separator := FormatSettings.DecimalSeparator;
  if akodval=51568 then
    sKeyVal := '>Доллар США<'
  else
    if (akodval=51567) or (akodval=Euro_bofm) then
      sKeyVal := '>ВРО<'
  else
    Exit;

  FormatSettings.DecimalSeparator := '.';
  try
    a:= Pos(sKeyVal,aRes);
    mashtab := 0;
    if a>0 then
      s:= Copy(aRes,a,300);
    a:= Pos('"right">',s);
    if a>0 then
    begin
      a:= a+StrLen('"right">');
      a2:=a;
      while s[a2]<>'<' do
        Inc(a2);
      mashtab := StrToInt(Copy(s,a,a2-a));
    end;
    if mashtab>0 then
    begin
      a:= Pos('strong>',s);
      if a>0  then
      begin
        a:= a+StrLen('strong>');
        a2:=a;
        while s[a2]<>'<' do
        Inc(a2);
        sResult := (Copy(s,a,a2-a));
      end;
    end;
    if sResult<>'' then
       Result := StrToFloat(sResult)
    else
      Result := 0;
{    if Result=0 then
    begin
      fStream := TFileStream.Create('d:\kursloader.html',fmCreate);
      Wr := TWriter.Create(fStream,2048);
      Wr.WriteStr(AnsiString(aRes));
      Wr.Free;
      fStream.Free;
    end;}
  finally
    FormatSettings.DecimalSeparator := old_separator;
  end;
 // Result := StrToFloat(sResult);
end;

function TFmKursLoader.GetKursRusCbr2(akodval: Integer; AList: TRusKursList): Double;
var a,a2, mashtab:Word;
    sKeyVal,s: String;
    p: PRusKursItem;
begin
  if akodval=51568 then
    sKeyVal := 'USD' //'<CharCode>USD</CharCode>'
  else
    if (akodval=51567) or (akodval=Euro_bofm) then
      sKeyVal := 'EUR'//'<CharCode>EUR</CharCode>'
  else
    sKeyVal := '';
  p := AList.findOnCharCode(sKeyVal);
  if Assigned(p) then
    Result := p.value / p.nominal
  else
    Result := 0;
end;



function TFmKursLoader.GetKursRusCbr(akodval: Integer;
  const aRes: String): Double;
var a,a2, mashtab:Word;
    sKeyVal,s: String;
    old_separator: Char;
    sResult: String;
//    fStream: TFileStream;
//    Wr: TWriter;
begin
  Result := 0;
  old_separator := FormatSettings.DecimalSeparator;
  if akodval=51568 then
    sKeyVal := '<CharCode>USD</CharCode>'
  else
    if (akodval=51567) or (akodval=Euro_bofm) then
      sKeyVal := '<CharCode>EUR</CharCode>'
  else
    Exit;


//  FormatSettings.DecimalSeparator := '.';
  try
    a:= Pos(sKeyVal,aRes);
    mashtab := 0;
    if a>0 then
      s:= Copy(aRes,a,300);
    a:= Pos('<Nominal>',s);
    if a>0 then
    begin
      a:= a+StrLen('<Nominal>');
      a2:=a;
      while s[a2]<>'<' do
        Inc(a2);
      mashtab := StrToInt(Copy(s,a,a2-a));
    end;
    if mashtab>0 then
    begin
      a:= Pos('<Value>',s);
      if a>0  then
      begin
        a:= a+StrLen('<Value>');
        a2:=a;
        while s[a2]<>'<' do
        Inc(a2);
        sResult := (Copy(s,a,a2-a));
      end;
    end;
    if sResult<>'' then
       Result := StrToFloat(sResult)
    else
      Result := 0;
{    if Result=0 then
    begin
      fStream := TFileStream.Create('d:\kursloader.html',fmCreate);
      Wr := TWriter.Create(fStream,2048);
      Wr.WriteStr(AnsiString(aRes));
      Wr.Free;
      fStream.Free;
    end;}
  finally
    FormatSettings.DecimalSeparator := old_separator;
  end;

end;

function TFmKursLoader.GetKursUkr(const akodval: String;const s_name:String; const aRes: String): Double;
var
//    old_separator: Char;
    cFevShValuta, cFevShKoef, cFevShKurs:String;
    nFevShKoef,nFevShKurs, nFevShValuta: Integer;
    nPosKod, nPosKoef1, nPosKoef2: Integer;
    nKoef, nPosVal1,nPosVal2: Integer;
    old_separator: Char;
//    nVal: double;
begin
//  Result := 0;
//  nKoef := 0;

  cFevShKoef := '<TD CLASS="CELL_C">';   // шаблон начала перед масштабом
  nFevShKoef := Length(cFevShKoef)        ;
  cFevShKurs := '<TD CLASS="CELL_C">';    // шаблон начала перед курсом
  nFevShKurs := Length(cFevShKurs);

  cFevShValuta :=   '<TD CLASS="CELL_C">'+Trim(String(ReplaceStr(String(s_name),'руб.','RUB')));

  nFevShValuta := Length(cFevShValuta);

  old_separator := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    nPosKod := Pos(cFevShValuta, aRes);
    // Масштаб
    nPosKoef1 := PosEx((cFevShKoef), (aRes), nPosKod+nFevShValuta);
    nPosKoef2 := PosEx('</TD>', String(aRes), nPosKoef1+nFevShKoef);

    nKoef    := StrToInt( Trim( Copy(aRes, nPosKoef1+nFevShKoef,
                                             nPosKoef2-(nPosKoef1+nFevShKoef))));

    // Значение курса
    nPosVal1 := PosEx(String(cFevShKurs), String(aRes), nPosKoef2);
    nPosVal2 := PosEx('</TD>', String(aRes), nPosVal1+nFevShKurs);

    Result := StrToFloat( Trim( Copy(aRes, nPosVal1+nFevShKurs,
                                         nPosVal2-(nPosVal1+nFevShKurs) )))/nKoef;
  finally
    FormatSettings.DecimalSeparator := old_separator;
  end;
end;

function TFmKursLoader.GetKursUkrMinfin(const akodval, s_name, aRes: String): Double;
var
//    old_separator: Char;
    cFevShValuta, cFevShKoef, cFevShKurs:String;
    nFevShKoef,nFevShKurs, nFevShValuta: Integer;
    nPosKod, nPosKoef1, nPosKoef2: Integer;
    nKoef, nPosVal1,nPosVal2: Integer;
    old_separator: Char;
//    nVal: double;
begin
//  Result := 0;
//  nKoef := 0;

  cFevShKoef := 'align=right>';   // шаблон начала перед масштабом
  nFevShKoef := Length(cFevShKoef)        ;
  cFevShKurs := 'align=right>';    // шаблон начала перед курсом
  nFevShKurs := Length(cFevShKurs);

  cFevShValuta :=   'align=center>'+Trim(String(ReplaceStr(String(s_name),'руб.','RUB')));

  nFevShValuta := Length(cFevShValuta);

  old_separator := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := ',';
  try
    nPosKod := Pos(cFevShValuta, aRes);
    // Масштаб
    nPosKoef1 := PosEx((cFevShKoef), (aRes), nPosKod+nFevShValuta);
    nPosKoef2 := PosEx('</td>', String(aRes), nPosKoef1+nFevShKoef);

    nKoef    := StrToInt( Trim( Copy(aRes, nPosKoef1+nFevShKoef,
                                             nPosKoef2-(nPosKoef1+nFevShKoef))));

    // Значение курса
    nPosVal1 := PosEx(String(cFevShKurs), String(aRes), nPosKoef2);
    nPosVal2 := PosEx('</td>', String(aRes), nPosVal1+nFevShKurs);

    Result := StrToFloat( Trim( Copy(aRes, nPosVal1+nFevShKurs,
                                         nPosVal2-(nPosVal1+nFevShKurs) )))/nKoef;
  finally
    FormatSettings.DecimalSeparator := old_separator;
  end;
end;

function TFmKursLoader.getS_Name(kodv: Integer): String;
begin
  with FDAdsQuery2 do
  begin
    Active := false;
    SQL.Clear;
    SQL.Add('SELECT * FROM valuta WHERE kodv=:kodv');
    ParamByName('kodv').AsInteger := kodv;
    Open;
    Result := FieldByName('s_name').AsString;
    Close;
  end;
end;

procedure TFmKursLoader.Lo1Click(Sender: TObject);
begin
  LoadKursFromPeriod(KURS_MEGB);
end;

procedure TFmKursLoader.LoadEvroBegonofmonth1Click(Sender: TObject);
begin
  LoadKursFromPeriod(KURS_RUS_BOFM);
end;

procedure TFmKursLoader.LoadKursFromPeriod(aTypeKurs: Integer);
var d1:TDateTime;
    d2:TDateTime;
begin
  case aTypeKurs of
    KURS_UKR: fm.Caption := ' Загрузка курсов (Украина)';
    KURS_RUS: fm.Caption := ' Загрузка курсов (Россия)';
    KURS_MEGB: fm.Caption := ' Загрузка курсов (Межбанк)';
    KURS_MEGB_SALE: fm.Caption := ' Загрузка курсов (Межбанк - продажа)';
  end;

//  Fm.Items[0].oVar.AsDateTime := now;
//  Fm.Items[1].oVar.AsDateTime := now;
  if Fm.ShowModal=mrOk then
  begin
    d1 := Fm.Items[0].oVar.AsDateTime;
    d2 := Fm.Items[1].oVar.AsDateTime;
    //if aTypeKurs=KURS_MEGB_SALE then
    //  CheckKurs(aTypeKurs,d1,d2)
    //else
    while d1<= d2 do
    begin
      CheckKurs(aTypeKurs,d1);
      d1 := d1 + 1;
    end;
    ShowMessage('Ok!');
  end;
end;

procedure TFmKursLoader.LoadKZ1Click(Sender: TObject);
begin
  LoadKursFromPeriod(KURS_KZ);
end;

procedure TFmKursLoader.LoadMegbankSaleClick(Sender: TObject);
begin
  LoadKursFromPeriod(KURS_MEGB_SALE);
end;

procedure TFmKursLoader.LoadRUS1Click(Sender: TObject);
begin
  LoadKursFromPeriod(KURS_RUS);
end;

procedure TFmKursLoader.LoadUKR1Click(Sender: TObject);
begin
  LoadKursFromPeriod(KURS_UKR);
end;

procedure TFmKursLoader.Re1Click(Sender: TObject);
{var s: String;
    f: TFormatSettings;
    v: Variant;}
begin
 { s:= '1 096.0000';
  s := ReplaceStr(s,' ','');
  FormatSettings.DecimalSeparator := '.';
  ThousandSeparator := ' ';
  v := s;
  ShowMessage(FloatToStr(StrToFloat(v)));}
  Timer1Timer(Self);
end;

procedure TFmKursLoader.SaveStringToFile(const filename, s: String);
var stream:TmemoryStream;
begin
  stream := TMemoryStream.Create;
  try
    stream.SetSize(s.Length+1);
    move(s[1],stream.Memory^,length(s));
    stream.SaveToFile(filename);
  finally
    stream.free;
  end;
end;

procedure TFmKursLoader.Timer1Timer(Sender: TObject);
var y1,m1,d1: Word;
    y2,m2,d2: Word;
    h,m,s,ms:Word;
begin
  MessageList.Clear;
  try
    DecodeTime(Time,h,m,s,ms);
    if h<7 then
      Exit;
    DecodeDate(Now,y1,m1,d1);
    DecodeDate(dLastUkr,y2,m2,d2);
//    if not ((y1=y2) and (m1=m2) and (d1=d2)) then
    begin
      //CheckKurs(KURS_UKR,Now-1);
      //CheckKurs(KURS_UKR,Now);
    end;

    DecodeDate(dLastMgb,y2,m2,d2);
    if not ((y1=y2) and (m1=m2) and (d1=d2)) then
    begin
      CheckKurs(KURS_MEGB);
    end;

    DecodeDate(dLastMgbSale,y2,m2,d2);
    if not ((y1=y2) and (m1=m2) and (d1=d2)) then
    begin
      CheckKurs(KURS_MEGB_SALE);
    end;
    CheckKurs(KURS_KZ);

 //   if h>=13 then
    begin
      DecodeDate(dLastRus,y2,m2,d2);
      if not ((y1=y2) and (m1=m2) and (d1=d2)) then
        CheckKurs(KURS_RUS);
      DecodeDate(dLastRus_bofm,y2,m2,d2);
      if not ((y1=y2) and (m1=m2) and (d1=d2)) then
        CheckKurs(KURS_RUS_BOFM);
    end;
  finally
    if MessageList.Count>0 then
      SendMail('lan@mikko.com.ua','dmitry.shpinev@mikko.com.ua','192.168.70.9','load kurs',
         MessageList.Text,'lan','hope1998');
    if not sameText(ParamStr(1),'-notclose') then
    begin
      TxtMonitor('close application');
      PostMessage(Handle,WM_CLOSE,0,0);
    end
    else
      TxtMonitor('continue');

  end;
end;

procedure TFmKursLoader.WmTray(var Msg: TMessage);
begin
  Application.Minimize;
  Self.Hide;
end;


procedure TFmKursLoader.WriteKurs(data:TDateTime; nKodV:Integer; nKurs:double);
var nSumma:double;
begin
  nSumma := nKurs * FDAdsQuery1.FieldByName('mashtab').AsInteger;
  if nSumma=0 then
  begin
//    TxtMonitor('-Нулевой курс! - '+ DateToStr(data)+' kodv-'+IntToStr(nKodv));
    MessageList.Add('-Нулевой курс! - '+ DateToStr(data)+' kodv-'+IntToStr(nKodv));
  end
  else
  begin
    FDTbKurs.Active := true;
    if not FDTbKurs.Locate('kodv;data',VarArrayOf([nKodV,data]),[]) then
       FDTbKurs.Append
    else
       FDTbKurs.Edit;
    try
      FDTbKurs.FieldByName('data').AsDateTime := data;
      FDTbKurs.FieldByName('kodv').AsInteger  := nKodV;
      FDTbKurs.FieldByName('summa').AsFloat   := nSumma;
      MessageList.add(DateToStr(data)+' '+IntToStr(nkodv)+' '+FloatToStr(nSumma));
    finally
      FDTbKurs.Post;
    end;
  end;
end;

end.
