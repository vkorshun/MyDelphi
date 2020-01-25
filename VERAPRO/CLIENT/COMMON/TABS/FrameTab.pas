unit FrameTab;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VkVariable,ActionManagerDescription, ActnMan, Vcl.ToolWin, Vcl.ActnCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Menus, Vcl.ImgList;

type
//  TTabFrame = class;
  TTabFrameClass = class of TTabFrame;
  TTabFrame = class(TFrame)
    ActionToolBar1: TActionToolBar;
    StatusBar1: TStatusBar;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
  private
    { Private declarations }
    FCurrentParams: TVkVariableCollection;
    FOnCreate: TNotifyEvent;
    FParentForm: TForm;
    FOnInitActionManager: TNotifyEvent;
    FActionDescription: TActionListDescriptionList;
  protected
    procedure DefaultActionListInit;virtual;abstract;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AParams: TVkVariableCollection);
    destructor destroy;override;
    function CheckParams(AParams: TVkVariableCollection): Boolean;
    function IsEqualParams(AParams: TVkVariableCollection): Boolean;
    procedure InitActionManager(AForm: TForm);
    function GetActiveControl: TWinControl; virtual; abstract;
    function GetCaption:String;virtual; abstract;
//    property OnCreate: TNotifyEvent read FOnCreate write FOnCreate;
    property ParentForm:TForm read FParentForm write FParentForm;
    property OnInitActionManager: TNotifyEvent read FOnInitActionManager write FOnInitActionManager;
    property  ActionDescription: TActionListDescriptionList read FActionDescription;
  end;

implementation

{$R *.dfm}

constructor TTabFrame.Create(AOwner: TComponent; AParams: TVkVariableCollection);
begin
  inherited create(AOwner);
  //Parent := TWinControl(AOwner);
  Align := alClient;
  FActionDescription := TActionListDescriptionList.Create;
//  if Assigned(FOnCreate) then
//    FOnCreate(self);
end;


destructor TTabFrame.destroy;
begin
  FActionDescription.Free;
  inherited;
end;

procedure TTabFrame.InitActionManager(AForm: TForm);
var
  ab: TActionBarItem;
  Am: TActionManager;
begin
  if not Assigned(FParentForm) then
    FParentForm := aForm;
  Am := TActionManager.Create(aForm);
  ab := Am.ActionBars.Add;
  ab.ActionBar := ActionToolBar1;
  ab.AutoSize := false;

  Am.Images := ImageList1;
  ActionToolBar1.ActionManager := Am;

  if Assigned(FOnInitActionManager) then
    FOnInitActionManager(self)
  else
    DefaultActionListInit;
  FActionDescription.InitActionManager(Am, PopUpMenu1, nil);

end;

function TTabFrame.IsEqualParams(AParams: TVkVariableCollection): Boolean;
var v: TVkVariable;
    i: Integer;
begin
   Result := True;
   if (Assigned(FCurrentParams) and Assigned(AParams)) then
   begin
     if FCurrentParams.Count <> AParams.count then
     begin
       Result := False;
     end
     else
     begin
       for I := 0 to AParams.Count-1 do
       begin
         v := FCurrentParams.FindVkVariable(AParams.Items[i].Name);
         if not Assigned(v) or (v.Value <> AParams.Items[i].Value) then
         begin
           Result := False;
           exit;
         end;
       end;
     end;
   end
   else
     Result := (not Assigned(FCurrentParams) and not Assigned(AParams))

end;

function TTabFrame.CheckParams(AParams: TVkVariableCollection): Boolean;
begin
  FCurrentParams := AParams;
  Result := true;
end;

end.
