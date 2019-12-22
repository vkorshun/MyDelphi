object Form5: TForm5
  Left = 0
  Top = 0
  Caption = 'Form5'
  ClientHeight = 476
  ClientWidth = 907
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object DBGridEhVk1: TDBGridEhVk
    Left = 0
    Top = 0
    Width = 907
    Height = 476
    Align = alClient
    DataSource = DataSource1
    DynProps = <>
    Flat = True
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghRowHighlight, dghDialogFind, dghColumnResize, dghColumnMove, dghExtendVertLines]
    TabOrder = 0
    TitleParams.MultiTitle = True
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object pFIBDataSetVk1: TpFIBDataSetVk
    SelectSQL.Strings = (
      'SELECT * FROM test1')
    Transaction = pFIBTransaction1
    Database = pFIBDatabaseVk1
    Left = 464
    Top = 40
  end
  object pFIBDatabaseVk1: TpFIBDatabaseVk
    Connected = True
    DBName = 'inet://localhost:3050/d:\FBDATA\DATA_FB4\lidaprovo.fdb'
    DBParams.Strings = (
      'password=masterkey'
      'user_name=sysdba'
      'lc_ctype=UTF-8')
    DefaultTransaction = pFIBTransaction1
    SQLDialect = 3
    Timeout = 0
    LibraryName = 'C:\FIREBIRD-4-32\fbclient.dll'
    WaitForRestoreConnect = 0
    Left = 72
    Top = 32
  end
  object pFIBQueryVk1: TpFIBQueryVk
    Left = 248
    Top = 48
  end
  object pFIBTransaction1: TpFIBTransaction
    Active = True
    DefaultDatabase = pFIBDatabaseVk1
    Left = 360
    Top = 48
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    Left = 208
    Top = 352
  end
  object SQLConnectionProviderEh1: TSQLConnectionProviderEh
    ServerType = 'Oracle'
    Left = 624
    Top = 56
  end
  object SQLDataDriverEh1: TSQLDataDriverEh
    DeleteCommand.Params = <>
    DynaSQLParams.Options = []
    GetrecCommand.Params = <>
    InsertCommand.Params = <>
    SelectCommand.Params = <>
    SelectCommand.CommandText.Strings = (
      'select * from client')
    UpdateCommand.Params = <>
    ConnectionProvider = SQLConnectionProviderEh1
    MacroVars.Macros = <>
    Left = 736
    Top = 24
  end
  object UIBDataSet1: TUIBDataSet
    Left = 264
    Top = 168
  end
  object DataSource1: TDataSource
    DataSet = FibApiDm.MemTableEh1
    Left = 488
    Top = 296
  end
  object UIBDataBase1: TUIBDataBase
    Params.Strings = (
      'sql_dialect=3'
      'lc_ctype=UTF8')
    CharacterSet = csUTF8
    LibraryName = 'fbclient.dll'
    Left = 656
    Top = 248
  end
end
