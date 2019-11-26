#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\Downloads\froggy.ico
#AutoIt3Wrapper_Outfile=..\..\BogrootGrowthsByRitIRL.Exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ScrollBarsConstants.au3>
#include <GuiEdit.au3>
#include <GuiRichEdit.au3>
#include <Array.au3>
#include <Date.au3>
#include "GWA2_Headers.au3"
#include "GWA2.au3"
#include "AddsOn.au3"
#include "GUI.au3"

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
Global $bDwarvenBlessing = False
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
Global $OpenedChestAgentIDs[1]	;dirty fix for not using TargetNearestItem() (black list variable as previously opened chests were not targeted using TargetNearestItem(), now they are)
Global $Weapon_Mod_Array[100]
Global $aOldWaypointX, $aOldWaypointY
Global $coords[2]


; Config
Global $bGetKreweBuff = true
Global $RenderingEnabled = True
Global $Ident = False
Global $UseBags = 4 ; sets number of bags to be used
Global $Sell_Items = True
Global $Open_Chests = True
Global $Use_Scrolls = False
Global $Use_Stones = False
Global $Store_Golds = True
Global $Purge = False

Main()

Func Main()

	While 1
		Sleep(100)

		While $IS_RUNNING
			GUICtrlSetData($lblLockpicksData, GetPicksCount())
			If $CURRENT_RUN == 0 And GetMapID() <> $SPARKFLY_SWAMP And GetMapID() <> $BOGROOT_GROWTH_LEVEL1 And GetMapID() <> $BOGROOT_GROWTH_LEVEL2 Then Setup()

			$CURRENT_RUN += 1
			GUICtrlSetData($lblRunNumData, $CURRENT_RUN)

			$OpenedChestAgentIDs[0] = ""
			ReDim $OpenedChestAgentIDs[1]
			If GetMapID() == $SPARKFLY_SWAMP Then TakeQuest()
			If GetMapID() == $BOGROOT_GROWTH_LEVEL1 Then BogrootLvl1()
			If GetMapID() == $BOGROOT_GROWTH_LEVEL2 Then 
			   BogrootLvl2()
			   Boss()
			Endif
		Wend
	Wend
EndFunc

Func Setup()
   If $Sell_Items = True Then ClearInventory()

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
	GUICtrlSetState($inpRuns, $GUI_DISABLE)
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
	AdlibRegister("DeldrimorPoints", 1000)
	AdlibRegister("AsuraPoints", 1000)
	AdlibRegister("DropCounts", 1000)
	AdlibRegister("Lockpicks", 1000)
	;GUICtrlSetData($lblLockpicksData, $iLockpicks)
	;GUICtrlSetData($lblChestsData, $iChestCount)

	$IS_RUNNING = True
EndFunc

Func BeforeRun()
	SwitchMode(1)
	Out("Moving to Sparkfly")
	MoveTo(-10018, -21892)
	MoveTo(-9550, -20400)
	TolSleep(500)

	Do
		MoveTo(-9451, -19766)
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

	Local $aWaypoints[16][4] = [ _
	[-7746, -16039, 2000, "Raptor Group"], _
	[-6804, -10431, 2000, "Ferothrax Group"], _
	[-4001, -6599, 2000, "Angorodon Group"], _
	[-805, -3997, 2000, "Raptor Group 2"], _
	[2244, -1934, 2000, "Ferothrax Group 2"], _
	[4904, 281, 2000, "Raptor Group 3"], _
	[8014, 2151, 2000, "Cutting"], _
	[11344, 2137, 2000, "Ferothrax Group 3"], _
	[10322, 6297, 2000, "Raptor Group 4"], _
	[11650, 10117, 2000, "Moving to Simiam Group"], _
	[13227, 10518, 2000, "Simiam Group"], _
	[13011, 14609, 2000, "Moving to Simiam Group 2"], _
	[13292, 18200, 2000, "Simiam Group 2"], _
	[12965, 20463, 2000, "Moving to Simiam Group 3"], _
	[11874, 21508, 2000, "Simiam Group 3"], _
	[11874, 21508, 2000, "Simiam Group 3"]]

	MoveandAggro($aWaypoints)
EndFunc ;RunToBogroot

Func TakeQuest()
	Global $START_TIME = TimerInit()
	AdlibRegister("CurrentRunTime", 1000)

	TolSleep(2000)
	MoveTo(12396, 22007)
	Out("Taking Quest: Tekks")
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
	Out("Aggro Frog Fight")
	MoveTo(17026, 2168)
	AggroMoveToEx(18092, 4590)

	Out("Moving to Beacon of Droknar")
	MoveTo(19099, 7762)

	Out("Getting Dwarven Blessing")
	GetDwarvenBlessing(19099, 7762)

	; Level 1
	UseScroll()
	UseStones()
	Local $aWaypointsLevel1[19][4] = [ _
	[16342, 8640, 2000, "First Group"], _
	[10387, 7205, 2000, "Nettle Spores"], _
	[10222, 8325, 2000, "Blooming/Nettle Spores"], _
	[7671, 6216, 2000, "Blooming/Nettle Spores"], _
	[6086, 4315, 2000, "Allied Ophil"], _
	[2661, 424, 2000, "Allied Ophil"], _
	[1264, -36, 2000, "Attacking Gokir"], _
	[306, -2018, 2000, "Poison Traps"], _
	[-1010, -4100, 2000, "Nettle Seedling"], _
	[-1296, -5038, 2000, "Nettle Seedling"], _
	[-478, -7580, 2000, "Poison Traps"], _
	[512, -8861, 2000, "Gokir"], _
	[1230, -9846, 2000, "Ayahuasca"], _
	[1693, -12198, 2000, "Nettle Spores"], _
	[1072, -13738, 2000, "Blooming Nettles"], _
	[1668, -14944, 2000, "Ayahuasca/Oakheart"], _
	[4941, -16181, 2000, "Nettle Spores"], _
	[7360, -17361, 2000, "Moving to Level 2 Portal"], _
	[7552, -18776, 2000, "Moving to Level 2 Portal"]]
	MoveandAggro($aWaypointsLevel1)

	Out("Travelling to Bogroot Growths - Level 2.")
	Do
		Move(7665, -19050)
	Until WaitMapLoading($BOGROOT_GROWTH_LEVEL2)
Endfunc ;BogrootLvl1

Func BogrootLvl2()
	Out("Clearing Spawn")
	AggroMoveToEx(-11330, -5483)

	Out("Moving to Beacon of Droknar")
	MoveTo(-11132, -5546)

	Out("Getting Dwarven Blessing")
	GetDwarvenBlessing(-11132, -5546)

	; Level 2
	UseScroll()
	UseStones()
	Local $aWaypointsLevel2[27][4] = [ _
	[-10970, -4264, 2000, "Blooming Nettles"], _
	[-11165, -2066, 2000, "Blooming/Nettle Spores"], _
	[-11014, -1144, 2000, "Blooming/Nettle Spores"], _
	[-8609, 638, 2000, "Moving to Fungal/Nettle Spores"], _
	[-7306, 2604, 2000, "Fungal/Nettle Spores"], _
	[-6212, 3200, 2000, "Ayahuasca/Nettle Spores"], _
	[-4002, 4884, 2000, "Moving to Ayahuasca/Incubus"], _
	[-2428, 5925, 2000, "Moving to Ayahuasca/Incubus"], _
	[-2824, 6859, 2000, "Ayahuasca/Incubus"], _
	[-2586, 8994, 2000, "Ayahuasca/Incubus"], _
	[-2935, 10431, 2000, "Nettle Spores/Seedlings"], _
	[-2360, 11888, 2000, "Moving to East Side of Bogroot"], _
	[218, 11537, 2000, "Thorn/Ghosteater Beetles"], _
	[2547, 12113, 2000, "Moving to Thorn/Ghosteater Beetles"], _
	[3729, 13897, 2000, "Thorn/Ghosteater Beetles"], _
	[5414, 13698, 2000, "Thorn/Ghosteater Beetles"], _
	[6263, 10903, 2000, "Thorn/Ghosteater Beetles"], _
	[7538, 8724, 2000, "Gokir Battle"], _
	[7929, 7204, 2000, "Gokir Battle/Patriarch"], _
	[8392, 4424, 2000, "Moving to Gokir"], _
	[8921, 437, 2000, "Gokir"], _
	[9637, -718, 2000, "Gokir"], _
	[9381, -1975, 2000, "Gokir"], _
	[10232, -3814, 2000, "Moving to Next Gokir"], _
	[12195, -6471, 2000, "Moving to Next Gokir"], _
	[13884, -6384, 2000, "Moving to Next Gokir"], _
	[16814, -5754, 2000, "Gokir Patriarch/Boss Key"]]

	MoveandAggro($aWaypointsLevel2)

	TolSleep(500)
	MoveTo(16854, -5830)
	TolSleep(500)
	PickupLootEx(10000)
	TolSleep(500)

	Out("Open Dungeon Door")
	$BossLock = GetNearestSignpostToCoords(17804, -6157)
	GoToSignpost($BossLock)
EndFunc ;BogrootLvl2

Func Boss()
	Local $aWaypointsBoss[9][4] = [ _
	[18334, -8838, 2000, "Moving to Boss"], _
	[16131, -11510, 2000, "Moving to Boss"], _
	[19009, -12300, 2000, "Moving to Boss"], _
	[18413, -13924, 2000, "Moving to Boss"], _
	[14188, -15231, 2000, "Moving to Boss"], _
	[13186, -17286, 2000, "Moving to Boss"], _
	[14035, -17800, 3000, "Engaging Boss"], _
	[14617, -18282, 3000, "Engaging Boss"], _
	[15117, -18582, 3000, "Engaging Boss"]]

    UseScroll()
	MoveandAggro($aWaypointsBoss)
	Out("Boss Group Dead")

	$NearestEnemy = GetNearestEnemyToAgent($aPlayerAgent)
	$NearestDistance = @extended
	If $NearestDistance > 3000 Then
		Sleep(2000)
		Out("Bogroot Chest")
		MoveTo(14876, -19033)
		GoToSignpost(GetNearestSignpostToCoords(14876, -19033))
		TolSleep(4000)
		Out("Pick Up Drops")
		PickupLootEx(6000)
	EndIf

	Out("Accepting Quest Reward")
	Local $deadlock = 0
	Do
		GoNPC(GetNearestNPCToCoords(13975, -17211))
		TolSleep(500)
		Dialog($TekksComplete)
		$dealock += 1
	Until Not IsDllStruct(GetQuestByID($TEKKS_WAR)) Or $deadlock == 50
	If IsDllStruct(GetQuestByID($TEKKS_WAR)) Then AbandonQuest($TEKKS_WAR)
	Out("Wait for Reload")

	Do
		Sleep(200)
	Until WaitMapLoading($SPARKFLY_SWAMP)
	If $Sell_Items = True Then ClearInventory()
	AdlibUnregister("CurrentRunTime")
	TolSleep(3000)
EndFunc ;Boss

Func Out($sMessage)
	ConsoleWrite($sMessage & @CRLF)
	_GUICtrlRichEdit_SetFont($edtLog, 8, "Trebuchet MS")
	_GUICtrlRichEdit_AppendText($edtLog, $sMessage & @CRLF)
	_GUICtrlEdit_Scroll($edtLog, $SB_SCROLLCARET)
EndFunc ;Out

Func MoveandAggro($aWaypoints)
	Local $iFinish = UBound($aWaypoints) - 1
	Local $iStep = 1

	For $i = 0 to $iFinish step $iStep
		Out("Moving to waypoint - " &  $aWaypoints[$i][3])
		Local $nWaypointX = $aWaypoints[$i][0]
		Local $nWaypointY = $aWaypoints[$i][1]
		Local $nRange = $aWaypoints[$i][2]

		AggroMoveToEx($nWaypointX, $nWaypointY, $nRange)
	Next
EndFunc ;MoveandAggro

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

Func PickupLootEx($iMaxDist = 3000, $bCanPickup = True)
	$lMe = GetAgentByID(-2)
	For $i = 1 To GetMaxAgents()
		$aAgent = GetAgentByID($i)
		If Not GetIsMovable($aAgent) Then ContinueLoop
		$aItem = GetItemByAgentID($i)
		$aItemX = DllStructGetData($aAgent, "x")
		$aItemY = DllStructGetData($aAgent, "y")
		If CanPickUpEx($aItem, $bCanPickup) And ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $aItemX, $aItemY) < $iMaxDist Then
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
	$aRarity = GetRarity($aItem)
	$aItemID = DllStructGetData($aItem, "id")

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
;		Case 24372 ; Naga Shaman Polymock Piece
;			Return True
;		Case 27036 ; Amphibian Tongue - Nicholas Sometimes
;			Return True
		Case 22751 ; Lockpick
			$iLockpickCount += 1
			Return True
		Case 10 ; Black dye (use 146 for all dyes)
			$iBlackDyeCount += 1
			Return True
		Case 2511 ; Gold/Plats
			Return GetGoldCharacter() + DllStructGetData($aItem, 'Value') < 100000
		Case 3256, 3746, 5594, 5595, 5611, 21233, 22279, 22280 ; Scrolls
		    $iScrollCount += 1
			Return True
		Case 21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795, 21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805 ; Tomes
			$iTomeCount += 1
			Return True
		Case 28435, 28436: ;Cider and Pie
			Return True
;		Case 30855 ; Bottle of Grog
;			Return True
	EndSwitch

	Switch $aRarity
		Case 2624 ; Gold Items
			$iGoldCount += 1
			Return True
;		Case 2627 ; Green Items
;			$iUniqueCount += 1
;			Return True
	EndSwitch

	Return False
EndFunc


Func AggroMoveToEx($x, $y, $z = 900) ;Reduced from 2000

   $random = 50
   $iBlocked = 0

   Move($x, $y, $random)
   $Me = GetAgentByID()
   $coords[0] = DllStructGetData($Me, 'X')
   $coords[1] = DllStructGetData($Me, 'Y')

  If $Open_Chests = True Then CheckForChest()

   Do
	  RndSleep(250)
	  $oldCoords = $coords
	  local $timeragro = TimerInit()
	  $nearestenemy = GetNearestEnemyToAgent(-2)
	  $lDistance = GetDistance($nearestenemy, -2)
	  If $lDistance < $z AND DllStructGetData($nearestenemy, 'ID') <> 0 Then
		 Attack($nearestenemy)
		 Fight($z)
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
	  If $oldCoords[0] = $coords[0] AND $oldCoords[1] = $coords[1] AND TimerDiff($timeragro) < 2000 Then
		 $iBlocked += 1
		 MoveTo($coords[0], $coords[1], 500)
		 Sleep(GetPing()+500)
		 Move($x, $y)
	  EndIf
   Until ComputeDistance($coords[0], $coords[1], $x, $y) < 250 OR $iBlocked > 20
	  If $Open_Chests = True Then CheckForChest()
	  PickuplootEX()
EndFunc

Func Fight($x)
	Local $lastId = 99999, $coordinate[2],$timer

	Do
		$Me = GetAgentByID(-2)
		$energy = GetEnergy()
		$skillbar = GetSkillbar()
		Out($Skillbar)
		$useSkill = -1
		For $i = 0 To 7
			$recharged = DllStructGetData($skillbar, 'Recharge' & ($i + 1))
			$strikes = DllStructGetData($skillbar, 'AdrenalineA' & ($i + 1))
			If $recharged = 0 AND $intSkillEnergy[$i] <= $energy  Then
				$useSkill = $i + 1
				ExitLoop
			EndIf
		Next

		$target = GetNearestEnemyToAgent(-2)
		$distance = ComputeDistance(DllStructGetData($target, 'X'),DllStructGetData($target, 'Y'),DllStructGetData(GetAgentByID(-2), 'X'),DllStructGetData(GetAgentByID(-2), 'Y'))
		If $useSkill <> -1 AND $target <> 0 AND $distance < $x Then
			If DllStructGetData($target, 'Id') <> $lastId Then
				ChangeTarget($target)
				RndSleep(150)
				CallTarget($target)
				RndSleep(150)
				Attack($target)
				$lastId = DllStructGetData($target, 'Id')
				$coordinate[0] = DllStructGetData($target, 'X')
				$coordinate[1] = DllStructGetData($target, 'Y')
				$timer = TimerInit()
				Do
					Move($coordinate[0],$coordinate[1])
					rndsleep(500)
					$Me = GetAgentByID(-2)
					$distance = ComputeDistance($coordinate[0],$coordinate[1],DllStructGetData($Me, 'X'),DllStructGetData($Me, 'Y'))
				Until $distance < 1100 or TimerDiff($timer) > 10000
			EndIf
			RndSleep(150)
			$timer = TimerInit()
			Do
				$target = GetNearestEnemyToAgent(-2)
				$distance = ComputeDistance(DllStructGetData($target, 'X'),DllStructGetData($target, 'Y'),DllStructGetData(GetAgentByID(-2), 'X'),DllStructGetData(GetAgentByID(-2), 'Y'))
				If $distance < 1250 Then
					UseSkill($useSkill, $target)
					RndSleep(500)
				EndIf
				Attack($target)
				$Me = GetAgentByID(-2)
				$target = GetAgentByID(DllStructGetData($target, 'Id'))
				$coordinate[0] = DllStructGetData($target, 'X')
				$coordinate[1] = DllStructGetData($target, 'Y')
				$distance = ComputeDistance($coordinate[0],$coordinate[1],DllStructGetData($Me, 'X'),DllStructGetData($Me, 'Y'))
			Until DllStructGetData(GetSkillbar(), 'Recharge' & $useSkill) >0 or DllStructGetData($target, 'HP') < 0.005 Or $distance > $x Or TimerDiff($timer) > 5000
		EndIf
		$target = GetNearestEnemyToAgent(-2)
		$distance = ComputeDistance(DllStructGetData($target, 'X'),DllStructGetData($target, 'Y'),DllStructGetData(GetAgentByID(-2), 'X'),DllStructGetData(GetAgentByID(-2), 'Y'))
	Until DllStructGetData($target, 'ID') = 0 OR $distance > $x
	If CountFreeSlots() = 0 Then
		Out("Inventory full")
	Else
		Out("Pickup Loot")
		PickUpLootEX()
		;PickupItems(-1, $x)
	EndIf
 EndFunc


Func Fight_Rit($nRange = 1200)
	Local Enum $SIGNET_OF_SPIRITS = 1, $SHADOWSONG, $PAIN, $AGONY, $BLOODSONG, $PAINFUL_BOND, $ARMOR_OF_UNFEELING, $SUMMON_SPIRITS
	Local $SIGNET_OF_SPIRITS_ID = 1239, $SHADOWSONG_ID = 871, $PAIN_ID = 1247, $AGONY_ID = 2205, $BLOODSONG_ID = 1253, $PAINFUL_BOND_ID = 1237, $ARMOR_OF_UNFEELING_ID = 1232, $SUMMON_SPIRITS_ID = 2051
	$lMe = GetAgentByID(-2)
	Do
		$lTarget = GetNearestEnemyToAgent(-2)
		If GetDistance($lMe, $lTarget) > $nRange Then Return

		Attack($lTarget, True)

		If GetEnergy() >= GetEnergyCost($SUMMON_SPIRITS) And GetSkillbarSkillRecharge($SUMMON_SPIRITS) = 0 Then
			UseSkill($SUMMON_SPIRITS)
			SkillSleep($SUMMON_SPIRITS_ID)
		EndIf



		If GetSpiritsInRange() >= 2 Then
			If GetEnergy() >= GetEnergyCost($PAINFUL_BOND) And GetSkillbarSkillRecharge($PAINFUL_BOND) = 0 Then
				UseSkill($PAINFUL_BOND, $lTarget)
				SkillSleep($PAINFUL_BOND_ID)
			EndIf
		EndIf

		RndSleep(500)

		If GetEnergy() >= GetEnergyCost($SIGNET_OF_SPIRITS) And GetSkillbarSkillRecharge($SIGNET_OF_SPIRITS) = 0 Then
			UseSkill($SIGNET_OF_SPIRITS)
			SkillSleep($SIGNET_OF_SPIRITS_ID)
		EndIf

		RndSleep(500)

		If GetEnergy() >= GetEnergyCost($SHADOWSONG) And GetSkillbarSkillRecharge($SHADOWSONG) = 0 Then
			UseSkill($SHADOWSONG)
			SkillSleep($SHADOWSONG_ID)
		EndIf

		RndSleep(500)

		If GetEnergy() >= GetEnergyCost($PAIN) And GetSkillbarSkillRecharge($PAIN) = 0 Then
			UseSkill($PAIN)
			SkillSleep($PAIN_ID)
		EndIf

		RndSleep(500)

		If GetEnergy() >= GetEnergyCost($AGONY) And GetSkillbarSkillRecharge($AGONY) = 0 Then
			UseSkill($AGONY)
			SkillSleep($AGONY_ID)
		EndIf

		RndSleep(500)

		If GetEnergy() >= GetEnergyCost($BLOODSONG) And GetSkillbarSkillRecharge($BLOODSONG) = 0 Then
			UseSkill($BLOODSONG)
			SkillSleep($BLOODSONG_ID)
		EndIf

		RndSleep(500)

		If GetEnergy() >= GetEnergyCost($ARMOR_OF_UNFEELING) And GetSkillbarSkillRecharge($ARMOR_OF_UNFEELING) = 0 Then
			UseSkill($ARMOR_OF_UNFEELING)
			SkillSleep($ARMOR_OF_UNFEELING_ID)
		EndIf

		RndSleep(500)
	Until GetIsDead($lTarget)
	PickupLootEx(4000)
EndFunc

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
EndFunc

 Func GetChecked($GUICtrl)
	Return (GUICtrlRead($GUICtrl)==$GUI_Checked)
 EndFunc


Func CheckForChest()
	Local $AgentArray, $lAgent, $lExtraType
	Local $ChestFound = False
	Local $lLockPicksBefore = GUICtrlRead($lblLockpicksData)
	;If $lLockPicksBefore == 0 Then Return
	If GetIsDead(-2) Then Return

	$AgentArray = GetAgentArraySorted(0x200)	;0x200 = type: static
	For $i = 0 To UBound($AgentArray) - 1	;there might be multiple chests in range
	    Out ("Looking for chests")
		$lAgent = GetAgentByID($AgentArray[$i][0])
		$lExtraType = DllStructGetData($lAgent, 'ExtraType')
		If $lExtraType <> 4582 And $lExtraType <> 8141 Then ContinueLoop	;dirty fix: skip signposts that aren't chests (nm And hm chest)
		If _ArraySearch($OpenedChestAgentIDs, $AgentArray[$i][0]) == -1 Then
			If @error <> 6 Then ContinueLoop
			If $OpenedChestAgentIDs[0] = "" Then	;dirty fix: blacklist chests that were opened before
				$OpenedChestAgentIDs[0] = $AgentArray[$i][0]
			Else
				_ArrayAdd($OpenedChestAgentIDs, $AgentArray[$i][0])
			EndIf
			$ChestFound = True
			Out ("Chest Found")
			ExitLoop
		EndIf
	Next
	If Not $ChestFound Then Return
	Out("opening chest")
	GoSignpost($lAgent)
	OpenChest()
	$iChestCount += 1
	Sleep(GetPing() + 500)
	$AgentArray = GetAgentArraySorted(0x400)	;0x400 = type: item
	ChangeTarget($AgentArray[0][0])	;in case you watch the bot running you can see what dropped immediately
    GUICtrlSetData($lblChestsData, $iChestCount)

	PickUpLootEX()
 EndFunc   ;==>CheckForChest

 Func GetAgentArraySorted($lAgentType)	;returns a 2-dimensional array([agentID, [distance]) sorted by distance
	Local $lDistance
	Local $lAgentArray = GetAgentArray($lAgentType)
	Local $lReturnArray[1][2]
	Local $lMe = GetAgentByID(-2)
	Local $AgentID

	For $i = 1 To $lAgentArray[0]
		$lDistance = (DllStructGetData($lMe, 'X') - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + (DllStructGetData($lMe, 'Y') - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
		$AgentID = DllStructGetData($lAgentArray[$i], 'ID')
		ReDim $lReturnArray[$i][2]
		$lReturnArray[$i - 1][0] = $AgentID
		$lReturnArray[$i - 1][1] = Sqrt($lDistance)
	Next
	_ArraySort($lReturnArray, 0, 0, 0, 1)
	Return $lReturnArray
EndFunc   ;==>GetAgentArraySorted


Func ToggleScrolls()
	$Use_Scrolls = Not $Use_Scrolls
EndFunc   ;==>ToggleScrolls

Func ToggleStones()
   If $Use_Stones = True Then
	  $Use_Stones = False
   Else
	  if $Use_Stones = False Then
		 $Use_Stones = True
	  Endif
   EndIf
EndFunc   ;==>ToggleStones


 Func ToggleRendering()
	$RenderingEnabled = Not $RenderingEnabled
	If $RenderingEnabled Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
	Else
		DisableRendering()
		WinSetState(GetWindowHandle(), "", @SW_HIDE)
		ClearMemory()
	EndIf
EndFunc   ;==>ToggleRendering

Func ToggleOpenChests()
   If $Open_Chests = True Then
	  $Open_Chests = False
   Else
	  if $Open_Chests = False Then
		 $Open_Chests = True
	  Endif
   EndIf
EndFunc ;==> ToggleOpenChests

Func ToggleStore()
   If $Store_Golds = True Then
	  $Store_Golds = False
   Else
	  if $Store_Golds = False Then
		 $Store_Golds = True
	  Endif
   EndIf
EndFunc ;==>ToggleIdent and identifies bags

Func ToggleSell()
   If $Sell_Items = True Then
	  $Sell_Items = False
   Else
	  if $Sell_Items = False Then
		 $Sell_Items = True
	  Endif
   EndIf
   IdentifyBag(1)
   IdentifyBag(2)
   IdentifyBag(3)
   IdentifyBag(4)
EndFunc ;==> ToggleSellItems

Func Purgehook()
	Out("PurgeHook")
	Enablerendering()
	Sleep(3000)
	Disablerendering()
Endfunc

Func TotalTime()
	Local $g_iSecs, $g_iMins, $g_iHour
	_TicksToTime(Int(TimerDiff($nTotalTime)), $g_iHour, $g_iMins, $g_iSecs)
	Local $sTime = StringFormat("%02i:%02i:%02i", $g_iHour, $g_iMins, $g_iSecs)
	GuiCtrlSetData($lblTotalRunData, $sTime)
EndFunc

Func CurrentRunTime()
	Local $g_iSecs, $g_iMins, $g_iHour
	_TicksToTime(Int(TimerDiff($START_TIME)), $g_iHour, $g_iMins, $g_iSecs)
	Local $sTime = StringFormat("%02i:%02i:%02i", $g_iHour, $g_iMins, $g_iSecs)
	GuiCtrlSetData($lblCurrentRunData, $sTime)
EndFunc

Func DeldrimorPoints()
	Local $iCurrentDeldrimorTitle = GetDeldrimorTitle()
	$iCalcPoints = $iCurrentDeldrimorTitle - $iDeldrimorTitle
	GUICtrlSetData($lblDeldrimorData, int($iCalcPoints))
EndFunc

Func AsuraPoints()
	Local $iCurrentAsuraTitle = GetAsuraTitle()
	$iCalcPoints = $iCurrentAsuraTitle - $iAsuraTitle
	GUICtrlSetData($lblAsuraData, int($iCalcPoints))
EndFunc

Func Lockpicks()
	Local $TotalPicksCount = GetPicksCount()
	GUICtrlSetData($lblLockpicksData, $TotalPicksCount)
EndFunc

Func DropCounts()
	GUICtrlSetData($lblFroggyData, $iFroggyCount)
	GUICtrlSetData($lblGoldData, $iGoldCount)
	GUICtrlSetData($lblLockpicksDropData, $iLockpickCount)
	GUICtrlSetData($lblChestsData, $iChestCount)
	GUICtrlSetData($lblBlackDyeData, $iBlackDyeCount)
	GUICtrlSetData($lblTomesData, $iTomeCount)
EndFunc

Func ExitBot()
	AdlibUnRegister("TotalTime")
	AdlibUnRegister("DeldrimorPoints")
	AdlibUnRegister("AsuraPoints")
	AdlibUnRegister("Lockpicks")
	AdlibUnRegister("DropCounts")
	Exit
EndFunc

Func GetSpiritsInRange($nRange = 600)
	Local $lMe = GetAgentByID(-2)
	Local $nSpirits = 0
	$lMe = GetAgentByID(-2)
	For $i = 1 to GetMaxAgents()
		$aAgent = GetAgentByID($i)
		If Not BitAND(DllStructGetData($aAgent, 'Typemap'), 131072) Then ContinueLoop
		If BitAND(DllStructGetData($aAgent, 'Effects'), 0x0010) Then ContinueLoop
		If BitAND(DllStructGetData($aAgent, 'Typemap'), 262144) And GetDistance($aAgent, $lMe) <= $nRange Then
			$nSpirits += 1
		EndIf
	Next
	Return $nSpirits
EndFunc

Func SkillSleep($nSkillID)
	$aSkill = GetSkillByID($nSkillID)
	$nActivationTime = DllStructGetData($aSkill, 'Activation') * 1000
	Sleep($nActivationTime + 100)
EndFunc

Func UseScroll() ;Uses scroll if in inventory based on GUI checkbox
	If $Use_Scrolls = True Then
		$item = GetItemByModelID(21233)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Lightbringer Scroll")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(5595)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Berserkers Insight")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(5611)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Slayers Insight")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(5594)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Heros Insight")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(5975)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Rampagers Insight")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(5976)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Hunters Insight")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(5853)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Adventurers Insight")
			UseItem($item)
			Return
		EndIf
		Out("No scrolls found")
	EndIf
EndFunc

Func UseStones() ;Uses summoning stone if in inventory based on GUI checkbox

	If $Use_Stones = True Then
		$item = GetItemByModelID(37810)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Legionnaire Summoning Crystal")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(31156)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Zaischen Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(30846)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Automaton Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(30959)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Chitinous Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(30961)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Amber Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(30962)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Artic Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(30963)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Demonic Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(30964)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Geletinous Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(30965)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Fossilized Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(30966)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Jadeite Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(31022)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Mischievous Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(31023)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Frosty Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(32557)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Ghastly Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(34176)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Celestial Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(30960)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Mystical Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(31155)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Mysterious Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(35126)                        ;the ID seems to be incorrect as this is activated even when non exists
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Shining Blade Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(30210)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Imperial Guard Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(30209)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Tengu Summoning Stone")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(21154)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Merchant Summoning Stone")
			UseItem($item)
			Return
		EndIf
		Out("No summoning stones found")
	EndIf
EndFunc

