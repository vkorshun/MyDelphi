unit docManagerPanel;

interface
uses classes, Vcl.Controls,Vcl.ExtCtrls, fib.framedoc, Forms, fib.dmDoc, System.SysUtils, Windows, vkvariable;

type
  TDocManagerPanel = class(TPanel)
  private
    function CreateFrameDoc(AFrameDocClass: TDocFrameClass): TDocFrame;
  public
    constructor create(aOwner: TComponent);
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
end;


procedure TDocManagerPanel.ShowDocument(const AFrameDocClassName: String; AParams:TVkVariableCollection);
var _FrameDocClass : TDocFrameClass;
    docFrame : TDocFrame;
begin
   _FrameDocClass := TDocFrameClass(FindClass(AFrameDocClassName));
   docFrame := CreateFrameDoc(_FrameDocClass);
   TForm(Owner).ActiveControl := docFrame.DBGridEhVkDoc;
   if (Assigned(AParams)) then
     docFrame.checkParams(AParams);
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



end.
