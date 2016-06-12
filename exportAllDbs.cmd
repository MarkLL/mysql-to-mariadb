@echo off
:: ---------------------------------------------------------
:: Utility to export all databases from the currently
:: instance of MySQL / MariaDB to seperate files.
::
:: The steps invloved are:
::   Prep 1: Create / Clean out Dump folder
::   Step 1: Export All Non-System databases to Dump folder
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
echo Matajas MySQL database Exporter v1.0.1
echo.
if '%1' EQU '' goto :noPassword
set password=%1

:step1
echo Step 1. Export each database into a seperate file in a 'dump' folder...
::
:: see if it exists; else clear it out
if not exist dump\nul (md dump) else (if exist dump\*.sql del dump\*.sql)

for /f "usebackq" %%i in (`.\bin\mysql.exe --user=root -p%password% --skip-column-names --batch -e "SHOW DATABASES WHERE `Database` not in ('mysql','information_schema','performance_schema','test');"`) do call :getDatabase %%i
echo OK, all databses exported...
echo.

:step2
echo Step 2. construct the Show Grant commands for each user and save to .\allUsers.txt
.\bin\mysql --user=root --password=%password% --batch --skip-column-names -A -e"SELECT CONCAT('SHOW GRANTS FOR ''',user,'''@''',host,''';') FROM mysql.user WHERE user<>''">.\allUsers.txt
echo OK, users exported...
echo.

:step3
echo Step 3. Read in each line allUsers.txt and run mysql to get the Grant commands and output to .\allUsers.sql
if exist zzzUsers.txt del zzzUsers.txt
:: Need to take each line and run command to get individual user privileges
for /f "tokens=*" %%q in (allUsers.txt) do .\bin\mysql --user=root --password=%password% --batch --skip-column-names -e"%%q">>zzzUsers.txt
echo OK, user privileges exported... Wait, Fixing Databse names. . .

:: Now take each line of that output and add a semicolon to the end.
if exist allUsers.sql del allUsers.sql
for /f "tokens=*" %%q in (zzzUsers.txt) do call :fixLine "%%q;"

echo OK, user privileges SQL created...
echo.
:: Don't need the intermediatary file
if exist zzzUsers.txt del zzzUsers.txt

:: Now in a format to add to the database
echo All Data exported OK...
echo.
echo Started : %started%
echo Finished: %date% %time%
echo.
set password=
goto :eof

::------------------------
:fixLine
:: Remove the quotes
set fixed=%~1
:: remove double slashes
set fixed=%fixed:\\=%

echo %fixed%>>allUsers.sql
goto :eof

:getDatabase
echo Exporting %1
.\bin\mysqldump.exe --user=root --password=%password% --result-file=dump/%1.sql --databases %1
goto :eof

:noPassword
echo Error: No databases password supplied.
echo.
echo Usage: %0 ^<Password^>
echo.
echo where ^<Password^> is the password for the 'root' user.
echo.
