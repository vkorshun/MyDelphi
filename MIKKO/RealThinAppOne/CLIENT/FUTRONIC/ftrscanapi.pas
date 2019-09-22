unit ftrscanapi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes;

{/*

Copyright (c) 2003-2006 Futronic Technology Company Ltd. All rights reserved.

Abstract:

Definitions and prototypes for the Futronic Scanner API.

*/ }

{$ifndef __FUTRONIC_SCAN_API_H__}
 {$define __FUTRONIC_SCAN_API_H__}
{$endif}

const
 B_TRUE	=	  1;
 B_FALSE =	0;
 P_NULL	 =  0;
 ERROR_NOT_ENOUGH_MEMORY = 8;
 ERROR_WRITE_PROTECT     = 19;
 ERROR_NOT_READY         = 21;
 ERROR_NOT_SUPPORTED     = 50;
 ERROR_INVALID_PARAMETER = 87;
 ERROR_CALL_NOT_IMPLEMENTED = 120;
 ERROR_NO_MORE_ITEMS        = 259;
 ERROR_NO_SYSTEM_RESOURCES  = 1450;
 ERROR_TIMEOUT              = 1460;
 ERROR_BAD_CONFIGURATION    = 1610;
 ERROR_MESSAGE_EXCEEDS_MAX_SIZE = 4336;

{$define FTR_API_PREFIX}
{$define FTR_API}

const
 FTR_MAX_INTERFACE_NUMBER	 =			128;
 FTR_OPTIONS_CHECK_FAKE_REPLICA	 =		$00000001;
 FTR_OPTIONS_DETECT_FAKE_FINGER	 =		FTR_OPTIONS_CHECK_FAKE_REPLICA;
 FTR_OPTIONS_FAST_FINGER_DETECT_METHOD = $00000002;

 FTR_ERROR_BASE		=					$20000000;
// FTR_ERROR_CODE( x )						(FTR_ERROR_BASE | (x))}

 FTR_ERROR_EMPTY_FRAME		=			4306 ;{* ERROR_EMPTY *}
 FTR_ERROR_MOVABLE_FINGER	= FTR_ERROR_BASE OR $0001;
 FTR_ERROR_NO_FRAME				= FTR_ERROR_BASE OR $0002;
 FTR_ERROR_USER_CANCELED	= FTR_ERROR_BASE OR $0003;
 FTR_ERROR_HARDWARE_INCOMPATIBLE = FTR_ERROR_BASE OR $0004;
 FTR_ERROR_FIRMWARE_INCOMPATIBLE = FTR_ERROR_BASE OR $0005;
 FTR_ERROR_INVALID_AUTHORIZATION_CODE	= FTR_ERROR_BASE OR $0006;

{/* Other return codes are Windows-compatible */}
 FTR_ERROR_NO_MORE_ITEMS =					ERROR_NO_MORE_ITEMS;
 FTR_ERROR_NOT_ENOUGH_MEMORY =				ERROR_NOT_ENOUGH_MEMORY;
 FTR_ERROR_NO_SYSTEM_RESOURCES =			ERROR_NO_SYSTEM_RESOURCES;
 FTR_ERROR_TIMEOUT =						ERROR_TIMEOUT;
 FTR_ERROR_NOT_READY =						ERROR_NOT_READY;
 FTR_ERROR_BAD_CONFIGURATION =				ERROR_BAD_CONFIGURATION;
 FTR_ERROR_INVALID_PARAMETER =				ERROR_INVALID_PARAMETER;
 FTR_ERROR_CALL_NOT_IMPLEMENTED	=		ERROR_CALL_NOT_IMPLEMENTED;
 FTR_ERROR_NOT_SUPPORTED =					ERROR_NOT_SUPPORTED;
 FTR_ERROR_WRITE_PROTECT =					ERROR_WRITE_PROTECT;
 FTR_ERROR_MESSAGE_EXCEEDS_MAX_SIZE	=	ERROR_MESSAGE_EXCEEDS_MAX_SIZE;

 FTR_CONST_DIODE_OFF:BYTE  =						0;
 FTR_CONST_DIODE_ON:byte	 =					255;
 FTR_VERSION_UNKNOWN_VERSION	=	$FFFF;

 FTR_SCANNER_FEATURE_LFD					 = 1;
 FTR_SCANNER_FEATURE_DIODES				 = 2;
 FTR_SCANNER_FEATURE_GET_IMAGE2		 = 3;
 FTR_SCANNER_FEATURE_SERIAL_NUMBER = 4;

 FTR_BLACKFIN_MAX_WRITE_DATA_LEN	= 4096;
type
  FTRHANDLE = Pointer;
  FTR_BYTE  = byte;
  FTR_BOOL  = Integer;
  FTR_DWORD = LongWord;
  FTR_WORD  = Word;
//typedef void * FTRHANDLE;
//typedef	unsigned char FTR_BYTE;
//typedef int FTR_BOOL;
//typedef	unsigned long FTR_DWORD;
//typedef	unsigned short FTR_WORD;

  FTR_PVOID = Pointer;
	FTR_PBOOL = ^FTR_BOOL;
	FTR_PBYTE = ^FTR_BYTE;
	FTR_PDWORD = ^FTR_DWORD;
//typedef	void * FTR_PVOID;
//typedef	FTR_BOOL * FTR_PBOOL;
//typedef	FTR_BYTE * FTR_PBYTE;
//typedef	FTR_DWORD * FTR_PDWORD;

//{$if defined( __cplusplus )
//extern "C" { /* assume C declarations for C++ */
//{$endif


//{$if defined(__WIN32__)
//{$pragma pack(push, 1)
//{$endif


{/*
byDeviceCompatibility:
	0 Ö USB 1.1 device,
	1 Ö USB 2.0 device
	2 - "Sweep" scanner
	3 - "BlackFin" scanner
*/}

PFTRSCAN_DEVICE_INFO  = ^FTRSCAN_DEVICE_INFO ;
FTRSCAN_DEVICE_INFO = record
  dwStructSize:	FTR_DWORD	;	{* [in, out] *}
	byDeviceCompatibility: FTR_BYTE	;
	wPixelSizeX: FTR_WORD	;
	wPixelSizeY: FTR_WORD ;
end;

PFTRSCAN_IMAGE_SIZE = ^FTRSCAN_IMAGE_SIZE;
FTRSCAN_IMAGE_SIZE = record
	nWidth: integer ;
	nHeight: integer;
	nImageSize: integer;
end;

PFTRSCAN_FAKE_REPLICA_PARAMETERS=^FTRSCAN_FAKE_REPLICA_PARAMETERS;
FTRSCAN_FAKE_REPLICA_PARAMETERS = record
	bCalculated:         FTR_BOOL;
	nCalculatedSum1:     integer ;
	nCalculatedSumFuzzy: integer ;
	nCalculatedSumEmpty: integer ;
	nCalculatedSum2:     integer ;
	dblCalculatedTremor: double  ;
	dblCalculatedValue:   double ;
end;

PFTRSCAN_FAKE_REPLICA_BUFFER = ^FTRSCAN_FAKE_REPLICA_BUFFER;
FTRSCAN_FAKE_REPLICA_BUFFER  = record
	bCalculated: FTR_BOOL;
	nBuffers:    Integer;
	nWidth:      Integer;
	nHeight:     Integer;
	nSize:       Integer;
	pBuffers:    FTR_PVOID;
end;

PFTRSCAN_LFD_CONSTANTS = ^FTRSCAN_LFD_CONSTANTS;
FTRSCAN_LFD_CONSTANTS = record
  nLMin:    integer;
	nLMax:    integer;
	nCMin:    integer;
	nCMax:    integer;
	nEEMin:   integer;
	nEEMax:   integer;
end;

PFTRSCAN_FRAME_PARAMETERS = ^FTRSCAN_FRAME_PARAMETERS;
FTRSCAN_FRAME_PARAMETERS  = record
	nContrastOnDose2:   integer;
	nContrastOnDose4:   integer;
	nDose:              integer;
	nBrightnessOnDose1: integer;
	nBrightnessOnDose2: integer;
	nBrightnessOnDose3: integer;
	nBrightnessOnDose4: integer;
	FakeReplicaParams:  FTRSCAN_FAKE_REPLICA_PARAMETERS;
	Reserved: array [0..64-sizeof(FTRSCAN_FAKE_REPLICA_PARAMETERS)] of FTR_BYTE;
end;

PFTRSCAN_INTERFACE_STATUS=^FTRSCAN_INTERFACE_STATUS;
FTRSCAN_INTERFACE_STATUS = (
	FTRSCAN_INTERFACE_STATUS_CONNECTED,
	FTRSCAN_INTERFACE_STATUS_DISCONNECTED
) ;

//TarrayFTRSCAN_INTERFACE_STATUS = array[0..FTR_MAX_INTERFACE_NUMBER] of FTRSCAN_INTERFACE_STATUS;
PFTRSCAN_INTERFACES_LIST=^FTRSCAN_INTERFACES_LIST;
FTRSCAN_INTERFACES_LIST = record
  InterfaceStatus: array[0..FTR_MAX_INTERFACE_NUMBER] of FTRSCAN_INTERFACE_STATUS;
end;
//typedef struct __FTRSCAN_INTERFACES_LIST {
//	FTRSCAN_INTERFACE_STATUS			InterfaceStatus[FTR_MAX_INTERFACE_NUMBER];
//} FTRSCAN_INTERFACES_LIST, *PFTRSCAN_INTERFACES_LIST FTR_PACKED;

PFTRSCAN_VERSION=^FTRSCAN_VERSION;
FTRSCAN_VERSION = record
  wMajorVersionHi: FTR_WORD;
  wMajorVersionLo: FTR_WORD;
  wMinorVersionHi: FTR_WORD;
  wMinorVersionLo: FTR_WORD;
end;
//typedef struct __FTRSCAN_VERSION {
//	FTR_WORD							wMajorVersionHi;
//	FTR_WORD							wMajorVersionLo;
//	FTR_WORD							wMinorVersionHi;
//	FTR_WORD							wMinorVersionLo;
//} FTRSCAN_VERSION, *PFTRSCAN_VERSION FTR_PACKED;

PFTRSCAN_VERSION_INFO = ^FTRSCAN_VERSION_INFO;
FTRSCAN_VERSION_INFO  = record
  dwVersionInfoSize: LongWord;
  APIVersion       : FTRSCAN_VERSION;
  HardwareVersion: FTRSCAN_VERSION;
  FirmwareVersion: FTRSCAN_VERSION;
end;

PFTRCALIBRATEFNCB = ^FTRCALIBRATEFNCB;
FTRCALIBRATEFNCB = function( pContext,pParams:FTR_PVOID  ):FTR_BOOL;

//typedef struct __FTRSCAN_VERSION_INFO {
//	DWORD								dwVersionInfoSize;		/* [in, out] */
//	FTRSCAN_VERSION						APIVersion;
//	FTRSCAN_VERSION						HardwareVersion;
//	FTRSCAN_VERSION						FirmwareVersion;
//} FTRSCAN_VERSION_INFO, *PFTRSCAN_VERSION_INFO FTR_PACKED;


//{$if defined(__WIN32__)
//{$pragma pack(pop)
//{$endif
//FTR_API_PREFIX FTRHANDLE FTR_API ftrScanOpenDevice();
//FTRHANDLE FTR_API ftrScanOpenDeviceOnInterface( int nInterface );
//FTR_API_PREFIX void FTR_API ftrScanCloseDevice( FTRHANDLE ftrHandle );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanSetOptions( FTRHANDLE ftrHandle, FTR_DWORD dwMask, FTR_DWORD dwFlags );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetOptions( FTRHANDLE ftrHandle, FTR_PDWORD lpdwFlags );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetDeviceInfo( FTRHANDLE ftrHandle, PFTRSCAN_DEVICE_INFO pDeviceInfo );

//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetInterfaces( PFTRSCAN_INTERFACES_LIST pInterfaceList );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrSetBaseInterface( int nBaseInterface );
//FTR_API_PREFIX int FTR_API ftrGetBaseInterfaceNumber();

//FTR_API_PREFIX FTR_DWORD FTR_API ftrScanGetLastError();
//FTR_API_PREFIX void FTR_API ftrScanSetLastError( FTR_DWORD dwErrCode );

//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetVersion( FTRHANDLE ftrHandle, PFTRSCAN_VERSION_INFO pVersionInfo );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanIsScannerFeaturePresent( FTRHANDLE ftrHandle, int nScannerFeature, FTR_PBOOL pIsPresent );

//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetFakeReplicaInterval( double *pdblMinFakeReplicaValue, double *pdblMaxFakeReplicaValue );
//FTR_API_PREFIX void FTR_API ftrScanSetFakeReplicaInterval( double dblMinFakeReplicaValue, double dblMaxFakeReplicaValue );


function ftrScanOpenDevice:FTRHANDLE; stdcall; external 'ftrscanapi.dll';
function ftrScanOpenDeviceOnInterfacee(nInterface:Integer):FTRHANDLE; stdcall; external 'ftrscanapi.dll';
procedure ftrScanCloseDevice( aftrHandle:FTRHANDLE  ); stdcall; external 'ftrscanapi.dll';
function ftrScanSetOptions(  aftrHandle:FTRHANDLE; dwMask: FTR_DWORD ;dwFlags: FTR_DWORD  ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetOptions(  aftrHandle:FTRHANDLE; lpdwFlags: FTR_PDWORD   ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetDeviceInfo( aftrHandle:FTRHANDLE; pDeviceInfo:PFTRSCAN_DEVICE_INFO  ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';

function ftrScanGetInterfaces( pInterfaceList: PFTRSCAN_INTERFACES_LIST ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanSetBaseInterfaces( nBaseInterface: Integer ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetBaseInterfaces:Integer; stdcall; external 'ftrscanapi.dll';

function ftrScanGetLastError:FTR_DWORD; stdcall; external 'ftrscanapi.dll';
procedure ftrScanSetLastError( dwErrCode:FTR_DWORD); stdcall; external 'ftrscanapi.dll';

function ftrScanGetVersion( aftrHandle:FTRHANDLE; pVersionInfo:PFTRSCAN_VERSION_INFO   ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanIsScannerFeaturePresent( aftrHandle:FTRHANDLE; nScannerFeature: integer;pIsPresent: FTR_PBOOL    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';

function ftrScanGetFakeReplicaInterval( pdblMinFakeReplicaValue: Pdouble; pdblMaxFakeReplicaValue:Pdouble ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
procedure ftrScanSetFakeReplicaInterval( dblMinFakeReplicaValue: double; dblMaxFakeReplicaValue:double ); stdcall; external 'ftrscanapi.dll';

function ftrScanGetLFDParameters( pLFDParameters:PFTRSCAN_LFD_CONSTANTS  ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanSetLFDParameters( pLFDParameters:PFTRSCAN_LFD_CONSTANTS  ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';

function ftrScanGetImageSize( aftrHandle:FTRHANDLE ; pImageSize:PFTRSCAN_IMAGE_SIZE   ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetImage( aftrHandle:FTRHANDLE ; nDose:Integer; pBuffer:FTR_PVOID    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetImage2( aftrHandle:FTRHANDLE ; nDose:Integer; pBuffer:FTR_PVOID    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetFuzzyImage( aftrHandle:FTRHANDLE ; pBuffer:FTR_PVOID    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetBacklightImage( aftrHandle:FTRHANDLE ; pBuffer:FTR_PVOID    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetDarkImage( aftrHandle:FTRHANDLE ; pBuffer:FTR_PVOID    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetColourImage( aftrHandle:FTRHANDLE ; pDoubleSizeBuffer:FTR_PVOID    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetSmallColourImage( aftrHandle:FTRHANDLE ; pSmallBuffer:FTR_PVOID    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetColorDarkImage( aftrHandle:FTRHANDLE ; pDoubleSizeBuffer:FTR_PVOID    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetImageByVariableDose( aftrHandle:FTRHANDLE ; nVariableDose:Integer;pBuffer:FTR_PVOID    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGet4in1Image( aftrHandle:FTRHANDLE ;pBuffer:FTR_PVOID    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';

//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetLFDParameters( PFTRSCAN_LFD_CONSTANTS pLFDParameters );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanSetLFDParameters( PFTRSCAN_LFD_CONSTANTS pLFDParameters );

//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetImageSize( FTRHANDLE ftrHandle, PFTRSCAN_IMAGE_SIZE pImageSize );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetImage( FTRHANDLE ftrHandle, int nDose, FTR_PVOID pBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetImage2( FTRHANDLE ftrHandle, int nDose, FTR_PVOID pBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetFuzzyImage( FTRHANDLE ftrHandle, FTR_PVOID pBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetBacklightImage( FTRHANDLE ftrHandle, FTR_PVOID pBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetDarkImage( FTRHANDLE ftrHandle, FTR_PVOID pBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetColourImage( FTRHANDLE ftrHandle, FTR_PVOID pDoubleSizeBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetSmallColourImage( FTRHANDLE ftrHandle, FTR_PVOID pSmallBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetColorDarkImage( FTRHANDLE ftrHandle, FTR_PVOID pDoubleSizeBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetImageByVariableDose( FTRHANDLE ftrHandle, int nVariableDose, FTR_PVOID pBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGet4in1Image( FTRHANDLE ftrHandle, FTR_PVOID pBuffer );

function ftrScanGetPartOfImageSize( aftrHandle:FTRHANDLE ;pPartOfImageSize:PFTRSCAN_IMAGE_SIZE   ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetPartOfImage( aftrHandle:FTRHANDLE ; nDose: Integer; pBuffer:FTR_PVOID    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetPartOfDarkImage( aftrHandle:FTRHANDLE ; pBuffer:FTR_PVOID    ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';

//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetPartOfImageSize( FTRHANDLE ftrHandle, PFTRSCAN_IMAGE_SIZE pPartOfImageSize);
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetPartOfImage( FTRHANDLE ftrHandle, int nDose, FTR_PVOID pBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetPartOfBacklightImage( FTRHANDLE ftrHandle, FTR_PVOID pBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetPartOfDarkImage( FTRHANDLE ftrHandle, FTR_PVOID pBuffer );

function ftrScanIsFingerPresent( aftrHandle:FTRHANDLE ; pFrameParameters:PFTRSCAN_FRAME_PARAMETERS ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetFrame( aftrHandle:FTRHANDLE ;pBuffer:FTR_PVOID ;pFrameParameters:PFTRSCAN_FRAME_PARAMETERS ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanIsFingerPresent( FTRHANDLE ftrHandle, PFTRSCAN_FRAME_PARAMETERS pFrameParameters );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetFrame( FTRHANDLE ftrHandle, FTR_PVOID pBuffer, PFTRSCAN_FRAME_PARAMETERS pFrameParameters );

function ftrScanSave7Bytes( aftrHandle:FTRHANDLE ;pBuffer:FTR_PVOID  ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanRestore7Bytes( aftrHandle:FTRHANDLE ;pBuffer:FTR_PVOID  ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanSave7Bytes( FTRHANDLE ftrHandle, FTR_PVOID pBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanRestore7Bytes( FTRHANDLE ftrHandle, FTR_PVOID pBuffer );

function ftrScanGetExtMemorySize( aftrHandle:FTRHANDLE ; pnSize:PInteger  ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanSaveExtMemory( aftrHandle:FTRHANDLE ; pBuffer:FTR_PVOID;nOffset,nCount:Integer  ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanRestoreExtMemory( aftrHandle:FTRHANDLE ; pBuffer:FTR_PVOID;nOffset,nCount:Integer  ):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetExtMemorySize( FTRHANDLE ftrHandle, int *pnSize );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanSaveExtMemory( FTRHANDLE ftrHandle, FTR_PVOID pBuffer, int nOffset, int nCount );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanRestoreExtMemory( FTRHANDLE ftrHandle, FTR_PVOID pBuffer, int nOffset, int nCount );

function ftrScanGetSerialNumber( aftrHandle:FTRHANDLE ; pBuffer:FTR_PVOID):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanSaveSerialNumber( aftrHandle:FTRHANDLE ; pReserved:FTR_PVOID):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetSerialNumber( FTRHANDLE ftrHandle, FTR_PVOID pBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanSaveSerialNumber( FTRHANDLE ftrHandle, FTR_PVOID pReserved );

function ftrScanZeroCalibration( pfnCallbackProc:PFTRCALIBRATEFNCB ; pContext:FTR_PVOID):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanZeroCalibration2( dwOptions:FTR_WORD ; pfnCallbackProc:PFTRCALIBRATEFNCB ; pContext:FTR_PVOID):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetCalibrationConstants( aftrHandle:FTRHANDLE ;pbyIRConst: FTR_PBYTE; pbyFuzzyConst:FTR_PBYTE):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanStoreCalibrationConstants( aftrHandle:FTRHANDLE ;pbyIRConst: FTR_PBYTE; pbyFuzzyConst:FTR_PBYTE; bBurnToFlash: FTR_BOOL):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanZeroCalibration(  pfnCallbackProc, FTR_PVOID pContext );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanZeroCalibration2( FTR_DWORD dwOptions, PFTRCALIBRATEFNCB pfnCallbackProc, FTR_PVOID pContext );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetCalibrationConstants( FTRHANDLE ftrHandle, FTR_PBYTE pbyIRConst, FTR_PBYTE pbyFuzzyConst );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanStoreCalibrationConstants( FTRHANDLE ftrHandle, FTR_BYTE byIRConst, FTR_BYTE byFuzzyConst, FTR_BOOL bBurnToFlash );

function ftrScanGetFakeReplicaParameters( aftrHandle:FTRHANDLE ;pFakeReplicaParams:PFTRSCAN_FAKE_REPLICA_PARAMETERS):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetFakeReplicaBuffer( aftrHandle:FTRHANDLE ;pFakeReplicaBuffer:PFTRSCAN_FAKE_REPLICA_BUFFER):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetFakeReplicaParameters( FTRHANDLE ftrHandle, PFTRSCAN_FAKE_REPLICA_PARAMETERS pFakeReplicaParams );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetFakeReplicaBuffer( FTRHANDLE ftrHandle, PFTRSCAN_FAKE_REPLICA_BUFFER pFakeReplicaBuffer );

function ftrScanSetNewAuthorizationCode( aftrHandle:FTRHANDLE ; pSevenBytesAuthorizationCode:FTR_PVOID):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanSaveSecret7Bytes( aftrHandle:FTRHANDLE ; pSevenBytesAuthorizationCode:FTR_PVOID; pBuffer:FTR_PVOID):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanRestoreSecret7Bytes( aftrHandle:FTRHANDLE ; pSevenBytesAuthorizationCode:FTR_PVOID; pBuffer:FTR_PVOID):FTR_BOOL; stdcall; external 'ftrscanapi.dll';

//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanSetNewAuthorizationCode( FTRHANDLE ftrHandle, FTR_PVOID pSevenBytesAuthorizationCode );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanSaveSecret7Bytes( FTRHANDLE ftrHandle, FTR_PVOID pSevenBytesAuthorizationCode, FTR_PVOID pBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanRestoreSecret7Bytes( FTRHANDLE ftrHandle, FTR_PVOID pSevenBytesAuthorizationCode, FTR_PVOID pBuffer );

function ftrScanSetDiodesStatus( aftrHandle:FTRHANDLE ; byGreenDiodeStatus:FTR_PVOID; byRedDiodeStatus:FTR_PVOID):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanGetDiodesStatus( aftrHandle:FTRHANDLE ; pbIsGreenDiodeOn:FTR_PBOOL; pbIsRedDiodeOn:FTR_PBOOL):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanSetDiodesStatus( FTRHANDLE ftrHandle, FTR_BYTE byGreenDiodeStatus, FTR_BYTE byRedDiodeStatus );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanGetDiodesStatus( FTRHANDLE ftrHandle, FTR_PBOOL pbIsGreenDiodeOn, FTR_PBOOL pbIsRedDiodeOn );

function ftrScanSave7ControlBytes( aftrHandle:FTRHANDLE ; pBuffer:FTR_PVOID; bBurnToFlash:FTR_BOOL):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrScanRestore7ControlBytes( aftrHandle:FTRHANDLE ; pBuffer:FTR_PVOID):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanSave7ControlBytes( FTRHANDLE ftrHandle, FTR_PVOID pBuffer, FTR_BOOL bBurnToFlash );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrScanRestore7ControlBytes( FTRHANDLE ftrHandle, FTR_PVOID pBuffer );

function ftrSweepGetSlice( aftrHandle:FTRHANDLE ; pBuffer:FTR_PVOID):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
function ftrSweepGetMultipleSlices( aftrHandle:FTRHANDLE ; nSlices:Integer;pBuffer:FTR_PVOID):FTR_BOOL; stdcall; external 'ftrscanapi.dll';
//FTR_API_PREFIX FTR_BOOL FTR_API ftrSweepGetSlice( FTRHANDLE ftrHandle, FTR_PVOID pBuffer );
//FTR_API_PREFIX FTR_BOOL FTR_API ftrSweepGetMultipleSlices( FTRHANDLE ftrHandle, int nSlices, FTR_PVOID pBuffer );

//FTR_API_PREFIX FTR_BOOL FTR_API ftrBlackfinDataExchange( FTRHANDLE ftrHandle, FTR_PVOID pWriteBuffer, int nWriteBufferLength, FTR_PVOID pReadBuffer, int nReadBufferLength );

//{$ifdef __cplusplus}
//{$endif}

//{$endif}	// __FUTRONIC_SCAN_API_H__


implementation

end.
