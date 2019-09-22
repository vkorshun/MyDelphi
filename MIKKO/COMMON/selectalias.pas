unit selectalias;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Registry,DateVk, fm_setfilter;

const
  Reg_UserData  = '\Software\WG SoftPro, Kharkov\ADS Task';

type
  TSelectAlias = class(TComponent)
  private
    FFmSelect: TFmSetFilter;
    FReg: TRegistry;
    procedure SetFmSelect(const Value: TFmSetFilter);
    procedure LoadRegistry;
  public
    constructor Create(aOwner:TComponent);override;
    destructor  Destroy;override;
    function GetPath:String;
    property FmSelect: TFmSetFilter read FFmSelect;
  end;
implementation

{ TSelectAliac }

constructor TSelectAlias.Create(aOwner: TComponent);
begin
  Inherited;
  FFmSelect := TFmSetFilter.Create(nil);
  FFmSelect.Position := poScreenCenter;
  FReg := TRegistry.Create;
  FReg.RootKey := HKEY_CURRENT_USER;
  FReg.OpenKey(Reg_UserData, true);
end;

destructor TSelectAlias.Destroy;
begin
  FreeAndNil(FFmSelect);
  FreeAndNil(FReg);
  inherited;
end;

function TSelectAlias.GetPath: String;
var i: Integer;
begin
  LoadRegistry;
  Result := '';
  fFmSelect.SetForm(fFmSelect);
  if FFmSelect.ShowModal=mrOk  then
  begin
    i := FFmSelect.ListBox1.ItemIndex;
    if i>-1 then
    begin
      FReg.OpenKey(Reg_UserData+'\'+FFmSelect.ListBox1.Items[i],True);
      Result := AnsiUpperCase(FReg.ReadString('DirMain'));
      if Result[Length(Result)]<>'\' then
         Result := result + '\';
      Result := Result + 'COMMON\'
    end;
  end;
end;

procedure TSelectAlias.LoadRegistry;
var L: TStringList;
      i: integer;
begin
  L := TStringList.Create;
  FmSelect.ListBox1.Items.Clear;
  try
    FReg.GetKeyNames(L);
    if L.Count = 0 then Exit;
    for i := 0 to L.Count-1 do begin
      FmSelect.ListBox1.Items.Add(L.Strings[i]);
    end;
  finally
    FreeAndNil(L);
  end;

end;

procedure TSelectAlias.SetFmSelect(const Value: TFmSetFilter);
begin

end;

end.
