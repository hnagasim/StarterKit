DECLARE @DISPNAME nvarchar(23);
DECLARE @LIFESPANACTION int;
DECLARE @WSQL nvarchar(max);
DECLARE @WSQLJET nvarchar(max);
DECLARE @WSQLSQL nvarchar(max);

SET @DISPNAME = 'Users10min';
SET @LIFESPANACTION = 1;
SET @WSQL = 
'SELECT
           T2.WGUID
         , GETUTCDATE()                                               AS VWTIME
         , DATEADD(n, CEILING(DATEDIFF(n, 0, T2.WTIME) / 10) * 10, 0) AS WTIME
         , WSERVER
         , ACCOUNT
         , T1.WUSAGE
         , CPU
         , MEMORY
         , IOPS
FROM
           (
           (
                      SELECT
                                 WTIME
                               , S1.STRVALUE AS ACCOUNT
                               , WUSAGE
                               , PRIV_CPU_MIPS + USER_CPU_MIPS AS CPU
                               , MEM_AVG                       AS MEMORY
                               , READ_OPS + WRITE_OPS          AS IOPS
                      FROM
                                 SASYSUSERS AS T1
                                 INNER JOIN
                                            SASTRUSER AS S1
                                            ON
                                                       S1.STRINGID = T1.ACCOUNT_ID
                      WHERE
                                 WTYPE            = 1
                                 AND S1.STRVALUE <> ''SYSTEM\SYSTEM''
                                 AND WTIME       >= ISNULL(<LASTREFRESHTIME>, ''1-1-1900'')
                                 AND WTIME        < GETUTCDATE()
           )
           AS T1
           RIGHT JOIN
                      SASYS AS T2
                      ON
                                 T2.WTIME = T1.WTIME)
           INNER JOIN
                      SAGUIDS AS T3
                      ON
                                 T3.WGUID = T2.WGUID
WHERE
           T2.WTYPE      =1
           AND T2.WTIME >= ISNULL(<LASTREFRESHTIME>, ''1-1-1900'')
           AND T2.WTIME  < GETUTCDATE()';
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
