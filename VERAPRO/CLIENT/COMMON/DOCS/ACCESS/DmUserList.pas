unit DmUserList;

interface

uses
  System.SysUtils, System.Classes, rtc.dmDoc, MemTableDataEh, Data.DB, rtcInfo,
  rtcConn, rtcDataCli, rtcCliModule, MemTableEh;

type
  TUserListDm = class(TDocDm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UserListDm: TUserListDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
