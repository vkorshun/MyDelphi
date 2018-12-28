unit fmhopedialogform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, fmhopeform, StdCtrls, ExtCtrls;

type
  THopeDialogFormFm = class(THopeFormFm)
    pnBottom: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HopeDialogFormFm: THopeDialogFormFm;

implementation

{$R *.dfm}

end.
