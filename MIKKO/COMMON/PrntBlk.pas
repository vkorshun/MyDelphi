unit PrntBlk;

interface

uses Messages, Windows, Classes, SysUtils, Dialogs, docdialog.fm_docdialog, Forms, variants,
  vararrayutil;

type
  TOpisBlank = Record
    Var1: TStringList;
    Var2: AnsiString;
    Var3: TStringList;
    Var4: TStringList;
    Var5: TStringList;
    Var6: TStringList;
    Var7: TStringList;
    Var8: TStringList;
    Var9: TStringList;
    Var10: TStringList;
    Var11: TStringList;
    Var12: TStringList;
  end;

  PBlankItem = ^TBlankItem;
  TBlankItem = Record
    Kod      : Integer;
    Name     : AnsiString;
    FileName : AnsiString;
    Width    : Word;
    Rtf      : AnsiString;
    ParamStr : AnsiString;
    EJect    : AnsiString;
    DelSetPrn: AnsiString;
    aOpisBlank : TOpisBlank;
  end;

  TGetBookmark= function (sender:TObject;i:integer):AnsiString of object;
  TGetBoolean = function (sender:TObject):boolean of object;
  TGetBooleanId = function (sender:TObject;i:integer):boolean of object;
  TNotifyEventId   = procedure (Sender:TObject; i:integer) of object;
  TBlank = class(TObject)
  private
    FBuf: WideString;
    FRtfName: TFileName;
    FFmDialog: TFmDocDialog;
    FFileName: TFileName;
    FbFirst: Boolean;

    FOnCreate: TNotifyEvent;
    FOnDestroy: TNotifyEvent;
    FOn: TNotifyEvent;
    FOnWhileDoc: TGetBoolean;
    FOnGetBookMark: TGetBookMark;

    FOnDoWhile: TGetBooleanId;
    FOnDoSkip: TNotifyEventId;
    procedure ReadBlank;
    procedure PrintRtf(cFileName:String);
    procedure RunWord(cFileName:String);
//    property selected:PBlankItem Read Fselected;

    function  DoWhileDoc:Boolean;
    procedure DoBeforeDoc;
    procedure DoSkipDoc;
    function  ReadRtf(cFileName: String): Boolean;
    procedure WriteRtf(v: Variant; cFileName: String);

    function  DoWhile(nWhile:byte):Boolean;
    procedure DoSkip(nWhile:byte);
    procedure DoBeforeWhile(nWhile:byte);
    function  DoBookmark(nBookmark:Integer):AnsiString;
  public
    constructor Create;
    procedure PrintBlank;
    property RtfName:TFileName read FRtfName write FRtfName;
    property FileName:TFileName read FFileName write FFileName;
    property OnCreate:TNotifyEvent read FOnCreate write FOnCreate;
    property OnDestroy:TNotifyEvent read FOnDestroy write FOnDestroy;
    property OnWhileDoc:TGetBoolean read FOnWhileDoc write FOnWhileDoc;
    property OnGetBookmar:TGetBookmark read FOnGetBookMark write FOnGetBookmark;
    property OnDoWhile:TGetBooleanId read FOnDoWhile write FOnDoWhile;
    property OnDoSkip:TNotifyEventId read FOnDoSkip write FOnDoSkip;
  end;

var
  MsWord: Variant;

implementation
uses datevk,comobj;

{ TBlank }



procedure TBlank.PrintBlank( );
begin
  try
//    fmMainWait.SetWait('Ожидайте...');
    FileName := NameLock(ExtractFileDir(Application.ExeName),'rtf');
    // Выполнение блока до
    if Assigned(FOnCreate) then
      FOnCreate(self);

    FbFirst := True;

    //Цикл по документу
    while DoWhileDoc do begin

      // Before Doc
      DoBeforeDoc;

      PrintRtf(FileName);

      // Skiper in Parametr
      // Skiper in Blank

      {v:= FSelected.aOpisBlank.Var3;
      if v.Count= 0 then Break;
      for i:=0 to v.Count-1 do
        self.Eval(v[i]);}
      DoSkipDoc;
    end;
    RunWord(FileName);
  finally
//    fmMainWait.RestWait;
  end;
  // After in Blank
end;

function TBlank.ReadRtf(cFileName: String):Boolean;
Var F:TFileStream;
    b: PAnsiChar;
begin
  if ExtractFileName(cFileName) = '' then
     Raise Exception.Create('Неопределен RTF!');
  F:= TFileStream.Create(cFileName,fmShareDenyNone	);
  try
    F.Seek(0,soFromBeginning	);
    b:= PAnsiChar(StrAlloc(F.Size+1));
    F.ReadBuffer(b^,F.Size);
    Fbuf := StrPas(b);
    Result := True;
    F.Destroy;
  except
    F.Destroy;
    Raise;
  end;
end;

Procedure TBlank.WriteRtf(v:Variant;cFileName: String);
var i: Integer;
    FNew:TFileStream;
    p: PAnsiChar;
    s: AnsiString;
begin
  FNew:= TFileStream.Create(cFileName,fmCreate);
  try
    for i:=1 to ALEN(v) do begin
      s:= v[i];
      p:= PAnsiChar(s);
      FNew.WriteBuffer(p^,Length(s));
    end;
    FNew.Free;
  except
    FNew.Free;
    Raise;
  end;
end;


procedure TBlank.PrintRtf(cFileName:String);
//var buf:String;

  function AtPos(sub,s:AnsiString;nVhod,nStart:Integer):Integer;
  var k,p: Integer;
  begin
    k := 0;
    Result := 0;
    while k<(nVhod) do begin
//      nStart:= nStart+1;
      s:= copy(s,nStart+1,Length(s));
      p := pos(sub,s);
      if p=0 then
        Exit
      else begin
        inc(k);
        Result := nStart+p;
        nStart:= nStart+p;
      end;
    end;
  end;

var
  nLen, nPos, nStartPos : Integer;
  nEndPos,nKod, nStackSize: Integer;
  aOutput, aLoopStack, aRichStack, aPosStack: Variant;
  cOutput,cBkmkName: AnsiString;
  nOutPos, nKodLoop: Integer;
  lLoop: Boolean;
  e: Variant;
begin
  if not ReadRtf(FRtfName) then Exit;
  nLen      := Length(Fbuf);
  nPos      := 1;
//  nStartPos := 1;
//  nEndPos   := 1;
//  nKod      := 0;
  nStackSize:= 0;
  cBkmkName := '';
  cOutPut   :='';
  aOutput   := VarArrayOf([null]);
  nKodLoop  := 0;
  aLoopStack:= VarArrayOf([null]);
  aRichStack:= VarArrayOf([null]);
  aPosStack := VarArrayOf([null]);
  nOutPos   := 1;
  lLoop     := False;

  while nPos < nLen do begin
    // Контроль длины строки
    if Length(cOutPut)>60000 then begin
      AADD(aOutPut,cOutPut);
      cOutput := '';
    end;

    //Ищем следующую закладку
    if lLoop then   // для пропущенного оставляем
      lLoop := False
    else
      nPos := atpos('\bkmkstart',Fbuf,1,nPos);



    // Если закладки закончились
    if nPos = 0 then begin
      // Дописываем оставшуюся часть в выходную строку
      cOutput := cOutput + copy(Fbuf, nOutPos,Length(Fbuf));

      // Если мы находимся в цикле
      if nStackSize > 0 then begin
        // Выполняем скиппер цикла
        try
{          Eval(FSelected.aOpisBlank.Var7[nKodLoop-1]);
          while (FSelected.aOpisBlank.Var12[nKodLoop-1]<> '') and
            not self.EvalBool(FSelected.aOpisBlank.Var12[nKodLoop-1]) and
               self.EvalBool(FSelected.aOpisBlank.Var6[nKodLoop-1])
           do Eval(FSelected.aOpisBlank.Var7[nKodLoop-1]);
}
          DoSkip(nKodLoop);
//          while DoSodWhile(nKodLoop-1) and DoSodsSkip(nKodLoop-1) do
//            DoEvalVars(nKodLoop-1);
        except
          Raise;
          //Ecception.Create('RTF : "SKIP" по циклу бланка (06)')
        end;

        // Оцениваем условие WHILE цикла
        try
//          e := EvalBool(FSelected.aOpisBlank.Var6[nKodLoop-1]);
          e := DoWhile(nKodLoop)
        except
          e := False;
          Raise;
        end;
        if e then begin
          // Переходим к началу цикла
          nPos    := 1;
          nOutPos := 1;

          // Выходим из цикла
        end else begin
          Fbuf  := aRichStack[nStackSize];
          nLen       := Length(Fbuf);
          nPos       := aPosStack[nStackSize];
          nOutPos    := aPosStack[nStackSize];
          nStackSize := nStackSize - 1;
          // Возвращаемся в предыдущий цикл, если он определен
          if nStackSize > 0 then begin
            nKodLoop   := aLoopStack[nStackSize];
          end;
          // Исключаем элементы массивов,
          // соответствующие завершеннному циклу - (nStackSize+1)
          VarArrayRedim(aLoopStack, nStackSize);
          VarArrayRedim(aRichStack, nStackSize);
          VarArrayRedim(aPosStack,  nStackSize);
        end;
        // Если мы не в цикле - идем дальше с позиции nPos+10
      end else Break;
    end;

    // Ищем конец маркера начала закладки
    nEndPos := nPos;
    while (nEndPos < nLen) and (copy(Fbuf, nEndPos, 1) <> '}')do
      nEndPos := nEndPos + 1;

    // Определяем имя закладки
    cBkmkName := Trim(copy(Fbuf, nPos + 10, nEndPos - nPos - 10));

    // Если закладка соответствует циклу
    if Copy(cBkmkName, 1,1) = 'L' then begin

      // Ищем конец маркера начала закладки
      nStartPos := nPos;
      while (nStartPos < nLen) and (Copy(Fbuf, nStartPos, 1) <> '}') do
         nStartPos := nStartPos + 1;
      if nStartPos < nLen then
         nStartPos := nStartPos + 1;

      // Выводим текст до закладки
      cOutput := cOutput + copy(Fbuf, nOutPos, nStartPos - nOutPos);
      nOutPos := nStartPos;

      // Ищем маркер конца закладки
      nPos := atpos('\bkmkend ' + cBkmkName, Fbuf, 1, nPos);
      if nPos = 0 then    nPos := Length(Fbuf);

      // Ищем начало маркера конца закладки
      nEndPos := nPos;
      while (nEndPos > 1) and (copy(Fbuf, nEndPos, 1) <> '{') do
        nEndPos := nEndPos - 1;
      if nEndPos > 1 then
        nEndPos := nEndPos - 1;

      // Определяем номер цикла
      nKodLoop := StrToInt(Copy(cBkmkName, 2,Length(cBkmkName)));

      // Контроль длины строки
      if Length(cOutPut) > 60000 then begin
        AADD(aOutPut, cOutPut);
        cOutPut := '';
      end;

      // Выполняем стартовый блок цикла
{      if FSelected.aOpisBlank.Var5[nKodLoop-1] <> '' then begin
        try
          Eval(FSelected.aOpisBlank.Var5[nKodLoop-1]);
          while (FSelected.aOpisBlank.Var12[nKodLoop-1] <>'') and
                (not EvalBool(FSelected.aOpisBlank.Var12[nKodLoop-1])) and
                (EvalBool(FSelected.aOpisBlank.Var6[nKodLoop-1])) do
           Eval(FSelected.aOpisBlank.Var7[nKodLoop-1])
        except
          Raise;
          //ErrorMessage(oError, 'RTF : "START" для цикла бланка (05)')
        end;
      end; }
      //?????
      DoBeforeWhile(nKodLoop);

      // Проверяем условие WHILE цикла
      try
        e := DoWhile(nKodLoop);
      except
        e := False;
        Raise;
       //     ErrorMessage(oError, 'RTF : "WHILE" для цикла бланка (06)')
      end;
      if e then begin
        // Сохраняем в стеке текущую строку
        AADD(aRichStack, Fbuf);
        AADD(aPosStack,  nEndPos + 1);
        AADD(aLoopStack, nKodLoop) ;     //  номер цикла в dbf-файле
        nStackSize := nStackSize + 1;    //  номер цикла в стэке

        // Входим в новый цикл с начала закладки
        Fbuf  := copy(Fbuf, nStartPos, nEndPos - nStartPos);
        nLen       := Length(Fbuf);
        nPos       := 1;
        nOutPos    := 1;
      end else if nStackSize > 0 then
         nKodLoop   := aLoopStack[nStackSize] ;

    // Если встретилась обычная закладка
    end else begin
      if copy(cBkmkName,1, 1) = 'V' then begin
        // Выводим текст до закладки
        cOutput := cOutput + copy(Fbuf, nOutPos, nEndPos - nOutPos + 1);
        nOutPos := nEndPos + 1;

        // Определяем код закладки в шаблоне
        nKod := StrToInt(copy(cBkmkName, 2,Length(cBkmkName)-1));
        if (nKod > 0) then
//          (nKod <= FSelected.aOpisBlank.Var4.Count) and
//          ((FSelected.aOpisBlank.Var4[nKod-1]) <> '') then begin
        begin
          // Выводим значение в закладку
          cOutput := cOutput + TRIM(DoBookmark(nKod));
        end;
      end;
    end;
  end;
  // Накопление массива строк до 60000 байт
  AADD(aOutPut, cOutPut);
  // Запись в выходной файл
  WriteRTf(aOutput, cFileName)
end;

procedure TBlank.RunWord(cFileName:String);
begin
//   ExecuteFile(cFileName,'',ExtractFileDir(cFileName),sw_showmaximized);
  if VarType(MsWord)<> 9 then
    MsWord := CreateOleObject('word.basic');
  try
    MsWord.FileOpen(cFileName);
  except
    MsWord := CreateOleObject('word.basic');
    MsWord.FileOpen(cFileName);
  end;
  MsWord.AppShow;
end;

procedure TBlank.DoBeforeDoc;
begin

end;

procedure TBlank.DoSkipDoc;
begin

end;

// Цикл по документам
function TBlank.DoWhileDoc: Boolean;
begin
  if Assigned(OnWhileDoc) then
    Result := OnWhileDoc(self)
  else
    Result := FbFirst;
  FbFirst := False;
end;

procedure TBlank.ReadBlank;
begin

end;

procedure TBlank.DoBeforeWhile(nWhile: byte);
begin

end;

function TBlank.DoBookmark(nBookmark: Integer): AnsiString;
begin
  if Assigned(FOnGetBookMark) then
    Result := FOnGetBookMark(self,nBookmark);
end;

procedure TBlank.DoSkip(nWhile: byte);
begin
  if Assigned(FOnDoSkip) then
    FOnDoSkip(self,nWhile);
end;

function TBlank.DoWhile(nWhile: byte): Boolean;
begin
  Result := False;
  if Assigned(FOnDoWhile) then
    Result:=FOnDoWhile(self,nWhile);
end;

constructor TBlank.Create;
begin
  FbFirst := True;
end;

end.
