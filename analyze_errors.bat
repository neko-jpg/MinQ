@echo off
echo Analyzing errors...
flutter analyze > analyze_output.txt 2>&1
echo Done! Check analyze_output.txt
