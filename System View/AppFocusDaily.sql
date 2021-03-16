DECLARE @DISPNAME nvarchar(23);
DECLARE @LIFESPANACTION int;
DECLARE @WSQL nvarchar(max);
DECLARE @WSQLJET nvarchar(max);
DECLARE @WSQLSQL nvarchar(max);

SET @DISPNAME = 'AppFocusDaily';
SET @LIFESPANACTION = 2;
SET @WSQL = '';
SET @WSQLJET = '
SELECT
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
       , APP
       , SUM(DATEDIFF(s, SWITCH(DATE_START<=START_TIME, START_TIME, TRUE, DATE_START), SWITCH(END_TIME<DATE_END, END_TIME, TRUE, DATE_END))) AS FOCUS_SEC
FROM
         (
                    SELECT
                               T1.WGUID
                             , WSERVER
                             , SASTRUSER.STRVALUE AS ACCOUNT
                             , SASTRAPP.STRVALUE  AS APP
                             , START_TIME
                             , SWITCH(END_TIME IS NULL, GETUTCDATE(), TRUE, END_TIME) AS END_TIME
                    FROM
                               (( SAAPPFOCUSHIST AS T1
                               INNER JOIN
                                          SAGUIDS
                                          ON
                                                     T1.WGUID = SAGUIDS.WGUID)
                               INNER JOIN
                                          SASTRUSER
                                          ON
                                                     T1.ACCOUNT_ID = SASTRUSER.STRINGID)
                               INNER JOIN
                                          SASTRAPP
                                          ON
                                                     T1.APP_ID = SASTRAPP.STRINGID
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
         START_TIME     < DATE_END
         AND DATE_START < END_TIME
GROUP BY
         WGUID
       , WSERVER
       , ACCOUNT
       , DATE_START
       , APP';
SET @WSQLSQL = '
SELECT
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
       , APP
       , SUM(DATEDIFF(s, CASE
                  WHEN DATE_START<=START_TIME
                           THEN START_TIME
                           ELSE DATE_START
         END, CASE
                  WHEN END_TIME<DATE_END
                           THEN END_TIME
                           ELSE DATE_END
         END)) AS FOCUS_SEC
FROM
         (
                    SELECT
                               T1.WGUID
                             , WSERVER
                             , SASTRUSER.STRVALUE AS ACCOUNT
                             , SASTRAPP.STRVALUE  AS APP
                             , START_TIME
                             , CASE
                                          WHEN END_TIME IS NULL
                                                     THEN GETUTCDATE()
                                                     ELSE END_TIME
                               END AS END_TIME
                    FROM
                               (( SAAPPFOCUSHIST AS T1
                               INNER JOIN
                                          SAGUIDS
                                          ON
                                                     T1.WGUID = SAGUIDS.WGUID)
                               INNER JOIN
                                          SASTRUSER
                                          ON
                                                     T1.ACCOUNT_ID = SASTRUSER.STRINGID)
                               INNER JOIN
                                          SASTRAPP
                                          ON
                                                     T1.APP_ID = SASTRAPP.STRINGID
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
         START_TIME     < DATE_END
         AND DATE_START < END_TIME
GROUP BY
         WGUID
       , WSERVER
       , ACCOUNT
       , DATE_START
       , APP';


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
