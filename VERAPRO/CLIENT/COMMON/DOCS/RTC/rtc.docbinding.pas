unit rtc.docbinding;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  rtc.framedoc, DmMainRtc, rtc.dmdoc, ActnMan, rtc.fmCustomDoc,uDocDescription,
  vkvariable, vkvariablebindingdialog, Vcl.StdCtrls, Vcl.ExtCtrls, System.Actions, Vcl.ActnList;

type
  TDocMEditBox= class(TItemMEditBox)
  private
    FOnInitBeforeSelect: TNotifyEvent;
    procedure SetOnInitBeforeSelect(const Value: TNotifyEvent);
  protected
    FFmDoc: TCustomDocFm;
    FFrameClassName: String;
    FValues: TVkVariableCollection;
    procedure InitBeforeSelect;virtual;
    procedure InternalOnClick(Sender: TObject);
    function Select: Boolean;
  public
    function GetValue: Variant;
    procedure SetValue(AValue: variant);
    constructor Create(AOwner: TComponent);override;
    function IsPrepared: Boolean;
    procedure Prepare(const AFrameDocClassName: String);virtual;
    property OnInitBeforeSelect:TNotifyEvent read FOnInitBeforeSelect write SetOnInitBeforeSelect;
    property DocFm:TCustomDocFm read FFmDoc;
  end;

  TCustomDocFmVkVariableBinding = class(TMEditBoxVkVariableBinding)
  private
    function MyGetValue(Sender: TObject): Variant;
    procedure MySetValue(Sender: TObject;const Value:Variant);
  public
    constructor Create(AOwner: TPersistent);override;
    function GetMEditBox: TDocMEditBox;
    property DocMEditBox: TDocMEditBox read GetMEditBox;
    class function GetDefaultTypeOfControl: TWinControlClass; override;
  end;
  TDocFmVkVariableBinding = TCustomDocFmVkVariableBinding;


  TDocMEditBoxBindingDescription = Class(TBindingDescription)
  private
    FOnInitBeforeSelect: TNotifyEvent;
    FDocMEditBoxClass: String;
    procedure SetDocMEditBoxClass(const Value: String);
    procedure SetOnInitBeforeSelect(const Value: TNotifyEvent);
  public
    property DocMEditBoxClass: String read FDocMEditBoxClass write SetDocMEditBoxClass;
    property OnInitBeforeSelect:TNotifyEvent read FOnInitBeforeSelect write SetOnInitBeforeSelect;
    class function GetDocMEditBoxBindingDescription(const ADocMEditBoxClass: String;
       AOnInitBeforeSelect:TNotifyEvent):TDocMEditBoxBindingDescription;
  end;
implementation

{ TCustomDocFmVkVariableBinding }

constructor TCustomDocFmVkVariableBinding.Create(AOwner: TPersistent);
begin
  inherited;
  OnGetValue := MyGetValue;
  OnSetValue := MySetValue;
end;

class function TCustomDocFmVkVariableBinding.GetDefaultTypeOfControl: TWinControlClass;
begin
  Result := TDocMEditBox;
end;

function TCustomDocFmVkVariableBinding.GetMeditBox: TDocMEditBox;
var oControl: TWinControl;
begin
  oControl := GetControl;
  if Assigned(oControl) then
    Result := TDocMEditBox(oControl)
  else
    raise Exception.Create('Control not difined');
end;

function TCustomDocFmVkVariableBinding.MyGetValue(Sender: TObject): Variant;
begin
  Result := GetMEditBox.GetValue;
end;

procedure TCustomDocFmVkVariableBinding.MySetValue(Sender: TObject; const Value: Variant);
begin
  GetMEditBox.SetValue(Value);
end;

{ TDocMEditBox }

constructor TDocMEditBox.Create(AOwner: TComponent);
begin
  inherited;
  FValues := TVkVariableCollection.Create(self);
  OnButtonClick := InternalOnClick;
end;

function TDocMEditBox.GetValue: Variant;
begin
  if FValues.Count=1 then
    Result := FValues.Items[0].Value
  else
    Result := Format('Selected %d',[FValues.Count]);
end;

procedure TDocMEditBox.InitBeforeSelect;
begin
  FFmDoc.FrameDoc.Selected.Clear;
  if Assigned(FOnInitbeforeSelect) then
    FOnInitbeforeSelect(Self);
end;

procedure TDocMEditBox.InternalOnClick(Sender: TObject);
begin
  Select;
end;

function TDocMEditBox.IsPrepared: Boolean;
begin
  Result := Assigned(FFmDoc);
end;

procedure TDocMEditBox.Prepare(const AFrameDocClassName: String);
var _FrameClass: TDocFrameClass;
begin
  if IsPrepared and (AFrameDocClassName<>FFrameClassName) then
  begin
      FreeAndNil(FFmDoc);
  end;

  if not IsPrepared then
  begin
    FFrameClassName := AFrameDocClassName;
    _FrameClass := TDocFrameClass(FindClass(AFrameDocClassName));
    FFmDoc := TCustomDocFm.Create(Application,_FrameClass);
    Text :=  FFmDoc.FrameDoc.GetSelectedCaption(FValues);
  end;
end;

function TDocMEditBox.Select: Boolean;
var i: Integer;
begin
  if not IsPrepared then
    Prepare(FFrameClassName);
  FFmDoc.IsSelect := True;
  InitBeforeSelect;
  FFmDoc.Width := Screen.Width div 2;
  FFmDoc.Height := Application.MainForm.Height;
  FFmDoc.Top := 0;
  FFmDoc.FrameDoc.Locate(FValues);
  Result := FFmDoc.ShowModal = mrOk;
  if Result then
  begin
    FValues.Clear;
    for I := 0 to FFmDoc.FrameDoc.CurrentFrame.Selected.Count-1 do
      FValues.CreateVkVariable(FFmDoc.FrameDoc.CurrentFrame.Selected.Items[i].Name,
        FFmDoc.FrameDoc.CurrentFrame.Selected.Items[i].Value);
    Text :=  FFmDoc.FrameDoc.GetSelectedCaption(FValues);
  end;
end;

procedure TDocMEditBox.SetOnInitBeforeSelect(const Value: TNotifyEvent);
begin
  FOnInitBeforeSelect := Value;
end;

procedure TDocMEditBox.SetValue(AValue: variant);
var v: TVkvariable;
begin
  FValues.Clear;
  v := FValues.CreateVkVariable('_internal', AValue);
  if IsPrepared and Assigned(FFmDoc.FrameDoc) then
    Text :=  FFmDoc.FrameDoc.GetSelectedCaption(FValues);
end;

{ TDocMEditBoxBindingDescription }

class function TDocMEditBoxBindingDescription.GetDocMEditBoxBindingDescription(
  const ADocMEditBoxClass: String; AOnInitBeforeSelect: TNotifyEvent): TDocMEditBoxBindingDescription;
begin
  Result := Self.Create;
  Result.TypeClassItemBinding := TDocFmVkVariableBinding;
  Result.OnInitBeforeSelect := AOnInitBeforeSelect;
  Result.DocMEditBoxClass := ADocMEditBoxClass;
end;

procedure TDocMEditBoxBindingDescription.SetDocMEditBoxClass(const Value: String);
begin
  FDocMEditBoxClass := Value;
end;

procedure TDocMEditBoxBindingDescription.SetOnInitBeforeSelect(const Value: TNotifyEvent);
begin
  FOnInitBeforeSelect := Value;
end;

end.
