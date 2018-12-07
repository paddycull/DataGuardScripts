@REM Script to create standby instance for dataguard. 
@REM Read the contents of params.txt and put them in variables
for /f "delims== tokens=1,2" %%G in (params.txt) do set %%G=%%H

set PRIMARY=%PRIMARY_DB%
set SECONDARY=%SECONDARY_DB%
set ORACLE_BASE=%ORACLE_BASE%
set ORACLE_HOME=%ORACLE_HOME%

set TEMP_PFILE_LOC=%ORACLE_BASE%\init%SECONDARY%.ora

@ECHO *.db_name='%PRIMARY%' > %TEMP_PFILE_LOC%
@ECHO *.db_unique_name='%SECONDARY%' >> %TEMP_PFILE_LOC%

@ECHO Temp PFILE %TEMP_PFILE_LOC% created
pause

@ECHO[
@ECHO[

@ECHO "Creating directories if needed..."

if not exist "%ORACLE_BASE%\oradata\%PRIMARY%" mkdir %ORACLE_BASE%\oradata\%PRIMARY%
if not exist "%ORACLE_BASE%\fast_recovery_area\%PRIMARY%" mkdir %ORACLE_BASE%\fast_recovery_area\%PRIMARY%
if not exist "%ORACLE_BASE%\admin\%PRIMARY%\adump" mkdir %ORACLE_BASE%\admin\%PRIMARY%\adump

@ECHO[
@ECHO[

@ECHO "Directories created."
pause

@ECHO[
@ECHO[

@ECHO "Creating password file..."

set /p prim_sys_pwd="Enter SYS password. Ensure this is the same as it is on primary: "
orapwd file=%ORACLE_HOME%\database\PWD%SECONDARY%.ora password=%prim_sys_pwd% entries=10

@ECHO "Password file created."
pause

@ECHO[
@ECHO[


@ECHO "Creating Oracle Service..."
@ECHO[

oradim -new -sid %SECONDARY% -startmode auto -RUNAS %ORA_HOME_USER%/%ORA_HOME_USER_PWD%

@REM sc config OracleService%SECONDARY% start=auto

@ECHO "Service Created"
pause
@ECHO[
@ECHO[

@ECHO "Creating standby database."

@REM Create startup command file with temp pfile file location

ECHO startup nomount pfile='%TEMP_PFILE_LOC%'; > startup_secondary.sql
ECHO exit; >> startup_secondary.sql

ECHO Starting Database, this may take a minute. 
@ECHO[

set ORACLE_SID=%SECONDARY%
sqlplus "/ as sysdba" @startup_secondary.sql

pause;


@REM EDIT THE SET PARAMETERS BELOW IF NEEDED
ECHO DUPLICATE TARGET DATABASE > duplicate_primary.sql
ECHO  FOR STANDBY >> duplicate_primary.sql
ECHO  FROM ACTIVE DATABASE >> duplicate_primary.sql
ECHO  DORECOVER >> duplicate_primary.sql
ECHO  SPFILE >> duplicate_primary.sql
ECHO    SET db_unique_name='%SECONDARY%' COMMENT 'Is standby' >> duplicate_primary.sql
ECHO  NOFILENAMECHECK; >> duplicate_primary.sql
ECHO exit; >> duplicate_primary.sql


rman target sys/%prim_sys_pwd%@%PRIMARY% AUXILIARY sys/%prim_sys_pwd%@%SECONDARY% @duplicate_primary.sql

pause.



