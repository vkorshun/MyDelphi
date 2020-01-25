program ledapravoTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  Unit1 in 'Unit1.pas' {Form1},
  Testcommoninterface in 'Testcommoninterface.pas',
  commoninterface in '..\..\..\SERVER\COMMON\INTERFACE\commoninterface.pas',
  ServerDocSqlManager in '..\..\..\SERVER\COMMON\INTERFACE\ServerDocSqlManager.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

