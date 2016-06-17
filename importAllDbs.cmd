@echo off
:: ---------------------------------------------------------
:: Utility to IMPORT all databases into the currently
:: running instance of MySQL/MariaDB from seperate files.
::
:: The steps involved are:
::   Step 1: Ensure required files exist
::   Step 2: Import the database from dump files
::   Step 3: Import the database Users and apply Permissions
::
:: Once this has completed, all your databases, users and
:: permissions are exactly as it was in the old database.
::
:: Copyright (c) 2016 Mark Larsen. All rights reserved.
::
:: Last updated: 2016-06-12 18:10
::
:: ---------------------------------------------------------
set started=%date% %time%
echo Matajas MySQL database Importer v1.0.1
echo.

:step1
echo Step 1. Make sure the required files exist
:: Make sure sql files exist
if not exist dump\*.sql     goto :notFound dump\*.sql
:: Make sure user sql files exist
if not exist .\allUsers.sql goto :notFound allUsers.sql
echo OK, found all required files...
echo.

:step2
echo Step 2. Import each database from a seperate file in the dump directory
for %%i in (dump\*.sql) do call :loadDatabase %%i
echo OK, imported all databases...
echo.

:step3
echo Step 3. Import the Grant commands for each user from .\allUsers.sql
call :loadDatabase .\allUsers.sql

:: Now in a format to add to the database
echo.
echo All Data Imported...
echo.
echo Started : %started%
echo Finished: %date% %time%
echo.
goto :eof

:loadDatabase
echo Importing %1. . .
.\bin\mysql.exe --user=root < %1
goto :eof

:notfound
echo Error can't find %1 files!
pause
