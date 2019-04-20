unit tabManagerPanel;

interface
uses classes, Vcl.Controls,Vcl.ExtCtrls, Forms, System.SysUtils, Windows, vkvariable,
AtTabs, Winapi.Messages, System.Math, FrameTab;

type
//  TFrameClass = class of TFrame;
  TTabManagerPanel = class(TPanel)
  private
    FFrameTabs: TATTabs;
    bInit: Boolean;
    function CreateFrameDoc(AFrameDocClass: TTabFrameClass): TTabFrame;
    procedure MyOnTabMove(Sender: TObject; NFrom, NTo: Integer);
    procedure MyOnTabClose(Sender: TObject; ATabIndex: Integer; var ACanClose, ACanContinue: Boolean);
    procedure MyOnTabClick(Sender: TObject);
    procedure SetVisible(AFrame: TTabFrame);
  public
    constructor create(aOwner: TComponent);override;
    procedure ShowTab(const AFrameDocClassName: String; AParams:TVkVariableCollection = nil);
//    procedure ShowDocument(AFrameDocClass: TDocFrameClass);
  end;

implementation

{ TDocManagerPanel }
var glId: Integer = 0;

constructor TTabManagerPanel.create(aOwner: TComponent);
begin
  inherited create(aOwner);
  Caption := '';
  Align := alClient;
  FFrameTabs := TAtTabs(aOwner.FindComponent('MainTabs'));
  if not Assigned(FFrameTabs) then
  begin
    FFrameTabs := TATTabs.Create(AOwner);
    FFrameTabs.parent := TWinControl(AOwner);
    FFrameTabs.Align := alTop;

  end;
  FFrameTabs.OnTabMove := MyOnTabMove;
  FFrameTabs.OnTabClose := MyOnTabClose;
  FFrameTabs.OnTabClick := MyOnTabClick;
end;

procedure TTabManagerPanel.MyOnTabClick(Sender: TObject);
var frm1: TTabFrame;
    i: Integer;
begin
  if not bInit then
  begin
    frm1 := TTabFrame(FFrameTabs.GetTabData(FFrameTabs.TabIndex).TabObject);
    if Assigned(frm1) then
      if not frm1.Visible then
        SetVisible(frm1);
  end;
end;



procedure TTabManagerPanel.ShowTab(const AFrameDocClassName: String; AParams:TVkVariableCollection);
var _FrameDocClass : TTabFrameClass;
    docFrame : TTabFrame;
    i: Integer;
    control: TWinControl;
begin
   _FrameDocClass := TTabFrameClass(FindClass(AFrameDocClassName));
   for I := 0 to FFrameTabs.Tabs.Count-1 do
   begin
      docFrame := TTabFrame(FFrameTabs.GetTabData(i).TabObject);
      if Assigned(docFrame) then
      begin
        if (docFrame.ClassType = _FrameDocClass) and (docFrame.IsEqualParams(AParams)) then
        begin
          SetVisible(docFrame);
          exit;
        end;
      end;
   end;

   docFrame := CreateFrameDoc(_FrameDocClass);
   docFrame.CheckParams(AParams);
   control := docFrame.getActiveControl;
   FFrameTabs.AddTab(FFrameTabs.TabCount,docFrame.GetCaption, docFrame);
   if (Assigned(control) and  control.visible and control.Enabled) then
   try
     // PostMessage(WM_SETFOCUS,control.Handle,0,0);
     TForm(Owner).ActiveControl := control;
   except

   end;
//   if (Assigned(AParams)) then
//     docFrame.checkParams(AParams);
end;


{*procedure TDocManagerPanel.ShowDocument(AFrameDocClass: TDocFrameClass);
begin
//  FPrepare := bPrepare;
  try
    Inc(glId);
    //inherited Create(AOwner);
    //if name='' then
    //  name := 'FmCustomUibDoc' + IntToStr(glId)
    //else
    //  name := name + IntToStr(glId);
    //FDmMain := MainDm;
    //FFrameDocClass := AFrameDocClass;
    var docFrame := CreateFrameDoc(AFrameDocClass);
    TForm(Owner).ActiveControl := docFrame.DBGridEhVkDoc;
    doc
  finally
//    FPrepare := False;
  end;
end;}

  function TTabManagerPanel.CreateFrameDoc(AFrameDocClass: TTabFrameClass): TTabFrame;
//  var _dmDoc: TDocDm;
  begin
//    _dmDoc :=  AFrameDocClass.GetDmDoc; //.Create(FDmMain);
    Result := AFrameDocClass.Create(self);
    Result.Name := Result.Name+'_'+IntToStr(GetTickCount);
    Result.Parent := self;
    Result.Align := alClient;
    Result.ParentForm := TForm(self.Owner);
    Result.InitActionManager(Result.ParentForm);
    //FFrameDoc.Prepare := FPrepare;
    //Caption := FFrameDoc.GetCaption;
  end;



procedure TTabManagerPanel.MyOnTabMove(Sender: TObject; NFrom, NTo: Integer);
var _DocFrame: TTabFrame;
begin
  if (NTo>-1) and not bInit then
  begin
    _DocFrame := TTabFrame(FFrameTabs.GetTabData(NTo).TabObject);
    SetVisible(_DocFrame);
  end;

end;

procedure TTabManagerPanel.SetVisible(AFrame: TTabFrame);
var frm: TTabFrame;
    i: Integer;
begin
  for I := 0 to FFrameTabs.TabCount-1 do
  begin
    frm := TTabFrame(FFrameTabs.GetTabData(i).TabObject);
    if Assigned(frm) then
    begin
      frm.Visible := frm = AFrame;
      if frm.Visible then
      begin
        //StatusBar1.Panels[0].Text := frm.GetFileName;
  //---      frm.SynEdit1.CaretX :=1;
  //      frm.SynEdit1.CaretY :=1;
       // TForm(Owner).ActiveControl := frm.GetActiveControl;
        if FFrameTabs.TabIndex <> i then
          FFrameTabs.TabIndex := i;
        PostMessage(WM_SETFOCUS,frm.GetActiveControl.Handle,0,0);
      end;
    end;

  end;
end;

procedure TTabManagerPanel.MyOnTabClose(Sender: TObject; ATabIndex: Integer;
  var ACanClose, ACanContinue: Boolean);
var frm: TTabFrame;
    NewIndex: Integer;
begin
  frm := TTabFrame(FFrameTabs.GetTabData(ATabIndex).TabObject);
  if Assigned(frm) then
  begin
    frm.Visible := False;
    frm.Free;
    if FFrameTabs.TabCount>1 then
    begin
      NewIndex := ifThen(ATabIndex > 0, ATabIndex-1,1);
      frm := TTabFrame(FFrameTabs.GetTabData(NewIndex).TabObject);
    end;
  end;

end;


end.
