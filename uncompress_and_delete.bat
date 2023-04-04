@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM Check if input file was provided
IF [%1]==[] (
    CALL :HANDLE_ERROR "Please provide an input file."
    EXIT /B 1
)

REM Set input file, output directory, 7-Zip path, and WinRAR path
SET "INPUT_FILE=%~1"
SET "OUTPUT_DIR=%~n1"
SET "ZIP_PATH=%ProgramFiles%\7-Zip\7z.exe"
SET "WINRAR_PATH=%ProgramFiles%\WinRAR\WinRAR.exe"
SET "TAR_PATH=%SystemRoot%\System32\tar.exe"

REM Check if 7-Zip, WinRAR, or TAR exists
IF NOT EXIST "%ZIP_PATH%" (
    SET "ZIP_PATH=%ProgramFiles(x86)%\7-Zip\7z.exe"
    IF NOT EXIST "%ZIP_PATH%" (
        REM Check for WinRAR
        IF NOT EXIST "%WINRAR_PATH%" (
            SET "WINRAR_PATH=%ProgramFiles(x86)%\WinRAR\WinRAR.exe"
            IF NOT EXIST "%WINRAR_PATH%" (
                REM Check for tar
                IF NOT EXIST "%TAR_PATH%" (
                    REM Check if input file is a zip file and use VBS command if it is
                    IF /I "%INPUT_FILE:~-4%"==".zip" (
                        SET "ARCHIVE_TOOL=VBS"
                    ) ELSE (
                        CALL :HANDLE_ERROR "7-Zip, WinRAR, and tar not found. Please check the path."
                        EXIT /B 1
                    )
                ) ELSE (
                    SET "ARCHIVE_TOOL=TAR"
                )
            ) ELSE (
                SET "ARCHIVE_TOOL=WINRAR"
            )
        ) ELSE (
            SET "ARCHIVE_TOOL=WINRAR"
        )
    ) ELSE (
        SET "ARCHIVE_TOOL=7ZIP"
    )
) ELSE (
    SET "ARCHIVE_TOOL=7ZIP"
)

REM Check if input file exists
IF NOT EXIST "%INPUT_FILE%" (
    CALL :HANDLE_ERROR "Input file %INPUT_FILE% not found. Please check the file."
    EXIT /B 1
)

REM Check if output directory exists and increment if necessary
IF NOT "%OUTPUT_DIR%"=="" (
    SET "N=0"
    :DIR_LOOP
    IF EXIST "%OUTPUT_DIR%" (
        SET /A N+=1
        IF !N! GTR 0 (
            SET "OUTPUT_DIR=%~n1_!N!"
        )
        GOTO :DIR_LOOP
    ) ELSE (
        ECHO Info: Using directory name "%OUTPUT_DIR%".
    )
)

REM Extract the archive using the appropriate tool
IF "%ARCHIVE_TOOL%"=="7ZIP" (
    CALL :EXTRACT_7ZIP "%ZIP_PATH%" "%INPUT_FILE%" "%OUTPUT_DIR%"
) ELSE IF "%ARCHIVE_TOOL%"=="WINRAR" (
    CALL :EXTRACT_WINRAR "%WINRAR_PATH%" "%INPUT_FILE%" "%OUTPUT_DIR%"
) ELSE IF "%ARCHIVE_TOOL%"=="TAR" (
    CALL :EXTRACT_TAR "%INPUT_FILE%" "%OUTPUT_DIR%"
) ELSE IF "%ARCHIVE_TOOL%"=="VBS" (
    CALL :EXTRACT_VBS "%INPUT_FILE%" "%OUTPUT_DIR%"
) ELSE (
    CALL :HANDLE_ERROR "No suitable archive tool found for the input file."
    EXIT /B 1
)

REM Check if extraction was successful
IF EXIST "%OUTPUT_DIR%" (
    ECHO Success: "%OUTPUT_DIR%\" was created.
    DEL "%INPUT_FILE%"
) ELSE (
    CALL :HANDLE_ERROR "An issue occurred while creating the output directory."
    GOTO :EOF
)

ENDLOCAL
GOTO :EOF

REM Function to extract the archive using 7-Zip
:EXTRACT_7ZIP
"%~1" x "%~2" -o"%~3\"
IF %ERRORLEVEL% NEQ 0 (
    CALL :HANDLE_ERROR "An issue occurred while extracting the archive with 7-Zip."
	EXIT /B 1
)
GOTO :EOF

REM Function to extract the archive using WinRAR
:EXTRACT_WINRAR
"%~1" x -ibck "%~2" "%~3\"
IF %ERRORLEVEL% NEQ 0 (
	CALL :HANDLE_ERROR "An issue occurred while extracting the archive with WinRAR."
	EXIT /B 1
)
GOTO :EOF

REM Function to extract the archive using tar
:EXTRACT_TAR
mkdir "%~2" 2>nul || (CALL :HANDLE_ERROR "Unable to create output directory." & EXIT /B 1)
tar -xf "%~1" -C "%~2" 2>nul
IF %ERRORLEVEL% NEQ 0 (
    CALL :HANDLE_ERROR "An issue occurred while extracting the archive with tar."
    EXIT /B 1
)
GOTO :EOF

REM Function to extract the archive using VBS
:EXTRACT_VBS
SET "VBS_FILE=%TEMP%\ExtractZip.vbs"
REM Create the VBS script
ECHO set objArgs = WScript.Arguments >> "%VBS_FILE%"
ECHO input = objArgs(0) >> "%VBS_FILE%"
ECHO output = objArgs(1) >> "%VBS_FILE%"
ECHO Set objShell = CreateObject("Shell.Application") >> "%VBS_FILE%"
ECHO Set objTarget = objShell.NameSpace(output) >> "%VBS_FILE%"
ECHO If Not objTarget Is Nothing Then >> "%VBS_FILE%"
ECHO     Set objSource = objShell.NameSpace(input).Items >> "%VBS_FILE%"
ECHO     intOptions = 4 + 16 >> "%VBS_FILE%"
ECHO     objTarget.CopyHere objSource, intOptions >> "%VBS_FILE%"
ECHO End If >> "%VBS_FILE%"
ECHO Set objShell = Nothing >> "%VBS_FILE%"
mkdir "%~2" 2>nul || (CALL :HANDLE_ERROR "Unable to create output directory." & EXIT /B 1)
CD /D "%~dp1"

REM Run the VBS script
cscript //nologo "%VBS_FILE%" "%~f1" "%~2" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    CALL :HANDLE_ERROR "An issue occurred while extracting the archive with VBS."
    EXIT /B 1
)
REM Change the working directory back to the original location
CD /D "%~dp0"
REM Delete the VBS script
DEL /F /Q "%VBS_FILE%"
GOTO :EOF

REM Function to handle errors
:HANDLE_ERROR
ECHO ERROR: %~1
PAUSE
EXIT /B 1