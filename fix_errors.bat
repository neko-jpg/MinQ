@echo off
echo Running dart fix dry-run...
dart fix --dry-run

echo.
echo Press any key to apply fixes...
pause

echo.
echo Applying fixes...
dart fix --apply

echo.
echo Running flutter format...
flutter format .

echo.
echo Done! Press any key to exit...
pause
