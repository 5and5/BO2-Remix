Write-Output "-----------------=========================================================---------------------"
Write-Output "GSC Autocompiler exe builder - By @DoktorSAS"
Write-Output "Building the .exe"
ps2exe -inputFile .\AutoCompile.ps1 -outputFile  "GSC AutoCompiler by DoktorSAS.exe" -iconFile .\tools\icon.ico
Write-Output ".exe builded"
Write-Output "-----------------=========================================================---------------------"
