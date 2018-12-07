@REM Set up %TNSNAMES% on both servers.
@REM Read the contents of params.txt and put them in variables
for /f "delims== tokens=1,2" %%G in (params.txt) do set %%G=%%H

set PRIMARY=%PRIMARY_DB%
set SECONDARY=%SECONDARY_DB%
set ORACLE_HOME=%ORACLE_HOME%

set TNSNAMES=%ORACLE_HOME%\network\admin\tnsnames.ora


For /F %%A In ('Find /C "%PRIMARY% ="^<"%TNSNAMES%"') Do (Set "primary_srv_count=%%A")

For /F %%A In ('Find /C "%SECONDARY% ="^<"%TNSNAMES%"') Do (Set "secondary_srv_count=%%A")

echo %primary_srv_count%
echo %secondary_srv_count%

pause

if %primary_srv_count% == 0 goto Add_Primary_Entry
if %secondary_srv_count% == 0 goto Add_Secondary_Entry

echo There seems to be an entry for both primary and secondary already check %TNSNAMES% manually.

goto EndScript

:Add_Primary_Entry

	echo Adding Primary Instance.
	pause
	
	@@REM Create backup of %TNSNAMES% file
	copy %TNSNAMES% %TNSNAMES%_%date:~-4,4%%date:~-7,2%%date:~-10,2%_%RANDOM%.bak

	@ECHO ON
	ECHO[ >> %TNSNAMES%
	echo %PRIMARY% = >> %TNSNAMES%
  	echo (DESCRIPTION = >> %TNSNAMES%
  	echo   (ADDRESS_LIST = >> %TNSNAMES%
  	echo     (ADDRESS = (PROTOCOL = TCP)(HOST = %PRIMARY_SERVER%)(PORT = 1521)) >> %TNSNAMES%
  	echo   ) >> %TNSNAMES%
  	echo   (CONNECT_DATA = >> %TNSNAMES%
  	echo     (SID = %PRIMARY%) >> %TNSNAMES%
  	echo   ) >> %TNSNAMES%
  	echo ) >> %TNSNAMES%

  	if secondary_srv_count == 0 goto Add_Secondary_Entry

  	Echo Added Primary server to %TNSNAMES%

  	goto EndScript




:Add_Secondary_Entry

	echo Adding Secondary Instance.
	pause

	@@REM Create backup of %TNSNAMES% file
	copy %TNSNAMES% %TNSNAMES%_%date:~-4,4%%date:~-7,2%%date:~-10,2%_%RANDOM%.bak

	@ECHO ON
	ECHO[ >> %TNSNAMES%
	ECHO %SECONDARY% = >> %TNSNAMES%
  	ECHO (DESCRIPTION = >> %TNSNAMES%
  	ECHO   (ADDRESS_LIST = >> %TNSNAMES%
  	ECHO     (ADDRESS = (PROTOCOL = TCP)(HOST = %SECONDARY_SERVER%)(PORT = 1521)) >> %TNSNAMES%
  	ECHO   ) >> %TNSNAMES%
  	ECHO   (CONNECT_DATA = >> %TNSNAMES%
  	ECHO     (SID = %SECONDARY%) >> %TNSNAMES%
  	ECHO   ) >> %TNSNAMES%
  	ECHO ) >> %TNSNAMES%

  	goto EndScript



:EndScript
pause



