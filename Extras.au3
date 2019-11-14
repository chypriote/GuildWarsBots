
#region new 07/26/2019 ~Zaishen
Func PickUpLootEx()
    Local $lMe = GetAgentByID(-2)
    Local $lBlockedTimer
    Local $lBlockedCount = 0
    Local $lItemExists = True
    Local $iCurDistance = 99999999
    Local $iBestDistance = 99999999
    Local $lAgent, $lTempAgent, $lTempIndex

    Local $lItemList[GetMaxAgents() + 1]
    Local $lPickupList[GetMaxAgents() + 1]

    ;Out("Picking Up Loot")
    For $i = 1 To GetMaxAgents()
        If GetIsDead(-2) Then Return False
        $lAgent = GetAgentByID($i)
        If Not GetIsMovable($lAgent) Then ContinueLoop
        $lDistance = GetDistance($lAgent)
        ;If $lDistance > 2500 Then ContinueLoop ;<----Increased from 2,000 to try to pickup all drops in area (5000 = Compass Range)
        $lItem = GetItemByAgentID($i)

        ;add Items to pick up to item list
        ;If GuiCtrlRead($Tomes) = $GUI_CHECKED And CanPickUp($lItem) Then
            ;$lItemList[0] += 1
            ;$lItemList[$lItemList[0]] = $lAgent
        ;EndIf
    Next

    ;calculate shortest paths for picking up items
    $lTempAgent = GetAgentByID(-2)
    While $lItemList[0] > 0
        $iBestDistance = 99999999

        For $i = 1 to $lItemList[0]
            $iCurDistance = GetDistance($lItemList[$i], $lTempAgent)

            If $iCurDistance < $iBestDistance Then
                $iBestDistance = $iCurDistance
                $lTempIndex = $i
            EndIf
        Next

        ;check if it's viable to run to the item
        If $iBestDistance > 2000 Then ExitLoop

        ;add Item to pickup list
        $lPickupList[0] += 1
        $lPickupList[$lPickupList[0]] = $lItemList[$lTempIndex]
        $lTempAgent = $lItemList[$lTempIndex]

        ;remove Item from Itemlist
        $lItemList[$lTempIndex] = $lItemList[$lItemList[0]]
        $lItemList[0] -= 1
    WEnd

    ;pickup items using shortest path
    For $i = 1 to $lPickupList[0]
        $lBlockedCount = 0

        Do
            If GetDistance($lPickupList[$i]) > 150 Then
                MoveTo(DllStructGetData($lPickupList[$i], 'X'), DllStructGetData($lPickupList[$i], 'Y'), 0)
            EndIf

            $lBlockedTimer = TimerInit()
            $lItem = GetAgentByID(DllStructGetData($lPickupList[$i],"Id"))
            If IsDllStruct($lItem) Then
                Do
                    PickUpItem($lItem)
                    PingSleep(250)
                    $lItemExists = IsDllStruct(GetAgentByID(DllStructGetData($lPickupList[$i],"Id")))
                Until Not $lItemExists Or TimerDiff($lBlockedTimer) > 2500
            Else
                $lItemExists = 0
            EndIf

            If $lItemExists Then $lBlockedCount += 1
        Until Not $lItemExists Or $lBlockedCount > 5
    Next
 EndFunc   ;==>PickUpLootEx
 #region new 07/26/2019 ~Zaishen

 #region new 31/03/2018
 ; Pass coords to move close to portal, thru portal, move close to expl. portal, thru expl. portal, TownID, Expl. ID
 ; Used for resign trick to spawn close to portal in town at end of run


 Func GetItemMaxReq7($aItem)
    Local $Type = DllStructGetData($aItem, "Type")
    Local $Dmg = GetItemMaxDmg($aItem)
    Local $Req = GetItemReq($aItem)

    Switch $Type
    Case 12 ;~ Offhand
        If $Dmg == 11 And $Req == 7 Then
        Return True
        Else
        Return False
        EndIf
    Case 24 ;~ Shield
        If $Dmg == 15 And $Req == 7 Then
        Return True
        Else
        Return False
        EndIf
    Case 27 ;~ Sword
        If $Dmg == 21 And $Req == 7 Then
        Return True
        Else
        Return False
        EndIf
    EndSwitch
 EndFunc
 Func IsReq8Max($aItem)
    Local $Type = DllStructGetData($aItem, "Type")
    Local $Rarity = GetRarity($aItem)
    Local $MaxDmgOffHand = GetItemMaxReq8($aItem)
    Local $MaxDmgShield = GetItemMaxReq8($aItem)
    Local $MaxDmgSword = GetItemMaxReq8($aItem)

    Switch $Rarity
    Case 2624 ;~ Gold
        Switch $Type
        Case 12 ;~ Offhand
        If $MaxDmgOffHand = True Then
            Return True
        Else
            Return False
        EndIf
        Case 24 ;~ Shield
        If $MaxDmgShield = True Then
            Return True
        Else
            Return False
        EndIf
        Case 27 ;~ Sword
        If $MaxDmgSword = True Then
            Return True
        Else
            Return False
        EndIf
        EndSwitch
    Case 2623 ;~ Purple?
        Switch $Type
        Case 12 ;~ Offhand
        If $MaxDmgOffHand = True Then
            Return True
        Else
            Return False
        EndIf
        Case 24 ;~ Shield
        If $MaxDmgShield = True Then
            Return True
        Else
            Return False
        EndIf
        Case 27 ;~ Sword
        If $MaxDmgSword = True Then
            Return True
        Else
            Return False
        EndIf
        EndSwitch
    Case 2626 ;~ Blue?
        Switch $Type
        Case 12 ;~ Offhand
        If $MaxDmgOffHand = True Then
            Return True
        Else
            Return False
        EndIf
        Case 24 ;~ Shield
        If $MaxDmgShield = True Then
            Return True
        Else
            Return False
        EndIf
        Case 27 ;~ Sword
        If $MaxDmgSword = True Then
            Return True
        Else
            Return False
        EndIf
        EndSwitch
    EndSwitch
    Return False
 EndFunc
  Func IsReq7Max($aItem)
    Local $Type = DllStructGetData($aItem, "Type")
    Local $Rarity = GetRarity($aItem)
    Local $MaxDmgOffHand = GetItemMaxReq7($aItem)
    Local $MaxDmgShield = GetItemMaxReq7($aItem)
    Local $MaxDmgSword = GetItemMaxReq7($aItem)

    Switch $Rarity
    Case 2624 ;~ Gold
        Switch $Type
        Case 12 ;~ Offhand
        If $MaxDmgOffHand = True Then
            Return True
        Else
            Return False
        EndIf
        Case 24 ;~ Shield
        If $MaxDmgShield = True Then
            Return True
        Else
            Return False
        EndIf
        Case 27 ;~ Sword
        If $MaxDmgSword = True Then
            Return True
        Else
            Return False
        EndIf
        EndSwitch
    Case 2623 ;~ Purple?
        Switch $Type
        Case 12 ;~ Offhand
        If $MaxDmgOffHand = True Then
            Return True
        Else
            Return False
        EndIf
        Case 24 ;~ Shield
        If $MaxDmgShield = True Then
            Return True
        Else
            Return False
        EndIf
        Case 27 ;~ Sword
        If $MaxDmgSword = True Then
            Return True
        Else
            Return False
        EndIf
        EndSwitch
    Case 2626 ;~ Blue?
        Switch $Type
        Case 12 ;~ Offhand
        If $MaxDmgOffHand = True Then
            Return True
        Else
            Return False
        EndIf
        Case 24 ;~ Shield
        If $MaxDmgShield = True Then
            Return True
        Else
            Return False
        EndIf
        Case 27 ;~ Sword
        If $MaxDmgSword = True Then
            Return True
        Else
            Return False
        EndIf
        EndSwitch
    EndSwitch
    Return False
 EndFunc

 Func IsPcon($aItem)
    Local $ModelID = DllStructGetData($aItem, "ModelID")

    Switch $ModelID
    Case 910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 19172, 19173, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682
        Return True ; Alcohol
    Case 6376, 21809, 21810, 21813, 36683
        Return True ; Party
    Case 21492, 21812, 22269, 22644, 22752, 28436
        Return True ; Sweets
    Case 6370, 21488, 21489, 22191, 26784, 28433
        Return True ; DP Removal
    Case 15837, 21490, 30648, 31020
        Return True ; Tonic
    EndSwitch
    Return False
 EndFunc
 Func IsSpecialItem($aItem)
    Local $ModelID = DllStructGetData($aItem, "ModelID")
    Local $ExtraID = DllStructGetData($aItem, "ExtraID")

    Switch $ModelID
    Case 5656, 18345, 21491, 37765, 21833, 28433, 28434
        Return True ; Special - ToT etc
    Case 22751
        Return True ; Lockpicks
    Case 27047
        Return True ; Glacial Stones
    Case 146
        If $ExtraID = 10 Or $ExtraID = 12 Then
        Return True ; Black & White Dye
        Else
        Return False
        EndIf
    Case 24353, 24354
        Return True ; Chalice & Rin Relics
    Case 27052
        Return True ; Superb Charr Carving
    Case 522
        Return True ; Dark Remains
    Case 3746, 22280
        Return True ; Underworld & FOW Scroll
    Case 819
        Return True ; Dragon Root
    Case 35121
        Return True ; War supplies
    Case 36985
        Return True ; Commendations
    EndSwitch
    Return False
 EndFunc
 Func IsEliteTome($aItem)
    Local $ModelID = DllStructGetData($aItem, "ModelID")

    Switch $ModelID
    Case 21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795
        Return True ; All Elite Tomes
    EndSwitch
    Return False
 EndFunc
 Func IsRegularTome($aItem)
    Local $ModelID = DllStructGetData($aItem, "ModelID")

    Switch $ModelID
    Case 21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805
        Return True
    EndSwitch
    Return False
 EndFunc
 #endregion added 31/03/2018
 #region added 05/04/2018
 Func IsPerfectShield($aItem)
    Local $ModStruct = GetModStruct($aItem)
    ; Universal mods
    Local $Plus30 = StringInStr($ModStruct, "1E4823", 0, 1) ; Mod struct for +30 (shield only?)
    Local $Minus3Hex = StringInStr($ModStruct, "3009820", 0, 1) ; Mod struct for -3wHex (shield only?)
    Local $Minus2Stance = StringInStr($ModStruct, "200A820", 0, 1) ; Mod Struct for -2Stance
    Local $Minus2Ench = StringInStr($ModStruct, "2008820", 0, 1) ; Mod struct for -2Ench
    Local $Plus45Stance = StringInStr($ModStruct, "02D8823", 0, 1) ; For +45Stance
    Local $Plus45Ench = StringInStr($ModStruct, "02D6823", 0, 1) ; Mod struct for +45ench
    Local $Plus44Ench = StringInStr($ModStruct, "02C6823", 0, 1) ; For +44/+10Demons
    Local $Minus520 = StringInStr($ModStruct, "5147820", 0, 1) ; For -5(20%)
    ; +1 20% Mods ~ Updated 08/10/2018 - FINISHED
    Local $PlusIllusion = StringInStr($ModStruct, "0118240", 0, 1) ; +1 Illu 20%
    Local $PlusDomination = StringInStr($ModStruct, "0218240", 0, 1) ; +1 Dom 20%
    Local $PlusInspiration = StringInStr($ModStruct, "0318240", 0, 1) ; +1 Insp 20%
    Local $PlusBlood = StringInStr($ModStruct, "0418240", 0, 1) ; +1 Blood 20%
    Local $PlusDeath = StringInStr($ModStruct, "0518240", 0, 1) ; +1 Death 20%
    Local $PlusSoulReap = StringInStr($ModStruct, "0618240", 0, 1) ; +1 SoulR 20%
    Local $PlusCurses = StringInStr($ModStruct, "0718240", 0, 1) ; +1 Curses 20%
    Local $PlusAir = StringInStr($ModStruct, "0818240", 0, 1) ; +1 Air 20%
    Local $PlusEarth = StringInStr($ModStruct, "0918240", 0, 1) ; +1 Earth 20%
    Local $PlusFire = StringInStr($ModStruct, "0A18240", 0, 1) ; +1 Fire 20%
    Local $PlusWater = StringInStr($ModStruct, "0B18240", 0, 1) ; +1 Water 20%
    Local $PlusHealing = StringInStr($ModStruct, "0D18240", 0, 1) ; +1 Heal 20%
    Local $PlusSmite = StringInStr($ModStruct, "0E18240", 0, 1) ; +1 Smite 20%
    Local $PlusProt = StringInStr($ModStruct, "0F18240", 0, 1) ; +1 Prot 20%
    Local $PlusDivine = StringInStr($ModStruct, "1018240", 0, 1) ; +1 Divine 20%
    ; +10vsMonster Mods
    Local $PlusDemons = StringInStr($ModStruct, "A0848210", 0, 1) ; +10vs Demons
    Local $PlusDragons = StringInStr($ModStruct, "A0948210", 0, 1) ; +10vs Dragons
    Local $PlusPlants = StringInStr($ModStruct, "A0348210", 0, 1) ; +10vs Plants
    Local $PlusUndead = StringInStr($ModStruct, "A0048210", 0, 1) ; +10vs Undead
    Local $PlusTengu = StringInStr($ModStruct, "A0748210", 0, 1) ; +10vs Tengu
    ; New +10vsMonster Mods 07/10/2018 - Thanks to Savsuds
    Local $PlusCharr = StringInStr($ModStruct, "0A014821", 0 ,1) ; +10vs Charr
    Local $PlusTrolls = StringInStr($ModStruct, "0A024821", 0 ,1) ; +10vs Trolls
    Local $PlusSkeletons = StringInStr($ModStruct, "0A044821", 0 ,1) ; +10vs Skeletons
    Local $PlusGiants = StringInStr($ModStruct, "0A054821", 0 ,1) ; +10vs Giants
    Local $PlusDwarves = StringInStr($ModStruct, "0A064821", 0 ,1) ; +10vs Dwarves
    Local $PlusDragons = StringInStr($ModStruct, "0A094821", 0 ,1) ; +10vs Dragons
    Local $PlusOgres = StringInStr($ModStruct, "0A0A4821", 0 ,1) ; +10vs Ogres
    ; +10vs Dmg
    Local $PlusPiercing = StringInStr($ModStruct, "A0118210", 0, 1) ; +10vs Piercing
    Local $PlusLightning = StringInStr($ModStruct, "A0418210", 0, 1) ; +10vs Lightning
    Local $PlusVsEarth = StringInStr($ModStruct, "A0B18210", 0, 1) ; +10vs Earth
    Local $PlusCold = StringInStr($ModStruct, "A0318210", 0, 1) ; +10 vs Cold
    Local $PlusSlashing = StringInStr($ModStruct, "A0218210", 0, 1) ; +10vs Slashing
    Local $PlusVsFire = StringInStr($ModStruct, "A0518210", 0, 1) ; +10vs Fire
    ; New +10vs Dmg 08/10/2018
    Local $PlusBlunt = StringInStr($ModStruct, "A0018210", 0, 1) ; +10vs Blunt

    If $Plus30 > 0 Then
        If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
        Return True
        ElseIf $PlusCharr > 0 Or $PlusTrolls > 0 Or $PlusSkeletons > 0 Or $PlusGiants > 0 Or $PlusDwarves > 0 Or $PlusDragons > 0 Or $PlusOgres > 0 Or $PlusBlunt > 0 Then
        Return True
        ElseIf $PlusDomination > 0 Or $PlusDivine > 0 Or $PlusSmite > 0 Or $PlusHealing > 0 Or $PlusProt > 0 Or $PlusFire > 0 Or $PlusWater > 0 Or $PlusAir > 0 Or $PlusEarth > 0 Or $PlusDeath > 0 Or $PlusBlood > 0 Or $PlusIllusion > 0 Or $PlusInspiration > 0 Or $PlusSoulReap > 0 Or $PlusCurses > 0 Then
        Return True
        ElseIf $Minus2Stance > 0 Or $Minus2Ench > 0 Or $Minus520 > 0 Or $Minus3Hex > 0 Then
        Return True
        Else
        Return False
        EndIf
    EndIf
    If $Plus45Ench > 0 Then
        If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
        Return True
        ElseIf $PlusCharr > 0 Or $PlusTrolls > 0 Or $PlusSkeletons > 0 Or $PlusGiants > 0 Or $PlusDwarves > 0 Or $PlusDragons > 0 Or $PlusOgres > 0 Or $PlusBlunt > 0 Then
        Return True
        ElseIf $Minus2Ench > 0 Then
        Return True
        ElseIf $PlusDomination > 0 Or $PlusDivine > 0 Or $PlusSmite > 0 Or $PlusHealing > 0 Or $PlusProt > 0 Or $PlusFire > 0 Or $PlusWater > 0 Or $PlusAir > 0 Or $PlusEarth > 0 Or $PlusDeath > 0 Or $PlusBlood > 0 Or $PlusIllusion > 0 Or $PlusInspiration > 0 Or $PlusSoulReap > 0 Or $PlusCurses > 0 Then
        Return True
        Else
        Return False
        EndIf
    EndIf
    If $Minus2Ench > 0 Then
        If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
        Return True
        ElseIf $PlusCharr > 0 Or $PlusTrolls > 0 Or $PlusSkeletons > 0 Or $PlusGiants > 0 Or $PlusDwarves > 0 Or $PlusDragons > 0 Or $PlusOgres > 0 Or $PlusBlunt > 0 Then
        Return True
        EndIf
    EndIf
    If $Plus44Ench > 0 Then
        If $PlusDemons > 0 Then
        Return True
        EndIf
    EndIf
    If $Plus45Stance > 0 Then
        If $Minus2Stance > 0 Then
        Return True
        EndIf
    EndIf
    Return False
 EndFunc
 Func IsPerfectStaff($aItem)
    Local $ModStruct = GetModStruct($aItem)
    Local $A = GetItemAttribute($aItem)
    ; Ele mods
    Local $Fire20Casting = StringInStr($ModStruct, "0A141822", 0, 1) ; Mod struct for 20% fire
    Local $Water20Casting = StringInStr($ModStruct, "0B141822", 0, 1) ; Mod struct for 20% water
    Local $Air20Casting = StringInStr($ModStruct, "08141822", 0, 1) ; Mod struct for 20% air
    Local $Earth20Casting = StringInStr($ModStruct, "09141822", 0, 1) ; Mod Struct for 20% Earth
    Local $Energy20Casting = StringInStr($ModStruct, "0C141822", 0, 1) ; Mod Struct for 20% Energy Storage (Doesnt drop)
    ; Monk mods
    Local $Smite20Casting = StringInStr($ModStruct, "0E141822", 0, 1) ; Mod struct for 20% smite
    Local $Divine20Casting = StringInStr($ModStruct, "10141822", 0, 1) ; Mod struct for 20% divine
    Local $Healing20Casting = StringInStr($ModStruct, "0D141822", 0, 1) ; Mod struct for 20% healing
    Local $Protection20Casting = StringInStr($ModStruct, "0F141822", 0, 1) ; Mod struct for 20% protection
    ; Rit mods
    Local $Channeling20Casting = StringInStr($ModStruct, "22141822", 0, 1) ; Mod struct for 20% channeling
    Local $Restoration20Casting = StringInStr($ModStruct, "21141822", 0, 1) ; Mod Struct for 20% Restoration
    Local $Communing20Casting = StringInStr($ModStruct, "20141822", 0, 1) ; Mod Struct for 20% Communing
    Local $Spawning20Casting = StringInStr($ModStruct, "24141822", 0, 1) ; Mod Struct for 20% Spawning (Unconfirmed)
    ; Mes mods
    Local $Illusion20Casting = StringInStr($ModStruct, "01141822", 0, 1) ; Mod struct for 20% Illusion
    Local $Domination20Casting = StringInStr($ModStruct, "02141822", 0, 1) ; Mod struct for 20% domination
    Local $Inspiration20Casting = StringInStr($ModStruct, "03141822", 0, 1) ; Mod struct for 20% Inspiration
    ; Necro mods
    Local $Death20Casting = StringInStr($ModStruct, "05141822", 0, 1) ; Mod struct for 20% death
    Local $Blood20Casting = StringInStr($ModStruct, "04141822", 0, 1) ; Mod Struct for 20% Blood
    Local $SoulReap20Casting = StringInStr($ModStruct, "06141822", 0, 1) ; Mod Struct for 20% Soul Reap (Doesnt drop)
    Local $Curses20Casting = StringInStr($ModStruct, "07141822", 0, 1) ; Mod Struct for 20% Curses

    Switch $A
    Case 1 ; Illusion
        If $Illusion20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 2 ; Domination
        If $Domination20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 3 ; Inspiration - Doesnt Drop
        If $Inspiration20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 4 ; Blood
        If $Blood20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 5 ; Death
        If $Death20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 6 ; SoulReap - Doesnt Drop
        If $SoulReap20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 7 ; Curses
        If $Curses20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 8 ; Air
        If $Air20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 9 ; Earth
        If $Earth20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 10 ; Fire
        If $Fire20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 11 ; Water
        If $Water20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 12 ; Energy Storage
        If $Air20Casting > 0 Or $Earth20Casting > 0 Or $Fire20Casting > 0 Or $Water20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 13 ; Healing
        If $Healing20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 14 ; Smiting
        If $Smite20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 15 ; Protection
        If $Protection20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 16 ; Divine
        If $Healing20Casting > 0 Or $Protection20Casting > 0 Or $Divine20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 32 ; Communing
        If $Communing20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 33 ; Restoration
        If $Restoration20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 34 ; Channeling
        If $Channeling20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    Case 36 ; Spawning - Unconfirmed
        If $Spawning20Casting > 0 Then
        Return True
        Else
        Return False
        EndIf
    EndSwitch
    Return False
 EndFunc
 Func IsPerfectCaster($aItem)
    Local $ModStruct = GetModStruct($aItem)
    Local $A = GetItemAttribute($aItem)
    ; Universal mods
    Local $PlusFive = StringInStr($ModStruct, "5320823", 0, 1) ; Mod struct for +5^50
    Local $PlusFiveEnch = StringInStr($ModStruct, "500F822", 0, 1)
    Local $10Cast = StringInStr($ModStruct, "A0822", 0, 1) ; Mod struct for 10% cast
    Local $10Recharge = StringInStr($ModStruct, "AA823", 0, 1) ; Mod struct for 10% recharge
    ; Ele mods
    Local $Fire20Casting = StringInStr($ModStruct, "0A141822", 0, 1) ; Mod struct for 20% fire
    Local $Fire20Recharge = StringInStr($ModStruct, "0A149823", 0, 1)
    Local $Water20Casting = StringInStr($ModStruct, "0B141822", 0, 1) ; Mod struct for 20% water
    Local $Water20Recharge = StringInStr($ModStruct, "0B149823", 0, 1)
    Local $Air20Casting = StringInStr($ModStruct, "08141822", 0, 1) ; Mod struct for 20% air
    Local $Air20Recharge = StringInStr($ModStruct, "08149823", 0, 1)
    Local $Earth20Casting = StringInStr($ModStruct, "09141822", 0, 1)
    Local $Earth20Recharge = StringInStr($ModStruct, "09149823", 0, 1)
    Local $Energy20Casting = StringInStr($ModStruct, "0C141822", 0, 1)
    Local $Energy20Recharge = StringInStr($ModStruct, "0C149823", 0, 1)
    ; Monk mods
    Local $Smiting20Casting = StringInStr($ModStruct, "0E141822", 0, 1) ; Mod struct for 20% smite
    Local $Smiting20Recharge = StringInStr($ModStruct, "0E149823", 0, 1)
    Local $Divine20Casting = StringInStr($ModStruct, "10141822", 0, 1) ; Mod struct for 20% divine
    Local $Divine20Recharge = StringInStr($ModStruct, "10149823", 0, 1)
    Local $Healing20Casting = StringInStr($ModStruct, "0D141822", 0, 1) ; Mod struct for 20% healing
    Local $Healing20Recharge = StringInStr($ModStruct, "0D149823", 0, 1)
    Local $Protection20Casting = StringInStr($ModStruct, "0F141822", 0, 1) ; Mod struct for 20% protection
    Local $Protection20Recharge = StringInStr($ModStruct, "0F149823", 0, 1)
    ; Rit mods
    Local $Channeling20Casting = StringInStr($ModStruct, "22141822", 0, 1) ; Mod struct for 20% channeling
    Local $Channeling20Recharge = StringInStr($ModStruct, "22149823", 0, 1)
    Local $Restoration20Casting = StringInStr($ModStruct, "21141822", 0, 1)
    Local $Restoration20Recharge = StringInStr($ModStruct, "21149823", 0, 1)
    Local $Communing20Casting = StringInStr($ModStruct, "20141822", 0, 1)
    Local $Communing20Recharge = StringInStr($ModStruct, "20149823", 0, 1)
    Local $Spawning20Casting = StringInStr($ModStruct, "24141822", 0, 1) ; Spawning - Unconfirmed
    Local $Spawning20Recharge = StringInStr($ModStruct, "24149823", 0, 1) ; Spawning - Unconfirmed
    ; Mes mods
    Local $Illusion20Recharge = StringInStr($ModStruct, "01149823", 0, 1)
    Local $Illusion20Casting = StringInStr($ModStruct, "01141822", 0, 1)
    Local $Domination20Casting = StringInStr($ModStruct, "02141822", 0, 1) ; Mod struct for 20% domination
    Local $Domination20Recharge = StringInStr($ModStruct, "02149823", 0, 1) ; Mod struct for 20% domination recharge
    Local $Inspiration20Recharge = StringInStr($ModStruct, "03149823", 0, 1)
    Local $Inspiration20Casting = StringInStr($ModStruct, "03141822", 0, 1)
    ; Necro mods
    Local $Death20Casting = StringInStr($ModStruct, "05141822", 0, 1) ; Mod struct for 20% death
    Local $Death20Recharge = StringInStr($ModStruct, "05149823", 0, 1)
    Local $Blood20Recharge = StringInStr($ModStruct, "04149823", 0, 1)
    Local $Blood20Casting = StringInStr($ModStruct, "04141822", 0, 1)
    Local $SoulReap20Recharge = StringInStr($ModStruct, "06149823", 0, 1)
    Local $SoulReap20Casting = StringInStr($ModStruct, "06141822", 0, 1)
    Local $Curses20Recharge = StringInStr($ModStruct, "07149823", 0, 1)
    Local $Curses20Casting = StringInStr($ModStruct, "07141822", 0, 1)

    Switch $A
    Case 1 ; Illusion
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Illusion20Casting > 0 Or $Illusion20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Illusion20Recharge > 0 Or $Illusion20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Illusion20Recharge > 0 Then
        If $Illusion20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 2 ; Domination
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Domination20Casting > 0 Or $Domination20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Domination20Recharge > 0 Or $Domination20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Domination20Recharge > 0 Then
        If $Domination20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 3 ; Inspiration
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Inspiration20Casting > 0 Or $Inspiration20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Inspiration20Recharge > 0 Or $Inspiration20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Inspiration20Recharge > 0 Then
        If $Inspiration20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 4 ; Blood
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Blood20Casting > 0 Or $Blood20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Blood20Recharge > 0 Or $Blood20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Blood20Recharge > 0 Then
        If $Blood20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 5 ; Death
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Death20Casting > 0 Or $Death20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Death20Recharge > 0 Or $Death20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Death20Recharge > 0 Then
        If $Death20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 6 ; SoulReap - Doesnt drop?
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $SoulReap20Casting > 0 Or $SoulReap20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $SoulReap20Recharge > 0 Or $SoulReap20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $SoulReap20Recharge > 0 Then
        If $SoulReap20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 7 ; Curses
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Curses20Casting > 0 Or $Curses20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Curses20Recharge > 0 Or $Curses20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Curses20Recharge > 0 Then
        If $Curses20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 8 ; Air
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Air20Casting > 0 Or $Air20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Air20Recharge > 0 Or $Air20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Air20Recharge > 0 Then
        If $Air20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 9 ; Earth
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Earth20Casting > 0 Or $Earth20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Earth20Recharge > 0 Or $Earth20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Earth20Recharge > 0 Then
        If $Earth20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 10 ; Fire
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Fire20Casting > 0 Or $Fire20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Fire20Recharge > 0 Or $Fire20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Fire20Recharge > 0 Then
        If $Fire20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 11 ; Water
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Water20Casting > 0 Or $Water20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Water20Recharge > 0 Or $Water20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Water20Recharge > 0 Then
        If $Water20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 12 ; Energy Storage
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Energy20Casting > 0 Or $Energy20Recharge > 0 Or $Water20Casting > 0 Or $Water20Recharge > 0 Or $Fire20Casting > 0 Or $Fire20Recharge > 0 Or $Earth20Casting > 0 Or $Earth20Recharge > 0 Or $Air20Casting > 0 Or $Air20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Energy20Recharge > 0 Or $Energy20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Or $Water20Casting > 0 Or $Water20Recharge > 0 Or $Fire20Casting > 0 Or $Fire20Recharge > 0 Or $Earth20Casting > 0 Or $Earth20Recharge > 0 Or $Air20Casting > 0 Or $Air20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Energy20Recharge > 0 Then
        If $Energy20Casting > 0 Then
            Return True
        EndIf
        EndIf
        If $10Cast > 0 Or $10Recharge > 0 Then
        If $Water20Casting > 0 Or $Water20Recharge > 0 Or $Fire20Casting > 0 Or $Fire20Recharge > 0 Or $Earth20Casting > 0 Or $Earth20Recharge > 0 Or $Air20Casting > 0 Or $Air20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 13 ; Healing
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Healing20Casting > 0 Or $Healing20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Healing20Recharge > 0 Or $Healing20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Healing20Recharge > 0 Then
        If $Healing20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 14 ; Smiting
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Smiting20Casting > 0 Or $Smiting20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Smiting20Recharge > 0 Or $Smiting20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Smiting20Recharge > 0 Then
        If $Smiting20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 15 ; Protection
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Protection20Casting > 0 Or $Protection20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Protection20Recharge > 0 Or $Protection20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Protection20Recharge > 0 Then
        If $Protection20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 16 ; Divine
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Divine20Casting > 0 Or $Divine20Recharge > 0 Or $Healing20Casting > 0 Or $Healing20Recharge > 0 Or $Smiting20Casting > 0 Or $Smiting20Recharge > 0 Or $Protection20Casting > 0 Or $Protection20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Divine20Recharge > 0 Or $Divine20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Or $Healing20Casting > 0 Or $Healing20Recharge > 0 Or $Smiting20Casting > 0 Or $Smiting20Recharge > 0 Or $Protection20Casting > 0 Or $Protection20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Divine20Recharge > 0 Then
        If $Divine20Casting > 0 Then
            Return True
        EndIf
        EndIf
        If $10Cast > 0 Or $10Recharge > 0 Then
        If $Healing20Casting > 0 Or $Healing20Recharge > 0 Or $Smiting20Casting > 0 Or $Smiting20Recharge > 0 Or $Protection20Casting > 0 Or $Protection20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 32 ; Communing
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Communing20Casting > 0 Or $Communing20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Communing20Recharge > 0 Or $Communing20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Communing20Recharge > 0 Then
        If $Communing20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 33 ; Restoration
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Restoration20Casting > 0 Or $Restoration20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Restoration20Recharge > 0 Or $Restoration20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Restoration20Recharge > 0 Then
        If $Restoration20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 34 ; Channeling
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Channeling20Casting > 0 Or $Channeling20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Channeling20Recharge > 0 Or $Channeling20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Channeling20Recharge > 0 Then
        If $Channeling20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    Case 36 ; Spawning - Unconfirmed
        If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
        If $Spawning20Casting > 0 Or $Spawning20Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Spawning20Recharge > 0 Or $Spawning20Casting > 0 Then
        If $10Cast > 0 Or $10Recharge > 0 Then
            Return True
        EndIf
        EndIf
        If $Spawning20Recharge > 0 Then
        If $Spawning20Casting > 0 Then
            Return True
        EndIf
        EndIf
        Return False
    EndSwitch
    Return False
 EndFunc
 Func IsRareRune($aItem)
    Local $ModStruct = GetModStruct($aItem)
    Local $SupVigor = StringInStr($ModStruct, "C202EA27", 0, 1) ; Mod struct for Sup vigor rune
    Local $WindWalker = StringInStr($ModStruct, "040430A5060518A7", 0, 1) ; Windwalker insig
    Local $MinorMyst = StringInStr($ModStruct, "05033025012CE821", 0, 1) ; Minor Mysticism
    ; Not Worth Anything - Local $SupEarthPrayers = StringInStr($ModStruct, "32BE82109033025", 0, 1) ; Sup earth prayers
    ; Not Worth Anything - Local $Prodigy = StringInStr($ModStruct, "C60330A5000528A7", 0, 1) ; Prodigy insig
    ; Not Worth Anything - Local $SupDom = StringInStr($ModStruct, "30250302E821770", 0, 1) ; Superior Domination
    Local $Shamans = StringInStr($ModStruct, "080430A50005F8A", 0, 1) ; Shamans insig
    Local $MinorSpawning = StringInStr($ModStruct, "0124E821", 0, 1) ; Minor Spawning
    Local $MinorEnergyStorage = StringInStr($ModStruct, "010CE821", 0, 1) ; Minor Energy Storage
    Local $MinorFastCasting = StringInStr($ModStruct, "0100E821", 0, 1) ; Minor Fast Casting
    Local $MinorIllusion = StringInStr($ModStruct, "0101E821", 0, 1) ; Minor Illusion
    Local $MinorSoulReap = StringInStr($ModStruct, "0106E821", 0, 1) ; Minor SoulReaping

    If $SupVigor > 0 Or $WindWalker > 0 Or $MinorMyst > 0 Or $Shamans > 0 Or $MinorSpawning > 0 Or $MinorEnergyStorage > 0 Or $MinorFastCasting > 0 Or $MinorIllusion > 0 Or $MinorSoulReap > 0 Then
        Return True
    Else
        Return False
    EndIf
 EndFunc
Func IsRareMaterial($aItem)
    Local $M = DllStructGetData($aItem, "ModelID")

    Switch $M
    Case 937, 938, 935, 931, 932, 936, 930, 945
    Return True ; Rare Mats
    EndSwitch
    Return False
EndFunc

Func UseItemEx($lItem) ; Send ModelID of the item to use
    Local $aBag
    Local $aItem
    Sleep(200)
    For $i = 1 To 4
    $aBag = GetBag($i)
    For $j = 1 To DllStructGetData($aBag, "Slots")
        $aItem = GetItemBySlot($aBag, $j)
        If DllStructGetData($aItem, "ModelID") == $lItem Then
            UseItem($aItem)
            Return True
        EndIf
    Next
    Next
EndFunc

Func EquipWeaponByModelID($lItem)
    Local $aBag
    Local $aItem
    Sleep(200)
    For $i = 1 To 4
    $aBag = GetBag($i)
    For $j = 1 To DllStructGetData($aBag, "Slots")
        $aItem = GetItemBySlot($aBag, $j)
        If DllStructGetData($aItem, "ModelID") == $lItem Then
            EquipItem($aItem)
            Return True
        EndIf
    Next
    Next
EndFunc
Func ReturnItemExists($lItem)
    Local $aBag
    Local $aItem
    Sleep(200)
    For $i = 1 To 4
    $aBag = GetBag($i)
    For $j = 1 To DllStructGetData($aBag, "Slots")
        $aItem = GetItemBySlot($aBag, $j)
        If DllStructGetData($aItem, "ModelID") == $lItem Then
            Out("Found Item Model: " & $lItem & " in slot: " & $j)
            Return $aItem
        Else
            Out("Couldnt find specified item")
            Return False
        EndIf
    Next
    Next
EndFunc
Func ReturnItemModelIDBySlot($lBag, $lSlot)
    Local $aBag
    Local $aItem
    Sleep(200)
    $aItem = GetItemBySlot($lBag, $lSlot)
    If DllStructGetData($aItem, "ModelID") <> 0 Then
    Return DllStructGetData($aItem, "ModelID")
    Else
    Out("Couldnt find an item in that slot")
    Return 0
    EndIf
EndFunc

Func PickUpLootEx_Old() ; For general Loot
    Local $lAgent
    Local $lItem
    Local $lDeadlock
    For $i = 1 To GetMaxAgents()
    If GetIsDead(-2) Then Return
        $lAgent = GetAgentByID($i)
        If Not GetIsMovable($lAgent) Then ContinueLoop
        $lItem = GetItemByAgentID($i)
        If CanPickUp($lItem) Then
            _MoveToItem($lAgent)
            Sleep(500)
            Do
            PickUpItem($lItem)
            Until GetAgentExists($lAgent) = False
            $lDeadlock = TimerInit()
            While GetAgentExists($i)
                sleep(50)
                _MoveToItem($lAgent)
                Sleep(500)
                PickUpItem($lItem)
                If GetIsDead(-2) Then Return
                If TimerDiff($lDeadlock) > 10000 Then ExitLoop
            WEnd
        EndIf
    Next
EndFunc

 Func _MoveToItem($agent) ; Carries on staying alive while collecting item
    Local $lMe
    If GetIsDead(-2) Then Return
    $x = DllStructGetData($agent, "x")
    $y = DllStructGetData($agent, "y")
    MoveTo($x, $y)
 EndFunc
 #endregion new 05/04/2018
 #region new 24/04/2018

 Func GoNearestNPCToCoords($x, $y)
    Local $guy, $Me
    Do
        RndSleep(250)
        $guy = GetNearestNPCToCoords($x, $y)
    Until DllStructGetData($guy, 'Id') <> 0
    ChangeTarget($guy)
    RndSleep(250)
    GoNPC($guy)
    RndSleep(250)
    Do
        RndSleep(500)
        Move(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 40)
        RndSleep(500)
        GoNPC($guy)
        RndSleep(250)
        $Me = GetAgentByID(-2)
    Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y')) < 250
    RndSleep(100)
 EndFunc
 #endregion new 24/04/2018


#region 21/05/2018
 Func GetNumberOfAlliesInRangeOfAgent($aAgent = -2, $fMaxDistance = 1012)
    Local $lDistance, $lCount = 0

    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    For $i = 1 To GetMaxAgents()
        $lAgentToCompare = GetAgentByID($i)
        If GetIsDead($lAgentToCompare) <> 0 Then ContinueLoop
        If DllStructGetData($lAgentToCompare, 'Allegiance') = 0x1 Then
            $lDistance = GetDistance($lAgentToCompare, $aAgent)
            If $lDistance < $fMaxDistance Then
                $lCount += 1
                ;ConsoleWrite("Counts: " &$lCount & @CRLF)
            EndIf
        EndIf
    Next
    Return $lCount
 EndFunc
#endregion 21/05/2018

#region 27/05/2018
  Func CheckArea($aX, $aY)
    $ret = False
    $pX = DllStructGetData(GetAgentByID(-2), "X")
    $pY = DllStructGetData(GetAgentByID(-2), "Y")

    If ($pX < $aX + 500) And ($pX > $aX - 500) And ($pY < $aY + 500) And ($pY > $aY - 500) Then
        $ret = True
    EndIf
    Return $ret
  EndFunc

  Func IsNiceMod($aItem)
    Local $ModStruct = GetModStruct($aItem)
    Local $t         = DllStructGetData($aItem, "Type")

    Local $ArmorAlways = StringInStr($ModStruct, "05000821", 0 ,1) ; Armor +5
        If $ArmorAlways > 0 And ($t = 36) Then ; 26 is Staff Head or Wrapping
            Return True
            Return False
        EndIf

    Local $FuriousPrefix = StringInStr($ModStruct, "0A00B823", 0 ,1) ; Axe haft, Dagger Tang, Hammer Haft, Scythe Snathe, Spearhead, Sword Hilt
        If $FuriousPrefix > 0 And ($t = 36) Then
            Return True
            Return False
    EndIf

    Local $HealthAlways = StringInStr($ModStruct, "001E4823", 0 ,1) ; +30 Health
        If $HealthAlways > 0 And ($t = 24 Or $t = 27 Or $t = 36) Then ; 12 is focus core, 26 can be Staff Head or Wrap
            Return True
            Return False
        EndIf

    Local $ofEnchanting = StringInStr($ModStruct, "1400B822", 0 ,1) ; +20% Enchantment Duration
        If $ofEnchanting > 0 And ($t = 26 Or $t = 36) Then ; 26 is Staff Wrapping
            Return True
            Return False
        EndIf


    ; ; +10 armor vs type
    ; Local $NotTheFace = StringInStr($ModStruct, "0A0018A1", 0 ,1) ; Armor +10 (vs Blunt damage)
    ;     If $NotTheFace > 0 Then
    ;         Return True
    ;         Return False
    ; EndIf
    ; Local $LeafOnTheWind = StringInStr($ModStruct, "0A0318A1", 0 ,1) ; Armor +10 (vs Cold damage)
    ;     If $LeafOnTheWind > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $LikeARollingStone = StringInStr($ModStruct, "0A0B18A1", 0 ,1) ; Armor +10 (vs Earth damage)
    ;     If $LikeARollingStone > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $SleepNowInTheFire = StringInStr($ModStruct, "0A0518A1", 0 ,1) ; Armor +10 (vs Fire damage)
    ;     If $SleepNowInTheFire > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $RidersOnTheStorm = StringInStr($ModStruct, "0A0418A1", 0 ,1) ; Armor +10 (vs Lightning damage)
    ;     If $RidersOnTheStorm > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $ThroughThickAndThin = StringInStr($ModStruct, "0A0118A1", 0 ,1) ; Armor +10 (vs Piercing damage)
    ;     If $ThroughThickAndThin > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $TheRiddleOfSteel = StringInStr($ModStruct, "0A0218A1", 0 ,1) ; Armor +10 (vs Slashing damage)
    ;     If $TheRiddleOfSteel > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf


    ; reduce blind dazed cripple -33%
    ; Local $ICanSeeClearlyNow = StringInStr($ModStruct, "00015828", 0 ,1) ; Reduces Blind duration on you by 20%
    ;     If $ICanSeeClearlyNow > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $SwiftAsTheWind = StringInStr($ModStruct, "00035828", 0 ,1) ; Reduces Crippled duration on you by 20%
    ;     If $SwiftAsTheWind > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $SoundnessOfMind = StringInStr($ModStruct, "00075828", 0 ,1) ; Reduces Dazed duration on you by 20%
    ;     If $SoundnessOfMind > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf


    ; 40/40 mods
    Local $HCT20 = StringInStr($ModStruct, "00140828", 0 ,1) ; Halves casting time of spells of item's attribute (Chance: 20%)
        If $HCT20 > 0 And ($t = 12 Or $t = 22 Or $t = 26) Then; 12 is Focus core of aptitude, 22 is Inscription Aptitude Not Attitude, 26 is Inscription or Adept Staff head
            Return True
            Return False
        EndIf

    Local $HSR20 = StringInStr($ModStruct, "00142828", 0, 1) ; Halves skill recharge of spells (Chance: 20%)
        If $HSR20 > 0 And ($t = 12 Or $t = 22) Then ; 12 is Forget Me Not, 22 is Wand Wrapping of Memory
            Return True
            Return False
        EndIf

    Return False
  EndFunc


    ; Axe (Type 2)
    ; Bow (Type 5)
    ; Runes (Type 8)
    ; Offhand (Type 12)
    ; Hammer (Type 15)
    ; Wand (Type 22)
    ; Shield (Type 24)
    ; Staff (Type 26)
    ; Sword (Type 27)
    ; Dagger  (Type 32)
    ; Scythe (Type 35)
    ; Spear (Type 36)
#EndRegion Other Functions

#region new 03/03/2019
Func GetItemMaxDmg($aItem)
    If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
    Local $lModString = GetModStruct($aItem)
    Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
    If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
    If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
    If $lPos = 0 Then Return 0
    Return Int("0x" & StringMid($lModString, $lPos - 2, 2))
 EndFunc

 Func GetItemMaxReq8($aItem)
    Local $Type = DllStructGetData($aItem, "Type")
    Local $Dmg = GetItemMaxDmg($aItem)
    Local $Req = GetItemReq($aItem)

    Switch $Type
    Case 12 ;~ Offhand
        If $Dmg == 12 And $Req == 8 Then
        Return True
        Else
        Return False
        EndIf
    Case 24 ;~ Shield
        If $Dmg == 16 And $Req == 8 Then
        Return True
        Else
        Return False
        EndIf
    Case 27 ;~ Sword
        If $Dmg == 22 And $Req == 8 Then
        Return True
        Else
        Return False
        EndIf
    EndSwitch
 EndFunc


 Func IsRareSkin($aItem)
    Local $ModelID = DllStructGetData($aItem, "ModelID")

    Switch $ModelID
    Case 399
        Return True ; Crystallines
    Case 344
        Return True ; Magmas Shield
    Case 603
        Return True ; Orrian Earth Staff
    Case 391
        Return True ; Raven Staff
    Case 926
        Return True ; Cele Scepter All Attribs
    Case 942, 943
        Return True ; Cele Shields (Str + Tact)
    Case 858, 776, 789
        Return True ; Paper Fans (Divine, Soul, Energy)
    Case 905
        Return True ; Divine Scroll (Canthan)
    Case 785
        Return True ; Celestial Staff all attribs.
    Case 1022, 874, 875
        Return True ; Jug - DF, SF, ES
    Case 952, 953
        Return True ; Kappa Shields (Str + Tact)
    Case 736, 735, 778, 777, 871, 872, 741, 870, 873, 871, 872, 869, 744, 1101
        Return True ; All rare skins from Cantha Mainland
    Case 945, 944, 940, 941, 950, 951, 1320, 1321, 789, 896, 875
        Return True ; All rare skins from Dragon Moss
    Case 959, 960
        Return True ; Plagueborn Shields
    Case 1026, 1027
        Return True ; Plagueborn Focus (ES, DF)
    Case 341
        Return True ; Stone Summit Shield
    Case 342
        Return True ; Summit Warlord Shield
    Case 1985
        Return True ; Eaglecrest Axe
    Case 2048
        Return True ; Wingcrest Maul
    Case 2071
        Return True ; Voltaic Spear
    Case 1953, 1954, 1955, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969, 1970, 1971, 1972, 1973
        Return True ; Froggy Scepters
    Case 1197, 1556, 1569, 1439, 1563
        Return True ; Elonian Swords (Colossal, Ornate, Tattooed etc)
    Case 21439
        Return True ; Polar Bear
    Case 1896
        Return True ; Draconic Aegis - Str
    Case 36674
        Return True ; Envoy Staff (Divine?)
    Case 1976
        Return True ; Emerald Blade
    Case 1978
        Return True ; Draconic Scythe
    Case 32823
        Return True ; Dhuums Soul Reaper
    Case 208
        Return True ; Ascalon War Hammer
    Case 1315
        Return True ; Gloom Shield (Str)
    Case 1039
        Return True ; Zodiac Shield (Str)
    Case 1037
        Return True ; Exalted Aegis (Str)
    Case 1320
        Return True ; Guardian Of The Hunt (Str)
    Case 956
        Return True ; Outcast Shield (Str)
    Case 336
        Return True ; Shadow Shield (OS - Str)
    Case 120
        Return True ; Sephis Axe (OS)
    Case 114
        Return True ; Dwarven Axe (OS)
    Case 794
        Return True ; Oni Blade
    Case 118
        Return True ; Serpent Axe (OS)
    Case 795
        Return True ; Golden Phoenix Blade (OS)
    Case 1052
        Return True ; Darkwing Defender (Str)
    Case 2236
        Return True ; Enamaled Shield (Tact)
    EndSwitch
    Return False
 EndFunc


Func IsRareScythe($aItem)
    Local $T = DllStructGetData($aItem, 'Type')
    Local $IsReq6 = IsReq6Max($aItem)
    Local $IsReq5 = IsReq5Max($aItem)
    Local $IsReq4 = IsReq4Max($aItem)
    Local $IsReq3 = IsReq3Max($aItem)
    Local $IsReq2 = IsReq2Max($aItem)
    Local $IsReq1 = IsReq1Max($aItem)
    Local $IsReq0 = IsReq0Max($aItem)

    Switch $T
    Case 35 ;~ Scythe
    If $IsReq6 = True Then
        Return True
    ;~    ElseIf $IsReq5 = True Then
    ;~ 	  Return True
    ;~    ElseIf $IsReq4 = True Then
    ;~ 	  Return True
    ;~    ElseIf $IsReq3 = True Then
    ;~ 	  Return True
    ;~    ElseIf $IsReq2 = True Then
    ;~ 	  Return True
    ;~    ElseIf $IsReq1 = True Then
    ;~ 	  Return True
    ElseIf $IsReq0 = True Then
    Return True
    Else
    Return False
    EndIf
    EndSwitch
EndFunc
Func IsRareDaggers($aItem)
    Local $T = DllStructGetData($aItem, 'Type')
    Local $IsReq6 = IsReq6Max($aItem)
    Local $IsReq5 = IsReq5Max($aItem)
    Local $IsReq4 = IsReq4Max($aItem)
    Local $IsReq3 = IsReq3Max($aItem)
    Local $IsReq2 = IsReq2Max($aItem)
    Local $IsReq1 = IsReq1Max($aItem)
    Local $IsReq0 = IsReq0Max($aItem)

    Switch $T
    Case 32 ;~ Daggers
    If $IsReq6 = True Then
    Return True
    ElseIf $IsReq5 = True Then
    Return True
    ElseIf $IsReq4 = True Then
    Return True
    ;~    ElseIf $IsReq3 = True Then
    ;~ 	  Return True
    ;~    ElseIf $IsReq2 = True Then
    ;~ 	  Return True
    ;~    ElseIf $IsReq1 = True Then
    ;~ 	  Return True
    ;~    ElseIf $IsReq0 = True Then
    ;~ 	  Return True
    Else
    Return False
    EndIf
    EndSwitch
EndFunc

Func IsReq6Max($aItem)
    Local $Type = DllStructGetData($aItem, "Type")
    Local $Rarity = GetRarity($aItem)
    Local $MaxDmgDaggers = GetItemMaxReq6($aItem)
    Local $MaxDmgShield = GetItemMaxReq6($aItem)
    Local $MaxDmgSword = GetItemMaxReq6($aItem)
    Local $MaxDmgScythe = GetItemMaxReq6($aItem)

    Switch $Rarity
    Case 2624 ;~ Gold
        Switch $Type
        Case 24 ;~ Shield
        If $MaxDmgShield = True Then
            Return True
        Else
            Return False
        EndIf
        ; Case 27 ;~ Sword
        ; If $MaxDmgSword = True Then
            ; Return True
        ; Else
            ; Return False
        ; EndIf
        Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
        ; Case 35 ;~ Scythe
        ; If $MaxDmgScythe = True Then
            ; Return True
        ; Else
            ; Return False
        ; EndIf
        EndSwitch
    Case 2623 ;~ Purple?
        Switch $Type
        Case 24 ;~ Shield
        If $MaxDmgShield = True Then
            Return True
        Else
            Return False
        EndIf
        ; Case 27 ;~ Sword
        ; If $MaxDmgSword = True Then
            ; Return True
        ; Else
            ; Return False
        ; EndIf
        Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
        ; Case 35 ;~ Scythe
        ; If $MaxDmgScythe = True Then
            ; Return True
        ; Else
            ; Return False
        ; EndIf
        EndSwitch
    Case 2626 ;~ Blue?
        Switch $Type
        Case 24 ;~ Shield
        If $MaxDmgShield = True Then
            Return True
        Else
            Return False
        EndIf
        ; Case 27 ;~ Sword
        ; If $MaxDmgSword = True Then
            ; Return True
        ; Else
            ; Return False
        ; EndIf
        Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
        ; Case 35 ;~ Scythe
        ; If $MaxDmgScythe = True Then
            ; Return True
        ; Else
            ; Return False
        ; EndIf
        EndSwitch
    EndSwitch
    Return False
 EndFunc
    Func IsReq5Max($aItem)
    Local $Type = DllStructGetData($aItem, "Type")
    Local $Rarity = GetRarity($aItem)
    Local $MaxDmgDaggers = GetItemMaxReq5($aItem)
    Local $MaxDmgShield = GetItemMaxReq5($aItem)
    Local $MaxDmgSword = GetItemMaxReq5($aItem)
    Local $MaxDmgScythe = GetItemMaxReq5($aItem)

    Switch $Rarity
    Case 2624 ;~ Gold
        Switch $Type
        Case 24 ;~ Shield
        If $MaxDmgShield = True Then
            Return True
        Else
            Return False
        EndIf
        ; Case 27 ;~ Sword
        ; If $MaxDmgSword = True Then
            ; Return True
        ; Else
            ; Return False
        ; EndIf
        Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
        ; Case 35 ;~ Scythe
        ; If $MaxDmgScythe = True Then
            ; Return True
        ; Else
            ; Return False
        ; EndIf
        EndSwitch
    Case 2623 ;~ Purple?
        Switch $Type
        Case 24 ;~ Shield
        If $MaxDmgShield = True Then
            Return True
        Else
            Return False
        EndIf
        ; Case 27 ;~ Sword
        ; If $MaxDmgSword = True Then
            ; Return True
        ; Else
            ; Return False
        ; EndIf
        Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
        ; Case 35 ;~ Scythe
        ; If $MaxDmgScythe = True Then
            ; Return True
        ; Else
            ; Return False
        ; EndIf
        EndSwitch
    Case 2626 ;~ Blue?
        Switch $Type
        Case 24 ;~ Shield
        If $MaxDmgShield = True Then
            Return True
        Else
            Return False
        EndIf
        ; Case 27 ;~ Sword
        ; If $MaxDmgSword = True Then
            ; Return True
        ; Else
            ; Return False
        ; EndIf
        Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
        ; Case 35 ;~ Scythe
        ; If $MaxDmgScythe = True Then
            ; Return True
        ; Else
            ; Return False
        ; EndIf
        EndSwitch
    EndSwitch
    Return False
 EndFunc
    Func IsReq4Max($aItem)
    Local $Type = DllStructGetData($aItem, "Type")
    Local $Rarity = GetRarity($aItem)
    Local $MaxDmgDaggers = GetItemMaxReq4($aItem)
    Local $MaxDmgScythe = GetItemMaxReq4($aItem)

    Switch $Rarity
    Case 2624 ;~ Gold
        Switch $Type
        Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
        Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
        EndSwitch
    Case 2623 ;~ Purple?
        Switch $Type
        Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
        Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
        EndSwitch
    Case 2626 ;~ Blue?
        Switch $Type
        Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
        Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
        EndSwitch
    EndSwitch
    Return False
 EndFunc
    Func IsReq3Max($aItem)
    Local $Type = DllStructGetData($aItem, "Type")
    Local $Rarity = GetRarity($aItem)
    Local $MaxDmgDaggers = GetItemMaxReq3($aItem)
    Local $MaxDmgScythe = GetItemMaxReq3($aItem)

    Switch $Rarity
    Case 2624 ;~ Gold
        Switch $Type
        Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
        Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
        EndSwitch
    Case 2623 ;~ Purple?
        Switch $Type
        Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
        Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
        EndSwitch
    Case 2626 ;~ Blue?
        Switch $Type
        Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
        Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
        EndSwitch
    EndSwitch
    Return False
 EndFunc
Func IsReq2Max($aItem)
    Local $Type = DllStructGetData($aItem, "Type")
    Local $Rarity = GetRarity($aItem)
    Local $MaxDmgDaggers = GetItemMaxReq2($aItem)
    Local $MaxDmgScythe = GetItemMaxReq2($aItem)

    Switch $Rarity
    Case 2624 ;~ Gold
    Switch $Type
    Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
    Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
    EndSwitch
    Case 2623 ;~ Purple?
    Switch $Type
    Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
    Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
    EndSwitch
    Case 2626 ;~ Blue?
    Switch $Type
    Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
    Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
    EndSwitch
    EndSwitch
    Return False
EndFunc
Func IsReq1Max($aItem)
    Local $Type = DllStructGetData($aItem, "Type")
    Local $Rarity = GetRarity($aItem)
    Local $MaxDmgDaggers = GetItemMaxReq1($aItem)
    Local $MaxDmgScythe = GetItemMaxReq1($aItem)

    Switch $Rarity
    Case 2624 ;~ Gold
    Switch $Type
    Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
    Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
    EndSwitch
    Case 2623 ;~ Purple?
    Switch $Type
    Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
    Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
    EndSwitch
    Case 2626 ;~ Blue?
    Switch $Type
    Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
    Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
    EndSwitch
    EndSwitch
    Return False
EndFunc
Func IsReq0Max($aItem)
    Local $Type = DllStructGetData($aItem, "Type")
    Local $Rarity = GetRarity($aItem)
    Local $MaxDmgDaggers = GetItemMaxReq0($aItem)
    Local $MaxDmgScythe = GetItemMaxReq0($aItem)

    Switch $Rarity
    Case 2624 ;~ Gold
    Switch $Type
    Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
    Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
    EndSwitch
    Case 2623 ;~ Purple?
    Switch $Type
    Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
    Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
    EndSwitch
    Case 2626 ;~ Blue?
    Switch $Type
    Case 32 ;~ Daggers
        If $MaxDmgDaggers = True Then
            Return True
        Else
            Return False
        EndIf
    Case 35 ;~ Scythe
        If $MaxDmgScythe = True Then
            Return True
        Else
            Return False
        EndIf
    EndSwitch
    EndSwitch
    Return False
EndFunc

 Func GetItemMaxReq6($aItem)
    Local $Type = DllStructGetData($aItem, 'Type')
    Local $Dmg = GetItemMaxDmg($aItem)
    Local $Req = GetItemReq($aItem)

    Switch $Type
    Case 24 ;~ Shield
    If $Dmg == 14 And $Req == 6 Then
        Return True
    Else
        Return False
    EndIf
    Case 27 ;~ Sword
    If $Dmg == 20 Or $Dmg == 19 And $Req == 6 Then
        Return True
    Else
        Return False
    EndIf
    Case 32 ;~ Daggers
    If $Dmg == 14 And $Req == 6 Then
        Return True
    Else
        Return False
    EndIf
    Case 35 ;~ Scythe
    If $Dmg == 34 And $Req == 6 Then
        Return True
    Else
        Return False
    EndIf
    EndSwitch
EndFunc
 Func GetItemMaxReq5($aItem)
    Local $Type = DllStructGetData($aItem, 'Type')
    Local $Dmg = GetItemMaxDmg($aItem)
    Local $Req = GetItemReq($aItem)

    Switch $Type
    Case 24 ;~ Shield
    If $Dmg == 13 And $Req == 5 Then
        Return True
    Else
        Return False
    EndIf
    Case 27 ;~ Sword
    If $Dmg == 18 Or $Dmg == 19 And $Req == 5 Then
        Return True
    Else
        Return False
    EndIf
    Case 32 ;~ Daggers
    If $Dmg == 13 And $Req == 5 Then
        Return True
    Else
        Return False
    EndIf
    Case 35 ;~ Scythe
    If $Dmg == 32 And $Req == 5 Then
        Return True
    Else
        Return False
    EndIf
    EndSwitch
EndFunc
 Func GetItemMaxReq4($aItem)
    Local $Type = DllStructGetData($aItem, 'Type')
    Local $Dmg = GetItemMaxDmg($aItem)
    Local $Req = GetItemReq($aItem)

    Switch $Type
    Case 32 ;~ Daggers
    If $Dmg == 12 And $Req == 4 Then
        Return True
    Else
        Return False
    EndIf
    Case 35 ;~ Scythe
    If $Dmg == 26 And $Req == 4 Then
        Return True
    Else
        Return False
    EndIf
    EndSwitch
EndFunc
 Func GetItemMaxReq3($aItem)
    Local $Type = DllStructGetData($aItem, 'Type')
    Local $Dmg = GetItemMaxDmg($aItem)
    Local $Req = GetItemReq($aItem)

    Switch $Type
    Case 32 ;~ Daggers
    If $Dmg == 11 And $Req == 3 Then
        Return True
    Else
        Return False
    EndIf
    Case 35 ;~ Scythe
    If $Dmg == 24 And $Req == 3 Then
        Return True
    Else
        Return False
    EndIf
    EndSwitch
EndFunc
 Func GetItemMaxReq2($aItem)
    Local $Type = DllStructGetData($aItem, 'Type')
    Local $Dmg = GetItemMaxDmg($aItem)
    Local $Req = GetItemReq($aItem)

    Switch $Type
    Case 32 ;~ Daggers
    If $Dmg == 9 And $Req == 2 Then
        Return True
    Else
        Return False
    EndIf
    Case 35 ;~ Scythe
    If $Dmg == 20 And $Req == 2 Then
        Return True
    Else
        Return False
    EndIf
    EndSwitch
EndFunc
 Func GetItemMaxReq1($aItem)
    Local $Type = DllStructGetData($aItem, 'Type')
    Local $Dmg = GetItemMaxDmg($aItem)
    Local $Req = GetItemReq($aItem)

    Switch $Type
    Case 32 ;~ Daggers
    If $Dmg == 9 And $Req == 1 Then
        Return True
    Else
        Return False
    EndIf
    Case 35 ;~ Scythe
    If $Dmg == 17 And $Req == 1 Then
        Return True
    Else
        Return False
    EndIf
    EndSwitch
EndFunc
 Func GetItemMaxReq0($aItem)
    Local $Type = DllStructGetData($aItem, 'Type')
    Local $Dmg = GetItemMaxDmg($aItem)
    Local $Req = GetItemReq($aItem)

    Switch $Type
    Case 32 ;~ Daggers
    If $Dmg == 8 And $Req <= 0 Then
        Return True
    Else
        Return False
    EndIf
    Case 35 ;~ Scythe
    If $Dmg == 17 Or $Dmg == 16 And $Req <= 0 Then
        Return True
    Else
        Return False
    EndIf
    EndSwitch
EndFunc

Func PingSleep($msExtra = 0)
    $ping = GetPing()
    Sleep($ping + $msExtra)
EndFunc   ;==>PingSleep
#endregion new 03/03/2019
