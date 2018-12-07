SET SERVEROUTPUT ON

DECLARE
    thread int;

    cursor c1 is SELECT * from v$log;

    sql_stmnt varchar2(2000);
    redo_location varchar2(100);
    LogSize varchar2(100);
    counter int :=1;
  BEGIN

  Select max(bytes) into LogSize from v$log;

  Select max(thread#) into thread from v$log;

  select DISTINCT SUBSTR(MEMBER, 1, INSTR(MEMBER, '\', -1, 2)) INTO redo_location from v$logfile;

  FOR FIRST_CHANGE# IN c1
  LOOP
  sql_stmnt := 'alter database add standby logfile thread ' || thread || ' (' || '''' || redo_location || 'standby_redo0' || counter || '.log' || '''' || ')' || ' size ' || LogSize;

  dbms_output.put_line(sql_stmnt);
  EXECUTE IMMEDIATE sql_stmnt;

  counter := counter+1;
  END LOOP;

  --one extra addition to ensure there is at least one more standby redo log than online redo logs. 
  sql_stmnt := 'alter database add standby logfile thread ' || thread || ' (' || '''' || redo_location || 'standby_redo0' || counter || '.log' || '''' || ')' || ' size ' || LogSize;
  dbms_output.put_line(sql_stmnt);
  EXECUTE IMMEDIATE sql_stmnt;


  END;
  /
exit;