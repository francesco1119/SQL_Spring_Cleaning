USE [msdb]
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Database Rank by DB Date Ascending',
    @enabled=1, 
    @notify_level_eventlog=0, 
    @notify_level_email=0, 
    @notify_level_netsend=0, 
    @notify_level_page=0, 
    @delete_level=0, 
    @category_name=N'[Uncategorized (Local)]', 
    @owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Get today''s date', 
    @step_id=1, 
    @cmdexec_success_code=0, 
    @on_success_action=1, 
    @on_success_step_id=0, 
    @on_fail_action=2, 
    @on_fail_step_id=0, 
    @retry_attempts=0, 
    @retry_interval=0, 
    @os_run_priority=0, @subsystem=N'TSQL', 
    @command=N'
	
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
					[Name]  AS ''td'','''',
					[db_size] AS ''td'','''',
					[owner] AS ''td'','''',
					[db_id]  AS ''td'','''',
					[created] AS ''td'','''',
					[status] AS ''td'','''',
					[compatibility_level] AS ''td''
					FROM  #Creation_Date_Ascending 
					WHERE db_id > 4
					ORDER BY CONVERT(datetime,created,111) ASC
					FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H2>Database Rank by Creation Date Ascending</H2>
			<H3>This e-mail lists all databases on the server by creation date ascending</H3>
			<H3>Please delete all databases that are no longer in use</H3>
			<table border = 1> 
			<tr>
			<th>Name</th> <th>db_size</th> <th>owner</th> <th>db_id</th> <th>Creation_Date_Ascending</th> <th>status</th> <th>compatibility_level</th></tr>''    

 
SET @body = @body + @xml +''</table></body></html>''

DECLARE @SubjectVariable VARCHAR(250)
set @SubjectVariable = ''Database Rank by DB Date Ascending for Server: '' + @@SERVERNAME + ''''

EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL_Spring_Cleaning_Profile'', -- replace with your SQL Database Mail Profile 
@body = @body,
@body_format =''HTML'',
@recipients = ''francesco84mantovani@gmail.com'', -- replace with your email address
@subject = @SubjectVariable;

DROP TABLE #Creation_Date_Ascending
	
	
	', 
    @database_name=N'master', 
    @flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'First day of month', 
    @enabled=1, 
    @freq_type=16, 
    @freq_interval=1, 
    @freq_subday_type=1, 
    @freq_subday_interval=0, 
    @freq_relative_interval=0, 
    @freq_recurrence_factor=1, 
    @active_start_date=20180312, 
    @active_end_date=99991231, 
    @active_start_time=0, 
    @active_end_time=235959, 
    @schedule_uid=N'7e73cf5c-8036-41a2-af0d-3b2151862684'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO