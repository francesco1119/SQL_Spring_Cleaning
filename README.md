# SQL Spring Cleaning
Identify unused databases and clean space on your SQL Server

![alt text](https://www.computerhope.com/cdn/colossus.jpg)

How to Install
======

1) Download the query **Create SQL_Spring_Cleaning.sql** and edit the first 4 rows:
   ```
   DECLARE @YourEmail NVARCHAR(50) SET @YourEmail = 'Your_Email' --Put here your E-mail
   DECLARE @YourPassword NVARCHAR(50) SET @YourPassword = 'Your_Password' --Put here your E-mail
   DECLARE @YourSMTPSserver NVARCHAR(50) SET @YourSMTPSserver = 'Your_SMTP_Server' --Put here your SMTP Server
   DECLARE @YourPort int SET @YourPort = 'Your_Port_Number' --Put here your SMTP port
   ```
   Keep in mind that if you are using Outlook, Gmail or any other 2FA e-mail SQL Server will not be able to send e-mails for you.

2) Now edit the line:
   ```
   @recipients = 'YourEmail', -- replace with your email address
   ```
   entering your recipient e-mail address

Done!

The e-mail you will receive will look like this:

#### Email_Date_Ascending

![alt text](https://github.com/francesco1119/SQL_Spring_Cleaning/blob/master/images/DB_Date_Ascending.png)

#### Email_Size_Descending

![alt text](https://github.com/francesco1119/SQL_Spring_Cleaning/blob/master/images/DB_Size_Descending.png)

How to Clean in case you made bubu
======

Download the query **Delete SQL_Spring_Claeaning.sql** and run it. 

This query delete your E-mail Account and Profile and both stored procedure
    
