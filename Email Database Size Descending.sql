

CREATE TABLE #DB_Size_Descending (
	[Name] [nvarchar](128), 
	[DB_Size_Descending] [nvarchar](50),
	[owner] [nvarchar](128),
	[db_id] [int],
	[created] [varchar](128),
	[status] [nvarchar](2000),
	[compatibility_level] [int]
)

INSERT INTO #DB_Size_Descending EXEC sp_helpdb

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)


SET @xml = CAST((	SELECT 
					[Name]  AS 'td','',
					[DB_Size_Descending] AS 'td','',
					[owner] AS 'td','',
					[db_id]  AS 'td','',
					[created] AS 'td','',
					[status] AS 'td','',
					[compatibility_level] AS 'td'
					FROM  #DB_Size_Descending 
					ORDER BY CONVERT (DECIMAL, REPLACE (DB_Size_Descending, 'MB', '')) DESC
					FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))


SET @body ='<html><body><H2>Database Rank by DB size Descending</H2>
			<H3>This e-mail lists all databases on the server by size descending</H3>
			<H3>Please delete all databases that are no longer in use</H3>
			<table border = 1> 
			<tr>
			<th>Name</th> <th>DB_Size_Descending</th> <th>owner</th> <th>db_id</th> <th>created</th> <th>status</th> <th>compatibility_level</th></tr>'    

 
SET @body = @body + @xml +'</table></body></html>'


EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'MonthlySQlSpringClean', -- replace with your SQL Database Mail Profile 
@body = @body,
@body_format ='HTML',
@recipients = 'YourEmail', -- replace with your email address
@subject = 'Database Rank by DB size Descending' ;


DROP TABLE #DB_Size_Descending
