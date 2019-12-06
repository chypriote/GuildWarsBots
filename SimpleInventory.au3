#include-once
#include <Array.au3>
#include "Constants.au3"

#Region About
#cs
    This is a simple inventory management without a GUI
    The bot will Store the items you want
    Identify whatever is left on your inventory
    Sell what he needs to

    Everything is easily configurable
    You can add more configuration very easily if you know what you're doing

    Configuration:
    - set $BAGS_TO_USE to the number of bafs you'll be using. The bot will not touch the others
    - edit CanStore() function to decide what items to keep in your chest
    - edit CanSell()  function to decide what items to sell to the merchant
    Note that Identify() will identify everything in your inventory, you can edit it to filter which items to ident
    Constants are defined at the bottom of this file
#ce
#EndRegion About

Global $BAGS_TO_USE = 4
Global $USE_EXPERT_ID_KIT = True

#Region Inventory
Func Inventory()
    Out("Going to merchant")
    GoMerchant() ;you NEED to implement this in your script

    Out("Storing")
    Store()
    Out("Identifying")
    Identify()
    Out("Salvaging")
    Salvage()
    Out("Selling")
    Sell()

    RndSleep(1000)
    If GetGoldCharacter() > 80000 Then DepositGold(80000)
EndFunc

Func CountSlots()
    Local $bag, $count = 0

    For $i = 1 To $BAGS_TO_USE
        $bag = GetBag($i)
        $count += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
    Next

    Return $count
EndFunc ;CountSlots

Func InventoryIsFull()
    Return CountSlots() < 2
EndFunc ;InventoryIsFull
#EndRegion Inventory

#Region Store
Func Store()
    Local $item, $bag

    For $i = 1 To $BAGS_TO_USE
        $bag = Getbag($i)

        For $j = 1 To DllStructGetData($bag, 'Slots')
            $item = GetItemBySlot($i, $j)
            If DllStructGetData($item, "Id") == 0 Then ContinueLoop
            If CanStore($item) Then
                StoreItem($item) ;hasSleep
                RndSleep(250)
            EndIf
        Next
    Next
EndFunc ;Store
Func CanStore($item)
    Local $ModelID = DllStructGetData($item, "ModelId")
    Local $rarity = GetRarity($item)

    If $rarity == $RARITY_GOLD		  Then Return True
    If $rarity == $RARITY_BLUE		  Then Return False
    If $rarity == $RARITY_PURPLE		Then Return False

    If $ModelID == $TROPHY_DIESSA_CHALICE       Then Return True
    If $ModelID == $TROPHY_RIN_RELIC            Then Return True
    If $ModelID == $ITEM_LOCKPICK               Then Return False
    If $ModelID == 946 							Then Return False ;Planks
    If $ModelID == 953 							Then Return False ;Scales
    If $ModelID == 949 							Then Return False ;Steel ingots
    If $ModelID == 955 							Then Return False ;Granite
    If $ModelID == 954 							Then Return False ;Chitine
    If $ModelID == 925 							Then Return False ;Cloth
    If $ModelID == 940 							Then Return False ;Tanned
    If $ModelID == $MAT_BONES 					Then Return True ;Bones
    If $ModelID == $ITEM_FEATHERED_CREST 		Then Return True

    If $ModelID == $ITEM_DYES 						Then Return False ;Dyes
    If InArray($ModelID, $SPECIAL_DROPS_ARRAY)      Then Return False
    If InArray($ModelID, $ALL_TOMES_ARRAY)		    Then Return True ;Tomes
    If InArray($ModelID, $ALL_MATERIALS_ARRAY)		Then Return True ;Materials
    If InArray($ModelID, $ALL_TROPHIES_ARRAY)	    Then Return True ;Trophies
    If InArray($ModelID, $ALL_TITLE_ITEMS)			Then Return True ;Party, Alcohol, Sweet
    If InArray($ModelID, $ALL_SCROLLS_ARRAY)		Then Return False ;Scrolls
    If InArray($ModelID, $GENERAL_ITEMS_ARRAY)		Then Return False ;Lockpicks, Kits
    If InArray($ModelID, $WEAPON_MOD_ARRAY)			Then Return False ;Weapon mods

    ; TODO: do not pickup those
    If InArray($ModelID, $MAP_PIECE_ARRAY)			Then Return False
    If $rarity == $RARITY_WHITE 					Then Return False

    Return False
EndFunc ;CanStore
Func StoreItem($item)
    Local $slot

    If InArray(DllStructGetData($item, 'Type'), $UNSTACKABLES) Then Return StoreInEmptySlot($item)

    For $i = 8 To 16
        $slot = FindItemInStorage($i, $item)
        If $slot <> 0 Then ExitLoop
    Next
    If $slot == 0 Then Return StoreInEmptySlot($item)

    MoveItem($item, getBag($i), $slot)
    RndSleep(500)
    Return True
EndFunc ;StoreItem
Func FindItemInStorage($bagIndex, $item)
    Local $slot, $inSlot
    Local $ModelID = DllStructGetData($item, 'ModelID')
    Local $ExtraID = DllStructGetData($item, 'ExtraID')

    For $slot = 1 To DllStructGetData(GetBag($bagIndex), 'Slots')
        $inSlot = GetItemBySlot($bagIndex, $slot)
        If DllStructGetData($inSlot, 'ModelID') == $ModelID And DllStructGetData($inSlot, 'ExtraID') == $ExtraID And DllStructGetData($inSlot, 'Quantity') < 250 Then
            SetExtended($slot)
            Return $slot
        EndIf
    Next

    Return 0
EndFunc ;FindItemInStorage
Func StoreInEmptySlot($item)
    Local $inSlot, $slot

    For $bagIndex = 8 To 16
        For $slot = 1 To DllStructGetData(GetBag($bagIndex), 'Slots')
            $inSlot = GetItemBySlot($bagIndex, $slot)
            If DllStructGetData($inSlot, 'ID') == 0 Then
                SetExtended($slot)
                MoveItem($item, getBag($bagIndex), $slot)
                Return True
            EndIf
        Next
    Next

    Return 0
EndFunc ;StoreInEmptySlot
#EndRegion Store

#Region Identification
Func Identify()
    Local $item, $bag

    For $i = 1 To $BAGS_TO_USE
        $bag = GetBag($i)

        If Not RetrieveIdentificationKit() Then Return
        For $j = 1 To DllStructGetData($bag, "slots")
            $item = GetItemBySlot($i, $j)
            If DllStructGetData($item, "Id") == 0 Then ContinueLoop
            IdentifyItem($item) ;hasSleep
        Next
    Next
EndFunc ;Identify
Func RetrieveIdentificationKit()
    If FindIdentificationKit() Then Return True

    If GetGoldCharacter() < 500 And GetGoldStorage() > 499 Then
        WithdrawGold(500)
        RndSleep(500)
    EndIf
    Local $j = 0
    Do
        $USE_EXPERT_ID_KIT ? BuySuperiorIdentificationKit() : BuyIdentificationKit()
        RndSleep(500)
        $j = $j + 1
    Until FindIdentificationKit() <> 0 Or $j = 3
    If $j == 3 Then Return False

    RndSleep(500)
    Return FindIdentificationKit()
EndFunc ;RetrieveIdentificationKit
#EndRegion Identification

#Region Salvage
Func Salvage()
    Local $item, $bag

    For $i = 1 To $BAGS_TO_USE
        $bag = Getbag($i)

        If Not RetrieveSalvageKit() Then Return
        For $j = 1 To DllStructGetData($bag, 'Slots')
            $item = GetItemBySlot($i, $j)
            If CanSalvage($item) Then
                StartSalvage($item, True) ;noSleep
                RndSleep(1000)
                SalvageMaterials()
                RndSleep(750)
            EndIf
        Next
    Next
EndFunc ;Salvage
Func CanSalvage($item)
    Local $ModelID = DllStructGetData($item, "ModelId")
    Local $rarity = GetRarity($item)

    If CountSlots() < 1 Then Return False
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
    Until FindExpertSalvageKit() <> 0 Or $j = 3
    If $j = 3 Then Return False
    RndSleep(500)
    Return True
EndFunc ;RetrieveSalvageKit
#EndRegion


#Region Sell
Func Sell()
    Local $item, $bag

    For $i = 1 To $BAGS_TO_USE
        $bag = Getbag($i)

        For $j = 1 To DllStructGetData($bag, 'Slots')
            $item = GetItemBySlot($i, $j)
            If DllStructGetData($item, "Id") == 0 Then ContinueLoop
            If CanSell($item) Then
                SellItem($item) ;noSleep
                RndSleep(250)
            EndIf
        Next
    Next
EndFunc ;Sell
Func CanSell($item)
    Local $ModelID = DllStructGetData($item, "ModelId")
    Local $rarity = GetRarity($item)

    If $rarity == $RARITY_GOLD Then
        RetrieveIdentificationKit()
        IdentifyItem($item)
        Return True
    EndIf
    If $rarity == $RARITY_BLUE		  	Then Return True
    If $rarity == $RARITY_PURPLE		Then Return True

    If $ModelID == $ITEM_DYES Then
        ;Uncomment for Only black and white dyes
        Local $ExtraID = DllStructGetData($item, "ExtraId")
        Return $ExtraID <> $ITEM_BLACK_DYE And $ExtraID <> $ITEM_WHITE_DYE
        ;Return False
    EndIf ;Dies

    If $ModelID == 34 Then Return True ;Pouch
    If $ModelID == 946 Then Return True ;Planks
    If $ModelID == 949 Then Return True ;Steel ingots
    If $ModelID == 955 Then Return True ;Granite
    If $ModelID == 954 Then Return True ;Chitine
    If $ModelID == 925 Then Return True ;Cloth
    If $ModelID == 940 Then Return True ;Tanned
    If $ModelID == 953 Then Return True ;Scales
    If $ModelID == $MAT_BONES Then Return True ;Bones
    If $ModelID == $ITEM_FEATHERED_CREST Then Return False
    If InArray($ModelID, $SPECIAL_DROPS_ARRAY)      Then Return False
    If InArray($ModelID, $ALL_TOMES_ARRAY)		  	Then Return False ;Tomes
    If InArray($ModelID, $ALL_MATERIALS_ARRAY)		Then Return False ;Materials
    If InArray($ModelID, $ALL_TROPHIES_ARRAY)	    Then Return False ;Trophies
    If InArray($ModelID, $ALL_TITLE_ITEMS)			Then Return False ;Party, Alcohol, Sweet
    If InArray($ModelID, $ALL_SCROLLS_ARRAY)		Then Return True ;Scrolls
    If InArray($ModelID, $GENERAL_ITEMS_ARRAY)		Then Return False ;Lockpicks, Kits
    If InArray($ModelID, $WEAPON_MOD_ARRAY)			Then Return False ;Weapon mods

    ; TODO: do not pickup those
    If InArray($ModelID, $MAP_PIECE_ARRAY)			Then Return True
    If $rarity == $RARITY_WHITE 					Then Return True

    Return True
EndFunc ;CanSell
#EndRegion Sell

#Region Helpers
Func InArray($modelId, $array)
    For $p = 0 To (UBound($array) -1)
        If $modelId == $array[$p] Then Return True
    Next
    Return False
EndFunc
#EndRegion Helpers
