#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <GWA2/GWA2.au3>
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
    Salvage()
    MsgBox(0, "Success", "Inventory has been salvaged for " & $charname)
    $BOT_RUNNING = False
    GUICtrlSetState($CharInput, $GUI_ENABLE)
    GUICtrlSetState($StartButton, $GUI_ENABLE)
    MainLoop()
EndFunc

#Region GUI
Func GUI()
    $GUI = GUICreate("Salvager bot", 115, 90, -1, -1)
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
    WinSetTitle($Gui, "", "Salvaging for " & $charname)
    $BOT_RUNNING = True
    SetMaxMemory()
EndFunc
Func _exit()
    Exit
EndFunc
#EndRegion Handlers

#Region Salvage
Func Salvage()
    Local $item, $bag

    For $i = 1 To $BAGS_TO_USE
        $bag = Getbag($i)

        If Not RetrieveSalvageKit() Then Return
        For $j = 1 To DllStructGetData($bag, 'Slots')
            $item = GetItemBySlot($i, $j)
            If DllStructGetData($item, "ModelId") == $ITEM_FEATHERED_CREST Then SalvageCrests($item)
            If CanSalvage($item) Then
                StartSalvage($item) ;noSleep
                RndSleep(1000)
                SalvageMaterials()
                RndSleep(750)
            EndIf
        Next
    Next
EndFunc ;Salvage
Func SalvageCrests($item)
    Local $q = DllStructGetData($item, 'Quantity')
    For $i = 0 to $q
        RetrieveSalvageKit()
        StartSalvage($item) ;noSleep
        RndSleep(10000)
        SalvageMaterials()
        RndSleep(750)
    Next
EndFunc
Func CanSalvage($item)
    Local $ModelID = DllStructGetData($item, "ModelId")
    Local $rarity = GetRarity($item)

    If DllStructGetData($item, "Type") == $ITEM_TYPE_KEY Then Return False

    If $rarity == $RARITY_GOLD			Then Return False
    If $rarity == $RARITY_BLUE			Then Return False
    If $rarity == $RARITY_PURPLE		Then Return False

    If $ModelID == $ITEM_DYES 						Then Return False ;Dyes
    If InArray($ModelID, $SPECIAL_DROPS_ARRAY)      Then Return False ;ToT bags
    If InArray($ModelID, $ALL_TOMES_ARRAY)		    Then Return False ;Tomes
    If InArray($ModelID, $ALL_MATERIALS_ARRAY)		Then Return False ;Materials
    If InArray($ModelID, $ALL_TROPHIES_ARRAY)	    Then Return False ;Trophies
    If InArray($ModelID, $ALL_TITLE_ITEMS)			Then Return False ;Party, Alcohol, Sweet
    If InArray($ModelID, $ALL_SCROLLS_ARRAY)		Then Return False ;Scrolls
    If InArray($ModelID, $GENERAL_ITEMS_ARRAY)		Then Return False ;Lockpicks, Kits
    If InArray($ModelID, $WEAPON_MOD_ARRAY)			Then Return False ;Weapon mods

    ; TODO: do not pickup those
    If InArray($ModelID, $MAP_PIECE_ARRAY)			Then Return False
    If $rarity == $RARITY_WHITE 					Then Return True

    Return False
EndFunc ;CanSalvage
Func RetrieveSalvageKit()
    If FindExpertSalvageKit() Then Return True

    If GetGoldCharacter() < 500 And GetGoldStorage() > 499 Then
        WithdrawGold(500)
        RndSleep(500)
    EndIf
    Local $j = 0
    Do
        BuyExpertSalvageKit()
        RndSleep(500)
        $j = $j + 1
    Until FindExpertSalvageKit() <> 0 Or $j == 3
    If $j == 3 Then Return False

    RndSleep(500)
    Return FindExpertSalvageKit()
EndFunc ;RetrieveSalvageKit
#EndRegion

#Region Helpers
Func InArray($modelId, $array)
    For $p = 0 To (UBound($array) -1)
        If $modelId == $array[$p] Then Return True
    Next
    Return False
EndFunc
#EndRegion Helpers
