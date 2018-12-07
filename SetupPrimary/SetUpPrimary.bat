@REM Script to put primary in archivelog mode and force logging
@REM Read the contents of params.txt and put them in variables
for /f "delims== tokens=1,2" %%G in (params.txt) do set %%G=%%H

set ORACLE_SID=%DB_NAME%
sqlplus "/ as sysdba" @check_mode.sql


@ECHO OFF
@ECHO[
@ECHO[
set /p check_log_mode="Is database already in archivelog mode? Check above output. (y/n)"


IF /I "%check_log_mode%"=="y" goto AlreadyInLogMode
IF /I "%check_log_mode%"=="n" goto NotInLogMode


:AlreadyInLogMode
	@ECHO[
	@ECHO[
	
	
	ECHO Already in log mode. Enabling Force Logging.
	
	@ECHO ON
	sqlplus "/ as sysdba" @force_logging.sql
	@ECHO[
	@ECHO[
	@ECHO "Database now in forcelogging mode."
	@ECHO OFF
	goto EndScript



:NotInLogMode
	
	@ECHO[
	@ECHO[
	
	set /p confirm_restart="Database not in log mode. Do you want to restart in ArchiveLog Mode? (y/n)"
	
	if /I "%confirm_restart%"=="y" goto SetupArchiveLog
	if /I "%confirm_restart%"=="n" goto NotConfirmed
	

	:SetupArchiveLog
		@ECHO ON
		sqlplus "/ as sysdba" @restart_archive_log.sql
		sqlplus "/ as sysdba" @check_mode.sql
		@ECHO[
		@ECHO[
		@ECHO "Database restarted in Archivelog Mode, and Force Logging has been enabled."
		@ECHO OFF
		goto EndScript
	
	:NotConfirmed
		@ECHO[
		@ECHO[
		@ECHO "User did not confirm restart. Exiting script."
		@ECHO OFF
		goto EndScript


goto EndScript

:EndScript
	set /p createstandbyredo="Do you want to automatically create the standby redo logs? (y/n)"

	if /I "%createstandbyredo%"=="y" CreateStandbyLogs.bat

	pause