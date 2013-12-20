-- ロックをかけているセッションID、ユーザー名、プログラム名、ロックしている時間を取得
select
    V$SESSION.SID      as SID
   ,V$SESSION.USERNAME as USERNAME
   ,V$SESSION.SERIAL#  as SERIAL_NO
   ,V$SESSION.PROGRAM  as PROGRAM
   ,V$LOCK.TYPE        as TYPE
   ,TO_CHAR(V$LOCK.CTIME / 60,'999990.9') as LOCK_TIME
   ,V$SQLAREA.SQL_TEXT as SQL
from V$SESSION
    inner join V$LOCK
        on  V$SESSION.SID = V$LOCK.SID
        and V$LOCK.TYPE IN ('TX','TM')
    inner join V$SQLAREA on V$SESSION.SQL_ADDRESS = V$SQLAREA.ADDRESS
;

-- ロックのため待ちが発生しているセッションID、ユーザー名、プログラム名、待たされている時間
select
    V$SESSION.SID      as SID
   ,V$SESSION.USERNAME as USERNAME
   ,V$SESSION.SERIAL#  as SERIAL_NO
   ,V$SESSION.PROGRAM  as PROGRAM
   ,V$LOCK.TYPE        as TYPE
   ,to_char(V$LOCK.CTIME / 60,'999990.9') as LOCK_TIME
from V$SESSION
    inner join V$LOCK
        on  V$SESSION.SID = V$LOCK.SID
        and V$LOCK.TYPE = 'TM'
        and V$LOCK.SID = (select SID from V$LOCK where TYPE = 'TX' and REQUEST > 0)
;
