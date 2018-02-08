@ECHO OFF
COLOR 0A
TITLE Stored Procedures Performance Testing
MODE con cols=140 lines=200
ECHO #--------------------------------------------------------------------------------------------#
ECHO #                            Stored Procedures Performance Testing                           #
ECHO #--------------------------------------------------------------------------------------------#
ECHO # Description :                                                                              #
ECHO # You should specify the database info in the following files:                               #
ECHO # 1. .\TestCases\PDBC\conf\db.json                                                           #
ECHO # 2. .\run.bat                                                                               #
ECHO #--------------------------------------------------------------------------------------------#


REM %1 HostName
REM %2 DATABASENAMEName
REM %3 USERNAMEName
REM %4 Password


SET HOSTNAME=""
SET USERNAME=""
SET PASSWORD=""
SET DATABASENAME=""


IF %HOSTNAME%=="" SET /p HOSTNAME=Please enter the host name (Format:[Hostname OR IP][,PORT]):
IF %DATABASENAME%=="" SET /p DATABASENAME=Please enter the database name:
IF %USERNAME%=="" SET /p USERNAME=Please enter the user name:
IF %PASSWORD%=="" SET /p PASSWORD=Please enter the password:

cd AspiraFocus
Sqlcmd -S %HOSTNAME% -d %DATABASENAME% -U %USERNAME% -P %PASSWORD% -i .\running_testcases.sql
cd ..
python .\AspiraFocusTCs\main.py
PAUSE

REM echo %HOSTNAME%
REM echo %DATABASENAME%
REM echo %USERNAME%
REM echo %PASSWORD%

