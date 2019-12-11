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
Global $BAGS_TO_USE = 4
Global $USE_SUPERIOR_ID_KIT = True

GUI()
MainLoop()

Func MainLoop()
    While Not $BOT_RUNNING
        Sleep(500)
    WEnd
    Identify()
    MsgBox(0, "Success", "Inventory has been identified for " & $charname, 2000)
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

#Region Identification
Func Identify()
    Local $item, $bag

    For $i = 1 To $BAGS_TO_USE
        $bag = GetBag($i)

        If Not RetrieveIdentificationKit($USE_SUPERIOR_ID_KIT) Then Return
        For $j = 1 To DllStructGetData($bag, "slots")
            $item = GetItemBySlot($i, $j)
            If DllStructGetData($item, "Id") == 0 Then ContinueLoop
            IdentifyItem($item) ;hasSleep
        Next
    Next
EndFunc ;Identify
Func RetrieveIdentificationKit($expert = True)
    If FindIdentificationKit() Then Return True

    If GetGoldCharacter() < 500 And GetGoldStorage() > 499 Then
        WithdrawGold(500)
        RndSleep(500)
    EndIf
    Local $j = 0
    Do
        $expert ? BuySuperiorIdentificationKit() : BuyIdentificationKit()
        RndSleep(500)
        $j = $j + 1
    Until FindIdentificationKit() <> 0 Or $j == 3
    If $j == 3 Then Return False

    RndSleep(500)
    Return FindIdentificationKit()
EndFunc ;RetrieveIdentificationKit
#EndRegion Identificationr
