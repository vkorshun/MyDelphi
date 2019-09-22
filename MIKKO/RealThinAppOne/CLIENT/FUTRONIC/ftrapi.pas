unit ftrapi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes;

CONST
//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
//'
//' Futronic SDK constants
//'
//
//' Return code values.
FTR_RETCODE_ERROR_BASE :Integer = 1 ;//     ' Base value for the error codes.
FTR_RETCODE_DEVICE_BASE :Integer = 200 ;//  ' Base value for the device error codes.

FTR_RETCODE_OK: Integer = 0 ;//             ' Successful function completion.

FTR_RETCODE_NO_MEMORY : Integer = 2;
FTR_RETCODE_INVALID_ARG: Integer = 3;
FTR_RETCODE_ALREADY_IN_USE : Integer = 4;
FTR_RETCODE_INVALID_PURPOSE : Integer = 5;
FTR_RETCODE_INTERNAL_ERROR : Integer = 6;
FTR_RETCODE_UNABLE_TO_CAPTURE : Integer = 7;
FTR_RETCODE_CANCELED_BY_USER : Integer = 8;
FTR_RETCODE_NO_MORE_RETRIES : Integer = 9;

FTR_RETCODE_FRAME_SOURCE_NOT_SET : Integer = 201;
FTR_RETCODE_DEVICE_NOT_CONNECTED : Integer = 202;
FTR_RETCODE_DEVICE_FAILURE :Integer = 203;
FTR_RETCODE_EMPTY_FRAME : Integer = 204;

//' Values used for the parameter definition (FTRSetParam and FTRGetParam).
FTR_PARAM_IMAGE_WIDTH  = 1 ;
FTR_PARAM_IMAGE_HEIGHT = 2 ;
FTR_PARAM_IMAGE_SIZE  = 3 ;
FTR_PARAM_CB_FRAME_SOURCE:LongWord  = 4 ;
FTR_PARAM_CB_CONTROL  = 5;
FTR_PARAM_MAX_TEMPLATE_SIZE  = 6 ;
FTR_PARAM_MAX_FAR_REQUESTED  = 7 ;
FTR_PARAM_MAX_MODELS  = 10;
FTR_PARAM_FAKE_DETECT  = 9;
FTR_PARAM_FFD_CONTROL  = 11;

//' Available frame sources. These device identifiers are intended to be used
//' with the FTR_PARAM_CB_FRAME_SOURCE parameter.
FSD_FUTRONIC_USB:LongWord  = 1 ;//      ' Futronic USB Fingerprint Scanner Device.

//'
//' User callback function definitions
//'
//' State bit mask values for user callback function.
 FTR_STATE_FRAME_PROVIDED  = 1;
 FTR_STATE_SIGNAL_PROVIDED  = 2;
//' Signal values.
 FTR_SIGNAL_UNDEFINED          = 0;
 FTR_SIGNAL_TOUCH_SENSOR       = 1;
 FTR_SIGNAL_TAKE_OFF           = 2;
 FTR_SIGNAL_FAKE_SOURCE        = 3;
//' Response values
 FTR_CANCEL:LongWord  = 1;
 FTR_CONTINUE:LongWord  = 2;

//' Values used for the purpose definition
 FTR_PURPOSE_IDENTIFY:LongWord  = 2;
 FTR_PURPOSE_ENROLL:LongWord  = 3;

type
  FTRAPI_RESULT = Integer;
  FTR_PARAM = LongWord;
  FTR_PARAM_VALUE = Pointer;
  FTR_FAR = LongWord;
  FTR_USER_CTX   = LongWord;
  FTR_PURPOSE    = LongWord;
  FTR_STATE      = LongWord;
  FTR_RESPONSE   = LongWord;
  FTR_SIGNAL     = LongWord;

  FTR_DATA_PTR = ^FTR_DATA;
  FTR_DATA = record
    dwSize: LongWord;//          ' Length of data in bytes.
    pData : Pointer ;// As Long           ' Data pointer.
  end;

  //' Futronic SDK image data
  FTR_BITMAP_PTR = ^FTR_BITMAP;
  FTR_BITMAP = record
    ftrWidth: LongWord; //        ' width in pixels
    ftrHeight: LongWord; //        ' height in pixels
    ftrBitmap: FTR_DATA; //   ' bitmap as FTR_DATA type
  End;

  //' Identify record description
  FTR_IDENTIFY_RECORD_PTR =   ^FTR_IDENTIFY_RECORD;
  FTR_IDENTIFY_RECORD = record
    KeyValue: array [0..15] of AnsiChar;// ' external key
    pData: FTR_DATA_PTR; //          ' pointer on FTR_DATA type
  End;

  //' Array of identify records
  FTR_IDENTIFY_ARRAY_PTR = ^FTR_IDENTIFY_ARRAY;
  FTR_IDENTIFY_ARRAY = record
    TotalNumber: LongWord;//     ' number of FTR_IDENTIFY_RECORD
    pMembers: FTR_IDENTIFY_RECORD_PTR;//       ' pointer on FTR_IDENTIFY_RECORD type
  End;


  //' Match record description
  FTR_MATCHED_RECORD_PTR = ^FTR_MATCHED_RECORD;
  FTR_MATCHED_RECORD = record
    KeyValue: array [0..15] of AnsiChar;// ' external key
    FarAttained: FTR_FAR;
  End;

  // ' Array of match records
  FTR_MATCHED_ARRAY_PTR = ^FTR_MATCHED_ARRAY;
  FTR_MATCHED_ARRAY = record
    TotalNumber: LongWord;//     ' number of FTR_MATCHED_RECORD
    pMembers: FTR_MATCHED_RECORD_PTR;//       ' pointer on FTR_MATCHED_RECORD
  End;

  // Data types used for enrollment.
 FTR_ENROLL_DATA_PTR = ^FTR_ENROLL_DATA;
 FTR_ENROLL_DATA = record
  dwSize: LongWord; // The size of the structure in bytes.
  dwQuality: LongWord; // Estimation of a template quality in terms of recognition:
 end;

//  BIOPERCONTEXT = record
//    oType: Integer        ' current biometric operation
//    hPrgWnd As Long         ' progress bar window handler. Use with
//    hTextWnd As Long        ' text window handler. Use with enroll
//End Type

//' struct of the user list get from fas
//Type FAMUSER
//    dUID As Double
//    nFingerID As Byte
//    nGroupID As Byte
//    nUType As Byte
//End Type

  TcbControl = procedure  ( Context: FTR_USER_CTX; StateMask:FTR_STATE ;  pResponse:PLongWord; Signal: FTR_SIGNAL ; pBitmap:FTR_BITMAP_PTR  );

//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
//'
//' Futronic SDK function prototypes
//'
 Function FTRInitialize:FTRAPI_RESULT;stdcall; external 'FtrAPI.DLL';
 Function FTRTerminate:FTRAPI_RESULT;stdcall; external 'FtrAPI.DLL';
 Function FTRSetParam( Param:FTR_PARAM; aValue:LongWord ):FTRAPI_RESULT;stdcall; external 'FtrAPI.DLL';
 Function FTRGetParam( Param:FTR_PARAM; aValue:FTR_PARAM_VALUE ):FTRAPI_RESULT;stdcall; external 'FtrAPI.DLL';
 Function FTRCaptureFrame(usrContext :FTR_USER_CTX; pFrameBuf:Pointer):FTRAPI_RESULT;stdcall; external 'FtrAPI.DLL';
 function FTREnrollX( UserContext:FTR_USER_CTX ;Purpose:FTR_PURPOSE;  pTemplate:FTR_DATA_PTR;pEData:FTR_ENROLL_DATA_PTR ):FTRAPI_RESULT;stdcall; external 'FtrAPI.DLL';
// RAPI_RESULT FTRAPI FTREnrollX( FTR_USER_CTX UserContext, FTR_PURPOSE Purpose, FTR_DATA_PTR pTemplate, FTR_ENROLL_DATA_PTR pEData );

 function FTREnroll( UserContext:FTR_USER_CTX ;Purpose:FTR_PURPOSE;  pTemplate:FTR_DATA_PTR ):FTRAPI_RESULT;stdcall; external 'FtrAPI.DLL';
 function FTRVerify( UserContext:FTR_USER_CTX ; pTemplate:FTR_DATA_PTR; var pResult:Boolean;pFARVerify:FTR_FAR  ):FTRAPI_RESULT;stdcall; external 'FtrAPI.DLL';
 function FTRSetBaseTemplate( pTemplate:FTR_DATA_PTR  ):FTRAPI_RESULT;stdcall; external 'FtrAPI.DLL';
 function FTRIdentify( pAIdent:FTR_IDENTIFY_ARRAY_PTR; pdwMatchCnt: PLongWord; pAMatch:FTR_MATCHED_ARRAY_PTR  ):FTRAPI_RESULT;stdcall; external 'FtrAPI.DLL';

// Declare Function FTREnroll Lib "FtrAPI.DLL" _
//    (ByVal usrContext As Any, ByVal Purpose As Long, ByRef pTemplate As FTR_DATA) As Integer
//Declare Function FTRVerify Lib "FtrAPI.DLL" _
//    (ByVal usrContext As Any, ByRef pTemplate As FTR_DATA, ByRef pResult As Boolean, _
//     ByRef pFARVerify As Long) As Integer
//Declare Function FTRSetBaseTemplate Lib "FtrAPI.DLL" _
//    (ByRef pTemplate As FTR_DATA) As Integer
//Declare Function FTRIdentify Lib "FtrAPI.DLL" _
//    (ByRef pAIdent As FTR_IDENTIFY_ARRAY, ByRef pdwMatchCnt As Long, _
//     ByRef pAMatch As FTR_MATCHED_ARRAY) As Long


implementation

end.
