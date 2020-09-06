; Simple Auto Clicker by Beatso

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

MsgBox, , Simple Auto Clicker, Go to Minecraft window and press Ctrl+J to start.

^j::
WinClose, ahk_class #32770
WinGet, winid, , A
WinGetTitle, winname, A
Gui, Add, Text, x12 y9 w430 h30, Minecraft window set to %winname%.`nPress Ctrl+Shift+J to pause/unpause clicking`, and Ctrl+Alt+J to quit the program altogether.
Gui, Add, CheckBox, x12 y39 w170 h20 vRightClick, Hold right click?
Gui, Add, Text, x12 y59 w60 h20, Cooldown:
Gui, Add, DropDownList, x72 y59 w230 h100 vweapon, Spam Click (0.1 seconds)|Any Sword (0.625 seconds)||Wooden or Stone Axe (1.25 seconds)|Iron Axe (1.11 seconds)|Gold, Diamond or Netherite Axe (1 second)
Gui, Add, Button, x168 y89 w120 h20 default, OK
Gui, Show, x246 y187 h118 w457, Simple Auto Clicker
return

ButtonOK:
Gui, Submit
if (weapon="Spam Click (0.1 seconds")
	timer:=100
else if (weapon="Any Sword (0.625 seconds)")
	timer:=630
else if (weapon="Wooden or Stone Axe (1.25 seconds)")
	timer:=1250
else if (weapon="Iron Axe (1.11 seconds)")
	timer:=1110
else if (weapon="Gold, Diamond or Netherite Axe (1 second)")
	timer:=1000
Loop {
	if (RightClick=1)
		ControlClick,, ahk_id %winid%,, Right,, NAD
	ControlClick,, ahk_id %winid%
	Sleep, %timer%
}
return

^+j::Pause
^!j::ExitApp