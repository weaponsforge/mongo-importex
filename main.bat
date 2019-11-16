::----------------------------------------------------------
:: Export a mongodb database in binary format.
:: Import a mongodb database (from mongodump).
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

  :: Screen ID's
  set /A _ViewDatabaseCredentials=1
  set /A _SetDatabaseCredentials=2
  set /A _ExportDatabase=3
  set /A _SelectDatabaseToImport=4
  set /A PreviousScreen=0
  set /A NextScreen=0

  set tempfile=%cd%\.tempfile
  echo %tempfile%

  GoTo FetchFile
EXIT /B o


:: Read the temporary file where the current database
:: connection credentials are saved
:FetchFile
  setlocal enabledelayedexpansion

  :: Reset values
  set /A index=0
  set /A PreviousScreen=0
  set /A NextScreen=0

  if exist %tempfile% (
    (for /f "tokens=*" %%a in (%tempfile%) do (
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
      ))
    ))

    GoTo ViewDatabaseCredentials
  ) else (
    GoTo SetDatabaseCredentials
  )
EXIT /B 0


:: View the current saved database connection credentials
:ViewDatabaseCredentials
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
  echo ----------------------------------------------------------
  echo.
  echo [1] Export Database
  echo [2] Import Database
  echo [3] Update Connection Credentials
  echo [4] Reset Connection Credentials
  echo [x] Exit
  set "choice=-1"
  echo.
  set /p choice="Select option:"


  (if %choice% EQU 1 (
    GoTo ExportDatabase
  ) else if %choice% EQU 2 (
    GoTo SelectDatabaseToImport
  ) else if %choice% EQU 3 (
    Goto SetDatabaseCredentials
  ) else if %choice% EQU 4 (
    Goto ResetData
  ) else if %choice% EQU x (
    EXIT /B 0
  ) else (
    GoTO ViewDatabaseCredentials
  ))
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
  echo [6] Save
  echo [7] Save and Export Database
  echo [8] Save and Import Database
  echo [9] Export Database
  echo [10] Import Database
  echo [x] Exit
  set "choice=-1"
  echo.
  set /p choice="Select option:"

  (if %choice% EQU 1 (
    set /p MONGO_HOST="Enter database host:"
  ) else if %choice% EQU 2 (
    set /p MONGO_DB="Enter database name:"
  ) else if %choice% EQU 3 (
    set /p MONGO_PORT="Enter port:"
  ) else if %choice% EQU 4 (
    set /p MONGO_USER="Enter mongodb user:"
  ) else if %choice% EQU 5 (
    set /p MONGO_PASSWORD="Enter password:"
  ) else if %choice% EQU 6 (
    echo.
    set /p go=[INFO] New data has been saved.
    set /A NextScreen=_ViewDatabaseCredentials
    Goto SaveData
  ) else if %choice% EQU 7 (
    set /A NextScreen=_ExportDatabase
    echo.
    echo [INFO] New data has been saved.
    GoTo SaveData
  ) else if %choice% EQU 8 (
    set /A NextScreen = _SelectDatabaseToImport
    echo.
    set /p go=[INFO] New data has been saved.
    GoTo SaveData
  ) else if %choice% EQU 9 (
    echo.
    echo [WARNING] Data has not yet been saved.
    GoTo ExportDatabase
  ) else if %choice% EQU 10 (
    echo.
    set /p go=[WARNING] Data has not yet been saved.
    GoTo SelectDatabaseToImport
  ) else if %choice% EQU x (
    if exist %tempfile% (
      Goto FetchFile
    ) else (
      echo.
      echo Is highly recommended to enter and save database
      set /p go=connection credentials [1-5] to cache for future use.
      EXIT /B 0
    )
  ))

  GoTo SetDatabaseCredentials
EXIT /B 0


:: Export (mongodump) the target database using current db credentials
:ExportDatabase
  set "continue="
  set /p continue=Are you ready to start the database export? [Y/n]
    
  :: Export the database given the connection
  echo.%continue% | findstr /C:"Y">nul && (
    echo Starting database export...

    (if %MONGO_PORT% EQU 20717 (
      mongodump -h %MONGO_HOST% -d %MONGO_DB% -u %MONGO_USER% -p %MONGO_PASSWORD% -o %cd%
    ) else (
      mongodump --host %MONGO_HOST% --port %MONGO_PORT% -d %MONGO_DB% -u %MONGO_USER% -p %MONGO_PASSWORD% -o %cd%
    ))

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
    if exist %tempfile% (
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
  set /p con=to the above database? [Y/n]:

  echo.%con% | findstr /C:"Y">nul && (
    echo Starting database import...

    (if %MONGO_PORT% EQU 20717 (
      mongorestore -h %MONGO_HOST% -d %MONGO_DB% -u %MONGO_USER% -p %MONGO_PASSWORD% %cd%\%db%
    ) else (
      mongorestore --host %MONGO_HOST% --port %MONGO_PORT% -d %MONGO_DB% -u %MONGO_USER% -p %MONGO_PASSWORD% %cd%\%db%
    ))

    Goto HandleFinishImport
  ) || (
    GoTo SelectDatabaseToImport
  )
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


:: Save (cache) new values for the database credentials
:SaveData
  set hasblank=false
  if "%MONGO_HOST%"=="" set hasblank=true
  if "%MONGO_DB%"=="" set hasblank=true
  if "%MONGO_PORT%"=="" set hasblank=true
  if "%MONGO_USER%"=="" set hasblank=true
  if "%MONGO_PASSWORD%"=="" set hasblank=true

  if %hasblank% == true (
    set /p go=Please check your input. All items must have a value.
    Goto SetDatabaseCredentials
  )

  :: Delete cache
  if exist %tempfile% (
    del %tempfile%
  )

  :: Save new values and proceed to next screen
  echo %MONGO_HOST% >> %tempfile%
  echo %MONGO_DB% >> %tempfile%
  echo %MONGO_PORT% >> %tempfile%
  echo %MONGO_USER% >> %tempfile%
  echo %MONGO_PASSWORD% >> %tempfile%

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


:ResetData
  set /p go=Are you sure you want to reset the saved database credentials? [Y/n]:
  :: Delete cache
  if exist %tempfile% (
    del %tempfile%
  )

  set "MONGO_HOST="
  set "MONGO_DB="
  set MONGO_PORT=27017
  set "MONGO_USER="
  set "MONGO_PASSWORD="

  GoTo FetchFile
EXIT /B 0