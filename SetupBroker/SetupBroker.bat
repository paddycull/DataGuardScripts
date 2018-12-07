@REM Script to create standby instance for dataguard. 
@REM Read the contents of params.txt and put them in variables
@REM alter system set dg_broker_start=true; must be run on each database before this script will work.
for /f "delims== tokens=1,2" %%G in (params.txt) do set %%G=%%H

@REM These params are already set with code above, but putting them here for clarity.
set PRIMARY=%PRIMARY_DB%
set SECONDARY=%SECONDARY_DB%
set ORACLE_BASE=%ORACLE_BASE%
set ORACLE_HOME=%ORACLE_HOME%
set PRIMARY_SERVER=%PRIMARY_SERVER%
set SECONDARY_SERVER=%SECONDARY_SERVER%
set PASSWORD=%SYS_PASSWORD%


echo alter system set dg_broker_start=true; > enable_dg_broker.sql

@REM This is so we can enable fast-start failover later;
echo ALTER DATABASE FLASHBACK ON; >> enable_dg_broker.sql
echo exit; >> enable_dg_broker.sql

sqlplus "/@%PRIMARY% as sysdba" @enable_dg_broker.sql
sqlplus "/@%SECONDARY% as sysdba" @enable_dg_broker.sql

dgmgrl sys/%PASSWORD%@%PRIMARY% "CREATE CONFIGURATION dg_config AS PRIMARY DATABASE IS %PRIMARY% CONNECT IDENTIFIER IS %PRIMARY%;"
dgmgrl sys/%PASSWORD%@%PRIMARY% "ADD DATABASE %SECONDARY% AS CONNECT IDENTIFIER IS %SECONDARY% MAINTAINED AS PHYSICAL;"

@REM Setting the StaticConnectIdentifier is needed for failovers - issues can occur if it is not set.
dgmgrl sys/%PASSWORD%@%PRIMARY% "EDIT DATABASE %PRIMARY% set property StaticConnectIdentifier='(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=%PRIMARY_SERVER%)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=%PRIMARY%)(INSTANCE_NAME=%PRIMARY%)(SERVER=DEDICATED)))';"
dgmgrl sys/%PASSWORD%@%PRIMARY% "EDIT DATABASE %SECONDARY% set property StaticConnectIdentifier='(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=%SECONDARY_SERVER%)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=%SECONDARY%)(INSTANCE_NAME=%SECONDARY%)(SERVER=DEDICATED)))';"

@ECHO[
@ECHO[
@ECHO "Enabling configration - this can take a few minutes."
@ECHO[
@ECHO[

dgmgrl sys/%PASSWORD%@%PRIMARY% "ENABLE CONFIGURATION;"

@ECHO[
@ECHO[
@ECHO "Creating standby redo logs."
@ECHO[
@ECHO[

pause

CreateStandbyLogs.bat

@ECHO[
@ECHO[
@ECHO "Restarting standby"
@ECHO[
@ECHO[

pause
echo alter system set standby_file_management=manual; > setup_standby.sql
echo @CreateStandbyLogs.sql >> setup_standby.sql
echo alter system set standby_file_management=auto; > setup_standby.sql
echo shutdown immediate; > setup_standby.sql
echo startup mount; >> setup_standby.sql
echo exit; >> setup_standby.sql

sqlplus "/@%SECONDARY% as sysdba" @setup_standby.sql

pause
