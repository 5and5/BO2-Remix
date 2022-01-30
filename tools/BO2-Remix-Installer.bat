@echo off

powershell -Command Start-BitsTransfer -Source "https://github.com/5and5/BO2-Remix/releases/download/latest/BO2-Remix.zip"
powershell -Command Expand-Archive -Force -LiteralPath BO2-Remix.zip -DestinationPath "%localappdata%\Plutonium\storage\t6\scripts"
powershell -Command Remove-Item -Force -Recurse "BO2-Remix.zip"

echo.
@echo ###############################################################
@echo ################ Remix Installation Complete ##################
@echo ###############################################################

timeout 5

end