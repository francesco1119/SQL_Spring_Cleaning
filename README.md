# SQL Spring Cleaning
Identify unused databases and clean space on your SQL Server

![alt text](https://www.computerhope.com/cdn/colossus.jpg)

How to Install
======

1) First of all we need to create a SQL Server **E-mail Profile** and **Account**; you can follow ![This guide](https://www.mssqltips.com/sqlservertip/1100/setting-up-database-mail-for-sql-server/)

2) Download the two queries in attach and on each file modify the lines
    * `@profile_name = 'MyEmailProfile',` -- replace this value with your SQL Database Mail Profile
    * `@recipients = 'myemail@domain.net',` -- replace this value with your email address

3) You now need to create 2 jobs following ![this guide](https://solutioncenter.apexsql.com/how-to-set-up-email-notifications-for-backup-jobs-in-sql-server/), you can call them as you wish; I usually call them **Email_Date_Ascending** and **Email_Size_Descending**. On each job setup the relative query you find here in attach. 

4) Schedule the job to run monthly or at any date you prefer. 

Done!

The e-mail you will receive will look like this:

#### Email_Date_Ascending

![alt text](https://github.com/francesco1119/SQL_Spring_Cleaning/blob/master/images/Creation_Date_Ascending.png)

#### Email_Size_Descending

![alt text](https://github.com/francesco1119/SQL_Spring_Cleaning/blob/master/images/DB_Size_Descending.png)


    
