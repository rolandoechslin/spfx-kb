REM  Source : https://thomasdaly.net/2018/05/07/simple-build-script-for-the-sharepoint-framework/

cls
call gulp clean
call gulp build --ship
call gulp bundle --ship
call gulp package-solution --ship
call explorer .\sharepoint\solution
