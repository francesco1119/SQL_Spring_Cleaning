

CREATE TABLE #Creation_Date_Ascending (
	[Name] [nvarchar](128), 
	[db_size] [nvarchar](50),
	[owner] [nvarchar](128),
	[db_id] [int],
	[created] [varchar](128),
	[status] [nvarchar](2000),
	[compatibility_level] [int]
)

INSERT INTO #Creation_Date_Ascending EXEC sp_helpdb

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)


SET @xml = CAST((	SELECT 
					[Name]  AS 'td','',
					[db_size] AS 'td','',
					[owner] AS 'td','',
					[db_id]  AS 'td','',
					[created] AS 'td','',
					[status] AS 'td','',
					[compatibility_level] AS 'td'
					FROM  #Creation_Date_Ascending 
					ORDER BY CONVERT(datetime,created,111) ASC
					FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))


SET @body ='<html><body><H3>Database Rank by Creation_Date_Ascending</H3>
			<table border = 1> 
			<tr>
			<th>Name</th> <th>db_size</th> <th>owner</th> <th>db_id</th> <th>Creation_Date_Ascending</th> <th>status</th> <th>compatibility_level</th></tr>'    

 
SET @body = @body + @xml +'</table></body></html>'


EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'FrancescoEmailProfile', -- replace with your SQL Database Mail Profile 
@body = @body,
@body_format ='HTML',
@recipients = 'francesco84mantovani@gmail.com', -- replace with your email address
@subject = 'Database Rank by DB size Descending' ;


DROP TABLE #Creation_Date_Ascending

--select Product_strCode,  Product_strVersion,  Product_strBuild  from VISTAMikeL.dbo.tblProduct