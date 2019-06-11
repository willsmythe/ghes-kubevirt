@echo off

set VNC_IP=%1
set VNC_IP=%VNC_IP:vnc://=%
cmd /c %VNC_EXE% %VNC_IP%
