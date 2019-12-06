#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <GWA2.au3>
AUTOITSETOPTION("TrayIconDebug", 1)

Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Global $BOT_RUNNING = False
Global $HWND
Global $GUI
Global $CharInput
Global $StartButton
Global $charname
Global $BAGS_TO_USE = 4

GUI()
MainLoop()

Func MainLoop()
    While Not $BOT_RUNNING
        Sleep(500)
    WEnd
    Open()
    MsgBox(0, "Success", "Inventory has been identified for " & $charname)
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
Func Open()
    Local $item, $bag

    For $i = 1 To $BAGS_TO_USE
        $bag = GetBag($i)

        For $j = 1 To DllStructGetData($bag, "slots")
            $item = GetItemBySlot($i, $j)
            If DllStructGetData($item, "Id") == 28434 Or DllStructGetData($item, "ModelId") == 28434 Then
                $quantity = DllStructGetData($item, 'Quantity')
                For $f = 0 To $quantity
                    UseItem($item) ;hasSleep
                    RndSleep(300)
                Next
            EndIf
        Next
    Next
EndFunc ;Open
#EndRegion Identification
