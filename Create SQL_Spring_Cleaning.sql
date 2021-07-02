DECLARE @YourEmail NVARCHAR(50) SET @YourEmail = 'your@e-mail.com' --Put here your E-mail
DECLARE @YourPassword NVARCHAR(50) SET @YourPassword = 'Your_Password' --Put here your Password
DECLARE @YourSMTPSserver NVARCHAR(50) SET @YourSMTPSserver = 'SMTP.ServerName.com' --Put here your SMTP Server
DECLARE @YourPort INT SET @YourPort = '587' --Put here your SMTP port

-- Create a Database Mail account  
EXECUTE msdb.dbo.sysmail_add_account_sp @account_name = 'SQL_Spring_Cleaning_Account'
	,@description = 'Mail account for SQL_Spring_Cleaning.'
	,@email_address = @YourEmail
	,@replyto_address = @YourEmail
	,@display_name = 'SQL_Spring_Cleaning Mailer'
	,@mailserver_name = @YourSMTPSserver
	,@port = @YourPort
	,@use_default_credentials = 0
	,@username = @YourEmail
	,@password = @YourPassword;

-- Create a Database Mail profile  
EXECUTE msdb.dbo.sysmail_add_profile_sp @profile_name = 'SQL_Spring_Cleaning_Profile'
	,@description = 'Profile used for SQL_Spring_Cleaning mail.';

-- Add the account to the profile  
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp @profile_name = 'SQL_Spring_Cleaning_Profile'
	,@account_name = 'SQL_Spring_Cleaning_Account'
	,@sequence_number = 1;

-- Grant access to the profile to the DBMailUsers role  
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp @profile_name = 'SQL_Spring_Cleaning_Profile'
	,@principal_name = 'public'
	,@is_default = 0;

EXEC msdb.dbo.sysmail_help_account_sp;

-- show advanced options
EXEC sp_configure 'show advanced options'
	,1
GO

RECONFIGURE
GO

-- enable Database Mail XPs
EXEC sp_configure 'Database Mail XPs'
	,1
GO

RECONFIGURE
GO

-- check if it has been changed
EXEC sp_configure 'Database Mail XPs'
GO

-- hide advanced options
EXEC sp_configure 'show advanced options'
	,0
GO

RECONFIGURE
GO

-- create database
USE [msdb];
GO

-- create table
CREATE TABLE [dbo].[ConnectionCounts_Local] (
	[ServerName] [nvarchar](130) NOT NULL
	,[DatabaseName] [nvarchar](130) NOT NULL
	,[NumberOfConnections] [int] NOT NULL
	,[TimeStamp] [datetime] NOT NULL
	,[hostname] [nchar](128) NULL
	,[program_name] [nchar](128) NULL
	,[loginame] [nchar](128) NULL
	);
GO

-- populate table
INSERT INTO [msdb].[dbo].[ConnectionCounts_Local]
SELECT @@ServerName AS [ServerName]
	,NAME AS DatabaseName
	,COUNT(STATUS) AS [NumberOfConnections]
	,GETDATE() AS [TimeStamp]
	,hostname
	,program_name
	,loginame
FROM sys.databases sd
LEFT JOIN master.dbo.sysprocesses sp ON sd.database_id = sp.dbid
WHERE database_id NOT BETWEEN 1
		AND 4
GROUP BY NAME
	,hostname
	,program_name
	,loginame
GO

USE [msdb]
GO

/****** Object:  Job [GatherDbConnections_Local]    Script Date: 02/07/2021 13:57:45 ******/
BEGIN TRANSACTION

DECLARE @ReturnCode INT

SELECT @ReturnCode = 0

/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 02/07/2021 13:57:45 ******/
IF NOT EXISTS (
		SELECT name
		FROM msdb.dbo.syscategories
		WHERE name = N'[Uncategorized (Local)]'
			AND category_class = 1
		)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB'
		,@type = N'LOCAL'
		,@name = N'[Uncategorized (Local)]'

	IF (
			@@ERROR <> 0
			OR @ReturnCode <> 0
			)
		GOTO QuitWithRollback
END

DECLARE @jobId BINARY (16)

EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name = N'GatherDbConnections_Local'
	,@enabled = 1
	,@notify_level_eventlog = 0
	,@notify_level_email = 0
	,@notify_level_netsend = 0
	,@notify_level_page = 0
	,@delete_level = 0
	,@description = N'No description available.'
	,@category_name = N'[Uncategorized (Local)]'
	,@owner_login_name = N'NT SERVICE\SQLSERVERAGENT'
	,@job_id = @jobId OUTPUT

IF (
		@@ERROR <> 0
		OR @ReturnCode <> 0
		)
	GOTO QuitWithRollback

/****** Object:  Step [Step1]    Script Date: 02/07/2021 13:57:45 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId
	,@step_name = N'Step1'
	,@step_id = 1
	,@cmdexec_success_code = 0
	,@on_success_action = 1
	,@on_success_step_id = 0
	,@on_fail_action = 2
	,@on_fail_step_id = 0
	,@retry_attempts = 0
	,@retry_interval = 0
	,@os_run_priority = 0
	,@subsystem = N'TSQL'
	,@command = N'-- populate table
INSERT INTO [msdb].[dbo].[ConnectionCounts_Local]
SELECT @@ServerName AS [ServerName]
	,NAME AS [DatabaseName]
	,COUNT(STATUS) AS [NumberOfConnections]
	,GETDATE() AS [TimeStamp]
	,hostname
	,program_name
	,loginame
FROM sys.databases sd
LEFT JOIN master.dbo.sysprocesses sp ON sd.database_id = sp.dbid
WHERE database_id NOT BETWEEN 1
		AND 4 -- ignore system databases
	--AND state_desc LIKE ''''ONLINE'''' -- ignore offline databases
GROUP BY NAME
	,hostname
	,program_name
	,loginame
GO


-- delete records earlier than 1 year ago
USE [msdb];
GO
DELETE [msdb].[dbo].[ConnectionCounts_Local]
WHERE [TimeStamp] < DATEADD(year, - 1, GETDATE());
GO'
	,@database_name = N'msdb'
	,@flags = 0

IF (
		@@ERROR <> 0
		OR @ReturnCode <> 0
		)
	GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId
	,@start_step_id = 1

IF (
		@@ERROR <> 0
		OR @ReturnCode <> 0
		)
	GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @jobId
	,@name = N'Schedule'
	,@enabled = 1
	,@freq_type = 4
	,@freq_interval = 1
	,@freq_subday_type = 8
	,@freq_subday_interval = 10
	,@freq_relative_interval = 0
	,@freq_recurrence_factor = 0
	,@active_start_date = 20210702
	,@active_end_date = 99991231
	,@active_start_time = 0
	,@active_end_time = 235959
	,@schedule_uid = N'1d0ba0f1-0f71-40b4-82e3-1ce3b712f8b5'

IF (
		@@ERROR <> 0
		OR @ReturnCode <> 0
		)
	GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId
	,@server_name = N'(local)'

IF (
		@@ERROR <> 0
		OR @ReturnCode <> 0
		)
	GOTO QuitWithRollback

COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:

IF (@@TRANCOUNT > 0)
	ROLLBACK TRANSACTION

EndSave:
GO

USE [msdb]
GO

/****** Object:  Job [SQL_Spring_Cleaning_Local]    Script Date: 02/07/2021 14:12:56 ******/
BEGIN TRANSACTION

DECLARE @ReturnCode INT

SELECT @ReturnCode = 0

/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 02/07/2021 14:12:56 ******/
IF NOT EXISTS (
		SELECT name
		FROM msdb.dbo.syscategories
		WHERE name = N'[Uncategorized (Local)]'
			AND category_class = 1
		)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB'
		,@type = N'LOCAL'
		,@name = N'[Uncategorized (Local)]'

	IF (
			@@ERROR <> 0
			OR @ReturnCode <> 0
			)
		GOTO QuitWithRollback
END

DECLARE @jobId BINARY (16)

EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name = N'SQL_Spring_Cleaning_Local'
	,@enabled = 1
	,@notify_level_eventlog = 0
	,@notify_level_email = 0
	,@notify_level_netsend = 0
	,@notify_level_page = 0
	,@delete_level = 0
	,@description = N'No description available.'
	,@category_name = N'[Uncategorized (Local)]'
	,@owner_login_name = N'NT SERVICE\SQLSERVERAGENT'
	,@job_id = @jobId OUTPUT

IF (
		@@ERROR <> 0
		OR @ReturnCode <> 0
		)
	GOTO QuitWithRollback

/****** Object:  Step [Step1]    Script Date: 02/07/2021 14:12:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId
	,@step_name = N'Step1'
	,@step_id = 1
	,@cmdexec_success_code = 0
	,@on_success_action = 1
	,@on_success_step_id = 0
	,@on_fail_action = 2
	,@on_fail_step_id = 0
	,@retry_attempts = 0
	,@retry_interval = 0
	,@os_run_priority = 0
	,@subsystem = N'TSQL'
	,@command = 
	N'DECLARE @xml1 NVARCHAR(MAX)
DECLARE @body1 NVARCHAR(MAX)
DECLARE @xml2 NVARCHAR(MAX)
DECLARE @body2 NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)


SET @xml1 = CAST((	
SELECT 
	[ServerName] AS ''td'','''',
	[DatabaseName] AS ''td'','''',
	sum([NumberOfConnections]) AS ''td'','''',
	max([TimeStamp]) AS ''td'','''',
	[hostname] AS ''td'','''',
	[program_name] AS ''td'','''',
	[loginame] AS ''td'','''' 
	FROM [msdb].[dbo].[ConnectionCounts_Local] 
	where hostname is not NULL
	GROUP BY [ServerName],
	[DatabaseName],
	[hostname],
	[program_name],
	[loginame] 
	ORDER BY sum([NumberOfConnections]) DESC, hostname desc
	FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body1 =''<html><body><H2>SQL_Spring_Cleaning :: Used databases</H2>
			<H3>This e-mail lists all databases that still receive connections</H3>
			<table border = 1> 
			<tr>
			<th>ServerName</th> <th>DatabaseName</th> <th>Number_Of_Connections</th> <th>Last_Connection_Timestamp</th> <th>hostname</th> <th>program_name</th> <th>loginame</th> </tr>''   


SET @xml2 = CAST((	
SELECT [ServerName] AS ''td'','''',
	[DatabaseName] AS ''td'','''',
	CONCAT (
		MAX([NumberOfConnections]),
		+ '' connections since '' + CONVERT(VARCHAR, MIN([TimeStamp]), 1)
		) AS ''td'','''' 
		FROM [msdb].[dbo].[ConnectionCounts_Local] GROUP BY [ServerName],
	[DatabaseName] HAVING MAX([NumberOfConnections]) = 0 ORDER BY [ServerName],
	[DatabaseName]
	FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body2 =''<html><body><H2>SQL_Spring_Cleaning :: Unused databases</H2>
			<H3>This e-mail lists all databases that are not receiving connections</H3>
			<table border = 1> 
			<tr>
			<th>ServerName</th> <th>DatabaseName</th> <th>Number_Of_Connections</th> </tr>''   

 
SET @body = @body1 + @xml1 +''</table></body></html>'' + @body2 + @xml2 +''</table></body></html>''

DECLARE @SubjectVariable VARCHAR(250)
set @SubjectVariable = ''SQL_Spring_Cleaning :: Unused databases for Server: '' + @@SERVERNAME + ''''

EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL_Spring_Cleaning_Profile'', -- replace with your SQL Database Mail Profile 
@body = @body,
@body_format =''HTML'',
@recipients = ''target.email@yourdomain.com'', -- replace with your email address
@subject = @SubjectVariable;'
	,@database_name = N'msdb'
	,@flags = 0

IF (
		@@ERROR <> 0
		OR @ReturnCode <> 0
		)
	GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId
	,@start_step_id = 1

IF (
		@@ERROR <> 0
		OR @ReturnCode <> 0
		)
	GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @jobId
	,@name = N'Schedule'
	,@enabled = 1
	,@freq_type = 4
	,@freq_interval = 1
	,@freq_subday_type = 1
	,@freq_subday_interval = 0
	,@freq_relative_interval = 0
	,@freq_recurrence_factor = 0
	,@active_start_date = 20210702
	,@active_end_date = 99991231
	,@active_start_time = 80000
	,@active_end_time = 235959
	,@schedule_uid = N'f15fee0d-9185-476a-b550-17b17725f800'

IF (
		@@ERROR <> 0
		OR @ReturnCode <> 0
		)
	GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId
	,@server_name = N'(local)'

IF (
		@@ERROR <> 0
		OR @ReturnCode <> 0
		)
	GOTO QuitWithRollback

COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:

IF (@@TRANCOUNT > 0)
	ROLLBACK TRANSACTION

EndSave:
GO

-- Start the 3 jobs to check if everythgin is alright
EXEC dbo.sp_start_job N'GatherDbConnections_Local';
GO

EXEC dbo.sp_start_job N'SQL_Spring_Cleaning_Local';
GO

