unit menustructure;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CategoryButtons, ToolWin, ActnMan, ActnCtrls, PlatformDefaultStyleActnCtrls, ActnList, ComCtrls,
  ActnMenus, ImgList, Generics.Collections;

type

  TMenuStructureItem = class (TObject)
  private
    FAction: TAction;
    FCaption: String;
    FList: TObjectList<TMenuStructureItem>;
  public
    constructor Create(const ACaption:String; AAction: TAction = nil);
    destructor Destroy;override;
    procedure Add(const ACaption:String; AAction: TAction = nil);
    property Items: TObjectList<TMenuStructureItem> read FList;
    procedure DefaultExecuteAction(Sender:TObject);
  end;

  TMenuStructure = class (TObject)
  private
    FRoot: TMenuStructureItem;
  public
    constructor Create;
    destructor Destroy;override;
    property Root: TMenuStructureItem read FRoot;
    procedure Add(const ACaption:String; AAction: TAction = nil);
    procedure FillActionMenu(AAM:tActionManager; AMenuBar: TActionMainMenuBar);
  end;

implementation

{ TMenuStructureItem }

procedure TMenuStructureItem.Add(const ACaption: String; AAction: TAction);
var _msi: TMenuStructureItem;
begin
  _msi := TMenuStructureItem.Create(Acaption, AAction);
  FList.Add(_msi);
end;

constructor TMenuStructureItem.Create(const ACaption:String; AAction: TAction);
begin
  FAction := AAction;
  FCaption := ACaption;
  FList := TObjectList<TMenuStructureItem>.Create;
  FList.OwnsObjects := True;
end;

procedure TMenuStructureItem.DefaultExecuteAction(Sender: TObject);
begin

end;

destructor TMenuStructureItem.Destroy;
begin
  FreeAndNil(FAction);
  inherited;
end;


{ TMenuStructure }

procedure TMenuStructure.Add(const ACaption: String; AAction: TAction);
begin
  FRoot.Add(ACaption, AAction);
end;

constructor TMenuStructure.Create;
begin
  FRoot := TMenuStructureItem.Create('ROOT',nil);
end;

destructor TMenuStructure.Destroy;
begin
  FreeAndNil(FRoot);
  inherited;
end;

procedure TMenuStructure.FillActionMenu(AAM:TActionManager; AMenuBar: TActionMainMenuBar);
var i: Integer;
var
  _ABI: TActionBarItem;
  _CA: TAction;
  _ACIMain, SomeMenu: TActionClientItem;

    procedure FillAction(AItem: TMenuStructureItem; pmi:TActionClientItem);
    var i: Integer;
    begin

      if not Assigned(pmi) then
      begin
        _ACIMain := _ABI.Items.Add;
        if Assigned(AItem.FAction) then
          _ACIMain.Action := AItem.FAction
        else
        begin
          _ACIMain.Caption := AItem.FCaption;
          _CA := TAction.Create(AAM);
          _CA.Caption := AItem.FCaption;
          _CA.OnExecute := AItem.DefaultExecuteAction;
          _ACIMain.Action := _CA
        end;

        for I := 0 to AItem.Items.Count - 1 do
          FillAction(AItem.Items[i], _ABI.Items[_ABI.Items.Count-1]);
      end
      else
      begin
        if AItem.FCaption='-' then
          SomeMenu := AAM.AddSeparator(SomeMenu)
        else
        begin
          SomeMenu := pmi.Items.Add;
          if Assigned(AItem.FAction) then
            SomeMenu.Action := AItem.FAction
          else
          begin
            SomeMenu.Caption := AItem.FCaption;
            _CA := TAction.Create(AAM);
            _CA.Caption := AItem.FCaption;
            SomeMenu.Action := _CA
          end;
        end;

        for I := 0 to AItem.Items.Count - 1 do
             FillAction(AItem.Items[i], SomeMenu);
      end;

    end;

begin

   _ABI := AAm.ActionBars.Add;
   _ABI.ActionBar := AMenuBar;

   for i := 0 to FRoot.Items.Count-1 do
   begin
      FillAction(FRoot.Items[i], nil);
   end;

end;

end.
