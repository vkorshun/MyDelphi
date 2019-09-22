unit soundsplay;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,  MMSystem;

type
  TEntranceSoundPlayer = class(TObject)
  private
    Fsound_notify: Pointer;
    Fsound_chimny: Pointer;
    Fsound_tada: Pointer;
    procedure Setsound_chimny(const Value: Pointer);
    procedure Setsound_notify(const Value: Pointer);
    procedure Setsound_tada(const Value: Pointer);
  public
    constructor Create();
    destructor Destroy();override;
    procedure play(AResource: Pointer);
    property sound_tada: Pointer read Fsound_tada write Setsound_tada;
    property sound_chimny: Pointer read Fsound_chimny write Setsound_chimny;
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

  Fsound_chimny := Pointer(FindResource(hInstance, 'chimny', 'wave'));
  if Fsound_chimny <> nil then begin
    Fsound_chimny := Pointer(LoadResource(hInstance, HRSRC(Fsound_chimny)));
    if Fsound_chimny <> nil then Fsound_chimny := LockResource(HGLOBAL(Fsound_chimny));
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
  UnlockResource(HGLOBAL(Fsound_chimny));
  UnlockResource(HGLOBAL(Fsound_notify));
  inherited;
end;

procedure TEntranceSoundPlayer.play(AResource: Pointer);
begin
  sndPlaySound(AResource, SND_MEMORY
    or SND_NODEFAULT or SND_ASYNC);
end;

procedure TEntranceSoundPlayer.Setsound_chimny(const Value: Pointer);
begin
  Fsound_chimny := Value;
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
