unit DmTestDoc;

interface

uses
  System.SysUtils, System.Classes, rtc.dmDoc, MemTableDataEh, Data.DB, DataDriverEh, MemTableEh, uDocDescription,
   vkvariablebindingdialog;

type
  TTestDocDm = class(TDocDm)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestDocDm: TTestDocDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TTestDocDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  InitClientSqlManager('TESTDOC');

  DocStruDescriptionList.Add('iddoc','','IDDOC','IDDOC',4,'',4,False,True,nil);
  DocStruDescriptionList.Add('name','','Наименование','Наименование',60,'',60,True,False,
  TBindingDescription.GetBindingDescription(TEditVkVariableBinding));
  DocStruDescriptionList.Add('AMOUNT','','Сумма','Сумма',60,'',60,True,False,
  TBindingDescription.GetBindingDescription(TDbNumberEditEhVkVariableBinding));
  DocStruDescriptionList.Add('COMMENTARY','','Комментарий','Комментарий',60,'',60,True,False,
  TBindingDescription.GetBindingDescription(TEditVkVariableBinding));

end;

end.
