@REM Set up LISTENER.ORA on both servers.
@REM Read the contents of params.txt and put them in variables
for /f "delims== tokens=1,2" %%G in (params.txt) do set %%G=%%H

set PRIMARY=%PRIMARY_DB%
set PRIMARY_SERVER=%PRIMARY_SERVER%

set ORACLE_HOME=%ORACLE_HOME%

set LISTENER=%ORACLE_HOME%\network\admin\listener.ora


For /F %%A In ('Find /C "(GLOBAL_DBNAME = %PRIMARY%)"^<"%LISTENER%"') Do (Set "primary_srv_count=%%A")

echo %primary_srv_count%

pause

if %primary_srv_count% == 0 goto Add_Primary_Entry

echo There seems to be a static entry already. 

goto EndScript

:Add_Primary_Entry

	echo Adding Primary Instance.
	pause
	
	@@REM Create backup of %LISTENER% file
	copy %LISTENER% %LISTENER%_%date:~-4,4%%date:~-7,2%%date:~-10,2%_%RANDOM%.bak

	@ECHO ON
	ECHO[ >> %LISTENER%
  ECHO SID_LIST_LISTENER = >> %LISTENER%
  ECHO (SID_LIST = >> %LISTENER%
  ECHO   (SID_DESC = >> %LISTENER%
  ECHO     (GLOBAL_DBNAME = %PRIMARY%) >> %LISTENER%
  ECHO     (ORACLE_HOME = %ORACLE_HOME%) >> %LISTENER%
  ECHO     (SID_NAME = %PRIMARY%) >> %LISTENER%
  ECHO   ) >> %LISTENER%
  ECHO ) >> %LISTENER%


  Echo Added Primary server to %LISTENER%

  goto EndScript

:EndScript
pause



