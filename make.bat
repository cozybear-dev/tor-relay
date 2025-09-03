@echo off

call :main %1
goto :EOF

:processArgs
    if /I "%~1"=="build" (
        call :buildImage
    ) else if /I "%~1"=="run" (
        call :runImage
    ) else if "%~1"=="" (
        call :buildImage
        call :runImage
    ) else (
        echo Unknown argument: %~1
    )
    goto :EOF

:buildImage
    echo Building Docker image...
    docker build -t tor-relay:latest .
    goto :EOF

:runImage
    echo Running Docker container...
    docker run -it -v "%CD%/torrc:/etc/tor/torrc" tor-relay:latest
    goto :EOF

:main
    call :processArgs %1
    goto :EOF