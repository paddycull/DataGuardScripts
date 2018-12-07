@REM Script to setup standby redo logs and standby Params.


@REM Read the contents of params.txt and put them in variables
for /f "delims== tokens=1,2" %%G in (params.txt) do set %%G=%%H

set ORACLE_SID=%DB_NAME%
sqlplus "/ as sysdba" @CreateStandbyLogs.sql

@ECHO "Ensure commands above ran successfully before continuing"

@ECHO OFF
pause
@ECHO ON

sqlplus "/ as sysdba" @SetStandbyParams.sql
exit

