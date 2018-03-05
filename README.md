# SQL Spring Cleaning
Identify unused databases and clean space on your SQL Server

![alt text](https://www.computerhope.com/cdn/colossus.jpg)

How to Install
======

1) First of all we need to create a SQL Server **E-mail Profile** and **Account**; you can follow ![This guide](https://www.mssqltips.com/sqlservertip/1100/setting-up-database-mail-for-sql-server/)

2) You now need to create 2 jobs following ![this guide](https://solutioncenter.apexsql.com/how-to-set-up-email-notifications-for-backup-jobs-in-sql-server/), you can call them as you wish; I usually call them **Email_Date_Ascending** and **Email_Size_Descending**. On each job setup the relative query you find here in attach. 

3) Schedule the job to run monthly or at any date you prefer. 

Done!

The e-mail you will receive will look like this:


    
