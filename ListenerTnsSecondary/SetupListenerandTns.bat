@REM Script to create standby instance for dataguard. 
@REM Read the contents of params.txt and put them in variables
for /f "delims== tokens=1,2" %%G in (params.txt) do set %%G=%%H

set PRIMARY=%PRIMARY_DB%
set SECONDARY=%SECONDARY_DB%
set ORACLE_BASE=%ORACLE_BASE%
set ORACLE_HOME=%ORACLE_HOME%

set LISTENER=%ORACLE_HOME%\network\admin\listener.ora


set /p create_listener="Do you want to automatically create the listener? Choose no if there are other instance on this server. (y/n)"
if "%create_listener%"=="y" goto CreateListener


goto AddEntries


:CreateListener
	@ECHO Creating Listener with default parameters.
	netca -silent -responsefile %ORACLE_HOME%\assistants\netca\netca.rsp

	goto AddEntries

:AddEntries
	set /p add_entries="Do you want to automatically add entries for Primary and Secondary to TNSNAMES and LISTENER files? (y/n)"
	if "%add_entries%" NEQ "y" goto EndScript

	echo Updating...
	pause

	CALL update_tnsnames.bat
	ECHO TNSNAMES updated, updating LISTENER

	@ECHO ON
	ECHO[ >> %LISTENER%
 	ECHO SID_LIST_LISTENER = >> %LISTENER%
  	ECHO (SID_LIST = >> %LISTENER%
  	ECHO   (SID_DESC = >> %LISTENER%
  	ECHO     (GLOBAL_DBNAME = %SECONDARY%) >> %LISTENER%
  	ECHO     (ORACLE_HOME = %ORACLE_HOME%) >> %LISTENER%
  	ECHO     (SID_NAME = %SECONDARY%) >> %LISTENER%
  	ECHO   ) >> %LISTENER%
  	ECHO ) >> %LISTENER%



:EndScript
pause
