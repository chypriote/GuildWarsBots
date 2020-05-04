#include-once
#include <Array.au3>

#Region Loot
Func Loot()
    Local $agent, $agentID, $deadlock
    Out("Looting")

    If GetIsDead() Then Return False
    If InventoryIsFull() Then Return False ;full inventory dont try to pick up

    For $agentID = 1 To GetMaxAgents()
        $agent = GetAgentByID($agentID)
        If Not GetIsMovable($agent) Or Not GetCanPickUp($agent) Then ContinueLoop
        $item = GetItemByAgentID($agentID)

        If Not CanPickUp($item) Then ContinueLoop
        PickUpItem($item)

        $deadlock = TimerInit()
        While IsDllStruct(GetAgentByID($agentID))
            Sleep(100)
            If TimerDiff($deadlock) > 10000 Then ExitLoop
        WEnd
    Next
EndFunc ;Loot

Func CanPickUp($item)
    Local $ModelID = DllStructGetData($item, 'ModelID')
    Local $ExtraID = DllStructGetData($item, 'ExtraID')
    Local $type = DllStructGetData($item, 'Type')
    Local $rarity = GetRarity($item)

    If $rarity == $RARITY_GOLD Then Return True
    If $ModelID == $ITEM_DYES And ($ExtraID == $ITEM_BLACK_DYE Or $ExtraID == $ITEM_WHITE_DYE) Then Return True ;Black and White Dye ; for only B/W

    If $ModelID == $ITEM_LOCKPICK Then Return True
    If $ModelID == $GOLD_COINS And GetGoldCharacter() < 99000 Then Return True

    If InArray($ModelID, $ALL_TOMES_ARRAY)          Then Return True
    If InArray($ModelID, $ALL_TROPHIES_ARRAY)       Then Return True
    If InArray($ModelID, $ALL_TITLE_ITEMS)          Then Return True
    If InArray($ModelID, $ALL_MATERIALS_ARRAY)      Then Return True
    If InArray($ModelID, $SPECIAL_DROPS_ARRAY)      Then Return True
    If InArray($ModelID, $ALL_DPREMOVAL_ARRAY)      Then Return True

    Return True ;Pickup everything else (later add filter for salvageable items)
    Return False
EndFunc ;CanPickUp

Func PickupArea($area = 1012)
    Local $itemID, $lNearestDistance
    $timer = TimerInit()
    $item = GetNearestItemToAgent()

    Do
        PickUpItem($item)
        
        $deadlock = TimerInit()
        While GetAgentExists($item)
            Sleep(100)
            If TimerDiff($deadlock) > 5000 Then ExitLoop
        WEnd
        $item = GetNearestItemToAgent()

    Until GetDistance($item) > $area Or TimerDiff($timer) > 20000 Or $item = 0
EndFunc ;PickupArea
#EndRegion Loot


Func CountSlots()
    Local $bag, $count = 0

    For $i = 1 To 3
        $bag = GetBag($i)
        $count += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
    Next

    Return $count
EndFunc ;CountSlots

Func InventoryIsFull()
    Return CountSlots() < 2
EndFunc ;InventoryIsFull