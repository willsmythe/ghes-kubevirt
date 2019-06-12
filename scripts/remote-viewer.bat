@echo off

REM This is a hacked up script that is needed on windows to use KubeVirt's "virtctl vnc" command.
REM 
REM To use, set the VNC_EXE environment variable to the full path to your VNC client/viewer app. 
REM This app needs to take IP:port as a single argument.

set VNC_IP=%1
set VNC_IP=%VNC_IP:vnc://=%

cmd /c %VNC_EXE% %VNC_IP%
