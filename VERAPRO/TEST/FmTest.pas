unit FmTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, fbdatabase, IB, Vcl.StdCtrls, fbresultset, FIBDatabase, pFIBDatabase, FIBQuery, pFIBQuery,
  pFIBQueryVk, pFIBDatabaseVk, Data.DB, FIBDataSet, pFIBDataSet, pFIBDataSetVk, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, DataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, DBGridEhVk, uibdataset;

type
  TForm5 = class(TForm)
    pFIBDataSetVk1: TpFIBDataSetVk;
    pFIBDatabaseVk1: TpFIBDatabaseVk;
    pFIBQueryVk1: TpFIBQueryVk;
    pFIBTransaction1: TpFIBTransaction;
    DBGridEhVk1: TDBGridEhVk;
    MemTableEh1: TMemTableEh;
    SQLConnectionProviderEh1: TSQLConnectionProviderEh;
    SQLDataDriverEh1: TSQLDataDriverEh;
    UIBDataSet1: TUIBDataSet;
    DataSource1: TDataSource;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FDatabase: TFbDatabase;
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}
uses DmFibApi;

procedure TForm5.FormCreate(Sender: TObject);
var dbParams: TFBdatabaseParams;
    rs: IResultSet;
    rb: RawByteString;
    stm: IStatement;
  I: Integer;
begin
   Exit;

   dbParams := TFBdatabaseParams.Create(self);
   dbParams.DbName := 'inet://localhost:3050/d:\FBDATA\VERA_PRO\ledapravo.fdb';
   dbParams.UserName := 'sysdba';
   dbParams.Password := 'masterkey';
   dbParams.LibPath := 'C:\FIREBIRD-4-32\fbclient.dll';
   FDatabase := TFBDatabase.Create(self, dbParams);
   FDatabase.connect;
   try
     if FDatabase.IsConnected then
     begin
       {*stm := FDatabase.Attachment.PrepareWithNamedParameters(FDatabase.startConcurencyTransaction,' INSERT INTO test1 VALUES(:id,:name)', FDatabase.params.SqlDialect);
       try
         stm.SQLParams.ByName('id').AsInteger := 6;
         stm.SQLParams.ByName('name').AsString := 'алад';
         stm.Execute();
         stm.GetTransaction.Commit();
       except on  ex: Exception do
         begin
           ShowMessage(ex.Message);
           stm.GetTransaction.Rollback();
         end;
       end; *}
       rs := TFBResultSet.Create(FDatabase,FDatabase.Attachment.OpenCursor(FDatabase.startReadTransaction,'SELECT * FROM objects ORDER BY name COLLATE UNICODE_CI'));
//       stm := FDatabase.Attachment.PrepareWithNamedParameters(FDatabase.startReadTransaction,'SELECT * FROM objects WHERE id=:id');
//       stm.SQLParams.ByName('ID').AsInt64 := 1;
 //      rs := stm.OpenCursor();
       while rs.FetchNext do
       begin
         for I := 0 to rs.Count-1 do
           //memo1.Lines.add(rs.Data[i].Name + ' | '+ rs.Data[i].GetSQLTypeName+' | '+ rs.Data[i].getRelationName +' | '+ rs.Data[i].getOwnerName);
//         rb := rs.ByName('sum1').value;
//         ShowMessage(rb);
//         rb := rs.ByName('sum2').value;
//         ShowMessage(rb);
//         memo1.Lines.add(rs.ByName('id').AsString+ ' | '+ UTF8String(rb)+' | '+rs.ByName('name').AsVariant);
       end;
     end;
   finally
     FDatabase.disconnect;
   end;
end;

end.
