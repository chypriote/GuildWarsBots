#include <Array.au3>
#include <Date.au3>
#include <GUIConstants.au3>
#include <GuiEdit.au3>
#include <GuiRichEdit.au3>
#include <ScrollBarsConstants.au3>
#include "../GWA2.au3"
#include "GUI.au3"
#include "../_SimpleInventory.au3"
TraySetIcon("froggy.ico")
;AutoItSetOption("TrayIconDebug", 1)

Opt("GUIOnEventMode", 1)

; Globals
Global Const $GuildWars = WinGetProcess("Guild Wars")
Global Const $GADDS_ENCAMPMENT = 638
Global Const $SPARKFLY_SWAMP = 558
Global Const $BOGROOT_GROWTH_LEVEL1 = 615
Global Const $BOGROOT_GROWTH_LEVEL2 = 616
Global Const $MAP_ID_BALTH_TEMPLE = 248
Global Const $ASURAN_BUFFS[5] = [2434, 2435, 2436, 2481, 2548]
Global Const $DWARVEN_BUFFS[9] = [2445, 2446, 2447, 2448, 2549, 2565, 2566, 2567, 2568]
Global $IS_RUNNING = False
Global $CURRENT_RUN = 0
Global $TEKKS_WAR = 0x339
Global $TekksDialog = 0x833901
Global $TekksComplete = 0x833907
Global $iFroggyCount = 0
Global $iUniqueCount = 0
Global $iGoldCount = 0
Global $iLockpickCount = 0
Global $iChestCount = 0
Global $iBlackDyeCount = 0
Global $iScrollCount = 0
Global $iTomeCount = 0
Global $DeadOnTheRun = False
Global $OpenedChestAgentIDs[1]  ;dirty fix for not using TargetNearestItem() (black list variable as previously opened chests were not targeted using TargetNearestItem(), now they are)
Global $aOldWaypointX, $aOldWaypointY
Global $coords[2]


; Config
Global $UseBags = 4 ; sets number of bags to be used
Global $Rendering = True
Global $Sell_Items = True
Global $Open_Chests = True
Global $Store_Golds = True
Global $Purge = False

;Template dervish OgGjkirMrSxgmXfbdbibaXNX7gA
Global $intSkillEnergy[8] = [0, 10, 5, 10, 0, 5, 5, 0]
; Change the next lines to your skill casting times in milliseconds. use ~250 for shouts/stances, ~1000 for attack skills:
Global $intSkillCastTime[8] = [250, 250, 500, 250, 250, 250, 1000, 1000]
; Change the next lines to your skill adrenaline count (1 to 8). leave as 0 for skills without adren
Global $intSkillAdrenaline[8] = [200, 0, 0, 0, 100, 0, 0, 130]

While 1
	Sleep(100)
	If Not $IS_RUNNING Then ContinueLoop

	GUICtrlSetData($lblLockpicksData, GetPicksCount())
	If $CURRENT_RUN == 0 And GetMapID() <> $SPARKFLY_SWAMP And GetMapID() <> $BOGROOT_GROWTH_LEVEL1 And GetMapID() <> $BOGROOT_GROWTH_LEVEL2 Then Setup()
	AdlibRegister("VerifyConnection", 5000)
	$CURRENT_RUN += 1
	GUICtrlSetData($lblRunNumData, $CURRENT_RUN)

	$OpenedChestAgentIDs[0] = ""
	ReDim $OpenedChestAgentIDs[1]
	$me = GetAgentByID()
	$tekksDistance = ComputeDistance(DllStructGetData($me, 'X'), DllStructGetData($me, 'Y'), 12503, 22721)

	If GetMapID() == $SPARKFLY_SWAMP And $tekksDistance > 2000 Then RunToBogroot()
	If GetMapID() == $SPARKFLY_SWAMP And $tekksDistance <= 2000 Then TakeQuest()
	If GetMapID() == $BOGROOT_GROWTH_LEVEL1 Then BogrootLvl1()
	If GetMapID() == $BOGROOT_GROWTH_LEVEL2 Then
	   BogrootLvl2()
	   Boss()
	Endif
	If InventoryIsFull() Then Inventory()
	AdlibUnRegister("VerifyConnection")
Wend

Func Setup()
   If GetMapID() <> $GADDS_ENCAMPMENT Then
	  Out("Not at Gadds Encampment, Travelling.")
	  TravelTo($GADDS_ENCAMPMENT)
   EndIf

   AbandonQuest($TEKKS_WAR)
   BeforeRun()
   TakeAzuranBlessing()
   RunToBogroot()
EndFunc

Func BotStartup()
	GUICtrlSetState($btnStart, $GUI_DISABLE)
	GUICtrlSetState($inpInit, $GUI_DISABLE)

	$sInitMethod = GUICtrlRead($inpInit)
	If Not Initialize($sInitMethod, True) Then
		If Not Initialize($GuildWars, True) Then
			Out("Initialization Failed!")
			Exit 1
		EndIf
	EndIf

	Global $aPlayerAgent = GetAgentByID(-2)
	Global $nTotalTime = TimerInit()
	AdlibRegister("TotalTime", 1000)

	Global $iAsuraTitle = GetAsuraTitle()
	Global $iDeldrimorTitle = GetDeldrimorTitle()
	AdlibRegister("DeldrimorPoints", 5000)
	AdlibRegister("AsuraPoints", 5000)
	AdlibRegister("DropCounts", 5000)
	AdlibRegister("Lockpicks", 5000)

	$IS_RUNNING = True
EndFunc

Func BeforeRun()
	SwitchMode(1)
	Out("Moving to Sparkfly")
	MoveTo(-10018, -21892)
	MoveTo(-9550, -20400)
	TolSleep(500)

	Do
		Move(-9451, -19766)
	Until WaitMapLoading($SPARKFLY_SWAMP)
	Out("Loaded Sparkfly")
EndFunc ;BeforeRun

Func TakeAzuranBlessing()
	Out("Getting Asuran Blessing")
	GoToNPC(GetNearestNPCToCoords(-9021, -19906))
	TolSleep(200)

	Dialog(0x84)
	TolSleep(200)
	For $i = 0 to UBound($ASURAN_BUFFS) - 1
		If IsDllStruct(GetEffect($ASURAN_BUFFS[$i])) Then
			Out("Asuran Blessing Received")
			Return
		EndIf
	Next
	Out("Unable To Get Asuran Blessing")
EndFunc ;TakeAzuranBlessing

Func RunToBogroot()
	Out("Running To Bogroot")
	AdlibRegister("ForceOfHonor", 5000)

	Local $aWaypoints[17][4] = [ _
	[-7746, -16039, 1500, "Raptor Group"], _
	[-6804, -10431, 1500, "Ferothrax Group"], _
	[-4001, -6599, 1500, "Angorodon Group"], _
	[-805, -3997, 1500, "Raptor Group 2"], _
	[2244, -1934, 1500, "Ferothrax Group 2"], _
	[4904, 281, 1500, "Raptor Group 3"], _
	[8014, 2151, 1500, "Cutting"], _
	[11344, 2137, 1500, "Ferothrax Group 3"], _
	[10322, 6297, 1500, "Raptor Group 4"], _
	[11650, 10117, 1500, "Simiam Group"], _
	[13227, 10518, 1500, "Simiam Group"], _
	[13011, 14609, 1500, "Simiam Group 2"], _
	[13292, 18200, 1500, "Simiam Group 2"], _
	[12965, 20463, 1500, "Simiam Group 3"], _
	[11874, 21508, 1500, "Simiam Group 3"], _
	[11874, 21508, 1500, "Simiam Group 3"], _
	[12503, 22721, 1500, "Tekk"]]
	MoveandAggro($aWaypoints)

	$NearestWaypoint = GetNearestWaypointIndex($aWaypoints)

	If $DeadOnTheRun Then
	   Out("Party wipe, restarting at"& $aWaypoints[$NearestWaypoint][3])
	   $DeadOnTheRun = False
	   MoveandAggro($aWaypoints)
	Endif
	AdlibUnRegister("ForceOfHonor")
EndFunc ;RunToBogroot

Func TakeQuest()
	Global $START_TIME = TimerInit()
	AdlibRegister("CurrentRunTime", 1000)

	Out("Taking Quest: Tekks")
	MoveTo(12396, 22007)
	GoToNPC(GetNearestNPCToCoords(12561, 22614)) ;Tekks

	Do
		TolSleep(500)
		AcceptQuest($TEKKS_WAR)
		Dialog($TekksDialog)
	Until IsDllStruct(GetQuestByID($TEKKS_WAR))

	Out("Starting Run Num: " & $CURRENT_RUN)
	Out("Moving to Bogroot Portal.")

	MoveTo(11197, 23820)
	MoveTo(12470, 25036)
	MoveTo(12968, 26219)
	Do
		Move(13097, 26393)
	Until WaitMapLoading($BOGROOT_GROWTH_LEVEL1)
	TolSleep(3000)
EndFunc ;TakeQuest

Func BogrootLvl1()
	AdlibRegister("ForceOfHonor", 5000)
	$DeadOnTheRun = False

	; Level 1
	Local $aWaypointsLevel1[19][4] = [ _
	[16342, 8640, 1500, "First Group"], _
	[10387, 7205, 1500, "Nettle Spores"], _
	[10222, 8325, 1500, "Blooming/Nettle Spores"], _
	[7671, 6216, 1500, "Blooming/Nettle Spores"], _
	[6086, 4315, 1500, "Allied Ophil"], _
	[2661, 424, 1500, "Allied Ophil"], _
	[1264, -36, 1500, "Attacking Gokir"], _
	[306, -2018, 1500, "Poison Traps"], _
	[-1010, -4100, 1500, "Nettle Seedling"], _
	[-1296, -5038, 1500, "Nettle Seedling"], _
	[-478, -7580, 1500, "Poison Traps"], _
	[512, -8861, 1500, "Gokir"], _
	[1230, -9846, 1500, "Ayahuasca"], _
	[1693, -12198, 1500, "Nettle Spores"], _
	[1072, -13738, 1500, "Blooming Nettles"], _
	[1668, -14944, 1500, "Ayahuasca/Oakheart"], _
	[4941, -16181, 1500, "Nettle Spores"], _
	[7360, -17361, 1500, "Level 2 Portal"], _
	[7552, -18776, 1500, "Level 2 Portal"]]

	$NearestWaypoint = GetNearestWaypointIndex($aWaypointsLevel1)
	If $NearestWaypoint < 3 Then
	   Out("Aggro Frog Fight")
	   MoveTo(17026, 2168)
	   AggroMoveToEx(18092, 4590)
	   Out("Moving to Beacon of Droknar")
	   MoveTo(19099, 7762)
	   Out("Getting Dwarven Blessing")
	   GetDwarvenBlessing(19099, 7762)
	Endif

	MoveandAggro($aWaypointsLevel1)

	If $DeadOnTheRun Then
	   Out("Party wipe, restarting at "& $aWaypointsLevel1[$NearestWaypoint][3])
	   $DeadOnTheRun = False
	   MoveandAggro($aWaypointsLevel1)
	Endif

	Out("Travelling to Bogroot Growths - Level 2.")
	AdlibUnRegister("ForceOfHonor")
	Do
		Move(7665, -19050)
	Until WaitMapLoading($BOGROOT_GROWTH_LEVEL2)
Endfunc ;BogrootLvl1

Func BogrootLvl2()
	AdlibRegister("ForceOfHonor", 5000)
	$DeadOnTheRun = False

	; Level 2
	Local $aWaypointsLevel2[28][4] = [ _
	[-10970, -4264, 1500, "Blooming Nettles"], _
	[-11165, -2066, 1500, "Blooming/Nettle Spores"], _
	[-11014, -1144, 1500, "Blooming/Nettle Spores"], _
	[-10017, -643, 1500, "Blooming/Nettle Spores"], _
	[-8609, 638, 1500, "Fungal/Nettle Spores"], _
	[-7306, 2604, 1500, "Fungal/Nettle Spores"], _
	[-6212, 3200, 1500, "Ayahuasca/Nettle Spores"], _
	[-4002, 4884, 1500, "Ayahuasca/Incubus"], _
	[-2428, 5925, 1500, "Ayahuasca/Incubus"], _
	[-2824, 6859, 1500, "Ayahuasca/Incubus"], _
	[-2586, 7549, 1500, "Ayahuasca/Incubus"], _
	[-480, 8281, 1500, "East Side of Bogroot"], _
	[-145, 10806, 1500, "Shrine"], _
	[218, 11537, 2000, "Thorn/Ghosteater Beetles"], _
	[2547, 12113, 2000, "Thorn/Ghosteater Beetles"], _
	[3729, 13897, 2000, "Thorn/Ghosteater Beetles"], _
	[5414, 13698, 2000, "Thorn/Ghosteater Beetles"], _
	[6263, 10903, 2000, "Thorn/Ghosteater Beetles"], _
	[7538, 8724, 2000, "Gokir Battle"], _
	[7929, 7204, 2000, "Gokir Battle/Patriarch"], _
	[8392, 4424, 2000, "Gokir"], _
	[8921, 437, 2000, "Gokir"], _
	[9637, -718, 2000, "Gokir"], _
	[9381, -1975, 2000, "Gokir"], _
	[10232, -3814, 2000, "Next Gokir"], _
	[12195, -6471, 2000, "Next Gokir"], _
	[13884, -6384, 2000, "Next Gokir"], _
	[16814, -5754, 2000, "Gokir Patriarch/Boss Key"]]

	$NearestWaypoint = GetNearestWaypointIndex($aWaypointsLevel2)
	If Not $NearestWaypoint Then
		Out("Starting level 2 at spawn")
		Out("Clearing Spawn")
		AggroMoveToEx(-11330, -5483)
		Out("Moving to Beacon of Droknar")
		MoveTo(-11132, -5546)
		Out("Getting Dwarven Blessing")
		GetDwarvenBlessing(-11132, -5546)
	EndIf

	MoveandAggro($aWaypointsLevel2)
	If $DeadOnTheRun Then
	   Out("Party wipe, restarting at "& $aWaypointsLevel2[$NearestWaypoint][3])
	   $DeadOnTheRun = False
	   MoveandAggro($aWaypointsLevel2)
	Endif

	TolSleep(500)
	MoveTo(16854, -5830)
	TolSleep(500)
	PickupLootEx(10000)
	TolSleep(500)

	Out("Open Dungeon Door")
	$BossLock = GetNearestSignpostToCoords(17804, -6157)
	GoToSignpost($BossLock)
	MoveTo(17482, -6661)
	AdlibUnRegister("ForceOfHonor")
EndFunc ;BogrootLvl2

Func Boss()
	AdlibRegister("ForceOfHonor", 5000)
	Local $aWaypointsBoss[9][4] = [ _
	[18334, -8838, 2000, "Boss"], _
	[16131, -11510, 2000, "Boss"], _
	[19009, -12300, 2000, "Boss"], _
	[18413, -13924, 2000, "Boss"], _
	[14188, -15231, 2000, "Boss"], _
	[13186, -17286, 2000, "Boss"], _
	[14035, -17800, 3000, "Engaging Boss"], _
	[14617, -18282, 3000, "Engaging Boss"], _
	[15117, -18582, 3000, "Engaging Boss"]]

	$NearestWaypoint = GetNearestWaypointIndex($aWaypointsBoss)
	MoveandAggro($aWaypointsBoss)

	If $DeadOnTheRun Then
		Out("Party wipe, restarting at "& $aWaypointsBoss[$NearestWaypoint][3])
		$DeadOnTheRun = False
		MoveandAggro($aWaypointsBoss)
	Endif

	$nearestEnemy = GetnearestEnemyToAgent($aPlayerAgent)
	$NearestDistance = @extended
	If $NearestDistance > 3000 Then
		Out("Boss Group Dead")
		Sleep(2000)

		Local $deadlock = 0
		Out("Accepting Quest Reward")
		Do
			GoNPC(GetNearestNPCToCoords(13975, -17211))
			TolSleep(500)
			Dialog($TekksComplete)
			$deadlock += 1
		Until Not IsDllStruct(GetQuestByID($TEKKS_WAR)) Or $deadlock == 50

		TolSleep(800)

		Out("Bogroot Chest")
		MoveTo(14876, -19033)
		GoToSignpost(GetNearestSignpostToCoords(14876, -19033))
		TolSleep(4000)
		Out("Pick Up Drops")
		PickupLootEx(6000)
	EndIf

	If IsDllStruct(GetQuestByID($TEKKS_WAR)) Then AbandonQuest($TEKKS_WAR)
	Out("Wait for Reload")

	AdlibUnRegister("ForceOfHonor")
	Do
		Sleep(200)
	Until WaitMapLoading($SPARKFLY_SWAMP)
	AdlibUnregister("CurrentRunTime")
	TolSleep(3000)
EndFunc ;Boss

Func GetDwarvenBlessing($iX, $iY)
	$aBeaconofDroknar = GetNearestNPCToCoords($iX, $iY)
	GoToNPC($aBeaconofDroknar)
	TolSleep(500)

	Dialog(0x84)
	TolSleep(200)
	For $i = 0 to UBound($DWARVEN_BUFFS) - 1
		If IsDllStruct(GetEffect($DWARVEN_BUFFS[$i])) Then
			Out("Dwarven Blessing Received")
			Return
		EndIf
	Next
	Out("Unable To Get Dwarven Blessing")
EndFunc ;GetDwarvenBlessing

Func Out($sMessage)
	ConsoleWrite($sMessage & @CRLF)
	_GUICtrlRichEdit_SetFont($edtLog, 8, "Trebuchet MS")
	_GUICtrlRichEdit_AppendText($edtLog, $sMessage & @CRLF)
	_GUICtrlEdit_Scroll($edtLog, $SB_SCROLLCARET)
EndFunc ;Out

Func MoveandAggro($aWaypoints)
	$iStart = GetNearestWaypointIndex($aWaypoints)
	$iFinish = UBound($aWaypoints) - 1
	$iStep = 1

	For $i = $iStart to $iFinish step $iStep
		Out("Moving to waypoint: " & $aWaypoints[$i][0] & ", " & $aWaypoints[$i][1])
		AggroMoveToEx($aWaypoints[$i][0], $aWaypoints[$i][1], $aWaypoints[$i][2])
	Next
EndFunc ;MoveandAggro

Func GetNearestWaypointIndex($aWaypoints)
	Local $lNearestWaypoint, $lNearestDistance = 100000000
	Local $distance

	$me = GetAgentByID()
	For $index = 0 To (UBound($aWaypoints) - 1)
		Local $nWaypointX = $aWaypoints[$index][0]
		Local $nWaypointY = $aWaypoints[$index][1]
		$distance = (DllStructGetData($me, 'X') - $nWaypointX) ^ 2 + (DllStructGetData($me, 'Y') - $nWaypointY) ^ 2
		If $distance < $lNearestDistance Then
			$lNearestWaypoint = $index
			$lNearestDistance = $distance
		EndIf
	Next
	Return $lNearestWaypoint
EndFunc ;GetNearestWaypointIndex

#Region Move
Func AggroMoveToEx($x, $y, $z = 1200) ;Reduced from 2000
	$iBlocked = 0
	Move($x, $y, 50)
	$Me = GetAgentByID()
	$coords[0] = DllStructGetData($Me, 'X')
	$coords[1] = DllStructGetData($Me, 'Y')
	If $Open_Chests Then CheckForChest()
	Do
		RndSleep(250)
		$oldCoords = $coords
		local $timeragro = TimerInit()
		local $timeragro = TimerInit()
		$nearestenemy = GetNearestEnemyToAgent(-2)
		$lDistance = GetDistance($nearestenemy, -2)
		If $lDistance < $z AND DllStructGetData($nearestenemy, 'ID') <> 0 Then
			Attack($nearestenemy)
			Fight()
		EndIf
		If GetPartyHealth() < 0.85 Then
			Out("Waiting For Party Heal")
			Do
			   Sleep(100)
			Until GetPartyHealth() >= 0.85
		EndIf

		 RndSleep(250)
		 $Me = GetAgentByID()
		 $coords[0] = DllStructGetData($Me, 'X')
		 $coords[1] = DllStructGetData($Me, 'Y')
		 If $oldCoords[0] = $coords[0] And $oldCoords[1] = $coords[1] Then
			$iBlocked += 1
			If $iBlocked >= 10 Then
				MoveTo($coords[0], $coords[1], 500)
			ElseIf $iBlocked >= 20 Then
				Move($aOldWaypointX, $aOldWaypointY, 500) ; Try going back a waypoint
			ElseIf $iBlocked >= 40 Then
				Out("Something is wrong, Stuck too many times, Restarting.")
				Setup() ; Go back to Gadds, Something has gone wrong
			EndIf
			MoveTo($coords[0], $coords[1], 500)
			Sleep(GetPing()+500)
			Move($x, $y, 50)
		 EndIf
	Until ComputeDistance($coords[0], $coords[1], $x, $y) < 250 Or $iBlocked > 60 Or $DeadOnTheRun
	If $iBlocked > 60 Then Fight()
	$aOldWaypointX = $x
	$aOldWaypointY = $y
	If $Open_Chests Then CheckForChest()
	If Not InventoryIsFull() Then PickupLootEx()
EndFunc ;AggroMoveToEx

Func Fight()
	$target = GetNearestEnemyToAgent()
	ChangeTarget($target)
	RndSleep(150)

	Do
		CallTarget($target)
		RndSleep(150)

		Do
			Attack($target)
			UseSkills()
			RndSleep(150)
		Until Not TargetIsAlive()

		$target = GetNearestEnemyToAgent()
		ChangeTarget($target)
		RndSleep(300)
	Until $target = 0 Or Not TargetIsInRange()
	RndSleep(250)
EndFunc ;Fight

Func UseSkills()
	For $i = 0 To 7
		If Not TargetIsAlive() Then ExitLoop
		If Not IsRecharged($i) And GetEnergy() < $intSkillEnergy[$i] And GetSkillbarSkillAdrenaline($i + 1) < $intSkillAdrenaline[$i] Then ContinueLoop

		UseSkill($i + 1)
		RndSleep(500)
	Next
EndFunc ;UseSkill

Func GetPartyHealth()
	Local $aTotalTeamHP
	$aParty = GetParty()
	_ArrayDelete($aParty, 0)
	For $i = 0 to Ubound($aParty) - 1
		If GetIsDead($aParty[$i]) Then ContinueLoop
		$aAgent = $aParty[$i]
		$aAgentHP = Round(DllStructGetData($aAgent, 'HP'), 6)
		$aTotalTeamHP += $aAgentHP
	Next
	$nAverageHP = Round($aTotalTeamHP / 8, 6)
	Return $nAverageHP
EndFunc ;GetPartyHealth
#EndRegion Move

Func GetChecked($GUICtrl)
	Return (GUICtrlRead($GUICtrl) == $GUI_Checked)
EndFunc ;GetChecked

#Region Loot
Func CheckForChest()
	Local $AgentArray, $lAgent, $lExtraType
	Local $ChestFound = False
	If GetIsDead(-2) Then Return

	$AgentArray = GetAgentArraySorted(0x200)    ;0x200 = type: static
	Out("Looking for chests")
	For $i = 0 To UBound($AgentArray) - 1   ;there might be multiple chests in range
		$lAgent = GetAgentByID($AgentArray[$i][0])
		$lExtraType = DllStructGetData($lAgent, 'ExtraType')
		If $lExtraType <> 4582 And $lExtraType <> 8141 Then ContinueLoop    ;dirty fix: skip signposts that aren't chests (nm And hm chest)
		If _ArraySearch($OpenedChestAgentIDs, $AgentArray[$i][0]) == -1 Then
			If @error <> 6 Then ContinueLoop
			If $OpenedChestAgentIDs[0] = "" Then    ;dirty fix: blacklist chests that were opened before
				$OpenedChestAgentIDs[0] = $AgentArray[$i][0]
			Else
				_ArrayAdd($OpenedChestAgentIDs, $AgentArray[$i][0])
			EndIf
			$ChestFound = True
			ExitLoop
		EndIf
	Next
	If Not $ChestFound Then Return
	Out("opening chest")
	GoSignpost($lAgent)
	OpenChest()
	$iChestCount += 1
	Sleep(GetPing() + 500)
	$AgentArray = GetAgentArraySorted(0x400)    ;0x400 = type: item
	ChangeTarget($AgentArray[0][0]) ;in case you watch the bot running you can see what dropped immediately
	GUICtrlSetData($lblChestsData, $iChestCount)
	PickupLootEx(3000)
 EndFunc ;CheckForChest

Func PickupLootEx($iMaxDist = 3000, $bCanPickup = True)
	$me = GetAgentByID()
	Out("Pickup Loot")
	For $i = 1 To GetMaxAgents()
		$aAgent = GetAgentByID($i)
		If Not GetIsMovable($aAgent) Then ContinueLoop
		$aItem = GetItemByAgentID($i)
		$aItemX = DllStructGetData($aAgent, "x")
		$aItemY = DllStructGetData($aAgent, "y")
		If CanPickUpEx($aItem, $bCanPickup) And ComputeDistance(DllStructGetData($me, 'X'), DllStructGetData($me, 'Y'), $aItemX, $aItemY) < $iMaxDist Then
			MoveTo($aItemX, $aItemY)
			TolSleep(300)
			Do
				PickUpItem($aItem)
			Until Not GetAgentExists($aAgent)
			$lDeadlock = TimerInit()
			While GetAgentExists($aAgent)
				Sleep(50)
				If GetIsDead(-2) Then Return
				If TimerDiff($lDeadlock) > 25000 Then ExitLoop
			Wend
		EndIf
	Next
EndFunc ;PickupLootEx

Func CanPickUpEx($aItem, $bCanPickup)
	If Not $bCanPickup Then Return True
	$aModelID = DllStructGetData($aItem, 'modelid')
	$aItemID = DllStructGetData($aItem, "id")

	Switch GetRarity($aItem)
		Case 2624 ; Gold Items
			$iGoldCount += 1
			Return True
		Case 2627 ; Green Items
			$iUniqueCount += 1
			Return True
	EndSwitch

	Switch $aModelID
		Case 1953, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969, 1970, 1971, 1972, 1973, 1974, 1975 ; All Froggy's
			$iFroggyCount += 1
			Return True
		Case 2593 ; 2593 = SavSuds Boss Key
			Return True
		Case 25416 ; 25416 = Boss Key
			Return True
		Case 935, 936 ; 935 = Diamond, 936 = Onyx Gemstone
			Return True
		Case 22751 ; Lockpick
			$iLockpickCount += 1
			Return True
		Case 146 And DllStructGetData($aItem,'extraid') == 10 ; Black dye (use 146 for all dyes)
			$iBlackDyeCount += 1
			Return True
		Case 2511 ; Gold
			Return GetGoldCharacter() + DllStructGetData($aItem, 'Value') < 100000
		Case 3256, 3746, 5594, 5595, 5611, 21233, 22279, 22280 ; Scrolls
			$iScrollCount += 1
			Return True
		Case 21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795, 21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805 ; Tomes
			$iTomeCount += 1
			Return True
		Case 28435, 28436: ;Cider and Pie
			Return True
	EndSwitch

	$aReq = GetItemReq($aItem)
	Switch DllStructGetData($aItem,'Type')
		Case $ITEM_TYPE_SHIELD ;shields
		   If $aReq = 8 And GetItemMaxDmg($aItem) = 16 Then ; Req8 Shields
			  Return True
		   ElseIf $aReq = 7 And GetItemMaxDmg($aItem) = 15 Then ; Req7 Shields
			  Return True
		   ElseIf $aReq = 6 And GetItemMaxDmg($aItem) = 14 Then ; Req6 Shields
			  Return True
		   ElseIf $aReq = 5 And GetItemMaxDmg($aItem) = 13 Then ; Req5 Shields
			  Return True
		   ElseIf $aReq = 4 And GetItemMaxDmg($aItem) = 12 Then ; Req4 Shields
			  Return True
		   EndIf
	EndSwitch

	Return False
EndFunc ;CanPickUpEx

Func GetItemMaxDmg($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Local $lModString = GetModStruct($aItem)
	Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
	If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
	If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
	If $lPos = 0 Then Return 0
	Return Int("0x" & StringMid($lModString, $lPos - 2, 2))
EndFunc

Func GetAgentArraySorted($lAgentType)  ;returns a 2-dimensional array([agentID, [distance]) sorted by distance
	Local $lDistance
	Local $lAgentArray = GetAgentArray($lAgentType)
	Local $lReturnArray[1][2]
	Local $me = GetAgentByID(-2)
	Local $AgentID

	For $i = 1 To $lAgentArray[0]
		$lDistance = (DllStructGetData($me, 'X') - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + (DllStructGetData($me, 'Y') - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
		$AgentID = DllStructGetData($lAgentArray[$i], 'ID')
		ReDim $lReturnArray[$i][2]
		$lReturnArray[$i - 1][0] = $AgentID
		$lReturnArray[$i - 1][1] = Sqrt($lDistance)
	Next
	_ArraySort($lReturnArray, 0, 0, 0, 1)
	Return $lReturnArray
EndFunc ;GetAgentArraySorted
#EndRegion Loot

#Region Inventory
Global Const $TYPE_ID[10] = [_
	$ITEM_TYPE_STAFF, _
	$ITEM_TYPE_WAND, _
	$ITEM_TYPE_SHIELD, _
	$ITEM_TYPE_SPEAR, _
	$ITEM_TYPE_SWORD, _
	$ITEM_TYPE_AXE, _
	$ITEM_TYPE_BOW, _
	$ITEM_TYPE_HAMMER, _
	$ITEM_TYPE_DAGGERS, _
	$ITEM_TYPE_SCYTHE]
Func ItemHasUsefulMod()
	If DllStructGetData($aItem, 'Type') <> $ITEM_TYPE_SALVAGE Then Return False
	;things that should be kept
	Local $lWhiteListMods[21] = [20, "Survivor Insignia", "Radiant Insignia", "Blessed Insignia", _
			"Sentinel's Insignia [Warrior]", "Bloodstained Insignia [Necromancer]", "Prodigy's Insignia [Mesmer]", _
			"Nightstalker's Insignia [Assassin]", "Shaman's Insignia [Ritualist]", "Windwalker Insignia [Dervish]", _
			"Centurion's Insignia [Paragon]"]

	Local $lWhiteListRunes[12] = [11, "Mesmer Rune of Superior Fast Casting", "Mesmer Rune of Superior Domination Magic", _
			"Ritualist Rune of Superior Channeling Magic", "Ritualist Rune of Superior Communing", _
			"Dervish Rune of Superior Earth Prayers", "Necromancer Rune of Superior Death Magic", _
			"Rune of Superior Vigor", "Rune of Major Vigor", "Rune of Clarity", "Rune of Restoration", "Rune of Vitae"]
	Local $lModStruct = GetModStruct($aItem)
	Local $ListToUse
	For $index = 0 To 1
		If $index == 0 Then $ListToUse = $lWhiteListMods
		If $index == 1 Then $ListToUse = $lWhiteListRunes
		For $i = 0 To 183	;all mods, inscriptions, runes, insignias from Mod Array
			For $j = 1 To $ListToUse[0]
				If $array_armormods[$i][1] == $ListToUse[$j] Then
					If StringInStr($lModStruct, $array_armormods[$i][3]) > 0 Then
						SetExtended($index)
						Return True
					EndIf
				EndIf
			Next
		Next
	Next
	Return False
EndFunc ;ItemHasUsefulMod
#EndRegion Inventory

#Region LibRegister
Func ForceOfHonor()
	If GetIsCasterProfession() Then Return False
	If DllStructGetData(GetEffect(243), 'skillid') Then Return
	UseHeroSkill(7, 8, -2)
EndFunc ;ForceOfHonor

Func GetPicksCount()
	Local $AmountPicks
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4 ;change 1 To 16 if you want to count storage also or 1 to 4 for just personal inv.  Will display on GUI
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") <> 22751 Then ContinueLoop
			$AmountPicks += DllStructGetData($aItem, "Quantity")
		Next
	Next
	Return $AmountPicks
EndFunc ;GetPicksCount
Func VerifyConnection()
	If GetMapLoading() == 2 Then Disconnected()
EndFunc ;VerifyConneciton
#EndRegion LibRegister

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
#EndRegion Helpers

#Region Professions
Func GetAgentPrimaryProfession($aAgent = -2)
	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
	Return DllStructGetData($aAgent, 'Primary')
EndFunc   ;==>GetAgentPrimaryProfession

Func GetIsCasterProfession($aAgent = -2)
	Return InArray(GetAgentPrimaryProfession($aAgent), $CASTER_PROFS)
EndFunc   ;==>GetIsCasterProfession
#EndRegion
