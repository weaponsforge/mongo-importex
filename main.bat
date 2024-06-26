::----------------------------------------------------------
:: Export a mongodb database in binary format.
:: Import a mongodb database (from mongodump).
:: Drop a local database.
:: weaponsforge;20191026
::----------------------------------------------------------

@echo off
GoTo Main


:: Display the main menu, set global constants values
:Main
  :: Database connection credentials
  set "MONGO_HOST="
  set "MONGO_DB="
  set MONGO_PORT=27017
  set "MONGO_USER="
  set "MONGO_PASSWORD="

  :: Legacy MongoDB uses "mongo" shell, newer versions use "mongosh"
  set "MONGO_SHELL=mongosh"

  :: Flag to use the "mongodb+srv://" SRV Connection String URI
  set "USESRV="

  :: User authentication database if using the Standard Connection String "mongo://"
  set "AUTHSOURCE="

  :: Screen ID's
  set /A _ViewDatabaseCredentials=1
  set /A _SetDatabaseCredentials=2
  set /A _ExportDatabase=3
  set /A _SelectDatabaseToImport=4
  set /A PreviousScreen=0
  set /A NextScreen=0

  :: Local temporary files
  set "LOG_FILE=log.txt"
  set "TEMP_USERS_FILE=_users.txt"
  set "LOCAL_USERS_FILE=users.txt"
  set ENV_FILE=%cd%\.env
  echo %ENV_FILE%

  if exist .dbs (
    del /f .dbs
  )

  CALL :DeleteLocalUsersFiles
  GoTo FetchFile
EXIT /B 0


:: View the current saved database connection credentials
:ViewDatabaseCredentials
  CALL :DeleteLocalUsersFiles

  set /A PreviousScreen=_ViewDatabaseCredentials
  cls
  echo ----------------------------------------------------------
  echo VIEWING THE [ACTIVE] MONGODB CONNECTION CREDENTIALS
  echo ----------------------------------------------------------
  echo Database host: %MONGO_HOST%
  echo Database name: %MONGO_DB%
  echo Port: %MONGO_PORT%
  echo User: %MONGO_USER%
  echo Password: %MONGO_PASSWORD%
  echo Mongo Shell: %MONGO_SHELL%
  echo ----------------------------------------------------------
  echo.
  echo [1] Export Database
  echo [2] Import Database
  echo [3] Drop Database
  echo [4] List Databases
  echo [5] List Local Databases
  echo [6] Local DB User: Create
  echo [7] Local DB User: Delete
  echo [8] Local DB User: List
  echo [9] Update Connection Credentials
  echo [10] Mongo Shell
  echo [11] Reset
  echo [x] Exit
  set "choice=-1"
  echo.
  set /p choice="Select option:"

  if %choice% EQU 1 GoTo ExportDatabase
  if %choice% EQU 2 GoTo SelectDatabaseToImport
  if %choice% EQU 3 Goto DeleteDatabase
  if %choice% EQU 4 (
    set /A NextScreen=_ViewDatabaseCredentials
    Goto ShowConnectionDatabases
  )
  if %choice% EQU 5 (
    set /A NextScreen=_ViewDatabaseCredentials
    Goto ShowDatabases
  )
  if %choice% EQU 6 Goto CreateLocalDatabaseUser
  if %choice% EQU 7 Goto DeleteLocalDatabaseUser
  if %choice% EQU 8 Goto ShowLocalDatabaseUsers
  if %choice% EQU 9 Goto SetDatabaseCredentials
  if %choice% EQU 10 Goto EnterMongoShell
  if %choice% EQU 11 Goto ResetData
  if %choice% == x EXIT /B 0

  Goto ViewDatabaseCredentials
EXIT /B 0


:: Export (mongodump) the target database using current db credentials
:ExportDatabase
  set "continue="
  set /p continue=Are you ready to start the database export? [Y/n]:

  (if "%continue%" == "Y" (
    CALL :ConfirmUseSrv
  ))

  :: Export the database given the connection
  echo.%continue% | findstr /C:"Y">nul && (
    echo Starting database export...

    echo.%USESRV% | findstr /C:"Y">nul && (
      mongodump --uri mongodb+srv://%MONGO_USER%:%MONGO_PASSWORD%@%MONGO_HOST%/%MONGO_DB% -o %cd%
    ) || (
      (if %MONGO_PORT% EQU 20717 (
        mongodump -h %MONGO_HOST% -d %MONGO_DB% -u %MONGO_USER% -p %MONGO_PASSWORD% -o %cd%
      ) else (
        mongodump --host %MONGO_HOST% --port %MONGO_PORT% -d %MONGO_DB% -u %MONGO_USER% -p %MONGO_PASSWORD% -o %cd%
      ))
    )

    Goto HandleFinish
  ) || (
    if %PreviousScreen% EQU %_ViewDatabaseCredentials% (
      GoTo FetchFile
    ) else if %PreviousScreen% EQU %_SetDatabaseCredentials% (
      GoTo SetDatabaseCredentials
    )
  )
EXIT /B 0


:: Select a database to import
:SelectDatabaseToImport
  cls
  echo ----------------------------------------------------------
  echo AVAILABLE DATABASES TO IMPORT
  echo ----------------------------------------------------------
  set /A count=0
  (for /d %%D in (*) do (
    set /A count += 1
    set DB[count]=%%D
    echo [!count!] %%D
  ))

  echo.
  echo (!count!) directories are available for import.

  set "db=-"
  echo Enter the name of the database you want to import.
  set /p db=Type "x" to Exit:

  if %db% EQU x (
    if exist %ENV_FILE% (
      GoTo FetchFile
    ) else (
      GoTo SetDatabaseCredentials
    )
  ) else if %db% NEQ - (
    GoTo ImportDatabase
  ) else (
    GoTo SelectDatabaseToImport
  )
EXIT /B 0


:: Import (mongorestore) the selected database to the target
:ImportDatabase
  echo  --selected [%db%]
  echo ----------------------------------------------------------
  echo CURRENT DATABASE CONNECTION
  echo  - Host: %MONGO_HOST%
  echo  - Database name: %MONGO_DB%
  echo  - Port: %MONGO_PORT%
  echo  - User: %MONGO_USER%
  echo  - Password: %MONGO_PASSWORD%

  set "con="
  echo Are you sure you want to import [%db%]
  set /p con=to the above database server? [Y/n]:

  (if "%con%" == "Y" (
    CALL :ConfirmUseSrv
  ))

  echo.%con% | findstr /C:"Y">nul && (
    echo Starting database import...

    echo.%USESRV% | findstr /C:"Y">nul && (
      mongorestore --uri mongodb+srv://%MONGO_USER%:%MONGO_PASSWORD%@%MONGO_HOST%/%MONGO_DB% %cd%\%db%
    ) || (
      (if %MONGO_PORT% EQU 20717 (
        mongorestore -h %MONGO_HOST% -d %MONGO_DB% -u %MONGO_USER% -p %MONGO_PASSWORD% %cd%\%db%
      ) else (
        mongorestore --host %MONGO_HOST% --port %MONGO_PORT% -d %MONGO_DB% -u %MONGO_USER% -p %MONGO_PASSWORD% %cd%\%db%
      ))
    )

    Goto HandleFinishImport
  ) || (
    GoTo SelectDatabaseToImport
  )
EXIT /B 0


:: Ask which database to drop. Only local databases can be dropped atm
:DeleteDatabase
  cls
  echo ----------------------------------------------------------
  echo DROP DATABASE
  echo ----------------------------------------------------------
  set "del=-"
  echo Enter the name of the database to drop.
  echo Only local databases (localhost) can be deleted atm.
  set /p del=Type "x" to exit:

  if %del% == x  GoTo ViewDatabaseCredentials
  echo.%del% | findstr [A-Za-z]>nul && (
    GoTo DropDatabase
  ) || (
    GoTo DeleteDatabase
  )
EXIT /B 0


:: Drop a database from the localhost connection.
:: Only local databases can be dropped atm
:DropDatabase
  echo.
  echo ----------------------------------------------------------
  echo CURRENT DATABASE CONNECTION
  echo  - Host: %MONGO_HOST%
  echo  - Database to drop: %del%
  echo  - Port: %MONGO_PORT%
  echo  - User: %MONGO_USER%
  echo  - Password: %MONGO_PASSWORD%

  set "con="
  echo Are you sure you want to drop [%del%]
  set /p con=from the above database server? [Y/n]:

  echo.%con% | findstr /C:"Y">nul && (
    echo.
    if %MONGO_HOST% NEQ localhost (
      echo Only local databases can be dropped atm.
      set /p go=Update your database credentials to localhost and try again.
    ) else (
      echo Dropping database...
      %MONGO_SHELL% --eval "printjson(db.adminCommand( { listDatabases: 1, nameOnly:true } ))" > .dbs

      echo. | findstr /C:%del% .dbs && (
        %MONGO_SHELL% %del% --eval "db.dropDatabase()"
        CALL :DeleteLocalDatabaseUsers %del%

        set /A NextScreen=_ViewDatabaseCredentials
        GoTo ShowDatabases
      ) || (
        echo Database [%del%] was not found.
        set /p go=Press enter to continue...
      )
    )
  )

  GoTo ViewDatabaseCredentials
EXIT /B 0


:: Set the mongodb database connection credentials
:SetDatabaseCredentials
  set /A PreviousScreen=_SetDatabaseCredentials
  set /A NextScreen=0
  cls
  echo ----------------------------------------------------------
  echo MONGODB CONNECTION CREDENTIALS SETUP
  echo ----------------------------------------------------------
  echo [1] Enter database host: %MONGO_HOST%
  echo [2] Enter database name: %MONGO_DB%
  echo [3] Enter port: %MONGO_PORT%
  echo [4] Enter user: %MONGO_USER%
  echo [5] Enter password: %MONGO_PASSWORD%
  echo [6] Enter the active mongodb shell "mongo or mongosh": %MONGO_SHELL%
  echo [7] Save
  echo [8] Save and Export Database
  echo [9] Save and Import Database
  echo [10] Export Database
  echo [11] Import Database
  echo [x] Exit
  set "choice=-1"
  echo.
  set /p choice="Select option:"

  :: Encode database credentials
  if %choice% EQU 1 set /p MONGO_HOST="Enter database host:"
  if %choice% EQU 2 set /p MONGO_DB="Enter database name:"
  if %choice% EQU 3 set /p MONGO_PORT="Enter port:"
  if %choice% EQU 4 set /p MONGO_USER="Enter mongodb user:"
  if %choice% EQU 5 set /p MONGO_PASSWORD="Enter password:"
  if %choice% EQU 6 set /p MONGO_SHELL="Enter the active mongodb shell (required):"

  :: Save the current database credentials displayed on this screen
  if %choice% EQU 7 (
    echo.
    set /p go=[INFO] New data has been saved.
    set /A NextScreen=_ViewDatabaseCredentials
    Goto SaveData
  )

  :: Export database (and save credentials)
  if %choice% EQU 8 (
    set /A NextScreen=_ExportDatabase
    echo.
    echo [INFO] New data has been saved.
    GoTo SaveData
  )

  :: Import database (and save credentials)
  if %choice% EQU 9 (
    set /A NextScreen = _SelectDatabaseToImport
    echo.
    set /p go=[INFO] New data has been saved.
    GoTo SaveData
  )

  :: Export database
  if %choice% EQU 10 (
    echo.
    echo [WARNING] Data has not yet been saved.
    GoTo ExportDatabase
  )

  :: Import database
  if %choice% EQU 11 (
    echo.
    set /p go=[WARNING] Data has not yet been saved.
    GoTo SelectDatabaseToImport
  )

  :: Exit
  if %choice% == x (
    if exist %ENV_FILE% (
      Goto FetchFile
    ) else (
      echo.
      echo Is highly recommended to enter and save database
      set /p go=connection credentials [1-6] to cache for future use.
      EXIT /B 0
    )
  )

  GoTo SetDatabaseCredentials
EXIT /B 0


:: Creates a local database user for a local database
:: The local database may or may not yet exist
:CreateLocalDatabaseUser
  setlocal enabledelayedexpansion

  cls
  echo ----------------------------------------------------------
  echo CREATE LOCAL DATABASE USER
  echo ----------------------------------------------------------

  set "databaseName="
  set "databaseUser="
  set "userPassword="

  set /p databaseName="Enter the database name:"
  set /p databaseUser="Enter the database user:"
  set /p userPassword="Enter the database user password:"
  echo.

  echo Do you want to create a local database user
  echo on host [%MONGO_HOST%], database [%databaseName%]?
  echo  - Database: %databaseName%
  echo  - User: %databaseUser%
  echo  - Passsword: %userPassword%
  echo.

  set "continue=Y"
  echo Press enter to continue
  set /p continue=Type "n" and press enter to cancel:

  if %continue% EQU n (
    set "retry=Y"
    set /p retry="Retry? [Y/n]:"

    if /i "!retry!"=="n" (
      GoTo ViewDatabaseCredentials
    ) else (
      GoTo CreateLocalDatabaseUser
    )
  ) else (
    (if %MONGO_HOST% EQU localhost (
      echo Creating local database user [!databaseUser!]...
      %MONGO_SHELL% !databaseName! --eval "db.createUser({user: '!databaseUser!' , pwd: '!userPassword!', roles: [{ role: 'readWrite', db: '!databaseName!' }]})"

      echo Success!
      CALL :ListLocalDatabaseUsers !databaseName!

      set /p go=Press enter to continue...
      GoTo ViewDatabaseCredentials
    ))
  )
EXIT /B 0


:: Deletes a local database user from a local database
:DeleteLocalDatabaseUser
  cls
  echo ----------------------------------------------------------
  echo DELETE A LOCAL DATABASE USER
  echo ----------------------------------------------------------
  set "databaseName="
  set "databaseUser="

  set /p databaseName="Enter the database name:"
  set /p databaseUser="Enter the database user:"
  echo.

  %MONGO_SHELL% %databaseName% --eval "db.dropUser('%databaseUser%')" > %LOG_FILE%

  findstr /C:"ok:" %LOG_FILE% > nul

  if %errorlevel% equ 0 (
    echo Success! User [%databaseUser%] deleted.
  ) else (
    echo Error deleting user
  )

  set /p go=Press enter to continue...
  GoTo ViewDatabaseCredentials
EXIT /B 0


:: Deletes all database users of a given local database
:DeleteLocalDatabaseUsers
  setlocal enabledelayedexpansion
  set "dbName=%~1"

  CALL :ListLocalDatabaseUsers %dbName%

  if exist %LOCAL_USERS_FILE% (
    (for /f "tokens=*" %%a in (%LOCAL_USERS_FILE%) do (
      for /f "tokens=2 delims='" %%u in ("%%a") do (
        echo Deleting user: %%u
        %MONGO_SHELL% %dbName% --eval "db.dropUser('%%u')"
      )
    ))
  )

  set /p go=Press enter to continue...
EXIT /B 0


:: Lists the local database users of a given local database
:ListLocalDatabaseUsers
  setlocal enabledelayedexpansion
  set "dbName=%~1"

  %MONGO_SHELL% %dbName% --eval "db.getUsers()" > %TEMP_USERS_FILE%
  findstr /C:user: %TEMP_USERS_FILE% > %LOCAL_USERS_FILE%

  if exist %LOCAL_USERS_FILE% (
    echo.
    echo ----------------------------------------------------------
    echo Available LOCAL users on localhost database [%dbName%]:

    (for /f "tokens=*" %%a in (%LOCAL_USERS_FILE%) do (
      for /f "tokens=2 delims='" %%u in ("%%a") do (
        echo  - User: %%u
      )
    ))
  )
EXIT /B 0


:: Prompt local database name for listing its local users
:ShowLocalDatabaseUsers
  cls
  echo ----------------------------------------------------------
  echo LIST LOCAL DATABASE USERS
  echo ----------------------------------------------------------

  set "databaseName="
  set /p databaseName="Enter the database name:"
  echo.

  set "continue=Y"
  echo Press enter to continue
  set /p continue=Type "n" and press enter to cancel:

  if %continue% EQU n (
    set "retry=Y"
    set /p retry="Retry? [Y/n]:"

    if /i "!retry!"=="n" (
      GoTo ViewDatabaseCredentials
    ) else (
      GoTo ShowLocalDatabaseUsers
    )
  ) else (
    CALL :ListLocalDatabaseUsers !databaseName!

    set /p go=Press enter to continue...
    GoTo ViewDatabaseCredentials
  )
EXIT /B 0


:: Starts a mongodb shell (mongosh) that connects to a local or remote database
:: using the stored database connection credentials file
:EnterMongoShell
  cls
  echo ----------------------------------------------------------
  echo CURRENT DATABASE CONNECTION

  if %MONGO_HOST% EQU localhost (
    echo  - Host: %MONGO_HOST%
    echo  - Database name: %MONGO_DB%
    echo  - Port: %MONGO_PORT%
    echo.

    set "continue=Y"
    echo Press enter to connect to the LOCAL database
    set /p continue=Type "n" and press enter to cancel:

    if !continue! EQU Y (
      %MONGO_SHELL% %MONGO_DB%
    )
  ) else (
    echo  - Host: %MONGO_HOST%
    echo  - Database name: %MONGO_DB%
    echo  - Port: %MONGO_PORT%
    echo  - User: %MONGO_USER%
    echo  - Password: %MONGO_PASSWORD%
    echo.

    set "continue=Y"
    echo Press enter to connect to the REMOTE database
    set /p continue=Type "n" and press enter to cancel:

    if !continue! EQU Y (
      echo connecting to remote...
      %MONGO_SHELL% mongodb+srv://%MONGO_USER%:%MONGO_PASSWORD%@%MONGO_HOST%/%MONGO_DB%
    )
  )

  set /p go=Press enter to continue...
  GoTo ViewDatabaseCredentials
EXIT /B 0


::----------------------------------------------------------
::  Utility helper scripts
::----------------------------------------------------------


:: Read the temporary file where the current database
:: connection credentials are saved
:FetchFile
  setlocal enabledelayedexpansion

  :: Reset values
  set /A index=0
  set /A PreviousScreen=0
  set /A NextScreen=0

  if exist .dbs (
    del /f .dbs
  )

  if exist %ENV_FILE% (
    (for /f "tokens=*" %%a in (%ENV_FILE%) do (
      set /A index += 1
      (if !index! EQU 1 (
        set MONGO_HOST=%%a
      ) else if !index! EQU 2 (
        set MONGO_DB=%%a
      ) else if !index! EQU 3 (
        set MONGO_PORT=%%a
      ) else if !index! EQU 4 (
        set MONGO_USER=%%a
      ) else if !index! EQU 5 (
        set MONGO_PASSWORD=%%a
      ) else if !index! EQU 6 (
        set MONGO_SHELL=%%a
      ))
    ))

    GoTo ViewDatabaseCredentials
  ) else (
    GoTo SetDatabaseCredentials
  )
EXIT /B 0


:: Save (cache) new values for the database credentials
:SaveData
  set hasblank=false
  if "%MONGO_HOST%"=="" set hasblank=true
  if "%MONGO_DB%"=="" set hasblank=true
  if "%MONGO_PORT%"=="" set hasblank=true
  if "%MONGO_USER%"=="" set hasblank=true
  if "%MONGO_PASSWORD%"=="" set hasblank=true
  if "%MONGO_SHELL%"=="" set hasblank=true

  if %hasblank% == true (
    echo Error saving, please check your input.
    set /p go=All items must have a value.
    Goto SetDatabaseCredentials
  )

  :: Delete cache
  if exist %ENV_FILE% (
    del %ENV_FILE%
  )

  :: Save new values and proceed to next screen
  echo %MONGO_HOST%>>%ENV_FILE%
  echo %MONGO_DB%>>%ENV_FILE%
  echo %MONGO_PORT%>>%ENV_FILE%
  echo %MONGO_USER%>>%ENV_FILE%
  echo %MONGO_PASSWORD%>>%ENV_FILE%
  echo %MONGO_SHELL%>>%ENV_FILE%

  GoTo RenderNextScreen
EXIT /B 0


:: Delete the cached database credentials data
:ResetData
  set /p go=Are you sure you want to reset the saved database credentials? [Y/n]:

  echo.%go% | findstr /C:"Y">nul && (
    :: Delete cache
    if exist %ENV_FILE% (
      del %ENV_FILE%
    )

    set "MONGO_HOST="
    set "MONGO_DB="
    set MONGO_PORT=27017
    set "MONGO_USER="
    set "MONGO_PASSWORD="
    set "MONGO_SHELL="
  )

  GoTo FetchFile
EXIT /B 0


:: Lists available databases (on localhost only)
:ShowDatabases
  %MONGO_SHELL% --eval "printjson(db.adminCommand( { listDatabases: 1, nameOnly:true } ))" > .dbs

  echo.
  echo ----------------------------------------------------------
  echo Available LOCAL databases (on localhost only):
  findstr /C:name .dbs

  set /p go=Press enter to continue...
  GoTo RenderNextScreen
EXIT /B 0


:: Lists available databases from the defined active connection credentials
:: - when using the SRV Connection String (mongo+srv://) or,
:: - when using the Standalone Connection String (mongo://) if prompted for an authentication database
:ShowConnectionDatabases
  CALL :ConfirmUseSrv

  :: Prompt for an authentication database if not using "mongo+srv://"
  (if NOT "%USESRV%" == "Y" (
    CALL :SetAuthSource

    echo.!AUTHSOURCE! | findstr [A-Za-z]>nul && (
      echo Selected [!AUTHSOURCE!] for the authentication database.
    ) || (
      echo.
      echo Error: Connecting using the standard connection string
      set /p go=requires the user's authentication database. Try again.
      GoTo RenderNextScreen
    )
  ))

  (if "%USESRV%" == "Y" (
    %MONGO_SHELL% mongodb+srv://%MONGO_USER%:%MONGO_PASSWORD%@%MONGO_HOST% --eval "printjson(db.adminCommand( { listDatabases: 1, nameOnly:true } ))" > .dbs
  ) else (
    %MONGO_SHELL% mongodb://%MONGO_USER%:%MONGO_PASSWORD%@%MONGO_HOST%:%MONGO_PORT%/?authSource=!AUTHSOURCE! --eval "printjson(db.adminCommand( { listDatabases: 1, nameOnly:true } ))" > .dbs
  ))

  echo.
  echo ----------------------------------------------------------
  echo Host: %MONGO_HOST%
  echo Available databases:
  findstr /C:name .dbs

  set /p go=Press enter to continue...
  GoTo RenderNextScreen
EXIT /B 0


:: Display a success notification
:HandleFinish
  echo.
  echo Database export has finished.
  echo [%MONGO_DB%] is saved to %cd%\%MONGO_DB%
  echo if the process finished without errors.
  set /p go=Press enter to continue...
  GoTo FetchFile
EXIT /B 0


:: Display a success notification
:HandleFinishImport
  echo.
  echo Database import has finished.
  echo [%db%] has been imported to %MONGO_DB%
  echo if the process finished without errors.
  set /p go=Press enter to continue...
  GoTo FetchFile
EXIT /B 0


:: Teleport to the next assigned screen
:RenderNextScreen
  if %NextScreen% EQU %_ExportDatabase% (
    GoTo ExportDatabase
  ) else if %NextScreen% EQU %_SelectDatabaseToImport% (
    GoTo SelectDatabaseToImport
  ) else if %NextScreen% EQU %_SetDatabaseCredentials% (
    GoTo SetDatabaseCredentials
  ) else if %NextScreen% EQU %_ViewDatabaseCredentials% (
    GoTo ViewDatabaseCredentials
  )
EXIT /B 0


:: Prompt to confirm using the "mongodb+srv://" URI connection string
:ConfirmUseSrv
  echo.
  set "USESRV="
  echo Do you want to use the mongodb+srv:// connection string?
  set /p USESRV=Tip: select mongodb+srv:// when interacting with Atlas databases [Y/n]:
EXIT /B 0

:SetAuthSource
  echo.
  set "AUTHSOURCE="
  set /p AUTHSOURCE="Enter the user authentication database:"
EXIT /B 0


:: Deletes the local database users list file
:DeleteLocalUsersFiles
  if exist %LOCAL_USERS_FILE% (
    del /f %LOCAL_USERS_FILE%
  )

  if exist %TEMP_USERS_FILE% (
    del /f %TEMP_USERS_FILE%
  )

  if exist %LOG_FILE% (
    del /f %LOG_FILE%
  )
EXIT /B 0