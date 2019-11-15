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

#Region Global Items
    Global Const $GOLD_COINS = 2511

    Global Const $RARITY_GOLD = 2624
    Global Const $RARITY_PURPLE = 2626
    Global Const $RARITY_BLUE = 2623
    Global Const $RARITY_WHITE = 2621

    ;~ All Weapon mods
    Global $WEAPON_MOD_ARRAY[25] = [893, 894, 895, 896, 897, 905, 906, 907, 908, 909, 6323, 6331, 15540, 15541, 15542, 15543, 15544, 15551, 15552, 15553, 15554, 15555, 17059, 19122, 19123]

    ;~ General Items
    Global $GENERAL_ITEMS_ARRAY[6] = [2989, 2991, 2992, 5899, 5900, 22751]
    Global Const $ITEM_SALVAGE_KIT = 2992
    Global Const $ITEM_SUP_SALVAGE_KIT = 5900
    Global Const $ITEM_EXP_SALVAGE_KIT = 2991
    Global Const $ITEM_IDENT_KIT = 2989
    Global Const $ITEM_SUP_IDENT_KIT = 5899
    Global Const $ITEM_LOCKPICK = 22751

    ;~ Dyes
    Global Const $ITEM_DYES = 146
    Global Const $ITEM_BLACK_DYE = 10
    Global Const $ITEM_WHITE_DYE = 12

    ;~ Tonics
    Global $TONIC_PARTY_ARRAY[23] = [4730, 15837, 21490, 22192, 30624, 30626, 30628, 30630, 30632, 30634, 30636, 30638, 30640, 30642, 30646, 30648, 31020, 31141, 31142, 31144, 31172, 37771, 37772]

    ;~ Special Drops
    Global $SPECIAL_DROPS[7] = [556, 18345, 21491, 37765, 21833, 28433, 28434]
    #cs
        CC_Shard = 556
        Flame_of_Balthazar = 2514
        Golden_Flame_of_Balthazar = 22188
        Celestial_Sigil = 2571
        Wintersday_Gift = 21491
        Wayfarer_Mark = 37765
    Global Const $ITEM_ID_TOTS = 28434
    Global Const $ITEM_ID_VICTORY_TOKEN = 18345
    Global Const $ITEM_ID_LUNAR_TOKEN = 21833
    Global Const $ITEM_ID_LUNAR_TOKENS = 28433
    #ce

    ;~ Map pieces
    Global $MAP_PIECE_ARRAY[4] = [24629, 24630, 24631, 24632]

    ;~ Materials
    Global $ALL_MATERIALS_ARRAY[36] = [921, 922, 923, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 948, 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533]
    Global $COMMON_MATERIALS_ARRAY[11] = [921, 925, 929, 933, 934, 940, 946, 948, 953, 954, 955]
    Global Const $ITEM_ID_FEATHERED_CREST = 835
    Global $RARE_MATERIALS_ARRAY[25] = [922, 923, 926, 927, 928, 930, 931, 932, 935, 936, 937, 938, 939, 941, 942, 943, 944, 945, 949, 950, 951, 952, 956, 6532, 6533]
    #cs
        Lumps of Charcoal 922
        Monstrous Claws 923
        Bolt of Linen 926
        Bolt of Damask 927
        Bolt of Silk 928
        Glob of Ectoplasm 930
        Monstrous Eye 931
        Monstrous Fangs 932
        Diamonds 935
        Onyx Gemstones 936
        Rubies 937
        Sapphires 938
        Tempered Glass Vial 939
        Fur Square 941
        Leather Squares 942
        Elonian Leather Square 943
        Vial of Ink 944
        Obsidian Shard 945
        Steel of Ignot 949
        Deldrimor Steel Ingot 950
        Rolls of Parchment 951
        Rolls of Vellum 952
        Spiritwood Planks 956
        Amber Chunk 6532
        Jadeite Shard 6533
    #ce

    ;~ Title Items (Alcohol, Party, Sweets)
    Global $ITEMS_ALCOHOL[19] = [910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 19172, 19173, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682]
    Global $ITEMS_SWEETS_TOWN[10] = [15528, 15479, 19170, 21492, 21812, 22644, 30208, 31150, 35125, 36681]
    Global $ITEMS_SWEETS_PVE[13] = [17060, 17061, 17062, 22269, 22752, 28431, 28432, 28436, 29431, 31151, 31152, 31153, 35121]
    Global $ITEMS_PARTY[7] = [6368, 6369, 6376, 21809, 21810, 21813, 36683]
    Global $ITEMS_DP_REMOVAL[8] = [6370, 19039, 21488, 21489, 22191, 26784, 28433, 35127]
    #cs
        Global Const $ITEM_ID_GOLDEN_EGGS = 22752
        Global Const $ITEM_ID_BUNNIES = 22644
        Global Const $ITEM_ID_PIE = 28436
        Global Const $ITEM_ID_CIDER = 28435
        Global Const $ITEM_ID_POPPERS = 21810
        Global Const $ITEM_ID_ROCKETS = 21809
        Global Const $ITEM_ID_CUPCAKES = 22269
        Global Const $ITEM_ID_SPARKLER = 21813
        Global Const $ITEM_ID_HONEYCOMB = 26784
        Global Const $ITEM_ID_HUNTERS_ALE = 910
        Global Const $ITEM_ID_GROG = 30855
        Global Const $ITEM_ID_CLOVER = 22191
        Global Const $ITEM_ID_KRYTAN_BRANDY = 35124
        Global Const $ITEM_ID_BLUE_DRINK = 21812
    #ce

    Global $ALL_TITLE_ITEMS[49]=[910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 19172, 19173, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682, 15528, 15479, 19170, 21492, 21812, 22644, 30208, 31150, 35125, 36681, 17060, 17061, 17062, 22269, 22752, 28431, 28432, 28436, 29431, 31151, 31152, 31153, 35121, 6368, 6369, 6376, 21809, 21810, 21813, 36683]

    ;~ Special Drops (Trophies)
    Global $STACKABLE_TROPHIES_ARRAY[5] = [27047, 27052, 27033, 24353, 24354]
    Global Const $ITEM_GLACIAL_STONES = 27047
    Global Const $ITEM_SUPERIOR_CHARR_CARVING = 27052
    Global Const $ITEM_DESTROYER_CORE = 27033
    Global Const $ITEM_DIESSA_CHALICE = 24353
    Global COnst $ITEM_RIN_RELIC = 24354

    ;~ Tomes
    Global $ALL_TOMES_ARRAY[20] = [21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795, 21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805]
    Global $ELITE_TOME_ARRAY[10] = [21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795]
    Global $REGULAR_TOME_ARRAY[10] = [21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805]

    ;~ Scrolls
    Global $ALL_SCROLLS_ARRAY[11] = [5853, 5975, 5976, 3256, 3746, 5594, 5595, 5611, 21233, 22279, 22280]

    #EndRegion Global Items

    #Region Item Types
    Global $ITEM_TYPE_SALVAGE = 0
    Global $ITEM_TYPE_LEADHAND = 1
    Global $ITEM_TYPE_AXE = 2
    Global $ITEM_TYPE_BAG = 3
    Global $ITEM_TYPE_FEET = 4
    Global $ITEM_TYPE_BOW = 5
    Global $ITEM_TYPE_BUNDLE = 6
    Global $ITEM_TYPE_CHEST = 7
    Global $ITEM_TYPE_RUNE = 8
    Global $ITEM_TYPE_CONSUMABLE = 9
    Global $ITEM_TYPE_DYE = 10
    Global $ITEM_TYPE_MATERIAL = 11
    Global $ITEM_TYPE_FOCUS = 12
    Global $ITEM_TYPE_ARMS = 13
    Global $ITEM_TYPE_SIGIL = 14
    Global $ITEM_TYPE_HAMMER = 15
    Global $ITEM_TYPE_HEAD = 16
    Global $ITEM_TYPE_SALVAGEITEM = 17
    Global $ITEM_TYPE_KEY = 18
    Global $ITEM_TYPE_LEGS = 19
    Global $ITEM_TYPE_COINS = 20
    Global $ITEM_TYPE_QUESTITEM = 21
    Global $ITEM_TYPE_WAND = 22
    Global $ITEM_TYPE_SHIELD = 24
    Global $ITEM_TYPE_STAFF = 26
    Global $ITEM_TYPE_SWORD = 27
    Global $ITEM_TYPE_KIT = 29
    Global $ITEM_TYPE_TROPHY = 30
    Global $ITEM_TYPE_SCROLL = 31
    Global $ITEM_TYPE_DAGGERS = 32
    Global $ITEM_TYPE_PRESENT = 33
    Global $ITEM_TYPE_MINIPET = 34
    Global $ITEM_TYPE_SCYTHE = 35
    Global $ITEM_TYPE_SPEAR = 36
    Global $ITEM_TYPE_HANDBOOK = 43
    Global $ITEM_TYPE_COSTUMEBODY = 44
    Global $ITEM_TYPE_COSTUMEHEAD = 45

    Global $UNSTACKABLES[23] = [$ITEM_TYPE_LEADHAND, $ITEM_TYPE_AXE, $ITEM_TYPE_BAG, $ITEM_TYPE_FEET, $ITEM_TYPE_BOW, $ITEM_TYPE_RUNE, $ITEM_TYPE_FOCUS, $ITEM_TYPE_ARMS, $ITEM_TYPE_SIGIL, $ITEM_TYPE_HAMMER, $ITEM_TYPE_HEAD, $ITEM_TYPE_SALVAGEITEM, $ITEM_TYPE_LEGS, $ITEM_TYPE_WAND, $ITEM_TYPE_SHIELD, $ITEM_TYPE_STAFF, $ITEM_TYPE_SWORD, $ITEM_TYPE_KIT, $ITEM_TYPE_DAGGERS, $ITEM_TYPE_MINIPET, $ITEM_TYPE_SCYTHE, $ITEM_TYPE_SPEAR, $ITEM_TYPE_HANDBOOK]
#EndRegion Item Types

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

        RetrieveSalvageKit()
        For $j = 1 To DllStructGetData($bag, 'Slots')
            $item = GetItemBySlot($i, $j)
            If DllStructGetData($item, "ModelId") == $ITEM_ID_FEATHERED_CREST Then SalvageCrests($item)
            If CanSalvage($item) Then
                StartSalvage($item, True) ;noSleep
                RndSleep(250)
                SalvageMaterials()
                RndSleep(750)
            EndIf
        Next
    Next
EndFunc ;Salvage
Func SalvageCrests($item)
    Local $q = DllStructGetData($item, 'Quantity')
    For $i = 0 to $q
        StartSalvage($item, True) ;noSleep
        RndSleep(250)
        SalvageMaterials()
        RndSleep(750)
        $i += 1
    Next
EndFunc
Func CanSalvage($item)
    Local $ModelID = DllStructGetData($item, "ModelId")
    Local $rarity = GetRarity($item)
    Local $requirement = GetItemReq($item)

    If $rarity == $RARITY_GOLD		  Then Return False
    If $rarity == $RARITY_BLUE		  Then Return True
    If $rarity == $RARITY_PURPLE		Then Return False

    If $ModelID == $ITEM_DYES                       Then Return False
    If InArray($ModelID, $SPECIAL_DROPS)            Then Return False
    If InArray($ModelID, $ALL_TOMES_ARRAY)		    Then Return False ;Tomes
    If InArray($ModelID, $ALL_MATERIALS_ARRAY)		Then Return False ;Materials
    If InArray($ModelID, $STACKABLE_TROPHIES_ARRAY)	Then Return False ;Trophies
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
    If FindExpertSalvageKit() = 0 Then
        If GetGoldCharacter() < 500 And GetGoldStorage() > 499 Then
            WithdrawGold(500)
            RndSleep(500)
        EndIf
        Local $j = 0
        Do
            BuyExpertSalvageKit()
            RndSleep(500)
            $j = $j + 1
        Until FindExpertSalvageKit() <> 0 Or $j = 3
        If $j = 3 Then Exit
        RndSleep(500)
    EndIf
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
