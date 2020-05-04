#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include-once
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiComboBox.au3>
#include "../GWA2/GWA2.au3"
#include "Fight.au3"
AUTOITSETOPTION("TrayIconDebug", 1)

Opt("GUIOnEventMode", 1)
Global $BOT_RUNNING = False
Global $BOT_INITIALIZED = False
Global $Rendering = True

$GUI = GUICreate("Follow Bot", 140, 145, 100, 100)

GUICtrlCreateGroup("Main:", 5, 5, 130, 45)
$mainInput = GUICtrlCreateCombo("", 10, 20, 120, 20, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, GetLoggedCharNames())

GUICtrlCreateGroup("Follower", 5, 50, 130, 65)
$botInput = GUICtrlCreateCombo("", 10, 70, 120, 20, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, GetLoggedCharNames())

$lootLabel = GUICtrlCreateCheckbox("Loot", 10, 95, 50, 15)
	GUICtrlSetState($lootLabel, $GUI_CHECKED)
$fightLabel = GUICtrlCreateCheckbox("Fight", 70, 95, 50, 15)
	GUICtrlSetState($fightLabel, $GUI_CHECKED)

$btnStart = GUICtrlCreateButton("Start", 5, 120, 130, 20, $WS_GROUP)


GUICtrlSetOnEvent($btnStart, "EventHandler")
GUISetOnEvent($GUI_EVENT_CLOSE, "EventHandler")

GUISetState(@SW_SHOW)

While 1
	Sleep(100)
	If $BOT_RUNNING Then 
        If Not $BOT_INITIALIZED Then 
        	AdlibRegister("VerifyConnection", 5000)
        	$BOT_INITIALIZED = True
    	EndIf
		Follow()
	EndIf
WEnd

Func EventHandler()
	Switch (@GUI_CtrlId)
		Case $btnStart
			If GUICtrlRead($botInput) == GUICtrlRead($mainInput) Then
				MsgBox(0, "Error", "Follower and Followed can't be the same window.")
				Exit
			EndIf

			$BOT_RUNNING = Not $BOT_RUNNING

			If $BOT_RUNNING Then
				If GUICtrlRead($botInput) == "" Then
					If Initialize(ProcessExists("gw.exe"), true) == False Then
						MsgBox(0, "Error", "Guild Wars it not running.")
						Exit
					EndIf
				Else
					If Initialize(GUICtrlRead($botInput), GUICtrlRead($botInput) & " - Guild Wars") == False Then
						MsgBox(0, "Error", "Can't find a Guild Wars client with that character name.")
						Exit
					EndIf
				EndIf
			EndIf
			ToggleGUI()
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
EndFunc   ;==>EventHandler

Func Follow()
	$main = GUICtrlRead($mainInput)
	$me = GetMyID()
	$self = GetAgentByID($me)

	For $i = 1 To GetMaxAgents()
		If $i <> $self Then
			$agent = GetAgentByID($i)
			If DllStructGetData($agent, 'Allegiance') == 1 And GetPlayerName($agent) == $main And GetDistance($self, $agent) > 200 Then
				MoveTo(DllStructGetData($agent, 'X'), DllStructGetData($agent, 'Y'))
				Loot()
			EndIf
		EndIf
	Next
	RndSleep(300)
EndFunc


Func Out($text)
EndFunc

Func Alert($text)
	MsgBox(0, "Debug", $text)
EndFunc

Func GetChecked($GUICtrl)
   Return GUICtrlRead($GUICtrl) == $GUI_Checked
EndFunc

Func ToggleGUI()
	If $BOT_RUNNING Then
		GUICtrlSetState($mainInput, $GUI_DISABLE)
		GUICtrlSetState($botInput, $GUI_DISABLE)
		GUICtrlSetState($lootLabel, $GUI_DISABLE)
		GUICtrlSetState($fightLabel, $GUI_DISABLE)
		GUICtrlSetData($btnStart, "Stop")
	Else
		GUICtrlSetState($mainInput, $GUI_ENABLE)
		GUICtrlSetState($botInput, $GUI_ENABLE)
		GUICtrlSetState($lootLabel, $GUI_ENABLE)
		GUICtrlSetState($fightLabel, $GUI_ENABLE)
		GUICtrlSetData($btnStart, "Start")
	EndIf
EndFunc
Func InArray($modelId, $array)
    For $p = 0 To (UBound($array) -1)
        If $modelId == $array[$p] Then Return True
    Next
    Return False
EndFunc
Func VerifyConnection()
    If GetMapLoading() == 2 Then Disconnected()
EndFunc ;VerifyConneciton