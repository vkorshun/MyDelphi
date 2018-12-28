unit uLog;

interface
uses forms, sysutils, Windows;

type
  TLogWriter = class
    class procedure LogException(Sender: TObject; E: Exception);
    class procedure Log(const AStr: String);
  end;

procedure LogMessage(text: string);

implementation

uses dialogs, classes;

var
  fileName: string;
  f: TextFile;

var
  FLogLock: TRTLCriticalSection;

procedure OpenLogFile;
var writeHeader: boolean;
begin
  if fileExists(fileName) then begin
    append(f);
    writeHeader:= trunc(FileDateToDateTime(
     fileAge(fileName))) <> date
    end
  else begin
    rewrite(f);
    writeHeader:= true;
  end;
  if writeHeader then begin
    writeln(f);
    writeln(f, stringOfChar('-', 40));
    writeln(f, DateToStr(Date));
    writeln(f, stringOfChar('-', 40));
    writeln(f);
  end;
  write(f, TimeToStr(now), '  ');
end;

procedure CloseLogFile;
begin
  closeFile(f);
end;

function ShiftText(s: string): string;
begin
  result:= stringReplace(
    adjustLineBreaks(s),
    #13#10,
    #13#10+stringOfChar(' ',10),
    [rfReplaceAll]);
end;


procedure LogMessage(text: string);
begin
  EnterCriticalSection(FLogLock);
  try
    openLogFile;
    writeln(f, shiftText(text));
  finally
    closeLogFile;
    LeaveCriticalSection(FLogLock);
  end;
end;

{ TLogWriter }

class procedure TLogWriter.Log(const AStr: String);
begin
  try
    openLogFile;
    writeln(f, AStr);
  finally
    closeLogFile;
  end;
end;

class procedure TLogWriter.LogException(Sender: TObject; E: Exception);
begin
  try
    openLogFile;
    writeln(f, 'Exception');
    writeln(f, '   Class: ', e.className);
    writeln(f, ' Message: ', shiftText(trim(e.Message)));
    writeln(f, '  Sender: ', sender.ClassName);
    if (sender is TComponent) then
      writeln(f, ' S. Name: ', TComponent(sender).Name);
    if screen.activeForm <> nil then begin
      writeln(f, '    Form: ', screen.activeForm.name);
      writeln(f, ' Caption: ', screen.activeForm.caption);
      writeln(f, ' Control: ', screen.activeControl.name);
      writeln(f);
    end;
  finally
    closeLogFile;
  end;
  application.ShowException(e);
end;

initialization
  fileName:= changeFileExt(application.exeName, '.log');
  assignFile(f, fileName);
  application.OnException:= TLogWriter.LogException;
  InitializeCriticalSection(FLogLock);

finalization
  DeleteCriticalSection(FLogLock);
end.

