unit rtc.fmCustomDoc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  rtc.framedoc, DmMainRtc, rtc.dmdoc, ActnMan,
  vkvariable, vkvariablebindingdialog, Vcl.StdCtrls, Vcl.ExtCtrls, System.Actions, Vcl.ActnList,
  fmhopeform;

type
  IDocSelectInterface = interface
    ['{09E06EED-6697-4907-9096-DEEFE6903866}']
    procedure InitBeforeSelect();
  end;

  TCustomDocFm = class(THopeFormFm)
    pnBottom: TPanel;
    btnOk: TButton;
    BtnCansel: TButton;
    ActionList1: TActionList;
    aOk: TAction;
    aCancel: TAction;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure pnBottomResize(Sender: TObject);
    procedure aOkExecute(Sender: TObject);
    procedure aCancelExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FFrameDoc: TDocFrame;
    FFrameDocClass : TDocFrameClass;
    FDmMain: TMainRtcDm;
    DmDoc: TDocDm;
    FInitSelectValue: TVkVariableCollection;
    procedure SetIsSelect(const Value: Boolean);
    function GetCurrentFrame: TDocFrame;
    procedure SetCurrentFrame(const Value: TDocFrame);
  protected
    FIsSelect: Boolean;
    FCurrentFrame: TDocFrame;
    FPrepare: Boolean;
    procedure CreateFrameDoc;virtual;
  public
    { Public declarations }
    function GetActionManager(const Aname: String): TActionManager;
    constructor Create(AOwner: TComponent;  AFrameDocClass: TDocFrameClass; bPrepare: Boolean = False); reintroduce;
    class function FindFormOnFrameClass(AFrameClass: TDocFrameClass):TCustomDocFm;
    class function FindFormOnFrame(AFrame: TDocFrame):TCustomDocFm;
//    class procedure ViewDoc(const AFrameClassName: String; AIdObject: TObject = nil);
//    function Select(AFmDoc:TCustomDocFm;const AFrameClassName: String):Boolean;
    property FrameDocClass: TDocFrameClass read FFrameDocClass;
    property IsSelect: Boolean read FIsSelect write SetIsSelect;
    property InitSelectValue: TVkVariableCollection read FInitSelectValue ;
    property FrameDoc: TDocFrame read FFrameDoc;
    property CurrentFrame: TDocFrame read GetCurrentFrame write SetCurrentFrame;
  end;

var
  CustomDocFm: TCustomDocFm;

implementation

//uses AppManager;


{$R *.dfm}

{ TFmCustomUibDoc }
var glId: Integer;

procedure TCustomDocFm.aCancelExecute(Sender: TObject);
begin
  inherited;
  ModalResult := mrCancel;
end;

procedure TCustomDocFm.aOkExecute(Sender: TObject);
begin
  inherited;
  if Assigned(CurrentFrame) then
    CurrentFrame.DoOk
  else
    FFrameDoc.DoOk;
end;

constructor TCustomDocFm.Create(AOwner: TComponent; AFrameDocClass: TDocFrameClass; bPrepare: Boolean);
begin
  FPrepare := bPrepare;
  try
    Inc(glId);
    inherited Create(AOwner);
    if name='' then
      name := 'FmCustomUibDoc' + IntToStr(glId)
    else
      name := name + IntToStr(glId);
    FDmMain := MainRtcDm;
    FFrameDocClass := AFrameDocClass;
    CreateFrameDoc;
    ActiveControl := FFrameDoc.DBGridEhVkDoc;
  finally
    FPrepare := False;
  end;
end;

procedure TCustomDocFm.CreateFrameDoc;
var _dmDoc: TDocDm;
begin
  _dmDoc :=  FFrameDocClass.GetDmDoc; //.Create(FDmMain);
  FFrameDoc := FFrameDocClass.Create(self,_dmDoc);
  FFrameDoc.Name := FFrameDoc.Name+'_'+IntToStr(GetTickCount);
  FFrameDoc.Parent := self;
  FFrameDoc.Align := alClient;
  FFrameDoc.ParentForm := self;
  FFrameDoc.InitActionManager(Self);
  FFrameDoc.Prepare := FPrepare;
  Caption := FFrameDoc.GetCaption;
end;

class function TCustomDocFm.FindFormOnFrame(AFrame: TDocFrame): TCustomDocFm;
var i: Integer;
begin
  Result := nil;
  for I := 0 to Application.MainForm.MDIChildCount-1 do
  if Application.MainForm.MDIChildren[i] is TCustomDocFm then
  begin
    with TCustomDocFm(Application.MainForm.MDIChildren[i]) do
    begin
      if FFrameDoc = AFrame then
      begin
         Result := TCustomDocFm(Application.MainForm.MDIChildren[i]);
         Break;
      end;
    end;
  end;

end;

class function TCustomDocFm.FindFormOnFrameClass(AFrameClass: TDocFrameClass): TCustomDocFm;
var i: Integer;
begin
  Result := nil;
  for I := 0 to Application.MainForm.MDIChildCount-1 do
  if Application.MainForm.MDIChildren[i] is TCustomDocFm then
  begin
    with TCustomDocFm(Application.MainForm.MDIChildren[i]) do
    begin
      if FrameDocClass = AFrameClass then
      begin
         Result := TCustomDocFm(Application.MainForm.MDIChildren[i]);
         Break;
      end;
    end;
  end;
end;

procedure TCustomDocFm.FormActivate(Sender: TObject);
begin
  inherited;
  if Assigned(FFrameDoc) then
  begin
    FFrameDoc.aDocRefresh.Execute;
    if Assigned(FFrameDoc.CurrentFrame) then
      FFrameDoc.CurrentFrame.DBGridEhVkDoc.SetFocus;
  end;
end;

procedure TCustomDocFm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if FormStyle = fsMDIChild then
    Action := caFree
end;

procedure TCustomDocFm.FormShow(Sender: TObject);
begin
  inherited;
  if IsSelect then
  begin
    Width := Screen.Width div 2;
    Left := Width;
    if Application.MainForm.Height> (Screen.Height div 2) then
    begin
      Height := Application.MainForm.Height;
      Top := Application.MainForm.Top;
    end
    else
    begin
      Height := Screen.Height - 20;
      Top := 0;
    end;
    if Assigned(FFrameDoc) and Assigned(FFrameDoc.CurrentFrame) then
      FFrameDoc.CurrentFrame.DBGridEhVkDoc.SetFocus
{    else
    if Assigned(FrameDoc.CurrentFrame) then
      FrameDoc.CurrentFrame.DBGridEhVkDoc.SetFocus
 }
  end;
end;

function TCustomDocFm.GetActionManager(const Aname: String): TActionManager;
var _Component: TComponent;
begin
  _Component := FindComponent(Aname);
  if Assigned(_Component) then
  begin
    if (_Component is TActionManager) then
      Result := TActionManager(_Component)
    else
      raise Exception.Create('Dublicate component name!');
  end
  else
  begin
    Result := TActionManager.Create(self);
    Result.Name := AName;
  end;
end;

function TCustomDocFm.GetCurrentFrame: TDocFrame;
begin
  Result := FCurrentFrame;
end;

procedure TCustomDocFm.pnBottomResize(Sender: TObject);
begin
  inherited;
  BtnCansel.left := pnBottom.width - BtnCansel.width - 10;
  btnOk.left := BtnCansel.left - btnOk.width - 10;
end;

procedure TCustomDocFm.SetCurrentFrame(const Value: TDocFrame);
begin
  FCurrentFrame := Value;
end;

procedure TCustomDocFm.SetIsSelect(const Value: Boolean);
begin
  FIsSelect := Value;
  pnBottom.Visible := Value;
  aOk.Visible := Value;
  aCancel.Visible := Value;

  if Assigned(FFrameDoc) then
    FFrameDoc.IsSelect := Value;
end;

{class procedure TCustomDocFm.ViewDoc(const AFrameClassName: String; AIdObject: TObject = nil);
var _FrameClass: TDocFrameClass;
    _Form: TCustomDocFm;
begin
  _FrameClass := TDocFrameClass(FindClass(AFrameClassName));
  if Assigned(_FrameClass) then
  begin
    _Form := FindFormOnFrameClass(_FrameClass);
    if Assigned(_Form) and _Form.FrameDoc.CheckIdObject(AIdObject) then
      _Form.Show
    else
    begin
      _Form := TCustomDocFm.Create(Application,_FrameClass);
      _Form.FrameDoc.CheckIdObject(AIdObject);
      _Form.FormStyle := fsMDIChild;
      TApplicationManager.SetMDIPosition(_Form);
    end;
  end;

end;}

initialization
  glId := 0;
end.
