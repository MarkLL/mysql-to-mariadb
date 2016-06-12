@echo off
:: ---------------------------------------------------------
:: Utility to IMPORT all databases into the currently
:: instance of MySQL / MariaDB from seperate files.
::
:: The steps invloved are:
::   Step 1: Ensure required files exist
::   Step 2: Export the databse Users to a file
::   Step 3: Extract Permissions (grants) for each user
::     Note: We need to manipulate the output to ensure we
::     remove the double slashes (\\) that are added
::     in older versions of MySQL. The table name does
::     not contain \\ but the permissions do!
::
:: Once this has completed, ther will be an sql file for
:: each database and also an sql file for permissions.
::
:: Next, start the required database and run import script.
::
:: Copyright (c) 2016 Mark Larsen. All rights reserved.
::
:: Last updated: 2016-06-12 13:35
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
