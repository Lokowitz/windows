@echo off
REM Build MSI installer for Pangolin
REM This script creates the MSI installer from an already-built executable

wix.exe build -arch x64 -define BuildDir=build -define ProjectDir=. -o build\Pangolin_Installer.msi installer\pangolin.wxs
