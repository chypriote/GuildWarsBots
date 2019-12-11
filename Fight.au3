#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <GWA2.au3>
#NoTrayIcon

Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Global $BOT_RUNNING = False
Global $HWND
Global $GUI
Global $CharInput
Global $StartButton
Global $charname

GUI()
MainLoop()

Func MainLoop()
    While Not $BOT_RUNNING
        Sleep(500)
    WEnd
    Fight()
    $BOT_RUNNING = False
    GUICtrlSetState($CharInput, $GUI_ENABLE)
    GUICtrlSetState($StartButton, $GUI_ENABLE)
    MainLoop()
EndFunc

#Region GUI
Func GUI()
    $GUI = GUICreate("Identifier bot", 115, 90, -1, -1)
    GUICtrlCreateLabel("Select character :", 5, 5, 105, 15)
    $CharInput = GUICtrlCreateCombo("", 5, 25, 105, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
        GUICtrlSetData(-1, GetLoggedCharNames())
    $StartButton = GUICtrlCreateButton("Start", 5, 55, 105, 25)
        GUICtrlSetOnEvent(-1, "_start")
    GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
    GUISetState(@SW_SHOW)
EndFunc
#EndRegion GUI

#Region Handlers
Func _start()
    GUICtrlSetState($CharInput, $GUI_DISABLE)
    GUICtrlSetState($StartButton, $GUI_DISABLE)
    $charname = GUICtrlRead($CharInput)
    If $charname == "" Then
        If Initialize(ProcessExists("gw.exe"), True, True) = False Then
            MsgBox(0, "Error", "Guild Wars is not running.")
            Exit
        EndIf
    Else
        If Initialize($charname, True, True) = False Then
            MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $charname & "'")
            Exit
        EndIf
    EndIf
    $HWND = GetWindowHandle()

    $charname = GetCharname()
    WinSetTitle($Gui, "", "Identifying for " & $charname)
    $BOT_RUNNING = True
    SetMaxMemory()
EndFunc
Func _exit()
    Exit
EndFunc
#EndRegion Handlers

Func Fight()
	$target = GetNearestEnemyToAgent()
	ChangeTarget($target)
	RndSleep(150)

	Do
		CallTarget($target)
		RndSleep(150)

		Do
			Attack($target)
			RndSleep(150)
			UseSkills()
			RndSleep(150)
		Until Not TargetIsAlive()

		$target = GetNearestEnemyToAgent()
		ChangeTarget($target)
		RndSleep(300)
	Until $target = 0 Or Not TargetIsInRange()
	RndSleep(250)
EndFunc ;Fight

Func UseSkills()
	For $i = 1 To 8
		If Not TargetIsAlive() Then ExitLoop
		$skillId = GetSkillbarSkillID($i)

        If GetSkillbarSkillRecharge($skillId) <> 0 Then ContinueLoop
        If GetEnergy() < GetEnergyCost($skillId) Then ContinueLoop
        If GetSkillbarSkillAdrenaline($i) < GetAdrenalineCost($skillId) Then ContinueLoop

		UseSkill($i, -1)
		RndSleep(GetActivationTime($skillId) + 500)
		Do
			Sleep(200)
		Until Not GetIsCasting()
	Next
EndFunc ;UseSkill

Func TargetIsAlive()
	Return DllStructGetData(GetCurrentTarget(), 'HP') > 0 And DllStructGetData(GetCurrentTarget(), 'Effects') <> 0x0010
EndFunc ;TargetIsAlive
Func TargetIsInRange()
	Return GetDistance(GetCurrentTarget()) < 1400
EndFunc ;TargetIsInRange
