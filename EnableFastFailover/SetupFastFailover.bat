@REM Script to create standby instance for dataguard. 
@REM Read the contents of params.txt and put them in variables
@REM alter system set dg_broker_start=true; must be run on each database before this script will work.
for /f "delims== tokens=1,2" %%G in (params.txt) do set %%G=%%H

set PRIMARY=%PRIMARY_DB%
set SECONDARY=%SECONDARY_DB%


@REM Set the log mode to SYNC for both databases;
dgmgrl sys/welcome1@%PRIMARY% "edit database %PRIMARY_DB% set property 'LogXptMode'='SYNC';"
dgmgrl sys/welcome1@%PRIMARY% "edit database %SECONDARY_DB% set property 'LogXptMode'='SYNC';"

pause

@REM Set the database failover target;
dgmgrl sys/welcome1@%PRIMARY% "edit database %PRIMARY_DB% set property FastStartFailoverTarget=%SECONDARY_DB%;"

pause 

@REM Set availability mode to maximum availability;
dgmgrl sys/welcome1@%PRIMARY% "EDIT CONFIGURATION SET PROTECTION MODE AS MAXAVAILABILITY;"

pause

@REM Enable fast start failover
dgmgrl sys/welcome1@%PRIMARY% "enable FAST_START failover;"

pause
@REM Start observor
dgmgrl -silent sys/welcome1@%PRIMARY% "start observer;"

pause