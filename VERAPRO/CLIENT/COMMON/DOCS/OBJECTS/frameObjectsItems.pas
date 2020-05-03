unit frameObjectsItems;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, rtc.framedoc, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls,
  DynVarsEh, System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.ImgList, Data.DB, GridsEh, DBAxisGridsEh, DBGridEh,
  DBGridEhVk, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, rtc.dmdoc,dmobjects,
  vkvariable, VariantUtils, EhLibVCL;

type
  TObjectsItemsFrame = class(TDocFrame)
  private
    { Private declarations }
    FObjectsDm: TObjectsDm;
    FIdGroup: LargeInt;
    procedure SetIdGroup(const Value: LargeInt);
    procedure DoInitActionManager(Sender:TObject);
  protected
    function getSetUpKeyName():String; override;
  public
    { Public declarations }
    constructor Create(AOwner:TComponent; ADmDoc:TDocDm); override;
    class function GetDmDoc:TDocDm;override;
    property IdGroup: LargeInt read FIdGroup write SetIdGroup;
    class function GetObjectsItemsFrame(AOwner: TComponent): TObjectsItemsFrame;
    class function GetSelectedCaption(AVar: TVkVariableCollection):String;override;
  end;

var
  ObjectsItemsFrame: TObjectsItemsFrame;

implementation

{$R *.dfm}

uses dmmainrtc;

{ TObjectsItemsFrame }

constructor TObjectsItemsFrame.Create(AOwner: TComponent; ADmDoc: TDocDm);
begin
  inherited;
  FObjectsDm := TObjectsDm(ADmDoc);
  FObjectsDm.ObjectsTypeDm := tdmoObjects;
  OnInitActionManager := DoInitActionManager;
end;

procedure TObjectsItemsFrame.DoInitActionManager(Sender: TObject);
begin
  DefaultActionListInit;
end;

class function TObjectsItemsFrame.GetDmDoc: TDocDm;
begin
  Result := TObjectsDm.GetDm;
end;


class function TObjectsItemsFrame.GetObjectsItemsFrame(AOwner: TComponent): TObjectsItemsFrame;
begin
  Result := Self.Create(AOwner,TObjectsDm.GetDm);
  Result.InitActionManager(Result.getparentForm);
end;

class function TObjectsItemsFrame.GetSelectedCaption(AVar: TVkVariableCollection): String;
begin
  if Avar.Count>1 then
    inherited
  else
  begin
    if Avar.Count=1 then
      Result := IfVarEmpty(MainRtcDm.QueryValue(
        'SELECT name FROM objects WHERE idobject=:idobject',[Avar.Items[0].AsLargeInt]),'')
    else
      Result := 'not defined';
  end;
end;

function TObjectsItemsFrame.getSetUpKeyName: String;
begin
  Result := inherited;
  Result := Result+IntToStr(FIdGroup);
end;

procedure TObjectsItemsFrame.SetIdGroup(const Value: LargeInt);
begin
  if FIdGroup <> Value then
  begin
    FFmSetUp.SaveChanges;
    FIdGroup := Value;
    FObjectsDm.RootIdGroup := FIdGroup;
    FmEdit.BindingList.Clear;
    ConfigureEdit;
  end;

//  FObjectsDm.
end;

end.
