DECLARE @YourEmail NVARCHAR(50) SET @YourEmail = 'my-email@address.com' --Put here your E-mail
DECLARE @YourPassword NVARCHAR(50) SET @YourPassword = 'MyPassword' --Put here your E-mail
DECLARE @YourSMTPSserver NVARCHAR(50) SET @YourSMTPSserver = 'SMTP.account.com' --Put here your SMTP Server
DECLARE @YourPort int SET @YourPort = 'port here' --Put here your SMTP port

-- Create a Database Mail account  
EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'SQL_Spring_Cleaning_Account',  
    @description = 'Mail account for SQL_Spring_Cleaning.',  
    @email_address = @YourEmail,  
    @replyto_address = @YourEmail,
	@display_name = 'SQL_Spring_Cleaning Mailer',  
    @mailserver_name = @YourSMTPSserver, 
	@port = @YourPort,
	@use_default_credentials = 0,
	@username = @YourEmail,
	@password = @YourPassword;


-- Create a Database Mail profile  
EXECUTE msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'SQL_Spring_Cleaning_Profile',  
    @description = 'Profile used for SQL_Spring_Cleaning mail.' ; 

-- Add the account to the profile  
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'SQL_Spring_Cleaning_Profile',  
    @account_name = 'SQL_Spring_Cleaning_Account',  
    @sequence_number =1 ; 

-- Grant access to the profile to the DBMailUsers role  
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp  
    @profile_name = 'SQL_Spring_Cleaning_Profile',  
    @principal_name = 'public',  
    @is_default = 0; 

EXEC msdb.dbo.sysmail_help_account_sp;

-- show advanced options
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
 
-- enable Database Mail XPs
EXEC sp_configure 'Database Mail XPs', 1
GO
RECONFIGURE
GO
 
-- check if it has been changed
EXEC sp_configure 'Database Mail XPs'
GO
 
-- hide advanced options
EXEC sp_configure 'show advanced options', 0
GO
RECONFIGURE
GO
