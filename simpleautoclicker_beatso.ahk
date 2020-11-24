; Simple Auto Clicker by Beatso rev by carlosmachina

#NoEnv
;remove question when running the script twice (force substitution)
#SingleInstance force
SendMode Input
SetWorkingDir %A_ScriptDir%

;Options Object, making possible to change the DropDown options here without updating if clauses. Its OK to edit, add and remove items from list
Global optObj := Object("Spam Click", 100, "Any Sword", 625, "Wooden or Stone Axe", 1250, "Iron Axe", 1110, "Gold, Diamond or Netherite Axe", 1000)
Global optListStr := "|"
Global timer = 1000

Global isClicking = False
Global guiInitialized = False
Global winid = ""

for k, v in optObj
    optListStr .= "|" k " (" Round(v/1000, 3) " s)"

MsgBox, , Simple Auto Clicker, Go to Minecraft window and press Ctrl+J to start.

^j::
	WinGet, currentWinId, , A
    WinClose, ahk_class #32770

    ;avoid setting variables to GUI controls twice, enabling reopening of GUI and change settings by just invoking CTRL+J at any time
    if (not guiInitialized)
    {
        WinGet, winid, , A
        WinGetTitle, winname, A

		Gui Add, Text, x14 y8 w402 h50, Minecraft window set to %winname%.`nPress Ctrl+Shift+J to pause/unpause clicking`, and Ctrl+Alt+J to quit the program altogether.
		Gui Add, CheckBox, x16 y64 w120 h23 vRightClick, Hold Right Click?
		Gui Add, Text, x144 y64 w54 h23 +0x200, Cooldown:
		Gui Add, DropDownList, x201 y64 w215 vweapon Choose2,%optListStr%
		Gui Add, CheckBox, x16 y96 w120 h23 vCustomCooldown, Custom Cooldown
		Gui Add, Slider, x144 y96 w201 h32 +Tooltip Range2-40 vCdSliderValue, 2
		Gui Add, Button, x16 y128 w80 h23, &OK

        guiInitialized = True
    }

	if (currentWinId = winid)
	{
		Gui Show, w425 h160, Simple Auto Clicker
	}
    
return

ButtonOK:
    Gui, Submit

    ;Fetches the value from the DropBox selection, assigning it to the timer directly from the options Object
    RegExMatch(weapon, "(.+)(?= \()", cleanWeapon)
    ;MsgBox ,,, %cleanWeapon%

    timer := optObj[cleanWeapon]

    ;Overrides the DropDown choice if Custom Cooldown is selected and assigns the slider value to it
	if (CustomCooldown)
	{
		timer := CdSliderValue * 1000
	}

    MsgBox, , Simple Auto Clicker, Cooldown set to %timer% ms. Press Ctrl+Shift+J in Minecraft to start.`nPress Ctrl+J at any time to change settings.

    ;Option set so that the user is able to trigger CTRL+SHIFT+J while looping
    #MaxThreadsPerHotkey 3
return

^+j::
    DetectHiddenWindows, On
    WinGet, currentWinId, , A

    ;Check if window is initialized and asks user for it if it wasn't
	if (winid = "")
	{
		MsgBox, , Simple Auto Clicker, Minecraft Window not set, please switch to it and press Ctrl+J to set it up.
		return
	}

    ;Check if HotKey was triggered in Minecraft, avoiding messing with any other application the user may be using (Alt Tabbed)
    if (currentWinId = winid)
    {
        ;Stop the Clicking, to avoid being "stuck" right clicking (as it would happen with the old ::Pause function) and
        ;returns to original state (waiting for CTRL+SHIFT+J)
        if isClicking 
        {
            isClicking := False
            ControlClick,, ahk_id %winid%,, Right,, NA U
            ControlClick,, ahk_id %winid%,,Left,,NA U
            return
        }

        isClicking := True
        Loop 
        {
            If (RightClick=1) 
            {
                ControlClick,, ahk_id %winid%,, Right,, NA D
            }

            ControlClick,, ahk_id %winid%,,Left,,NA
            Sleep, %timer%

            ;Check every loop if it should continue, otherwise, break the loop
            if not isClicking
            {
                break
            }
        }
        isClicking := False
    }

return
#MaxThreadsPerHotkey 1

^!j::
	MsgBox, , Simple Auto Clicker, Simple Auto Clicker closed
	ExitApp