unit SoundPlayerEntrance;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,  MMSystem;

type
  TEntranceSoundPlayer = class(TObject)
  private
    Fsound_notify: Pointer;
    Fsound_chimes: Pointer;
    Fsound_tada: Pointer;
    procedure Setsound_chimes(const Value: Pointer);
    procedure Setsound_notify(const Value: Pointer);
    procedure Setsound_tada(const Value: Pointer);
  public
    constructor Create();
    destructor Destroy();override;
    procedure play(AResource: Pointer);
    property sound_tada: Pointer read Fsound_tada write Setsound_tada;
    property sound_chimes: Pointer read Fsound_chimes write Setsound_chimes;
    property sound_notify: Pointer read Fsound_notify write Setsound_notify;
  end;


implementation

{$R sounds.res}


{ TEntranceSoundPlayer }

constructor TEntranceSoundPlayer.Create;
begin
  Fsound_tada := Pointer(FindResource(hInstance, 'tada', 'wave'));
  if Fsound_tada <> nil then begin
    Fsound_tada := Pointer(LoadResource(hInstance, HRSRC(Fsound_tada)));
    if Fsound_tada <> nil then Fsound_tada := LockResource(HGLOBAL(Fsound_tada));
  end;

  Fsound_chimes := Pointer(FindResource(hInstance, 'chimes', 'wave'));
  if Fsound_chimes <> nil then begin
    Fsound_chimes := Pointer(LoadResource(hInstance, HRSRC(Fsound_chimes)));
    if Fsound_chimes <> nil then Fsound_chimes := LockResource(HGLOBAL(Fsound_chimes));
  end;

  Fsound_notify := Pointer(FindResource(hInstance, 'notify', 'wave'));
  if Fsound_notify <> nil then begin
    Fsound_notify := Pointer(LoadResource(hInstance, HRSRC(Fsound_notify)));
    if Fsound_notify <> nil then Fsound_notify := LockResource(HGLOBAL(Fsound_notify));
  end;

end;

destructor TEntranceSoundPlayer.Destroy;
begin
  UnlockResource(HGLOBAL(Fsound_tada));
  UnlockResource(HGLOBAL(Fsound_chimes));
  UnlockResource(HGLOBAL(Fsound_notify));
  inherited;
end;

procedure TEntranceSoundPlayer.play(AResource: Pointer);
begin
  sndPlaySound(AResource, SND_MEMORY
    or SND_NODEFAULT or SND_ASYNC);
end;

procedure TEntranceSoundPlayer.Setsound_chimes(const Value: Pointer);
begin
  Fsound_chimes := Value;
end;

procedure TEntranceSoundPlayer.Setsound_notify(const Value: Pointer);
begin
  Fsound_notify := Value;
end;

procedure TEntranceSoundPlayer.Setsound_tada(const Value: Pointer);
begin
  Fsound_tada := Value;
end;

end.
