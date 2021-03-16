DECLARE @DISPNAME nvarchar(23);
DECLARE @LIFESPANACTION int;
DECLARE @WSQL nvarchar(max);
DECLARE @WSQLJET nvarchar(max);
DECLARE @WSQLSQL nvarchar(max);

SET @DISPNAME = 'WebFocusDaily';
SET @LIFESPANACTION = 2;
SET @WSQL = 
'SELECT
         WGUID
       , GETUTCDATE() AS VWTIME
       , WSERVER
       , ACCOUNT
       , DATEADD(n, (
                SELECT
                       TOP 1 SYTIMEZONE
                FROM
                       SASCFG
         )
         , DATE_START) AS WDATE
       , SITE
       , COUNT(*)       AS ACCESS_COUNT
       , SUM(FOCUS_SEC) AS FOCUS_SEC
FROM
         (
                    SELECT
                               T1.WGUID
                             , WSERVER
                             , SASTRUSER.STRVALUE AS ACCOUNT
                             , SAWEBSTR.STRVALUE  AS SITE
                             , LAST_USE
                             , FOCUSTIMEONPAGE AS FOCUS_SEC
                    FROM
                               (( SAWEB AS T1
                               INNER JOIN
                                          SAGUIDS
                                          ON
                                                     T1.WGUID = SAGUIDS.WGUID)
                               INNER JOIN
                                          SASTRUSER
                                          ON
                                                     T1.ACCOUNT_ID = SASTRUSER.STRINGID)
                               INNER JOIN
                                          SAWEBSTR
                                          ON
                                                     T1.URL = SAWEBSTR.STRINGID
                    WHERE
                               SASTRUSER.STRVALUE NOT LIKE ''% DWM\DWM-%''
         )
         AS T2
       , (
                SELECT
                       DATEADD(n, -1*
                       (
                              SELECT
                                     TOP 1 SYTIMEZONE
                              FROM
                                     SASCFG
                       )
                       , DATEADD(d, -V2.A*6-V1.A-1+DATEDIFF(d, 0, DATEADD(n, (
                              SELECT
                                     TOP 1 SYTIMEZONE
                              FROM
                                     SASCFG
                       )
                       , GETUTCDATE())), 0)) AS DATE_START
                     , DATEADD(n, -1*
                       (
                              SELECT
                                     TOP 1 SYTIMEZONE
                              FROM
                                     SASCFG
                       )
                       , DATEADD(d, -V2.A*6-V1.A+DATEDIFF(d, 0, DATEADD(n, (
                              SELECT
                                     TOP 1 SYTIMEZONE
                              FROM
                                     SASCFG
                       )
                       , GETUTCDATE())), 0)) AS DATE_END
                FROM
                       (
                              SELECT
                                     TOP 1 0 AS A
                              FROM
                                     SASCFG
                              UNION ALL
                              SELECT
                                     TOP 1 1 AS A
                              FROM
                                     SASCFG
                              UNION ALL
                              SELECT
                                     TOP 1 2 AS A
                              FROM
                                     SASCFG
                              UNION ALL
                              SELECT
                                     TOP 1 3 AS A
                              FROM
                                     SASCFG
                              UNION ALL
                              SELECT
                                     TOP 1 4 AS A
                              FROM
                                     SASCFG
                              UNION ALL
                              SELECT
                                     TOP 1 5 AS A
                              FROM
                                     SASCFG
                       )
                       AS V1
                     , (
                              SELECT
                                     TOP 1 0 AS A
                              FROM
                                     SASCFG
                              UNION ALL
                              SELECT
                                     TOP 1 1 AS A
                              FROM
                                     SASCFG
                              UNION ALL
                              SELECT
                                     TOP 1 2 AS A
                              FROM
                                     SASCFG
                              UNION ALL
                              SELECT
                                     TOP 1 3 AS A
                              FROM
                                     SASCFG
                              UNION ALL
                              SELECT
                                     TOP 1 4 AS A
                              FROM
                                     SASCFG
                       )
                       AS V2
         )
         AS T3
WHERE
         DATE_START  <= LAST_USE
         AND LAST_USE < DATE_END
GROUP BY
         WGUID
       , WSERVER
       , ACCOUNT
       , DATE_START
       , SITE';
 SET @WSQLJET = '';
 SET @WSQLSQL = '';


IF (SELECT COUNT(*) FROM SAVIEWS WHERE DISPNAME = @DISPNAME) = 0
BEGIN
	INSERT INTO SAVIEWS
           (VIEWID
           ,DISPNAME
           ,WDESC
           ,WTABLE
           ,WFLAGS
           ,WTYPE
           ,LASTTIME
           ,LIFESPAN
           ,LIFESPANTYPE
           ,LIFESPANACTION
           ,REFRESHTYPE
           ,REFRESHACTION
           ,REFRESH
           ,OVERDUEDAYS
           ,TIMEWINDOW
           ,WSQLGUIDS
           ,WSQL
           ,WSQLJET
           ,WSQLSQL
           ,WSQLORACLE)
     VALUES
           (CASE WHEN (SELECT MAX(VIEWID) FROM SAVIEWS) < 1000000 THEN 1000000 ELSE (SELECT MAX(VIEWID) FROM SAVIEWS) + 1 END
           ,@DISPNAME
           ,''
           ,'VU' + @DISPNAME
           ,64
           ,0
           ,'1899-12-30 00:00:00.000'
           ,30
           ,3
           ,@LIFESPANACTION
           ,0
           ,0
           ,1
           ,0
           ,'24x7'
           ,'SELECT WGUID FROM SAGUIDS'
           ,@WSQL
           ,@WSQLJET
           ,@WSQLSQL
           ,'');
        SELECT
               @DISPNAME + N'を追加しました。' AS MSG
END ELSE BEGIN
	IF (SELECT COUNT(*) FROM SAVIEWS WHERE DISPNAME = @DISPNAME AND LIFESPANACTION = @LIFESPANACTION AND WSQL = @WSQL AND WSQLJET = @WSQLJET AND WSQLSQL = @WSQLSQL) = 0
	BEGIN
		UPDATE SAVIEWS
              SET
                     LIFESPANACTION = @LIFESPANACTION
                     ,WSQL = @WSQL
                     ,WSQLJET = @WSQLJET
                     ,WSQLSQL = @WSQLSQL
              WHERE
                     DISPNAME = @DISPNAME;
              SELECT
				   @DISPNAME + N'を更新しました。' AS MSG
	END ELSE BEGIN
        SELECT
               @DISPNAME + N'は既に存在します。' AS MSG
   END
END
