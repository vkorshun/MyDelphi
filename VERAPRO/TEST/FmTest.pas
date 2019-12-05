unit FmTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, fbdatabase, IB, Vcl.StdCtrls, fbresultset;

type
  TForm5 = class(TForm)
    Memo1: TMemo;
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

procedure TForm5.FormCreate(Sender: TObject);
var dbParams: TFBdatabaseParams;
    rs: IResultSet;
    rb: RawByteString;
    stm: IStatement;
  I: Integer;
begin
   dbParams := TFBdatabaseParams.Create;
   dbParams.DbName := 'inet://localhost:3050/d:\FBDATA\DATA_FB4\lidaprovo.fdb';
   dbParams.UserName := 'sysdba';
   dbParams.Password := 'masterkey';
   dbParams.LibPath := 'C:\FIREBIRD-4-32\fbclient.dll';
   FDatabase := TFBDatabase.Create(self, dbParams);
   try
     FDatabase.connect;
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
       rs := TFBResultSet.Create(FDatabase,FDatabase.Attachment.OpenCursor(FDatabase.startReadTransaction,'SELECT * FROM test1 ORDER BY name COLLATE UNICODE_CI'));
       stm := FDatabase.Attachment.PrepareWithNamedParameters(FDatabase.startReadTransaction,'SELECT sum1, sum2 FROM test1 WHERE id=:id');
       stm.SQLParams.ByName('ID').AsInt64 := 1;
       rs := stm.OpenCursor();
       while rs.FetchNext do
       begin
         for I := 0 to rs.Count-1 do
           memo1.Lines.add(rs.Data[i].Name + ' | '+ rs.Data[i].GetSQLTypeName+' | '+ rs.Data[i].getRelationName +' | '+ rs.Data[i].getOwnerName);
         rb := rs.ByName('sum1').value;
         ShowMessage(rb);
         rb := rs.ByName('sum2').value;
         ShowMessage(rb);
//         memo1.Lines.add(rs.ByName('id').AsString+ ' | '+ UTF8String(rb)+' | '+rs.ByName('name').AsVariant);
       end;
     end;
   finally
     FDatabase.disconnect;
   end;
end;

end.
