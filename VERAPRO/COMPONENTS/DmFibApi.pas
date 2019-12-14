unit DmFibApi;

interface

uses
  System.SysUtils, System.Classes, MemTableDataEh, Data.DB, MemTableEh, fbdatabase, IB;

type
  TFibApiDm = class(TDataModule)
    MemTableEh1: TMemTableEh;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FDbParams: TFBDatabaseParams;
    FDatabase: TFBDatabase;
    FResultSet: IResultSet;
    FStatement: IStatement;
  public
    { Public declarations }
    procedure testQuery(const cQuery:String);
    function GetFieldType(const Data:IColumnMetaData ):TFieldType;
  end;

var
  FibApiDm: TFibApiDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TFibApiDm.DataModuleCreate(Sender: TObject);
begin
   FDbParams := TFBdatabaseParams.Create(self);
   FDbParams.DbName := 'inet://localhost:3050/d:\FBDATA\VERA_PRO\ledapravo.fdb';
   FDbParams.UserName := 'sysdba';
   FDbParams.Password := 'masterkey';
   FDbParams.LibPath := 'C:\FIREBIRD-4-32\fbclient.dll';
   FDatabase := TFBDatabase.Create(self, FDbParams);
   FDatabase.connect;
   testQuery('SELECT * FROM objects');
end;

function TFibApiDm.GetFieldType(const Data: IColumnMetaData): TFieldType;
begin
   case Data.SQLType of
     SQL_VARYING,
     SQL_TEXT:  Result := ftString;
     SQL_DOUBLE,
     SQL_FLOAT,
     SQL_D_FLOAT: Result := ftFloat;
     SQL_LONG: result := ftInteger;
     SQL_SHORT: Result := ftSmallInt;
     SQL_TIMESTAMP: Result := ftTimeStamp;
     SQL_BLOB: Result := ftBlob;
     SQL_ARRAY: Result := ftArray;
     SQL_QUAD,
     SQL_INT64: Result := ftLargeInt;
     SQL_TYPE_TIME: Result := ftTime;
     SQL_TYPE_DATE,
     SQL_BOOLEAN: Result := ftBoolean;
     SQL_DECFLOAT16,
     SQL_DECFLOAT34: Result := ftBCD;
   end;
//  SQL_VARYING                    =        448;
//  SQL_TEXT                       =        452;
//  SQL_DOUBLE                     =        480;
//  SQL_FLOAT                      =        482;
//  SQL_LONG                       =        496;
//  SQL_SHORT                      =        500;
//  SQL_TIMESTAMP                  =        510;
//  SQL_BLOB                       =        520;
//  SQL_D_FLOAT                    =        530;
//  SQL_ARRAY                      =        540;
//  SQL_QUAD                       =        550;
//  SQL_TYPE_TIME                  =        560;
//  SQL_TYPE_DATE                  =        570;
//  SQL_INT64                      =        580;
//  SQL_BOOLEAN                    =        32764;
//  SQL_DATE                       =        SQL_TIMESTAMP;
//  SQL_DECFLOAT16                 =        32760;
//  SQL_DECFLOAT34                 =        32762;

end;

procedure TFibApiDm.testQuery(const cQuery: String);
var i: Integer;
    ft: TFieldType;
    isNotEmpty: Boolean;
    Data: IColumnMetaData;
    name: String;
begin
   FStatement := FDatabase.Attachment.Prepare(FDatabase.startReadTransaction,'SELECT * FROM objects WHERE idobject>-101 ORDER BY name COLLATE UNICODE_CI ' );
//   FResultSet := FDatabase.Attachment.OpenCursor(FDatabase.startReadTransaction,'SELECT * FROM objects WHERE idobject=-101 ORDER BY name COLLATE UNICODE_CI ');
//   MemTableEh1.ClearFields;
//   isNotEmpty := FResultSet.FetchNext;
   for I := 0 to FStatement.MetaData.Count-1 do
   begin
      ft := GetFieldType(FStatement.MetaData.ColMetaData[i]);
      if (ft = ftString) then
        MemTableEh1.FieldDefs.Add(FStatement.MetaData.ColMetaData[i].Name,ft, FStatement.MetaData.ColMetaData[i].size)
      else
        MemTableEh1.FieldDefs.Add(FStatement.MetaData.ColMetaData[i].Name,ft);

   end;
   MemTableEh1.CreateDataSet;
   MemTableEh1.Open;
   FResultSet := FStatement.OpenCursor;
   while FResultSet.FetchNext do
   begin
     MemtableEh1.Append;
     for I := 0 to FStatement.MetaData.Count-1 do
     begin
       Data := FStatement.MetaData.ColMetaData[i];
       name := Data.Name;
       case Data.SQLType of
         SQL_VARYING,
         SQL_TEXT:  MemTableEh1.FieldByName(name).AsString := FResultSet.Data[i].AsString;
         SQL_DOUBLE,
         SQL_FLOAT,
         SQL_D_FLOAT: MemTableEh1.FieldByName(name).AsFloat := FResultSet.Data[i].AsFloat;
         SQL_LONG: MemTableEh1.FieldByName(name).AsInteger := FResultSet.Data[i].AsLong;
         SQL_SHORT: MemTableEh1.FieldByName(name).AsInteger := FResultSet.Data[i].AsShort;
         SQL_TIMESTAMP: MemTableEh1.FieldByName(name).AsDateTime := FResultSet.Data[i].AsDateTime;
//         SQL_BLOB: MemTableEh1.FieldByName(name).AsBString := FResultSet.Data[i].AsBlob;
//         SQL_ARRAY: Result := ftArray;
         SQL_QUAD,
         SQL_INT64: MemTableEh1.FieldByName(name).AsLargeInt := FResultSet.Data[i].AsInt64;
         SQL_TYPE_TIME: MemTableEh1.FieldByName(name).AsDateTime := FResultSet.Data[i].AsTime;
         SQL_TYPE_DATE,
         SQL_BOOLEAN: MemTableEh1.FieldByName(name).AsBoolean := FResultSet.Data[i].AsBoolean;
//         SQL_DECFLOAT16,
//         SQL_DECFLOAT34: MemTableEh1.FieldByName(name).AsBCD := FResultSet.Data[i].AsVariant;
       end;
     end;
       MemTableEh1.Post;
   end;


end;

end.
