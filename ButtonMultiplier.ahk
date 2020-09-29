#NoEnv
#KeyHistory 0
#MaxHotkeysPerInterval 500
ListLines Off
CoordMode, Mouse, Screen

#Include %A_ScriptDir%
#Include autoexec\global_vars_intern.ahk
#Include autoexec\generated\global_vars_user.ahk

#Include impl\FKeyImplementation.ahk
#Include impl\GestureImplementation.ahk
#Include impl\generated\WindowNames.ahk
#Include impl\generated\FKeyLabels.ahk
#Include impl\generated\ProfileIncludes.ahk

#Include functions\Functions.ahk
#Include functions\RepeatableWhilePressed.ahk

; ------------------------------------------------------------------

^.::
ChangeActiveWinMonitor(1)
return

^,::
ChangeActiveWinMonitor(-1)
return

~^!r::
Click, M, U
Menu, Tray, Icon
Reload
return

~^!y::
Menu, Tray, NoIcon
return