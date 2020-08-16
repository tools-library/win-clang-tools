@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION



:PROCESS_CMD
    SET "utility_folder=%~dp0"
    SET "utility_software_folder=%utility_folder%software"
    SET "utility_sfx=%utility_folder%software.exe"

    CALL "%utility_folder%..\win-utils\setup.cmd" cecho 7zip

    SET help_arg=false
    SET pack_arg=false
    SET unpack_arg=false

    SET current_arg=%1
    IF  [%current_arg%] EQU [-h]       SET help_arg=true
    IF  [%current_arg%] EQU [--help]   SET help_arg=true
    IF  [%current_arg%] EQU [--pack]   SET pack_arg=true
    IF  [%current_arg%] EQU [--unpack] SET unpack_arg=true

    IF  [%help_arg%] EQU [true] (
        CALL :SHOW_HELP
    ) ELSE (
        IF  [%pack_arg%] EQU [true]  (
            CALL :PACK
        ) ELSE (
            IF  [%unpack_arg%] EQU [true]  (
                CALL :UNPACK
            ) ELSE (
                CALL :MAIN %*
                IF !ERRORLEVEL! NEQ 0 (
                    EXIT /B !ERRORLEVEL!
                )
            )
        )
    )

    REM All changes to variables within this script, will have local scope. Only
    REM variables specified in the following block can propagates to the outside
    REM world (For example, a calling script of this script).
    ENDLOCAL & (
        SET "TOOLSET_CLANG_TOOLS_PATH=%utility_software_folder%"
        SET "PATH=%PATH%"
    )
EXIT /B 0



:MAIN
    CALL :UNPACK

    REM Check if the 'utility_software_folder' is not already in system path. If
    REM not, insert it.
    IF "!PATH:%utility_software_folder%=!" EQU "%PATH%" (
        SET "PATH=%utility_software_folder%;%PATH%"
        CALL :SHOW_INFO "Utility added to system path."
    )
EXIT /B 0



:PACK
    IF EXIST "!utility_software_folder!" (
        CALL :SHOW_INFO "Packing utility files."
        7z u -uq0 -mx9 -sfx "!utility_sfx!" "!utility_software_folder!"
    )
EXIT /B 0

:UNPACK
    IF NOT EXIST "!utility_software_folder!" (
        CALL :SHOW_INFO "Unpacking utility files."
        CALL "!utility_sfx!" -y -o"!utility_folder!"
    )
EXIT /B 0



:SHOW_INFO
    cecho {olive}[TOOLSET - UTILS - CLANG TOOLS]{default} INFO: %~1{\n}
EXIT /B 0

:SHOW_ERROR
    cecho {olive}[TOOLSET - UTILS - CLANG TOOLS]{red} ERROR: %~1 {default} {\n}
EXIT /B 0



:SHOW_HELP
    SET "script_name=%~n0%~x0"
    ECHO #######################################################################
    ECHO #                                                                     #
    ECHO #                      T O O L   S E T U P                            #
    ECHO #                                                                     #
    ECHO #    'CLANG TOOLS' are standalone command line tools designed for     #
    ECHO #     use by C++ developers. These tools provide developer-oriented   #
    ECHO #     functionality such as fast syntax checking, automatic           #
    ECHO #     formatting, refactoring, etc.                                   #
    ECHO #                                                                     #
    ECHO # TOOL   : CLANG TOOLS                                                #
    ECHO # VERSION: LLVM 10.0.0                                                #
    ECHO # ARCH   : x32                                                        #
    ECHO #                                                                     #
    ECHO # USAGE:                                                              #
    ECHO #     %SCRIPT_NAME% [-h^|--help^|--pack^|--unpack]                           #
    ECHO #                                                                     #
    ECHO # EXAMPLES:                                                           #
    ECHO #     %script_name%                                                       #
    ECHO #     %script_name% -h                                                    #
    ECHO #     %script_name% --pack                                                #
    ECHO #                                                                     #
    ECHO # ARGUMENTS:                                                          #
    ECHO #     -h^|--help    Print this help and exit.                          #
    ECHO #                                                                     #
    ECHO #     --pack    Pack the content of the software folder in one        #
    ECHO #         self-extract executable called 'software.exe'.              #
    ECHO #                                                                     #
    ECHO #     --unpack    Unpack the self-extract executable 'software.exe'   #
    ECHO #         to the software folder.                                     #
    ECHO #                                                                     #
    ECHO # EXPORTED ENVIRONMENT VARIABLES:                                     #
    ECHO #     TOOLSET_CLANG_TOOLS_PATH    Absolute path where this tool is    #
    ECHO #         located.                                                    #
    ECHO #                                                                     #
    ECHO #     PATH    This tool will export all local changes that it made to #
    ECHO #         the path's environment variable.                            #
    ECHO #                                                                     #
    ECHO #     The environment variables will be exported only if this tool    #
    ECHO #     executes without any error.                                     #
    ECHO #                                                                     #
    ECHO #######################################################################
EXIT /B 0