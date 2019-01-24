unit docManagerPanel;

interface
uses classes, Vcl.Controls,Vcl.ExtCtrls, fdac.framedoc, Forms, fDAC.dmDoc, System.SysUtils, Windows, vkvariable,
AtTabs, Winapi.Messages, System.Math;

type
  TDocManagerPanel = class(TPanel)
  private
    FDocFrameTabs: TATTabs;
    bInit: Boolean;
    function CreateFrameDoc(AFrameDocClass: TDocFrameClass): TDocFrame;
    procedure MyOnTabMove(Sender: TObject; NFrom, NTo: Integer);
    procedure MyOnTabClose(Sender: TObject; ATabIndex: Integer; var ACanClose, ACanContinue: Boolean);
    procedure MyOnTabClick(Sender: TObject);
    procedure SetVisible(ADocFrame: TDocFrame);
  public
    constructor create(aOwner: TComponent);override;
    procedure ShowDocument(const AFrameDocClassName: String; AParams:TVkVariableCollection = nil);
//    procedure ShowDocument(AFrameDocClass: TDocFrameClass);
  end;

implementation

{ TDocManagerPanel }
var glId: Integer = 0;

constructor TDocManagerPanel.create(aOwner: TComponent);
begin
  inherited create(aOwner);
  Caption := '';
  Align := alClient;
  FDocFrameTabs := TAtTabs(aOwner.FindComponent('MainTabs'));
  if not Assigned(FDocFrameTabs) then
  begin
    FDocFrameTabs := TATTabs.Create(AOwner);
    FDocFrameTabs.parent := TWinControl(AOwner);
    FDocFrameTabs.Align := alTop;

  end;
  FDocFrameTabs.OnTabMove := MyOnTabMove;
  FDocFrameTabs.OnTabClose := MyOnTabClose;
  FDocFrameTabs.OnTabClick := MyOnTabClick;
end;

procedure TDocManagerPanel.MyOnTabClick(Sender: TObject);
var frm1: TDocFrame;
    i: Integer;
begin
  if not bInit then
  begin
    frm1 := TDocFrame(FDocFrameTabs.GetTabData(FDocFrameTabs.TabIndex).TabObject);
    if Assigned(frm1) then
      if not frm1.Visible then
        SetVisible(frm1);
  end;
end;



procedure TDocManagerPanel.ShowDocument(const AFrameDocClassName: String; AParams:TVkVariableCollection);
var _FrameDocClass : TDocFrameClass;
    docFrame : TDocFrame;
    i: Integer;
    control: TWinControl;
begin
   _FrameDocClass := TDocFrameClass(FindClass(AFrameDocClassName));
   for I := 0 to FDocFrameTabs.Tabs.Count-1 do
   begin
      docFrame := TDocFrame(FDocFrameTabs.GetTabData(i).TabObject);
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
   FDocFrameTabs.AddTab(FDocFrameTabs.TabCount,docFrame.GetCaption, docFrame);
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

  function TDocManagerPanel.CreateFrameDoc(AFrameDocClass: TDocFrameClass): TDocFrame;
  var _dmDoc: TDocDm;
  begin
    _dmDoc :=  AFrameDocClass.GetDmDoc; //.Create(FDmMain);
    Result := AFrameDocClass.Create(self,_dmDoc);
    Result.Name := Result.Name+'_'+IntToStr(GetTickCount);
    Result.Parent := self;
    Result.Align := alClient;
    Result.ParentForm := TForm(self.Owner);
    Result.InitActionManager(Result.ParentForm);
    //FFrameDoc.Prepare := FPrepare;
    //Caption := FFrameDoc.GetCaption;
  end;



procedure TDocManagerPanel.MyOnTabMove(Sender: TObject; NFrom, NTo: Integer);
var _DocFrame: TDocFrame;
begin
  if (NTo>-1) and not bInit then
  begin
    _DocFrame := TDocFrame(FDocFrameTabs.GetTabData(NTo).TabObject);
    SetVisible(_DocFrame);
  end;

end;

procedure TDocManagerPanel.SetVisible(ADocFrame: TDocFrame);
var frm: TDocFrame;
    i: Integer;
begin
  for I := 0 to FDocFrameTabs.TabCount-1 do
  begin
    frm := TDocFrame(FDocFrameTabs.GetTabData(i).TabObject);
    if Assigned(frm) then
    begin
      frm.Visible := frm = ADocFrame;
      if frm.Visible then
      begin
        //StatusBar1.Panels[0].Text := frm.GetFileName;
  //---      frm.SynEdit1.CaretX :=1;
  //      frm.SynEdit1.CaretY :=1;
       // TForm(Owner).ActiveControl := frm.GetActiveControl;
        if FDocFrameTabs.TabIndex <> i then
          FDocFrameTabs.TabIndex := i;
        PostMessage(WM_SETFOCUS,frm.GetActiveControl.Handle,0,0);
      end;
    end;

  end;
end;

procedure TDocManagerPanel.MyOnTabClose(Sender: TObject; ATabIndex: Integer;
  var ACanClose, ACanContinue: Boolean);
var frm: TDocFrame;
    NewIndex: Integer;
begin
  frm := TDocFrame(FDocFrameTabs.GetTabData(ATabIndex).TabObject);
  if Assigned(frm) then
  begin
    frm.Visible := False;
    frm.Free;
    if FDocFrameTabs.TabCount>1 then
    begin
      NewIndex := ifThen(ATabIndex > 0, ATabIndex-1,1);
      frm := TDocFrame(FDocFrameTabs.GetTabData(NewIndex).TabObject);
    end;
  end;

end;


end.
