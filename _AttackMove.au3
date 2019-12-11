#include-once
#include <Array.au3>

Out("AttackMove loaded")

Func FollowPath($aWaypoints)
	$iStart = GetNearestWaypointIndex($aWaypoints)
	$iFinish = UBound($aWaypoints) - 1
	$iStep = 1

	For $i = $iStart to $iFinish step $iStep
		If $DeadOnTheRun Then ExitLoop
		Out("Moving to waypoint " & $aWaypoints[$i][0] & ", " & $aWaypoints[$i][1])
		AttackMove($aWaypoints[$i][0], $aWaypoints[$i][1])
		Loot()
		DoChest()
	Next
EndFunc ;FollowPath

Func AttackMove($x, $y)
	Local $timer = TimerInit(), $iBlocked = 0, $jBlocked
	Do
		$jBlocked = 0
		Do
			Move($x, $y)
			RndSleep(250)
			$jBlocked += 1
		Until EnemyInRange() Or ReachedDestination($x, $y) Or $jBlocked > 50 Or GetIsDead()
		If $jBlocked > 50 Then Out("I got stuck " & $iBlocked)

		If EnemyInRange() Then Fight()
		$iBlocked += 1
	Until ReachedDestination($x, $y) Or $iBlocked > 5
	RndSleep(250)
EndFunc ;AttackMove

Func Fight()
	Out("Fighting")
	$target = GetNearestEnemyToAgent()
	ChangeTarget($target)
	RndSleep(150)

	Do
		CallTarget($target)
		RndSleep(150)

		Do
			Attack($target)
			RndSleep(200)
			UseSkills()
			RndSleep(150)
		Until Not TargetIsAlive() Or GetIsDead()

		$target = GetNearestEnemyToAgent()
		ChangeTarget($target)
		RndSleep(300)
	Until $target = 0 Or Not TargetIsInRange() Or GetIsDead()
	RndSleep(250)
EndFunc ;Fight

Func UseSkills()
	For $i = 1 To 8
		If Not TargetIsAlive() Then
			ExitLoop
		EndIf
		If DllStructGetData(GetSkillBar(), "Recharge" & $i) <> 0 Then ContinueLoop
		If GetEnergy() < GetEnergyCost(GetSkillbarSkillID($i)) Then ContinueLoop
		;If GetSkillbarSkillAdrenaline($i + 1) < DllStructGetData(GetSkillByID(GetSkillbarSkillID($i)), 'Adrenaline') Then ContinueLoop

		UseSkill($i)
		RndSleep(GetActivationTime(GetSkillbarSkillID($i)) * 1000 + 750)
	Next
EndFunc ;UseSkill

#Region Looting
Func DoChest()
	Local $TimeCheck = TimerInit()

	TargetNearestItem()
	If DllStructGetData(GetCurrentTarget(), 'Type') <> 512 Then Return False
	Out("Found chest")

	GoSignpost(-1)
	$chest = GetCurrentTarget()
	$oldCoordsX = DllStructGetData($chest, "X")
	$oldCoordsY = DllStructGetData($chest, "Y")

	Do
		Sleep(1000)
	Until ReachedDestination($oldCoordsX, $oldCoordsY) Or TimerDiff($TimeCheck) > 10000 Or GetIsDead()

	OpenChest()
	RndSleep(1000)
	Loot()
EndFunc ;DoChest

Func Loot($maxDist = 3000)
	Local $agent, $agentID
	Local $me = GetAgentByID()
	Out("Pick up loot")

	If GetIsDead() Or InventoryIsFull() Then Return False ;full inventory dont try to pick up

	For $agentID = 1 To GetMaxAgents()
		$agent = GetAgentByID($agentID)
		If Not GetIsMovable($agent) Or Not GetCanPickUp($agent) Then ContinueLoop
		$item = GetItemByAgentID($agentID)

		If Not CanPickUp($item) Then ContinueLoop

		Local $meX = DllStructGetData($me, 'X')
		Local $meY = DllStructGetData($me, 'Y')
		Local $itemX = DllStructGetData($agent, "x")
		Local $itemY = DllStructGetData($agent, "y")

		If ComputeDistance($meX, $meY, $itemX, $itemY) < $maxDist Then
			Local $deadlock = TimerInit()
			MoveTo($itemX, $itemY)
			TolSleep(300)
			Do
				PickUpItem($item)
			Until Not GetAgentExists($item) Or GetIsDead() Or TimerDiff($deadlock) > 25000
		EndIf
	Next
EndFunc ;Loot

Func CanPickUp($item)
	Local $ModelID = DllStructGetData($item, 'ModelID')
	Local $ExtraID = DllStructGetData($item, 'ExtraID')
	Local $type = DllStructGetData($item, 'Type')
	Local $rarity = GetRarity($item)

	If $ModelID == $GOLD_COINS And GetGoldCharacter() < 99000 Then Return True
	If $ModelID == $ITEM_LOCKPICK		Then Return True ; Lockpick
	If $rarity == $RARITY_GOLD			Then Return True
	If $rarity == $RARITY_PURPLE		Then Return True
	If $rarity == $RARITY_BLUE			Then Return False

	If $ModelID == $ITEM_DYES						Then Return True
	If InArray($ModelID, $ALL_TOMES_ARRAY)			Then Return True
	If InArray($ModelID, $ALL_SCROLLS_ARRAY)		Then Return True
	If InArray($ModelID, $ALL_TROPHIES_ARRAY)		Then Return True
	If InArray($ModelID, $ALL_TITLE_ITEMS)			Then Return True
	If InArray($ModelID, $ALL_MATERIALS_ARRAY)		Then Return True
	If InArray($ModelID, $SPECIAL_DROPS_ARRAY)		Then Return True
	If InArray($ModelID, $MAP_PIECE_ARRAY)			Then Return False
	If InArray($ModelID, $ALL_DPREMOVAL_ARRAY)		Then Return True

	Return False
EndFunc ;CanPickUp
#EndRegion Looting

#Region Helpers
Func ReachedDestination($x, $y)
	$me = GetAgentByID()
	$distance = ComputeDistance(DllStructGetData($me, 'X'), DllStructGetData($me, 'Y'), $x, $y)
	Return $distance < 250
EndFunc ;ReachedDestination
Func EnemyInRange()
	$enemy = GetNearestEnemyToAgent()
	If $enemy = 0 Then Return False

	Return GetDistance($enemy) < 1400
EndFunc ;EnemyInRange
Func TargetIsAlive()
	Return DllStructGetData(GetCurrentTarget(), 'HP') > 0 And DllStructGetData(GetCurrentTarget(), 'Effects') <> 0x0010
EndFunc ;TargetIsAlive
Func TargetIsInRange()
	Return GetDistance(GetCurrentTarget()) < 1400
EndFunc ;TargetIsInRange
Func GetNearestWaypointIndex($aWaypoints)
	Local $lNearestWaypoint, $lNearestDistance = 100000000
	Local $distance

	$me = GetAgentByID()
	For $index = 0 To (UBound($aWaypoints) - 1)
		Local $wX = $aWaypoints[$index][0]
		Local $wY = $aWaypoints[$index][1]
		Local $meX = DllStructGetData($me, 'X')
		Local $meY = DllStructGetData($me, 'Y')

		$distance = ComputeDistance($meX, $meY, $wX, $wY)
		If $distance < $lNearestDistance Then
			$lNearestWaypoint = $index
			$lNearestDistance = $distance
		EndIf
	Next
	Return $lNearestWaypoint
EndFunc ;GetNearestWaypointIndex
#EndRegion Helpers
