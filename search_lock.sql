-- ロック状況を把握
select
    V$SESSION.SID      as SID
   ,V$SESSION.USERNAME as USERNAME
   ,V$SESSION.OSUSER   as OSUSER
   ,V$SESSION.SERIAL#  as SERIAL_NO
   ,V$SESSION.MACHINE  as MACHINE
   ,V$SESSION.PROGRAM  as PROGRAM
   ,V$LOCK.TYPE        as LOCK_TYPE
   ,V$LOCK.ID1         as ID1
   ,V$LOCK.ID2         as ID2
   ,TO_CHAR(V$LOCK.CTIME / 60,'999990.9') as LOCK_TIME
   ,case V$LOCK.LMODE
        when 0 then 'NONE'
        when 1 then 'NULL'
        when 2 then '  RS'
        when 3 then '  RX'
        when 4 then '   S'
        when 5 then ' SRX'
        when 6 then '   X'
               else '   ?' end as HELD
   ,case V$LOCK.REQUEST
        when 0 then 'NONE'
        when 1 then 'NULL'
        when 2 then '  RS'
        when 3 then '  RX'
        when 4 then '   S'
        when 5 then ' SRX'
        when 6 then '   X'
               else '   ?' end as REQUESTED
from V$SESSION
    inner join V$LOCK on V$SESSION.SID = V$LOCK.SID
where
    V$SESSION.USERNAME like upper('%%')
order by
    V$SESSION.SID
   ,V$LOCK.TYPE
;

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
