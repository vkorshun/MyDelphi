unit fasapi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes;

const
 // biometric operation types
    BO_CAPTURE  =      0;        // capture operation
    BO_ENROLL   =      1;        // enroll --"--
    BO_VERIFY   =      2;        // verify --"--
    BO_IDENTIFY =      3;        // identify --"--

type
// /******************************************************************************
//  *
//  * Data types, constants and macros.
//  *
//  */
 // callback function contex
LPBIOPERCONTEXT = ^ BIOPERCONTEXT;
BIOPERCONTEXT = record
   oType: Integer;                     // current biometric operation
   hPrgWnd: HWND;                   // progress bar window handler. Use with
                                    // enroll operation
   hTextWnd:HWND;                  // text window handler. Use with enroll
                                       // operation
end;



 function FasInitialize(lpszFas: PAnsiChar; nPort:Integer):Integer;stdcall;external 'FASExtend.dll';
 function FasTerminate:Integer;stdcall;external 'FASExtend.dll';
 function FasSetFac(bFlag: Byte; FacID: Byte; FacIP: PAnsiChar):Integer;stdcall;external 'FASExtend.dll';
 function FasSetGroup(bFlag:Byte; GroupID: Byte; GroupName:PAnsiChar):Integer;stdcall;external 'FASExtend.dll';
 function FasAddUserFromFile(bSorC:Byte;FacID:Byte; FileName :PAnsiChar; UserName: PAnsiChar;
                    UserID: PAnsiChar;  GroupID:Byte;  FingerID: Byte; UserType: Byte):Integer;stdcall;external 'FASExtend.dll';
 function FasDeleteUser( bSorC:Byte;FacID:Byte; UserID:PAnsiChar):Integer;stdcall;external 'FASExtend.dll';
 function FasChangeUserType(FacID:Byte; UserID: PAnsiChar;  UserType: Byte):Integer;stdcall;external 'FASExtend.dll';
 function FasSendUserFromFasToFac(FacID: Byte; UserID:PAnsiChar):Integer;stdcall;external 'FASExtend.dll';
 function FasIdentifyUser ( UserID:PAnsiChar; dwSize: LongWord;  pSample: Pointer;  RetID:PAnsiChar):Integer;stdcall;external 'FASExtend.dll';
 Function FasGetFacRALToFas ( FacID: Byte; bDelete:Byte):Integer;stdcall;external 'FASExtend.dll';
 function FasGetRALSize ( year: short; month:Byte; day: Byte;  hour: Byte; minute: Byte; second:Byte;var nLength:Integer):Integer;stdcall;external 'FASExtend.dll';
 function FasGetRALData  ( buffer :PAnsiChar;  bDelete: Boolean):Integer;stdcall;external 'FASExtend.dll';
 function FasDeleteRAL( bSorC: Byte; FacID: Byte):Integer;stdcall;external 'FASExtend.dll';
 function FasSecurityLevel(bFlag:Boolean; bSorC: Boolean; FacID: Byte;var SecurityLevel:Byte):Integer;external 'FASExtend.dll';
 function FasAddDenialSetting( FacID: Byte; bFlag: Byte; GroupID: Byte; UserID: PAnsiChar;
                     month1: Byte; day1: Byte; weekday1: Byte; hour1: Byte; minute1: Byte;
                     month2: Byte; day2: Byte; weekday2: Byte; hour2: Byte; minute2: Byte):Integer;stdcall;external 'FASExtend.dll';
 function FasEditDenialSetting( FacID: Byte; Action:Byte; Level: Byte; GroupID: Byte; UserID:PAnsiChar):Integer;stdcall;external 'FASExtend.dll';
 function FasGetSizeOfUserList( FacID: Byte;var nLength: LongWord):Integer;stdcall;external 'FASExtend.dll';
 function FasGetUserList( buffer: PByte):Integer;stdcall;external 'FASExtend.dll';
 function FasGetFacUserToFas( FacID:Byte; GroupID :Byte; FingerID: Byte; UserID: PAnsiChar; UserType: Byte; Delete: Byte):Integer;stdcall;external 'FASExtend.dll';
 function FasGetFasUserTemplateToFile( UserID:PAnsiChar; FingerID:byte; FileName:PAnsiChar):Integer;stdcall;external 'FASExtend.dll';
 function FasUnlockFac( FacID: Byte):Integer;stdcall;external 'FASExtend.dll';

implementation

end.
