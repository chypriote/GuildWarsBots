
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
					RndSleep(250)
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

#endregion new 07/26/2019

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

#region 27/05/2018
Func CheckArea($aX, $aY)
	$pX = DllStructGetData(GetAgentByID(-2), "X")
	$pY = DllStructGetData(GetAgentByID(-2), "Y")

	Return ($pX < $aX + 500) And ($pX > $aX - 500) And ($pY < $aY + 500) And ($pY > $aY - 500)
EndFunc
#EndRegion 27/05/2018

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
#endregion new 03/03/2019
