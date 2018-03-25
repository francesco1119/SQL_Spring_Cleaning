

EXECUTE msdb.dbo.sysmail_delete_profile_sp  
    @profile_name = 'SQL_Spring_Cleaning_Profile' ;  

EXECUTE msdb.dbo.sysmail_delete_account_sp  
    @account_name = 'SQL_Spring_Cleaning_Account' ;  

EXEC sp_delete_job  
    @job_name = N'Database Rank by DB Date Ascending' ;  

EXEC sp_delete_job  
    @job_name = N'Database Rank by DB size Descending' ;  
  
  
