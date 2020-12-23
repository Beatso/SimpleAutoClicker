; Simple Auto Clicker by Beatso rev by carlosmachina
#NoEnv
;remove question when running the script twice (force substitution)
#SingleInstance force
SendMode Input
SetWorkingDir %A_ScriptDir%

;Options Object, making possible to change the DropDown options here without updating if clauses. Its OK to edit, add and remove items from list
Global optObj := Object("Spam Click", 100, "Any Sword", 625, "Wooden or Stone Axe", 1250, "Iron Axe", 1110, "Gold, Diamond or Netherite Axe", 1000)
Global optListStr := "|"
Global timer := 1000
Global appTitle := "Simple Auto Clicker v2.2.5"

Global isClicking := False
Global guiInitialized := False
Global mcStatus := ""
Global winid := ""
Global winname := ""

for k, v in optObj
{
    optListStr .= "|" k " ("ValueDisplayFormat(v)")"
}

Menu, Tray, Add, Start Clicking, ToggleClicking
Menu, Tray, Add, Reset Minecraft Window, ResetMc
Menu, Tray, Add ;separator
Menu, Tray, Add, Exit, CloseScript

Menu, Tray, Disable, Start Clicking
Menu, Tray, Disable, Reset Minecraft Window
menu, Tray, Tip, %appTitle%
Menu, Tray, NoStandard

MsgBox, , Simple Auto Clicker, Go to Minecraft window and press Ctrl+J to start.

^j::

    WinGet, currentWinId, , A
    WinClose, ahk_class #32770

    UpdateMcStatus(currentWinId)

    if (mcStatus = "inactive")
    {
        return
    }

    if (mcStatus = "closed")
    {
        McStatusHandler() 
    }

    if (mcStatus = "detached")
    {
        AttachMc()
        UpdateMcStatus(currentWinId)
    }

    ;Avoid setting variables to GUI controls twice, enabling reopening of GUI and change settings by just invoking CTRL+J at any time
    if (not guiInitialized)
    {
        Gui Add, Text, x14 y8 w402 h50, Minecraft window set to %winname%.`nPress Ctrl+Shift+J to pause/unpause clicking`, and Ctrl+Alt+J to quit the program altogether.
        Gui Add, CheckBox, x16 y64 w120 h23 vRightClick, Hold Right Click?
        Gui Add, Text, x144 y64 w54 h23 +0x200, Cooldown:
        Gui Add, DropDownList, x201 y64 w215 vweapon Choose2,%optListStr%
        Gui Add, CheckBox, x16 y96 w120 h23 vCustomCooldown, Custom Cooldown
        Gui Add, Slider, x144 y96 w201 h32 +Tooltip Range2-40 vCdSliderValue, 2
        Gui Add, Button, x16 y128 w80 h23, &OK

        guiInitialized := True
    }

    if (mcStatus = "ok")
    {
        if(isClicking)
        {
            Gosub, ^+j 
        }
        Gui Show, w425 h160, %appTitle%
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

    displayTimer := ValueDisplayFormat(timer)

    MsgBox, , Simple Auto Clicker, Cooldown set to %displayTimer%. Press Ctrl+Shift+J in Minecraft to start.`nPress Ctrl+J at any time to change settings.

    Menu, Tray, UseErrorLevel
    Menu, Tray, Enable, Start Clicking
    Menu, Tray, UseErrorLevel, Off

    ;Option set so that the user is able to trigger CTRL+SHIFT+J while looping
    #MaxThreadsPerHotkey 3
return

^+j::
    DetectHiddenWindows, On
    WinGet, currentWinId, , A

    UpdateMcStatus(currentWinId)

    ;Check if HotKey was triggered in Minecraft avoiding messing with any other application the user may be using (Alt Tabbed)
    if (mcStatus = "inactive")
    {
        return
    }

    ;Stop the Clicking, to avoid being "stuck" right clicking (as it would happen with the old ::Pause function) and
    ;returns to original state (waiting for CTRL+SHIFT+J)
    if (isClicking)
    {
        isClicking := False
        TrayTip, %appTitle%, Clicking Deactivated
        ToggleClickMenu()
        ControlClick,, ahk_id %winid%,, Right,, NA U
        ControlClick,, ahk_id %winid%,,Left,,NA U
        McStatusHandler()
        return
    }

    isClicking := True
    ToggleClickMenu()
    TrayTip, %appTitle%, Clicking Activated

    Loop 
    {
        UpdateMcStatus(currentWinId)
        ;If the window becomes unavailable, stop clicking
        if(mcStatus = "closed" || mcStatus = "detached")
        {
            Gosub, ^+j
            break
        }

        ;Check every loop if it should continue, otherwise break the loop
        if not isClicking
        {
            ControlClick,, ahk_id %winid%,, Right,, NA U
            break
        }

        If (RightClick=1) 
        {
            ControlClick,, ahk_id %winid%,, Right,, NA D
        }

        ControlClick,, ahk_id %winid%,,Left,,NA
        Sleep, %timer%
    }

return
#MaxThreadsPerHotkey 1

^!j::
    MsgBox, , %appTitle%, Simple Auto Clicker closed
ExitApp

ValueDisplayFormat(value)
{
    formattedValue := 0
    valueMeasurement := "ms"
    if (value < 1000)
    {
        formattedValue := value
    }
    else if (value >= 2000)
    {
        formattedValue := value/1000
        formattedValue := Format("{:d}", formattedValue)
        valueMeasurement := "s"
    }
    else
    {
        formattedValue := value/1000
        formattedValue := Format("{:.2f}" , formattedValue)
        valueMeasurement := "s"
    }

return formattedValue valueMeasurement
}

ToggleClickMenu()
{
    if (isClicking)
    {
        Menu, Tray, Rename, Start Clicking, Stop Clicking
    }
    Else
    {
        Menu, Tray, Rename, Stop Clicking, Start Clicking
    }
}

UpdateMcStatus(currentWindowId)
{
    isAttached := winid != ""
    isAlive := WinExist("ahk_id" winid)
    isActive := currentWindowId = winid

    if (!isAttached)
    {
        mcStatus := "detached"
        return
    }

    if (!isAlive)
    {
        mcStatus := "closed"
        return
    }

    if (!isActive)
    {
        mcStatus := "inactive"
        return
    }

    mcStatus := "ok"
return
}

McStatusHandler()
{
    switch mcStatus
    {
        case "detached": {
            MsgBox, , %appTitle%, Minecraft Window not set, please switch to it and press Ctrl+J to set it up.
        }
        case "closed": {
            DetachMc()
            MsgBox, , %appTitle%, Minecraft Window not found (maybe it was closed).`nSwitch to new window and press CTRL+J to set it up.
        }
    }

return
}

AttachMc()
{
    WinGet, winid, , A
    WinGetTitle, winname, A
    Menu, Tray, Enable, Reset Minecraft Window
}

DetachMc()
{
    winid := ""
    winname := ""
    Menu, Tray, UseErrorLevel
    Menu, Tray, Disable, Start Clicking
    Menu, Tray, UseErrorLevel, Off
    Menu, Tray, Disable, Reset Minecraft Window
}

ToggleClicking:
    {
        if WinExist("ahk_id" winid)
            WinActivate

        Gosub, ^+j
        return
    }

ResetMc:
    {
        if (isClicking)
        {
            WinActivate, "ahk_id" winid
            Gosub, ^+j
        }
        Reload
        return
    }

CloseScript:
    {
        Gosub, ^!j
        return
    }
