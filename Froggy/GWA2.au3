Local $mGWA2Version = '3.7.11' ; GWA2 Version
; Fixed string log

#include-once
#RequireAdmin

If @AutoItX64 Then
	MsgBox(16, "Error!", "Please run all bots in 32-bit (x86) mode.")
	Exit
EndIf

#Region Declarations
Local $mKernelHandle
Local $mGWProcHandle
Local $mGWProcessId
Local $mGWWindowHandle
Local $mMemory
Local $mLabels[1][2]
Local $mBase = 0x00DE0000
Local $mASMString
Local $mASMSize
Local $mASMCodeOffset
Local $mGUI = GUICreate('GWA2')
Local $mSkillActivate
Local $mSkillCancel
Local $mSkillComplete
Local $mChatReceive
Local $mLoadFinished
Local $mSkillLogStruct = DllStructCreate('dword;dword;dword;float')
Local $mSkillLogStructPtr = DllStructGetPtr($mSkillLogStruct)
Local $mChatLogStruct = DllStructCreate('dword;wchar[256]')
Local $mChatLogStructPtr = DllStructGetPtr($mChatLogStruct)
GUIRegisterMsg(0x501, 'Event')
Local $mCharname
Local $mBasePointer
Local $mAgentBase
Local $mMaxAgents
Local $mMyID
Local $mMapLoading
Local $mCurrentTarget
Local $mPing
Local $mMapID
Local $mLoggedIn
Local $mRegion
Local $mLanguage
Local $mSkillBase
Local $mSkillTimer
Local $mBuildNumber
Local $mZoomStill
Local $mZoomMoving
Local $mCurrentStatus
Local $mQueueCounter
Local $mQueueSize
Local $mQueueBase
Local $mTargetLogBase
Local $mStringLogBase
Local $mMapIsLoaded
Local $mEnsureEnglish
Local $mTraderQuoteID
Local $mTraderCostID
Local $mTraderCostValue
Local $mDisableRendering
Local $mAgentCopyCount
Local $mAgentCopyBase
Local $mCharslots
#EndRegion Declarations

#Region Variables
Global $MyPlayerNumber
Global Enum $RARITY_White = 0xa3D, $RARITY_Blue = 0xa3F, $RARITY_Purple = 0xa42, $RARITY_Gold = 0xa40, $RARITY_Green = 0xa43
Global Enum $DIFFICULTY_NORMAL, $DIFFICULTY_HARD
Global Enum $INSTANCETYPE_OUTPOST, $INSTANCETYPE_EXPLORABLE, $INSTANCETYPE_LOADING
Global Enum $PROF_NONE, $PROF_WARRIOR, $PROF_RANGER, $PROF_MONK, $PROF_NECROMANCER, $PROF_MESMER, $PROF_ELEMENTALIST, $PROF_ASSASSIN, $PROF_RITUALIST, $PROF_PARAGON, $PROF_DERVISH
Global Enum $BAG_Backpack = 1, $BAG_BeltPouch, $BAG_Bag1, $BAG_Bag2, $BAG_EquipmentPack, $BAG_UnclaimedItems = 7, $BAG_Storage1, $BAG_Storage2, _
		$BAG_Storage3, $BAG_Storage4, $BAG_Storage5, $BAG_Storage6, $BAG_Storage7, $BAG_Storage8, $BAG_StorageAnniversary
Global Enum $HERO_Norgu = 1, $HERO_Goren, $HERO_Tahlkora, $HERO_MasterOfWhispers, $HERO_AcolyteJin, $HERO_Koss, $HERO_Dunkoro, $HERO_AcolyteSousuke, $HERO_Melonni, _
		$HERO_ZhedShadowhoof, $HERO_GeneralMorgahn, $HERO_MargridTheSly, $HERO_Olias = 14, $HERO_Razah, $HERO_MOX, $HERO_Jora = 18, $HERO_PyreFierceshot, _
		$HERO_Livia = 21, $HERO_Hayda, $HERO_Kahmu, $HERO_Gwen, $HERO_Xandra, $HERO_Vekk, $HERO_Ogden
Global Enum $SKILLTYPE_Stance = 3, $SKILLTYPE_Hex, $SKILLTYPE_Spell, $SKILLTYPE_Enchantment, $SKILLTYPE_Signet, $SKILLTYPE_Condition, $SKILLTYPE_Well, _
		$SKILLTYPE_Skill, $SKILLTYPE_Ward, $SKILLTYPE_Glyph, $SKILLTYPE_Attack = 14, $SKILLTYPE_Shout, $SKILLTYPE_Preparation = 19, _
		$SKILLTYPE_Trap = 21, $SKILLTYPE_Ritual, $SKILLTYPE_ItemSpell = 24, $SKILLTYPE_WeaponSpell, $SKILLTYPE_Chant = 27, $SKILLTYPE_EchoRefrain
Global Enum $ComboReq_FollowsDual = 1, $ComboReq_FollowsLead, $ComboReq_FollowsOffhand = 4
Global Enum $ATTRIB_FastCasting, $ATTRIB_IllusionMagic, $ATTRIB_DominationMagic, $ATTRIB_InspirationMagic, _
		$ATTRIB_BloodMagic, $ATTRIB_DeathMagic, $ATTRIB_SoulReaping, $ATTRIB_Curses, _
		$ATTRIB_AirMagic, $ATTRIB_EarthMagic, $ATTRIB_FireMagic, $ATTRIB_WaterMagic, $ATTRIB_EnergyStorage, _
		$ATTRIB_HealingPrayers, $ATTRIB_SmitingPrayers, $ATTRIB_ProtectionPrayers, $ATTRIB_DivineFavor, _
		$ATTRIB_Strength, $ATTRIB_AxeMastery, $ATTRIB_HammerMastery, $ATTRIB_Swordsmanship, $ATTRIB_Tactics, _
		$ATTRIB_BeastMastery, $ATTRIB_Expertise, $ATTRIB_WildernessSurvival = 24, $ATTRIB_Marksmanship, _
		$ATTRIB_DaggerMastery = 29, $ATTRIB_DeadlyArts, $ATTRIB_ShadowArts, _
		$ATTRIB_Communing, $ATTRIB_RestorationMagic, $ATTRIB_ChannelingMagic, _
		$ATTRIB_CriticalStrikes, _
		$ATTRIB_SpawningPower, _
		$ATTRIB_SpearMastery, $ATTRIB_Command, $ATTRIB_Motivation, $ATTRIB_Leadership, _
		$ATTRIB_ScytheMastery, $ATTRIB_WindPrayers, $ATTRIB_EarthPrayers, $ATTRIB_Mysticism
Global $mSelf
Global $GoPlayer = 0
Global $MyMaxHP
Global Const $Null = 0
Global $AOEDanger = False
Global $AOEDangerRange = 0
Global $AOEDangerXLocation
Global $AOEDangerYLocation
Global $AOEDangerDuration
Global $AOEDangerTimer
Global $mSelfID
Global $mLowestAlly
Global $mLowestAllyHP
Global $mLowestAllyDist
Global $mHighestAlly
Global $mHighestAllyHP
Global $mLowestOtherAlly
Global $mLowestOtherAllyHP
Global $mLowestOtherAllyDist
Global $mHighestOtherAlly
Global $mHighestOtherAllyHP
Global $SpeedBoostTarget
Global $mLowestEnemy
Global $mLowestEnemyHP
Global $mClosestEnemy
Global $mClosestEnemyDist
Global $mBestShrineTarget
Global $mAlliesInRangeOfShrine
Global $mClosestAlly
Global $mClosestAllyDist
Global $mClosestOtherAlly
Global $mClosestOtherAllyDist
Global $mClosestFriendlyQuarry
Global $mClosestFriendlyQuarryDist
Global $mClosestCarrier
Global $mClosestCarrierDist
Global $mAverageTeamHP
Global $mAverageTeamLocationX
Global $mAverageTeamLocationY
Global $TotalAlliesOnMap
Global $NumberOfFoesInAttackRange = 0
Global $NumberOfDeadFoes = 0
Global $NumberOfFoesInSpellRange = 0
Global $NumPlayersInCloseRange = 0
Global $NumAlliesInCloseRange = 0
Global $NumPlayersOnMap = 0
Global $NearestShrineTarget = 0
Global $NearestShrineDist
Global $LeastAttackedShrine = 0
Global $LeastAttackedShrineDist
Global $NearestQuarryTarget = 0
Global $NearestQuarryDist
Global $BestAOETarget
Global $HexedAlly
Global $ConditionedAlly
Global $EnemyHexed
Global $EnemyNonHexed
Global $EnemyConditioned
Global $EnemyNonConditioned
Global $EnemyHealer
Global $EnemyAttacker = 0
Global $ClostestX[1]
Global $ClostestY[1]
Global $mTeam[1] ;Array of living members
Global $mTeamOthers[1] ;Array of living members other than self
Global $mTeamDead[1] ;Array of dead teammates
Global $mEnemies[1] ;Array of living enemy team
Global $mEnemiesRange[1] ;Array of living enemy team in range of waypoint
Global $mEnemiesSpellRange[1] ;Array of living enemy team in spell range
Global $mEnemyCorpesSpellRange[1] ;Array of dead enemy team in spell range
Global $mSpirits[1] ;Array of your spirits
Global $mPets[1] ;Array of your/your hero's pets
Global $mMinions[1] ;Array of your minions
Global Const $BoneHorrorID = 2198
Global $mDazed = False
Global $mBlind = False
Global $mSkillHardCounter = False
Global $mSkillSoftCounter = 0
Global $mAttackHardCounter = False
Global $mAttackSoftCounter = 0
Global $mAllySpellHardCounter = False
Global $mEnemySpellHardCounter = False
Global $mSpellSoftCounter = 0
Global $mBlocking = False
Global $mCastTime = -1
Global $mLastTarget = 0
Global $mMinipet = True
Global $boolRun = False
Global $Goldz = False
Global $boolIDSell = True
Global $boolPickAll = True
Global $intFaction = 0
Global $intTitle = 0
Global $intPrevious = -1
Global $intStarted = -1
Global $intCash = -1
Global $intGold = 0
Global $intRuns = 0
Global $Runs = 0
Global $grog = 30855
Global $golds = 2511
Global $gstones = 27047
Global $tots = 28434
Global $Resigned = False
Global $SavedLeader
Global $SavedLeaderID
Global $NumberInParty
Global $InOutpostCounter = 0
Global $GotBounty = False
Global $Defending = False
Global $CurrentMapID = 0
Global $UpdateText
Global $FirstRun = True
Global $RENDERING = True
Global $GWPID = -1
Global $UseEverlastingTonic = False
Global $HurtTimer = TimerInit()
Global $RestTimer
Global $CurrentHP = 1000
Global $NeedToChangeMap = False
Global $Resting = False
Global $Pink = 9
Global $InAttackRange = False
Global Const $Sunday = "Sunday"
Global Const $Monday = "Monday"
Global Const $Tuesday = "Tuesday"
Global Const $Wednesday = "Wednesday"
Global Const $Thursday = "Thursday"
Global Const $Friday = "Friday"
Global Const $Saturday = "Saturday"
Global $mTempStorage[1][2] = [[0, 0]]
Global $SlotFull[5][25]
Global $NewSlot
Global $mFoundMerch = False
Global $mFoundChest = False
Global $aMerchName = "Merchant"
Global Const $SaveGolds = False ;Save gold items.
Global Const $Bags = 4
Global Const $Ectoplasm = 930
Global Const $ObsidianShards = 945
Global Const $Ruby = 937
Global Const $Sapphire = 938
Global Const $DiessaChalice = 24353
Global Const $GoldenRinRelics = 24354
Global Const $Lockpicks = 22751
Global Const $SuperbCharrCarving = 27052
Global Const $DarkRemains = 522
Global Const $UmbralSkeletalLimbs = 525
Global Const $Scroll_Underworld = 3746
Global Const $Scroll_FOW = 22280
Global Const $MAT_Bone = 921
Global Const $MAT_Dust = 929
Global Const $MAT_Iron = 948
Global Const $MAT_TannedHides = 940
Global Const $MAT_Scales = 953
Global Const $MAT_Chitin = 954
Global Const $MAT_Cloth = 925
Global Const $MAT_Wood = 946
Global Const $MAT_Granite = 955
Global Const $MAT_Fiber = 934
Global Const $MAT_Feathers = 933
Global Const $CON_EssenceOfCelerity = 24859
Global Const $CON_GrailOfMight = 24861
Global Const $CON_ArmorOfSalvation = 24860

Global Const $ENEMY = 0x3
;===========Skills Stuff============;
Global $GetSkillBar = False
Global $mSkillTimer = TimerInit()
Global $mSkillbarCache[9] = [False]
Global $mSkillbarCacheStruct[9] = [False]
Global $mSkillbarCacheEnergyReq[9] = [False]
Global $mEffects
Global $mSkillbar
Global $mEnergy
Global $IsHealingSpell[9] = [False]
Global $IsCorpseSpell[9] = [False]
Global $IsHealingOtherAllySpell[9] = [False]
Global $IsSpeedBoostSkill[9] = [False]
Global $IsSpiritSpell[9] = [False]
Global $IsHexRemover[9] = [False]
Global $IsConditionRemover[9] = [False]
Global $IsAOESpell[9] = [False]
Global $IsGeneralAttackSpell[9] = [False]
Global $IsInterruptSpell[9] = [False]
Global $IsYMLAD[9] = [False]
Global $YMLADSlot = 0
Global $IsRezSpell[9] = [False]
Global $IsSummonSpell[9] = [False]
Global $IsSoulTwistingSpell[9] = [False]
Global $IsSelfCastingSpell[9] = [False]
Global $IsWeaponSpell[9] = [False]
Global $SkillDamageAmount[9] = [False]
Global $SkillAdrenalineReq[9] = [False]
Global $SkillComboFollowsDual[9] = [False]
Global $SkillComboFollowsLead[9] = [False]
Global $SkillComboFollowsOffhand[9] = [False]
Global $IsHealerPrimary = False
Global $Skill_FAILED = 0
Global $EnemyCaster = 0
Global $EnemyCasterTimer
Global $EnemyCasterSkillTime
Global $EnemyCasterActivationTime = 0
Global $lMyProfession
Global $lAttrPrimary
Global $SkillTYP
Global $YMLADTimer = 5000

Const $MK_LBUTTON = 0x0001
Const $MK_RBUTTON = 0x0002

Global $HoMID = 646
Global $EotNID = 642
Global $ArrowHeafExpID = 849
Global $RataSumID = 640
Global $RivenEarthID = 501
Global $DrazachThicketmID = 195
Global $TheEternalGroveID = 222
Global $LongeyesLedgeID = 650
Global $BjoraMarchesID = 482
Global $JagaMoraineID = 546
Global $DrazachThicketmID = 195
Global $TheEternalGroveID = 222
Global $IsleOfTheNamelessID = 280
Global $JadeQuarryKurzickID = 296
Global $JadeQuarryLuxonID = 295
Global $JadeQuarryArenaID = 223
Global $GreatTempleOfBalthazarID = 248
Global $RandomArenaID = 188
Global $RAID = 365
Global $DAlessioArenaID = 339
Global $AmnoonArena_ID = 340
Global $FortKoga_ID = 341
Global $HeroesCryptID = 342
Global $ShiverpeakArenaID = 343
Global $BrawlersPitID = 352
Global $PetrifiedArenaID = 353
Global $SeabedArenaID = 354
Global $IsleofWeepingStone_ID = 355
Global $IsleofJadeID = 356
Global $ImperialIsleID = 357
Global $IsleofMeditationID = 358
Global $ImperialIsleID = 359
Global $IsleofMeditationID = 360
Global $IsleofWeepingStoneID = 361
Global $IsleofJadeID = 362
Global $ImperialIsle_ID = 363
Global $IsleofMeditation_ID = 364
Global $Random_Arenas_TestID = 365
Global $ShingJeaArena_ID = 366


Global $ScryingPoolPN = 5864
Global $WhiteMantleZealotPN = 8143
Global $Faction_Kurzick = 1
Global $Faction_Luxon = 2

;; ModelIDs
Global $LuxonLongbowMID = 3081
Global $LuxonStormCallerMID = 3079
Global $LuxonWizardMID = 3077
Global $KurzickFarShotMID = 3080
Global $KurzickThunderMID = 3078
Global $KurzickIllusionistMID = 3076
Global $LuxonBaseDefenderMID = 3083
Global $KurzickBaseDefenderMID = 3082
Global $GreenTurtleMID = 3575
Global $PurpleCarrierJuggernautMID = 3357
;~ Front of Luxon base, 851, 7019
;~ Lux base door 2, 3729, 4538
;~ front of kurzick base, -3850, 1922
;~ kurz door 2, -1272, -716
Global $MapCenter[2] = [-486, 2017]



#EndRegion Variables

#Region CommandStructs
Local $mUseSkill = DllStructCreate('ptr;dword;dword;dword')
Local $mUseSkillPtr = DllStructGetPtr($mUseSkill)

Local $mMove = DllStructCreate('ptr;float;float;float')
Local $mMovePtr = DllStructGetPtr($mMove)

Local $mChangeTarget = DllStructCreate('ptr;dword')
Local $mChangeTargetPtr = DllStructGetPtr($mChangeTarget)

Local $mPacket = DllStructCreate('ptr;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword')
Local $mPacketPtr = DllStructGetPtr($mPacket)

Local $mSellItem = DllStructCreate('ptr;dword;dword')
Local $mSellItemPtr = DllStructGetPtr($mSellItem)

Local $mAction = DllStructCreate('ptr;dword;dword')
Local $mActionPtr = DllStructGetPtr($mAction)

Local $mToggleLanguage = DllStructCreate('ptr;dword')
Local $mToggleLanguagePtr = DllStructGetPtr($mToggleLanguage)

Local $mUseHeroSkill = DllStructCreate('ptr;dword;dword;dword')
Local $mUseHeroSkillPtr = DllStructGetPtr($mUseHeroSkill)

Local $mBuyItem = DllStructCreate('ptr;dword;dword;dword')
Local $mBuyItemPtr = DllStructGetPtr($mBuyItem)

Local $mSendChat = DllStructCreate('ptr;dword')
Local $mSendChatPtr = DllStructGetPtr($mSendChat)

Local $mWriteChat = DllStructCreate('ptr')
Local $mWriteChatPtr = DllStructGetPtr($mWriteChat)

Local $mRequestQuote = DllStructCreate('ptr;dword')
Local $mRequestQuotePtr = DllStructGetPtr($mRequestQuote)

Local $mRequestQuoteSell = DllStructCreate('ptr;dword')
Local $mRequestQuoteSellPtr = DllStructGetPtr($mRequestQuoteSell)

Local $mTraderBuy = DllStructCreate('ptr')
Local $mTraderBuyPtr = DllStructGetPtr($mTraderBuy)

Local $mTraderSell = DllStructCreate('ptr')
Local $mTraderSellPtr = DllStructGetPtr($mTraderSell)

Local $mSalvage = DllStructCreate('ptr;dword;dword;dword')
Local $mSalvagePtr = DllStructGetPtr($mSalvage)

Local $mSetAttributes = DllStructCreate("ptr;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword")
Local $mSetAttributesPtr = DllStructGetPtr($mSetAttributes)

Local $mMakeAgentArray = DllStructCreate('ptr;dword')
Local $mMakeAgentArrayPtr = DllStructGetPtr($mMakeAgentArray)

Local $mChangeStatus = DllStructCreate('ptr;dword')
Local $mChangeStatusPtr = DllStructGetPtr($mChangeStatus)
#EndRegion CommandStructs

#Region Headers
$SalvageMaterialsHeader = 0x7F
$SalvageModHeader = 0x80
$IdentifyItemHeader = 0x71
$EquipItemHeader = 0x36
$UseItemHeader = 0x83
$PickUpItemHeader = 0x45
$DropItemHeader = 0x32
$MoveItemHeader = 0x77
$AcceptAllItemsHeader = 0x78
$DropGoldHeader = 0x35
$ChangeGoldHeader = 0x81
$AddHeroHeader = 0x23
$KickHeroHeader = 0x24
$AddNpcHeader = 0xA5
$KickNpcHeader = 0xAE
$CommandHeroHeader = 0x1E
$CommandAllHeader = 0x1F
$LockHeroTargetHeader = 0x18
$SetHeroAggressionHeader = 0x17
$ChangeHeroSkillSlotStateHeader = 0x1C
$SetDisplayedTitleHeader = 0x5D
$RemoveDisplayedTitleHeader = 0x5E
$GoPlayerHeader = 0x39
$GoNPCHeader = 0x3F
$GoSignpostHeader = 0x57
$AttackHeader = 0x2C
$MoveMapHeader = 0xB7
$ReturnToOutpostHeader = 0xAD
$EnterChallengeHeader = 0xAB
$TravelGHHeader = 0xB6
$LeaveGHHeader = 0xB8
$AbandonQuestHeader = 0x12
$CallTargetHeader = 0x28
$CancelActionHeader = 0x2E
$OpenChestHeader = 0x59
$DropBuffHeader = 0x2F
$LeaveGroupHeader = 0xA8
$SwitchModeHeader = 0xA1
$DonateFactionHeader = 0x3B
$DialogHeader = 0x41
$SkipCinematicHeader = 0x68
$SetSkillbarSkillHeader = 0x61
$LoadSkillbarHeader = 0x62
$ChangeSecondProfessionHeader = 0x47
$SendChatHeader = 0x69
$SetAttributesHeader = 0x10
#EndRegion Headers

#Region Memory
;~ Description: Internal use only.
Func MemoryOpen($aPID)
	$mKernelHandle = DllOpen('kernel32.dll')
	Local $lOpenProcess = DllCall($mKernelHandle, 'int', 'OpenProcess', 'int', 0x1F0FFF, 'int', 1, 'int', $aPID)
	$mGWProcHandle = $lOpenProcess[0]
EndFunc   ;==>MemoryOpen

;~ Description: Internal use only.
Func MemoryClose()
	DllCall($mKernelHandle, 'int', 'CloseHandle', 'int', $mGWProcHandle)
	DllClose($mKernelHandle)
EndFunc   ;==>MemoryClose

;~ Description: Internal use only.
Func WriteBinary($aBinaryString, $aAddress)
	Local $lData = DllStructCreate('byte[' & 0.5 * StringLen($aBinaryString) & ']'), $i
	For $i = 1 To DllStructGetSize($lData)
		DllStructSetData($lData, 1, Dec(StringMid($aBinaryString, 2 * $i - 1, 2)), $i)
	Next
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'ptr', $aAddress, 'ptr', DllStructGetPtr($lData), 'int', DllStructGetSize($lData), 'int', 0)
EndFunc   ;==>WriteBinary

;~ Description: Internal use only.
Func MemoryWrite($aAddress, $aData, $aType = 'dword')
	Local $lBuffer = DllStructCreate($aType)
	DllStructSetData($lBuffer, 1, $aData)
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
EndFunc   ;==>MemoryWrite

;~ Description: Internal use only.
Func MemoryRead($aAddress, $aType = 'dword')
	Local $lBuffer = DllStructCreate($aType)
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
	Return DllStructGetData($lBuffer, 1)
EndFunc   ;==>MemoryRead

;~ Description: Internal use only.
Func MemoryReadPtr($aAddress, $aOffset, $aType = 'dword')
	Local $lPointerCount = UBound($aOffset) - 2
	Local $lBuffer = DllStructCreate('dword')

	For $i = 0 To $lPointerCount
		$aAddress += $aOffset[$i]
		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
		$aAddress = DllStructGetData($lBuffer, 1)
		If $aAddress == 0 Then
			Local $lData[2] = [0, 0]
			Return $lData
		EndIf
	Next

	$aAddress += $aOffset[$lPointerCount + 1]
	$lBuffer = DllStructCreate($aType)
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
	Local $lData[2] = [$aAddress, DllStructGetData($lBuffer, 1)]
	Return $lData
EndFunc   ;==>MemoryReadPtr

;~ Description: Internal use only.
Func SwapEndian($aHex)
	Return StringMid($aHex, 7, 2) & StringMid($aHex, 5, 2) & StringMid($aHex, 3, 2) & StringMid($aHex, 1, 2)
EndFunc   ;==>SwapEndian
#EndRegion Memory

#Region Initialisation
;~ Description: Returns a list of logged characters
Func GetLoggedCharNames()
	Local $array = ScanGW()
	If $array[0] <= 0 Then Return ''
	Local $ret = $array[1]
	For $i=2 To $array[0]
		$ret &= "|"
		$ret &= $array[$i]
	Next
	Return $ret
EndFunc

;~ Description: Returns an array of logged characters of gw windows (at pos 0 there is the size of the array)
Func ScanGW()
	Local $lProcessList = processList("gw.exe")
	Local $lReturnArray[1] = [0]
	Local $lPid

	For $i = 1 To $lProcessList[0][0]
		MemoryOpen($lProcessList[$i][1])

		If $mGWProcHandle Then
			$lReturnArray[0] += 1
			ReDim $lReturnArray[$lReturnArray[0] + 1]
			$lReturnArray[$lReturnArray[0]] = ScanForCharname()
		EndIf

		MemoryClose()

		$mGWProcHandle = 0
	Next

	Return $lReturnArray
EndFunc

Func GetHwnd($aProc)
	Local $wins = WinList()
	For $i = 1 To UBound($wins)-1
		If (WinGetProcess($wins[$i][1]) == $aProc) And (BitAND(WinGetState($wins[$i][1]), 2)) Then Return $wins[$i][1]
	Next
EndFunc

;~ Description: Injects GWA² into the game client. 3rd and 4th arguments are here for legacy purposes
Func Initialize($aGW, $bChangeTitle = True, $notUsed1 = 0, $notUsed2 = 0)
	If IsString($aGW) Then
		Local $lProcessList = processList("gw.exe")
		For $i = 1 To $lProcessList[0][0]
			$mGWProcessId = $lProcessList[$i][1]
			$mGWWindowHandle = GetHwnd($mGWProcessId)
			MemoryOpen($mGWProcessId)
			If $mGWProcHandle Then
				If StringRegExp(ScanForCharname(), $aGW) = 1 Then ExitLoop
			EndIf
			MemoryClose()
			$mGWProcHandle = 0
		Next
	Else
		$mGWProcessId = $aGW
		$mGWWindowHandle = GetHwnd($mGWProcessId)
		MemoryOpen($aGW)
		ScanForCharname()
	EndIf

	If $mGWProcHandle = 0 Then Return False

	Scan()

	$mBasePointer = MemoryRead(GetScannedAddress('ScanBasePointer', -3))
	SetValue('BasePointer', '0x' & Hex($mBasePointer, 8))
	$mAgentBase = MemoryRead(GetScannedAddress('ScanAgentBase', 13))
	SetValue('AgentBase', '0x' & Hex($mAgentBase, 8))
	$mMaxAgents = $mAgentBase + 8
	SetValue('MaxAgents', '0x' & Hex($mMaxAgents, 8))
	$mMyID = $mAgentBase - 84
	SetValue('MyID', '0x' & Hex($mMyID, 8))
	$mMapLoading = $mAgentBase - 240
	$mCurrentTarget = $mAgentBase - 1280
	SetValue('PacketLocation', '0x' & Hex(MemoryRead(GetScannedAddress('ScanBaseOffset', -3)), 8))
	$mPing = MemoryRead(GetScannedAddress('ScanPing', 7))
	$mMapID = MemoryRead(GetScannedAddress('ScanMapID', 71))
	$mLoggedIn = MemoryRead(GetScannedAddress('ScanLoggedIn', -3)) + 4
	$mRegion = MemoryRead(GetScannedAddress('ScanRegion', 8))
	$mLanguage = MemoryRead(GetScannedAddress('ScanLanguage', 8)) + 12
	$mSkillBase = MemoryRead(GetScannedAddress('ScanSkillBase', 9))
	$mSkillTimer = MemoryRead(GetScannedAddress('ScanSkillTimer', -3))
	$mBuildNumber = MemoryRead(GetScannedAddress('ScanBuildNumber', 0x54))
	$mZoomStill = GetScannedAddress("ScanZoomStill", -1)
	$mZoomMoving = GetScannedAddress("ScanZoomMoving", 5)
	$mCurrentStatus = MemoryRead(GetScannedAddress('ScanChangeStatusFunction', -3))
	$mCharslots = MemoryRead(GetScannedAddress('ScanCharslots', 22))

	Local $lTemp
	$lTemp = GetScannedAddress('ScanEngine', -16)
	SetValue('MainStart', '0x' & Hex($lTemp, 8))
	SetValue('MainReturn', '0x' & Hex($lTemp + 5, 8))
	SetValue('RenderingMod', '0x' & Hex($lTemp + 116, 8))
	SetValue('RenderingModReturn', '0x' & Hex($lTemp + 138, 8))
	$lTemp = GetScannedAddress('ScanTargetLog', 1)
	SetValue('TargetLogStart', '0x' & Hex($lTemp, 8))
	SetValue('TargetLogReturn', '0x' & Hex($lTemp + 5, 8))
	$lTemp = GetScannedAddress('ScanSkillLog', 1)
	SetValue('SkillLogStart', '0x' & Hex($lTemp, 8))
	SetValue('SkillLogReturn', '0x' & Hex($lTemp + 5, 8))
	$lTemp = GetScannedAddress('ScanSkillCompleteLog', -4)
	SetValue('SkillCompleteLogStart', '0x' & Hex($lTemp, 8))
	SetValue('SkillCompleteLogReturn', '0x' & Hex($lTemp + 5, 8))
	$lTemp = GetScannedAddress('ScanSkillCancelLog', 5)
	SetValue('SkillCancelLogStart', '0x' & Hex($lTemp, 8))
	SetValue('SkillCancelLogReturn', '0x' & Hex($lTemp + 6, 8))
	$lTemp = GetScannedAddress('ScanChatLog', 18)
	SetValue('ChatLogStart', '0x' & Hex($lTemp, 8))
	SetValue('ChatLogReturn', '0x' & Hex($lTemp + 6, 8))
	$lTemp = GetScannedAddress('ScanTraderHook', -7)
	SetValue('TraderHookStart', '0x' & Hex($lTemp, 8))
	SetValue('TraderHookReturn', '0x' & Hex($lTemp + 5, 8))
	$lTemp = GetScannedAddress('ScanStringFilter1', -0x23)
	SetValue('StringFilter1Start', '0x' & Hex($lTemp, 8))
	SetValue('StringFilter1Return', '0x' & Hex($lTemp + 5, 8))
	$lTemp = GetScannedAddress('ScanStringFilter2', 97)
	SetValue('StringFilter2Start', '0x' & Hex($lTemp, 8))
	SetValue('StringFilter2Return', '0x' & Hex($lTemp + 5, 8))
	SetValue('StringLogStart', '0x' & Hex(GetScannedAddress('ScanStringLog', 35), 8))
	SetValue('LoadFinishedStart', '0x' & Hex(GetScannedAddress('ScanLoadFinished', 79), 8))
	SetValue('PostMessage', '0x' & Hex(MemoryRead(GetScannedAddress('ScanPostMessage', 11)), 8))
	SetValue('Sleep', MemoryRead(MemoryRead(GetValue('ScanSleep') + 8) + 3))
	SetValue('SalvageFunction', MemoryRead(GetValue('ScanSalvageFunction') + 8) - 18)
	SetValue('SalvageGlobal', MemoryRead(MemoryRead(GetValue('ScanSalvageGlobal') + 8) + 1))
	SetValue('MoveFunction', '0x' & Hex(GetScannedAddress('ScanMoveFunction', 1), 8))
	SetValue('UseSkillFunction', '0x' & Hex(GetScannedAddress('ScanUseSkillFunction', 1), 8))
	SetValue('ChangeTargetFunction', '0x' & Hex(GetScannedAddress('ScanChangeTargetFunction', -119), 8))
	SetValue('WriteChatFunction', '0x' & Hex(GetScannedAddress('ScanWriteChatFunction', 1), 8))
	SetValue('SellItemFunction', '0x' & Hex(GetScannedAddress('ScanSellItemFunction', -85), 8))
	SetValue('PacketSendFunction', '0x' & Hex(GetScannedAddress('ScanPacketSendFunction', 1), 8))
	SetValue('ActionBase', '0x' & Hex(MemoryRead(GetScannedAddress('ScanActionBase', -9)), 8))
	SetValue('ActionFunction', '0x' & Hex(GetScannedAddress('ScanActionFunction', -5), 8))
	SetValue('UseHeroSkillFunction', '0x' & Hex(GetScannedAddress('ScanUseHeroSkillFunction', -0xA1), 8))
	SetValue('BuyItemFunction', '0x' & Hex(GetScannedAddress('ScanBuyItemFunction', 1), 8))
	SetValue('RequestQuoteFunction', '0x' & Hex(GetScannedAddress('ScanRequestQuoteFunction', -2), 8))
	SetValue('TraderFunction', '0x' & Hex(GetScannedAddress('ScanTraderFunction', -71), 8))
	SetValue('ClickToMoveFix', '0x' & Hex(GetScannedAddress("ScanClickToMoveFix", 30), 8))
	SetValue('ChangeStatusFunction', '0x' & Hex(GetScannedAddress("ScanChangeStatusFunction", 12), 8))

	SetValue('QueueSize', '0x00000010')
	SetValue('SkillLogSize', '0x00000010')
	SetValue('ChatLogSize', '0x00000010')
	SetValue('TargetLogSize', '0x00000200')
	SetValue('StringLogSize', '0x00000200')
	SetValue('CallbackEvent', '0x00000501')

	ModifyMemory()

	$mQueueCounter = MemoryRead(GetValue('QueueCounter'))
	$mQueueSize = GetValue('QueueSize') - 1
	$mQueueBase = GetValue('QueueBase')
	$mTargetLogBase = GetValue('TargetLogBase')
	$mStringLogBase = GetValue('StringLogBase')
	$mMapIsLoaded = GetValue('MapIsLoaded')
	$mEnsureEnglish = GetValue('EnsureEnglish')
	$mTraderQuoteID = GetValue('TraderQuoteID')
	$mTraderCostID = GetValue('TraderCostID')
	$mTraderCostValue = GetValue('TraderCostValue')
	$mDisableRendering = GetValue('DisableRendering')
	$mAgentCopyCount = GetValue('AgentCopyCount')
	$mAgentCopyBase = GetValue('AgentCopyBase')

	;EventSystem
	MemoryWrite(GetValue('CallbackHandle'), $mGUI)

	DllStructSetData($mUseSkill, 1, GetValue('CommandUseSkill'))
	DllStructSetData($mMove, 1, GetValue('CommandMove'))
	DllStructSetData($mChangeTarget, 1, GetValue('CommandChangeTarget'))
	DllStructSetData($mPacket, 1, GetValue('CommandPacketSend'))
	DllStructSetData($mSellItem, 1, GetValue('CommandSellItem'))
	DllStructSetData($mAction, 1, GetValue('CommandAction'))
	DllStructSetData($mToggleLanguage, 1, GetValue('CommandToggleLanguage'))
	DllStructSetData($mUseHeroSkill, 1, GetValue('CommandUseHeroSkill'))
	DllStructSetData($mBuyItem, 1, GetValue('CommandBuyItem'))
	DllStructSetData($mSendChat, 1, GetValue('CommandSendChat'))
	DllStructSetData($mSendChat, 2, $HEADER_SEND_CHAT)
	DllStructSetData($mWriteChat, 1, GetValue('CommandWriteChat'))
	DllStructSetData($mRequestQuote, 1, GetValue('CommandRequestQuote'))
	DllStructSetData($mRequestQuoteSell, 1, GetValue('CommandRequestQuoteSell'))
	DllStructSetData($mTraderBuy, 1, GetValue('CommandTraderBuy'))
	DllStructSetData($mTraderSell, 1, GetValue('CommandTraderSell'))
	DllStructSetData($mSalvage, 1, GetValue('CommandSalvage'))
	DllStructSetData($mSetAttributes, 1, GetValue('CommandPacketSend'))
	DllStructSetData($mSetAttributes, 2, 0x90)
	DllStructSetData($mSetAttributes, 3, $HEADER_SET_ATTRIBUTES)
	DllStructSetData($mMakeAgentArray, 1, GetValue('CommandMakeAgentArray'))
	DllStructSetData($mChangeStatus, 1, GetValue('CommandChangeStatus'))

	If $bChangeTitle Then WinSetTitle($mGWWindowHandle, '', 'Guild Wars - ' & GetCharname())
	Return $mGWWindowHandle
EndFunc   ;==>Initialize

;~ Description: Internal use only.
Func GetValue($aKey)
	For $i = 1 To $mLabels[0][0]
		If $mLabels[$i][0] = $aKey Then Return Number($mLabels[$i][1])
	Next
	Return -1
EndFunc   ;==>GetValue

;~ Description: Internal use only.
Func SetValue($aKey, $aValue)
	$mLabels[0][0] += 1
	ReDim $mLabels[$mLabels[0][0] + 1][2]
	$mLabels[$mLabels[0][0]][0] = $aKey
	$mLabels[$mLabels[0][0]][1] = $aValue
EndFunc   ;==>SetValue

;~ Description: Internal use only.
Func Scan()
	$mASMSize = 0
	$mASMCodeOffset = 0
	$mASMString = ''

	_('MainModPtr/4')
	_('ScanBasePointer:')
	AddPattern('85C0750F8BCE')
	_('ScanAgentBase:')
	AddPattern('568BF13BF07204')
	_('ScanEngine:')
	AddPattern('5356DFE0F6C441')
	_('ScanLoadFinished:')
	AddPattern('894DD88B4D0C8955DC8B')
	_('ScanPostMessage:')
	AddPattern('6A00680080000051FF15')
	_('ScanTargetLog:')
	AddPattern('5356578BFA894DF4E8')
	_('ScanChangeTargetFunction:')
	AddPattern('33C03BDA0F95C033')
	_('ScanMoveFunction:')
	AddPattern('558BEC83EC2056578BF98D4DF0')
	_('ScanPing:')
	AddPattern('C390908BD1B9')
	_('ScanMapID:')
	AddPattern('B07F8D55')
	_('ScanLoggedIn:')
	AddPattern('85C07411B807')
	_('ScanRegion:')
	AddPattern('83F9FD7406')
	_('ScanLanguage:')
	AddPattern('C38B75FC8B04B5')
	_('ScanUseSkillFunction:')
	AddPattern('558BEC83EC1053568BD9578BF2895DF0')
	_('ScanChangeTargetFunction:')
	AddPattern('33C03BDA0F95C033')
	_('ScanPacketSendFunction:')
	AddPattern('558BEC83EC2C5356578BF985')
	_('ScanBaseOffset:')
	AddPattern('5633F63BCE740E5633D2')
	_('ScanWriteChatFunction:')
	AddPattern('558BEC5153894DFC8B4D0856578B')
	_('ScanSkillLog:')
	AddPattern('408946105E5B5D')
	_('ScanSkillCompleteLog:')
	AddPattern('741D6A006A40')
	_('ScanSkillCancelLog:')
	AddPattern('85C0741D6A006A42')
	_('ScanChatLog:')
	AddPattern('8B45F48B138B4DEC50')
	_('ScanSellItemFunction:')
	AddPattern('8B4D2085C90F858E')
	_('ScanStringLog:')
	AddPattern('893E8B7D10895E04397E08')
	_('ScanStringFilter1:')
	AddPattern('8B368B4F2C6A006A008B06')
	_('ScanStringFilter2:')
	AddPattern('D85DF85F5E5BDFE0F6C441')
	_('ScanActionFunction:')
	AddPattern('8B7D0883FF098BF175116876010000')
	_('ScanActionBase:')
	AddPattern('8B4208A80175418B4A08')
	_('ScanSkillBase:')
	AddPattern('8D04B65EC1E00505')
	_('ScanUseHeroSkillFunction:')
	AddPattern('8D0C765F5E8B')
	_('ScanBuyItemFunction:')
	AddPattern('558BEC81ECC000000053568B75085783FE108BFA8BD97614')
	_('ScanRequestQuoteFunction:')
	AddPattern('81EC9C00000053568B')
	_('ScanTraderFunction:')
	AddPattern('8B45188B551085')
	_('ScanTraderHook:')
	AddPattern('8955FC6A008D55F8B9BA')
	_('ScanSleep:')
	AddPattern('5F5E5B741A6860EA0000')
	_('ScanSalvageFunction:')
	AddPattern('8BFA8BD9897DF0895DF4')
	_('ScanSalvageGlobal:')
	AddPattern('8B018B4904A3')
	_('ScanSkillTimer:')
	AddPattern('85C974158BD62BD183FA64')
	_('ScanClickToMoveFix:')
	AddPattern('568BF1578B460883F80F')
	_('ScanZoomStill:')
	AddPattern('3B448BCB')
	_('ScanZoomMoving:')
	AddPattern('50EB116800803B448BCE')
	_('ScanBuildNumber:')
	AddPattern('8D8500FCFFFF8D')
	_('ScanChangeStatusFunction:')
	AddPattern('C390909090909090909090568BF183FE04')
	_('ScanCharslots:')
	AddPattern('8B551041897E38897E3C897E34897E48897E4C890D')

	_('ScanProc:')
	_('pushad')
	_('mov ecx,401000')
	_('mov esi,ScanProc')
	_('ScanLoop:')
	_('inc ecx')
	_('mov al,byte[ecx]')
	_('mov edx,ScanBasePointer')

	_('ScanInnerLoop:')
	_('mov ebx,dword[edx]')
	_('cmp ebx,-1')
	_('jnz ScanContinue')
	_('add edx,50')
	_('cmp edx,esi')
	_('jnz ScanInnerLoop')
	_('cmp ecx,900000')
	_('jnz ScanLoop')
	_('jmp ScanExit')

	_('ScanContinue:')
	_('lea edi,dword[edx+ebx]')
	_('add edi,C')
	_('mov ah,byte[edi]')
	_('cmp al,ah')
	_('jz ScanMatched')
	_('mov dword[edx],0')
	_('add edx,50')
	_('cmp edx,esi')
	_('jnz ScanInnerLoop')
	_('cmp ecx,900000')
	_('jnz ScanLoop')
	_('jmp ScanExit')

	_('ScanMatched:')
	_('inc ebx')
	_('mov edi,dword[edx+4]')
	_('cmp ebx,edi')
	_('jz ScanFound')
	_('mov dword[edx],ebx')
	_('add edx,50')
	_('cmp edx,esi')
	_('jnz ScanInnerLoop')
	_('cmp ecx,900000')
	_('jnz ScanLoop')
	_('jmp ScanExit')

	_('ScanFound:')
	_('lea edi,dword[edx+8]')
	_('mov dword[edi],ecx')
	_('mov dword[edx],-1')
	_('add edx,50')
	_('cmp edx,esi')
	_('jnz ScanInnerLoop')
	_('cmp ecx,900000')
	_('jnz ScanLoop')

	_('ScanExit:')
	_('popad')
	_('retn')

	Local $lScanMemory = MemoryRead($mBase, 'ptr')

	If $lScanMemory = 0 Then
		$mMemory = DllCall($mKernelHandle, 'ptr', 'VirtualAllocEx', 'handle', $mGWProcHandle, 'ptr', 0, 'ulong_ptr', $mASMSize, 'dword', 0x1000, 'dword', 0x40)
		$mMemory = $mMemory[0]
		MemoryWrite($mBase, $mMemory)
	Else
		$mMemory = $lScanMemory
	EndIf

	CompleteASMCode()

	If $lScanMemory = 0 Then
		WriteBinary($mASMString, $mMemory + $mASMCodeOffset)
		Local $lThread = DllCall($mKernelHandle, 'int', 'CreateRemoteThread', 'int', $mGWProcHandle, 'ptr', 0, 'int', 0, 'int', GetLabelInfo('ScanProc'), 'ptr', 0, 'int', 0, 'int', 0)
		$lThread = $lThread[0]
		Local $lResult
		Do
			$lResult = DllCall($mKernelHandle, 'int', 'WaitForSingleObject', 'int', $lThread, 'int', 50)
		Until $lResult[0] <> 258
		DllCall($mKernelHandle, 'int', 'CloseHandle', 'int', $lThread)
	EndIf
EndFunc   ;==>Scan

;~ Description: Internal use only.
Func AddPattern($aPattern)
	Local $lSize = Int(0.5 * StringLen($aPattern))
	$mASMString &= '00000000' & SwapEndian(Hex($lSize, 8)) & '00000000' & $aPattern
	$mASMSize += $lSize + 12
	For $i = 1 To 68 - $lSize
		$mASMSize += 1
		$mASMString &= '00'
	Next
EndFunc   ;==>AddPattern

;~ Description: Internal use only.
Func GetScannedAddress($aLabel, $aOffset)
	Return MemoryRead(GetLabelInfo($aLabel) + 8) - MemoryRead(GetLabelInfo($aLabel) + 4) + $aOffset
EndFunc   ;==>GetScannedAddress

;~ Description: Internal use only.
Func ScanForCharname()
	Local $lCharNameCode = BinaryToString('0x90909066C705')
	Local $lCurrentSearchAddress = 0x00401000
	Local $lMBI[7], $lMBIBuffer = DllStructCreate('dword;dword;dword;dword;dword;dword;dword')
	Local $lSearch, $lTmpMemData, $lTmpAddress, $lTmpBuffer = DllStructCreate('ptr'), $i

	While $lCurrentSearchAddress < 0x00900000
		Local $lMBI[7]
		DllCall($mKernelHandle, 'int', 'VirtualQueryEx', 'int', $mGWProcHandle, 'int', $lCurrentSearchAddress, 'ptr', DllStructGetPtr($lMBIBuffer), 'int', DllStructGetSize($lMBIBuffer))
		For $i = 0 To 6
			$lMBI[$i] = StringStripWS(DllStructGetData($lMBIBuffer, ($i + 1)), 3)
		Next

		If $lMBI[4] = 4096 Then
			Local $lBuffer = DllStructCreate('byte[' & $lMBI[3] & ']')
			DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lCurrentSearchAddress, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')

			$lTmpMemData = DllStructGetData($lBuffer, 1)
			$lTmpMemData = BinaryToString($lTmpMemData)

			$lSearch = StringInStr($lTmpMemData, $lCharNameCode, 2)
			If $lSearch > 0 Then
				$lTmpAddress = $lCurrentSearchAddress + $lSearch - 1
				DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lTmpAddress + 0x6, 'ptr', DllStructGetPtr($lTmpBuffer), 'int', DllStructGetSize($lTmpBuffer), 'int', '')
				$mCharname = DllStructGetData($lTmpBuffer, 1)
				Return GetCharname()
			EndIf

			$lCurrentSearchAddress += $lMBI[3]
		EndIf
	WEnd

	Return ''
EndFunc   ;==>ScanForCharname
#EndRegion Initialisation

#Region Commands
#Region Item
;~ Description: Starts a salvaging session of an item.
Func StartSalvage($aItem, $aExpert = False)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x690]
	Local $lSalvageSessionID = MemoryReadPtr($mBasePointer, $lOffset)

	If IsDllStruct($aItem) = 0 Then
		Local $lItemID = $aItem
	Else
		Local $lItemID = DllStructGetData($aItem, 'ID')
	EndIf

	Local $lSalvageKit = 0
	If $aExpert Then
		$lSalvageKit = FindExpertSalvageKit()
	Else
		$lSalvageKit = FindSalvageKit()
	EndIf
	If $lSalvageKit = 0 Then Return

	DllStructSetData($mSalvage, 2, $lItemID)
	DllStructSetData($mSalvage, 3, $lSalvageKit)
	DllStructSetData($mSalvage, 4, $lSalvageSessionID[1])

	Enqueue($mSalvagePtr, 16)
EndFunc   ;==>StartSalvage

;~ Description: Salvage the materials out of an item.
Func SalvageMaterials()
	Return SendPacket(0x4, $HEADER_SALVAGE_MATS)
EndFunc   ;==>SalvageMaterials

;~ Description: Salvages a mod out of an item.
Func SalvageMod($aModIndex)
	Return SendPacket(0x8, $HEADER_SALVAGE_MODS, $aModIndex)
EndFunc   ;==>SalvageMod

;~ Description: Identifies an item.
Func IdentifyItem($aItem)
	If GetIsIDed($aItem) Then Return

	Local $lItemID
	If IsDllStruct($aItem) = 0 Then
		$lItemID = $aItem
	Else
		$lItemID = DllStructGetData($aItem, 'ID')
	EndIf

	Local $lIDKit = FindIDKit()
	If $lIDKit == 0 Then Return

	SendPacket(0xC, $HEADER_ITEM_ID, $lIDKit, $lItemID)

	Local $lDeadlock = TimerInit()
	Do
		Sleep(20)
	Until GetIsIDed($lItemID) Or TimerDiff($lDeadlock) > 5000
	If Not GetIsIDed($lItemID) Then IdentifyItem($aItem)
EndFunc   ;==>IdentifyItem

;~ Description: Identifies all items in a bag.
Func IdentifyBag($aBag, $aWhites = False, $aGolds = True)
	Local $lItem
	If Not IsDllStruct($aBag) Then $aBag = GetBag($aBag)
	For $i = 1 To DllStructGetData($aBag, 'Slots')
		$lItem = GetItemBySlot($aBag, $i)
		If DllStructGetData($lItem, 'ID') == 0 Then ContinueLoop
		If GetRarity($lItem) == 2621 And $aWhites == False Then ContinueLoop
		If GetRarity($lItem) == 2624 And $aGolds == False Then ContinueLoop
		IdentifyItem($lItem)
		Sleep(GetPing())
	Next
EndFunc   ;==>IdentifyBag

;~ Description: Equips an item.
Func EquipItem($aItem)
	Local $lItemID

	If IsDllStruct($aItem) = 0 Then
		$lItemID = $aItem
	Else
		$lItemID = DllStructGetData($aItem, 'ID')
	EndIf

	Return SendPacket(0x8, $HEADER_ITEM_EQUIP, $lItemID)
EndFunc   ;==>EquipItem

;~ Description: Uses an item.
Func UseItem($aItem)
	Local $lItemID

	If IsDllStruct($aItem) = 0 Then
		$lItemID = $aItem
	Else
		$lItemID = DllStructGetData($aItem, 'ID')
	EndIf

	Return SendPacket(0x8, $HEADER_ITEM_USE, $lItemID)
EndFunc   ;==>UseItem

;~ Description: Picks up an item.
Func PickUpItem($aItem)
	Local $lAgentID

	If IsDllStruct($aItem) = 0 Then
		$lAgentID = $aItem
	ElseIf DllStructGetSize($aItem) < 400 Then
		$lAgentID = DllStructGetData($aItem, 'AgentID')
	Else
		$lAgentID = DllStructGetData($aItem, 'ID')
	EndIf

	Return SendPacket(0xC, $HEADER_ITEM_PICKUP, $lAgentID, 0)
EndFunc   ;==>PickUpItem

;~ Description: Drops an item.
Func DropItem($aItem, $aAmount = 0)
	Local $lItemID, $lAmount

	If IsDllStruct($aItem) = 0 Then
		$lItemID = $aItem
		If $aAmount > 0 Then
			$lAmount = $aAmount
		Else
			$lAmount = DllStructGetData(GetItemByItemID($aItem), 'Quantity')
		EndIf
	Else
		$lItemID = DllStructGetData($aItem, 'ID')
		If $aAmount > 0 Then
			$lAmount = $aAmount
		Else
			$lAmount = DllStructGetData($aItem, 'Quantity')
		EndIf
	EndIf

	Return SendPacket(0xC, $HEADER_ITEM_DROP, $lItemID, $lAmount)
EndFunc   ;==>DropItem

;~ Description: Moves an item.
Func MoveItem($aItem, $aBag, $aSlot)
	Local $lItemID, $lBagID

	If IsDllStruct($aItem) = 0 Then
		$lItemID = $aItem
	Else
		$lItemID = DllStructGetData($aItem, 'ID')
	EndIf

	If IsDllStruct($aBag) = 0 Then
		$lBagID = DllStructGetData(GetBag($aBag), 'ID')
	Else
		$lBagID = DllStructGetData($aBag, 'ID')
	EndIf

	Return SendPacket(0x10, $HEADER_ITEM_MOVE, $lItemID, $lBagID, $aSlot - 1)
EndFunc   ;==>MoveItem

;~ Description: Accepts unclaimed items after a mission.
Func AcceptAllItems()
	Return SendPacket(0x8, $HEADER_ITEMS_ACCEPT_UNCLAIMED, DllStructGetData(GetBag(7), 'ID'))
EndFunc   ;==>AcceptAllItems

;~ Description: Sells an item.
Func SellItem($aItem, $aQuantity = 0)
	If IsDllStruct($aItem) = 0 Then $aItem = GetItemByItemID($aItem)
	If $aQuantity = 0 Or $aQuantity > DllStructGetData($aItem, 'Quantity') Then $aQuantity = DllStructGetData($aItem, 'Quantity')

	DllStructSetData($mSellItem, 2, $aQuantity * DllStructGetData($aItem, 'Value'))
	DllStructSetData($mSellItem, 3, DllStructGetData($aItem, 'ID'))
	Enqueue($mSellItemPtr, 12)
EndFunc   ;==>SellItem

;~ Description: Buys an item.
Func BuyItem($aItem, $aQuantity, $aValue)
	Local $lMerchantItemsBase = GetMerchantItemsBase()

	If Not $lMerchantItemsBase Then Return
	If $aItem < 1 Or $aItem > GetMerchantItemsSize() Then Return

	DllStructSetData($mBuyItem, 2, $aQuantity)
	DllStructSetData($mBuyItem, 3, MemoryRead($lMerchantItemsBase + 4 * ($aItem - 1)))
	DllStructSetData($mBuyItem, 4, $aQuantity * $aValue)
	Enqueue($mBuyItemPtr, 16)
EndFunc   ;==>BuyItem

;~ Description: Legacy function, use BuyIdentificationKit instead.
Func BuyIDKit($aQuantity = 1)
	BuyIdentificationKit($aQuantity)
EndFunc   ;==>BuyIDKit

;~ Description: Buys an ID kit.
Func BuyIdentificationKit($aQuantity = 1)
	BuyItem(5, $aQuantity, 100)
EndFunc   ;==>BuyIdentificationKit

;~ Description: Legacy function, use BuySuperiorIdentificationKit instead.
Func BuySuperiorIDKit($aQuantity = 1)
	BuySuperiorIdentificationKit($aQuantity)
EndFunc   ;==>BuySuperiorIDKit

;~ Description: Buys a superior ID kit.
Func BuySuperiorIdentificationKit($aQuantity = 1)
	BuyItem(6, $aQuantity, 500)
EndFunc   ;==>BuySuperiorIdentificationKit

func BuySalvageKit($aQuantity = 1)
	buyItem(2, $aQuantity, 100)
endFunc   ;==>buySalvageKit

func BuyExpertSalvageKit($aQuantity = 1)
	buyItem(3, $aQuantity, 400)
endFunc   ;==>buyExpertSalvageKit

;~ Description: Request a quote to buy an item from a trader. Returns true if successful.
Func TraderRequest($aModelID, $aExtraID = -1)
	Local $lItemStruct = DllStructCreate('long Id;long AgentId;byte Unknown1[4];ptr Bag;ptr ModStruct;long ModStructSize;ptr Customized;byte unknown2[4];byte Type;byte unknown4;short ExtraId;short Value;byte unknown4[2];short Interaction;long ModelId;ptr ModString;byte unknown5[4];ptr NameString;ptr SingleItemName;byte Unknown4[10];byte IsSalvageable;byte Unknown6;word Quantity;byte Equiped;byte Profession;byte Type2;byte Slot')
	Local $lOffset[4] = [0, 0x18, 0x40, 0xC0]
	Local $lItemArraySize = MemoryReadPtr($mBasePointer, $lOffset)
	Local $lOffset[5] = [0, 0x18, 0x40, 0xB8, 0]
	Local $lItemPtr, $lItemID
	Local $lFound = False
	Local $lQuoteID = MemoryRead($mTraderQuoteID)

	For $lItemID = 1 To $lItemArraySize[1]
		$lOffset[4] = 0x4 * $lItemID
		$lItemPtr = MemoryReadPtr($mBasePointer, $lOffset)
		If $lItemPtr[1] = 0 Then ContinueLoop

		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lItemPtr[1], 'ptr', DllStructGetPtr($lItemStruct), 'int', DllStructGetSize($lItemStruct), 'int', '')
		If DllStructGetData($lItemStruct, 'ModelID') = $aModelID And DllStructGetData($lItemStruct, 'bag') = 0 And DllStructGetData($lItemStruct, 'AgentID') == 0 Then
			If $aExtraID = -1 Or DllStructGetData($lItemStruct, 'ExtraID') = $aExtraID Then
				$lFound = True
				ExitLoop
			EndIf
		EndIf
	Next
	If Not $lFound Then Return False

	DllStructSetData($mRequestQuote, 2, DllStructGetData($lItemStruct, 'ID'))
	Enqueue($mRequestQuotePtr, 8)

	Local $lDeadlock = TimerInit()
	$lFound = False
	Do
		Sleep(20)
		$lFound = MemoryRead($mTraderQuoteID) <> $lQuoteID
	Until $lFound Or TimerDiff($lDeadlock) > GetPing() + 5000
	Return $lFound
EndFunc   ;==>TraderRequest

;~ Description: Buy the requested item.
Func TraderBuy()
	If Not GetTraderCostID() Or Not GetTraderCostValue() Then Return False
	Enqueue($mTraderBuyPtr, 4)
	Return True
EndFunc   ;==>TraderBuy

;~ Description: Request a quote to sell an item to the trader.
Func TraderRequestSell($aItem)
	Local $lItemID
	Local $lFound = False
	Local $lQuoteID = MemoryRead($mTraderQuoteID)

	If IsDllStruct($aItem) = 0 Then
		$lItemID = $aItem
	Else
		$lItemID = DllStructGetData($aItem, 'ID')
	EndIf

	DllStructSetData($mRequestQuoteSell, 2, $lItemID)
	Enqueue($mRequestQuoteSellPtr, 8)

	Local $lDeadlock = TimerInit()
	Do
		Sleep(20)
		$lFound = MemoryRead($mTraderQuoteID) <> $lQuoteID
	Until $lFound Or TimerDiff($lDeadlock) > GetPing() + 5000
	Return $lFound
EndFunc   ;==>TraderRequestSell

;~ Description: ID of the item item being sold.
Func TraderSell()
	If Not GetTraderCostID() Or Not GetTraderCostValue() Then Return False
	Enqueue($mTraderSellPtr, 4)
	Return True
EndFunc   ;==>TraderSell

;~ Description: Drop gold on the ground.
Func DropGold($aAmount = 0)
	Local $lAmount

	If $aAmount > 0 Then
		$lAmount = $aAmount
	Else
		$lAmount = GetGoldCharacter()
	EndIf

	Return SendPacket(0x8, $HEADER_GOLD_DROP, $lAmount)
EndFunc   ;==>DropGold

;~ Description: Deposit gold into storage.
Func DepositGold($aAmount = 0)
	Local $lAmount
	Local $lStorage = GetGoldStorage()
	Local $lCharacter = GetGoldCharacter()

	If $aAmount > 0 And $lCharacter >= $aAmount Then
		$lAmount = $aAmount
	Else
		$lAmount = $lCharacter
	EndIf

	If $lStorage + $lAmount > 1000000 Then $lAmount = 1000000 - $lStorage

	ChangeGold($lCharacter - $lAmount, $lStorage + $lAmount)
EndFunc   ;==>DepositGold

;~ Description: Withdraw gold from storage.
Func WithdrawGold($aAmount = 0)
	Local $lAmount
	Local $lStorage = GetGoldStorage()
	Local $lCharacter = GetGoldCharacter()

	If $aAmount > 0 And $lStorage >= $aAmount Then
		$lAmount = $aAmount
	Else
		$lAmount = $lStorage
	EndIf

	If $lCharacter + $lAmount > 100000 Then $lAmount = 100000 - $lCharacter

	ChangeGold($lCharacter + $lAmount, $lStorage - $lAmount)
EndFunc   ;==>WithdrawGold

;~ Description: Internal use for moving gold.
Func ChangeGold($aCharacter, $aStorage)
	Return SendPacket(0xC, $HEADER_GOLD_MOVE, $aCharacter, $aStorage)
EndFunc   ;==>ChangeGold
#EndRegion Item

#Region H&H
;~ Description: Adds a hero to the party.
Func AddHero($aHeroId)
	Return SendPacket(0x8, $HEADER_HERO_ADD, $aHeroId)
EndFunc   ;==>AddHero

;~ Description: Kicks a hero from the party.
Func KickHero($aHeroId)
	Return SendPacket(0x8, $HEADER_HERO_KICK, $aHeroId)
EndFunc   ;==>KickHero

;~ Description: Kicks all heroes from the party.
Func KickAllHeroes()
	Return SendPacket(0x8, $HEADER_HEROES_KICK, 0x26)
EndFunc   ;==>KickAllHeroes

;~ Description: Add a henchman to the party.
Func AddNpc($aNpcId)
	Return SendPacket(0x8, $HEADER_HENCHMAN_ADD, $aNpcId)
EndFunc   ;==>AddNpc

;~ Description: Kick a henchman from the party.
Func KickNpc($aNpcId)
	Return SendPacket(0x8, $HEADER_HENCHMAN_KICK, $aNpcId)
EndFunc   ;==>KickNpc

;~ Description: Clear the position flag from a hero.
Func CancelHero($aHeroNumber)
	Local $lAgentID = GetHeroID($aHeroNumber)
	Return SendPacket(0x14, $HEADER_HERO_CLEAR_FLAG, $lAgentID, 0x7F800000, 0x7F800000, 0)
EndFunc   ;==>CancelHero

;~ Description: Clear the position flag from all heroes.
Func CancelAll()
	Return SendPacket(0x10, $HEADER_PARTY_CLEAR_FLAG, 0x7F800000, 0x7F800000, 0)
EndFunc   ;==>CancelAll

;~ Description: Place a hero's position flag.
Func CommandHero($aHeroNumber, $aX, $aY)
	Return SendPacket(0x14, $HEADER_HERO_PLACE_FLAG, GetHeroID($aHeroNumber), FloatToInt($aX), FloatToInt($aY), 0)
EndFunc   ;==>CommandHero

;~ Description: Place the full-party position flag.
Func CommandAll($aX, $aY)
	Return SendPacket(0x10, $HEADER_PARTY_PLACE_FLAG, FloatToInt($aX), FloatToInt($aY), 0)
EndFunc   ;==>CommandAll

;~ Description: Lock a hero onto a target.
Func LockHeroTarget($aHeroNumber, $aAgentID = 0) ;$aAgentID=0 Cancels Lock
	Local $lHeroID = GetHeroID($aHeroNumber)
	Return SendPacket(0xC, $HEADER_HERO_LOCK, $lHeroID, $aAgentID)
EndFunc   ;==>LockHeroTarget

;~ Description: Change a hero's aggression level.
Func SetHeroAggression($aHeroNumber, $aAggression) ;0=Fight, 1=Guard, 2=Avoid
	Local $lHeroID = GetHeroID($aHeroNumber)
	Return SendPacket(0xC, $HEADER_HERO_AGGRESSION, $lHeroID, $aAggression)
EndFunc   ;==>SetHeroAggression

;~ Description: Disable a skill on a hero's skill bar.
Func DisableHeroSkillSlot($aHeroNumber, $aSkillSlot)
	If Not GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot) Then ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot)
EndFunc   ;==>DisableHeroSkillSlot

;~ Description: Enable a skill on a hero's skill bar.
Func EnableHeroSkillSlot($aHeroNumber, $aSkillSlot)
	If GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot) Then ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot)
EndFunc   ;==>EnableHeroSkillSlot

;~ Description: Internal use for enabling or disabling hero skills
Func ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot)
	Return SendPacket(0xC, $HEADER_HERO_TOGGLE_SKILL, GetHeroID($aHeroNumber), $aSkillSlot - 1)
EndFunc   ;==>ChangeHeroSkillSlotState

;~ Description: Order a hero to use a skill.
Func UseHeroSkill($aHero, $aSkillSlot, $aTarget = 0)
	Local $lTargetID

	If IsDllStruct($aTarget) = 0 Then
		$lTargetID = ConvertID($aTarget)
	Else
		$lTargetID = DllStructGetData($aTarget, 'ID')
	EndIf

	DllStructSetData($mUseHeroSkill, 2, GetHeroID($aHero))
	DllStructSetData($mUseHeroSkill, 3, $lTargetID)
	DllStructSetData($mUseHeroSkill, 4, $aSkillSlot - 1)
	Enqueue($mUseHeroSkillPtr, 16)
EndFunc   ;==>UseHeroSkill

Func SetDisplayedTitle($aTitle = 0)
	If $aTitle Then
		Return SendPacket(0x8, $HEADER_TITLE_DISPLAY, $aTitle)
	Else
		Return SendPacket(0x4, $HEADER_TITLE_CLEAR)
	EndIf
EndFunc   ;==>SetDisplayedTitle
#EndRegion H&H

#Region Movement
;~ Description: Move to a location.
Func Move($aX, $aY, $aRandom = 50)
	;returns true if successful
	If GetAgentExists(-2) Then
		DllStructSetData($mMove, 2, $aX + Random(-$aRandom, $aRandom))
		DllStructSetData($mMove, 3, $aY + Random(-$aRandom, $aRandom))
		Enqueue($mMovePtr, 16)
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>Move


Func CheckArea($aX, $aY)
	$ret = False
	$pX = DllStructGetData(GetAgentByID(-2), "X")
	$pY = DllStructGetData(GetAgentByID(-2), "Y")

	If ($pX < $aX + 500) And ($pX > $aX - 500) And ($pY < $aY + 500) And ($pY > $aY - 500) Then
		$ret = True
	EndIf
	Return $ret
EndFunc

;~ Description: Move to a location and wait until you reach it.
Func MoveTo($aX, $aY, $aRandom = 50)
	Local $lBlocked = 0
	Local $lMe
	Local $lMapLoading = GetMapLoading(), $lMapLoadingOld
	Local $lDestX = $aX + Random(-$aRandom, $aRandom)
	Local $lDestY = $aY + Random(-$aRandom, $aRandom)

	Move($lDestX, $lDestY, 0)

	Do
		Sleep(100)
		$lMe = GetAgentByID(-2)

		If DllStructGetData($lMe, 'HP') <= 0 Then ExitLoop

		$lMapLoadingOld = $lMapLoading
		$lMapLoading = GetMapLoading()
		If $lMapLoading <> $lMapLoadingOld Then ExitLoop

		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			$lBlocked += 1
			$lDestX = $aX + Random(-$aRandom, $aRandom)
			$lDestY = $aY + Random(-$aRandom, $aRandom)
			Move($lDestX, $lDestY, 0)
		EndIf
	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < 25 Or $lBlocked > 14
EndFunc   ;==>MoveTo

;~ Description: Run to or follow a player.
Func GoPlayer($aAgent)
	Local $lAgentID

	If IsDllStruct($aAgent) = 0 Then
		$lAgentID = ConvertID($aAgent)
	Else
		$lAgentID = DllStructGetData($aAgent, 'ID')
	EndIf

	Return SendPacket(0x8, $HEADER_AGENT_FOLLOW, $lAgentID)
EndFunc   ;==>GoPlayer

;~ Description: Talk to an NPC
Func GoNPC($aAgent)
	Local $lAgentID

	If IsDllStruct($aAgent) = 0 Then
		$lAgentID = ConvertID($aAgent)
	Else
		$lAgentID = DllStructGetData($aAgent, 'ID')
	EndIf

	Return SendPacket(0xC, $HEADER_NPC_TALK, $lAgentID)
EndFunc   ;==>GoNPC

;~ Description: Talks to NPC and waits until you reach them.
Func GoToNPC($aAgent)
	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
	Local $lMe
	Local $lBlocked = 0
	Local $lMapLoading = GetMapLoading(), $lMapLoadingOld

	Move(DllStructGetData($aAgent, 'X'), DllStructGetData($aAgent, 'Y'), 100)
	Sleep(100)
	GoNPC($aAgent)

	Do
		Sleep(100)
		$lMe = GetAgentByID(-2)

		If DllStructGetData($lMe, 'HP') <= 0 Then ExitLoop

		$lMapLoadingOld = $lMapLoading
		$lMapLoading = GetMapLoading()
		If $lMapLoading <> $lMapLoadingOld Then ExitLoop

		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			$lBlocked += 1
			Move(DllStructGetData($aAgent, 'X'), DllStructGetData($aAgent, 'Y'), 100)
			Sleep(100)
			GoNPC($aAgent)
		EndIf
	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), DllStructGetData($aAgent, 'X'), DllStructGetData($aAgent, 'Y')) < 140 Or $lBlocked > 14
	GoNPC($aAgent)
	Sleep(GetPing() + 300)
EndFunc   ;==>GoToNPC

;~ Description: Run to a signpost.
Func GoSignpost($aAgent)
	Local $lAgentID

	If IsDllStruct($aAgent) = 0 Then
		$lAgentID = ConvertID($aAgent)
	Else
		$lAgentID = DllStructGetData($aAgent, 'ID')
	EndIf

	Return SendPacket(0xC, $HEADER_SIGNPOST_RUN, $lAgentID, 0)
EndFunc   ;==>GoSignpost

;~ Description: Go to signpost and waits until you reach it.
Func GoToSignpost($aAgent)
	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
	Local $lMe
	Local $lBlocked = 0
	Local $lMapLoading = GetMapLoading(), $lMapLoadingOld

	Move(DllStructGetData($aAgent, 'X'), DllStructGetData($aAgent, 'Y'), 100)
	Sleep(100)
	GoSignpost($aAgent)

	Do
		Sleep(100)
		$lMe = GetAgentByID(-2)

		If DllStructGetData($lMe, 'HP') <= 0 Then ExitLoop

		$lMapLoadingOld = $lMapLoading
		$lMapLoading = GetMapLoading()
		If $lMapLoading <> $lMapLoadingOld Then ExitLoop

		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			$lBlocked += 1
			Move(DllStructGetData($aAgent, 'X'), DllStructGetData($aAgent, 'Y'), 100)
			Sleep(100)
			GoSignpost($aAgent)
		EndIf
	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), DllStructGetData($aAgent, 'X'), DllStructGetData($aAgent, 'Y')) < 250 Or $lBlocked > 14
	Sleep(GetPing() + Random(1500, 2000, 1))
EndFunc   ;==>GoToSignpost

;~ Description: Attack an agent.
Func Attack($aAgent, $aCallTarget = False)
	Local $lAgentID

	If IsDllStruct($aAgent) = 0 Then
		$lAgentID = ConvertID($aAgent)
	Else
		$lAgentID = DllStructGetData($aAgent, 'ID')
	EndIf

	Return SendPacket(0xC, $HEADER_ATTACK_AGENT, $lAgentID, $aCallTarget)
EndFunc   ;==>Attack

;~ Description: Turn character to the left.
Func TurnLeft($aTurn)
	If $aTurn Then
		Return PerformAction(0xA2, 0x18)
	Else
		Return PerformAction(0xA2, 0x1A)
	EndIf
EndFunc   ;==>TurnLeft

;~ Description: Turn character to the right.
Func TurnRight($aTurn)
	If $aTurn Then
		Return PerformAction(0xA3, 0x18)
	Else
		Return PerformAction(0xA3, 0x1A)
	EndIf
EndFunc   ;==>TurnRight

;~ Description: Move backwards.
Func MoveBackward($aMove)
	If $aMove Then
		Return PerformAction(0xAC, 0x18)
	Else
		Return PerformAction(0xAC, 0x1A)
	EndIf
EndFunc   ;==>MoveBackward

;~ Description: Run forwards.
Func MoveForward($aMove)
	If $aMove Then
		Return PerformAction(0xAD, 0x18)
	Else
		Return PerformAction(0xAD, 0x1A)
	EndIf
EndFunc   ;==>MoveForward

;~ Description: Strafe to the left.
Func StrafeLeft($aStrafe)
	If $aStrafe Then
		Return PerformAction(0x91, 0x18)
	Else
		Return PerformAction(0x91, 0x1A)
	EndIf
EndFunc   ;==>StrafeLeft

;~ Description: Strafe to the right.
Func StrafeRight($aStrafe)
	If $aStrafe Then
		Return PerformAction(0x92, 0x18)
	Else
		Return PerformAction(0x92, 0x1A)
	EndIf
EndFunc   ;==>StrafeRight

;~ Description: Auto-run.
Func ToggleAutoRun()
	Return PerformAction(0xB7, 0x18)
EndFunc   ;==>ToggleAutoRun

;~ Description: Turn around.
Func ReverseDirection()
	Return PerformAction(0xB1, 0x18)
EndFunc   ;==>ReverseDirection
#EndRegion Movement

#Region Travel
;~ Description: Map travel to an outpost.
Func TravelTo($aMapID, $aDis = 0)
	;returns true if successful
	If GetMapID() = $aMapID And $aDis = 0 And GetMapLoading() = 0 Then Return True
	ZoneMap($aMapID, $aDis)
	Out("Travel to map " & $aMapID)
	Return WaitMapLoading($aMapID)
EndFunc   ;==>TravelTo

;~ Description: Internal use for map travel.
Func ZoneMap($aMapID, $aDistrict = 0)
	MoveMap($aMapID, GetRegion(), $aDistrict, GetLanguage());
EndFunc   ;==>ZoneMap

;~ Description: Internal use for map travel.
Func MoveMap($aMapID, $aRegion, $aDistrict, $aLanguage)
	Return SendPacket(0x18, $HEADER_MAP_TRAVEL, $aMapID, $aRegion, $aDistrict, $aLanguage, False)
EndFunc   ;==>MoveMap

;~ Description: Returns to outpost after resigning/failure.
Func ReturnToOutpost()
	Return SendPacket(0x4, $HEADER_OUTPOST_RETURN)
EndFunc   ;==>ReturnToOutpost

;~ Description: Enter a challenge mission/pvp.
Func EnterChallenge()
	Return SendPacket(0x8, $HEADER_MISSION_ENTER, 1)
EndFunc   ;==>EnterChallenge

;~ Description: Enter a foreign challenge mission/pvp.
Func EnterChallengeForeign()
	Return SendPacket(0x8, $HEADER_MISSION_FOREIGN_ENTER, 0)
EndFunc   ;==>EnterChallengeForeign

;~ Description: Travel to your guild hall.
Func TravelGH()
    Local $lOffset[3] = [0, 0x18, 0x3C]
    Local $lGH = MemoryReadPtr($mBasePointer, $lOffset)
    SendPacket(0x18, $HEADER_GUILDHALL_TRAVEL, MemoryRead($lGH[1] + 0x64), MemoryRead($lGH[1] + 0x68), MemoryRead($lGH[1] + 0x6C), MemoryRead($lGH[1] + 0x70), 1)
    Return WaitMapLoading()
EndFunc   ;==>TravelGH

;~ Description: Leave your guild hall.
Func LeaveGH()
	SendPacket(0x8, $HEADER_GUILDHALL_LEAVE, 1)
	Return WaitMapLoading()
EndFunc   ;==>LeaveGH
#EndRegion Travel

#Region Quest
;~ Description: Accept a quest from an NPC.
Func AcceptQuest($aQuestID)
	Return SendPacket(0x8, $HEADER_QUEST_ACCEPT, '0x008' & Hex($aQuestID, 3) & '01')
EndFunc   ;==>AcceptQuest

;~ Description: Accept the reward for a quest.
Func QuestReward($aQuestID)
	Return SendPacket(0x8, $HEADER_QUEST_REWARD, '0x008' & Hex($aQuestID, 3) & '07')
EndFunc   ;==>QuestReward

;~ Description: Abandon a quest.
Func AbandonQuest($aQuestID)
	Return SendPacket(0x8, $HEADER_QUEST_ABANDON, $aQuestID)
EndFunc   ;==>AbandonQuest
#EndRegion Quest

#Region Windows
;~ Description: Close all in-game windows.
Func CloseAllPanels()
	Return PerformAction(0x85, 0x18)
EndFunc   ;==>CloseAllPanels

;~ Description: Toggle hero window.
Func ToggleHeroWindow()
	Return PerformAction(0x8A, 0x18)
EndFunc   ;==>ToggleHeroWindow

;~ Description: Toggle inventory window.
Func ToggleInventory()
	Return PerformAction(0x8B, 0x18)
EndFunc   ;==>ToggleInventory

;~ Description: Toggle all bags window.
Func ToggleAllBags()
	Return PerformAction(0xB8, 0x18)
EndFunc   ;==>ToggleAllBags

;~ Description: Toggle world map.
Func ToggleWorldMap()
	Return PerformAction(0x8C, 0x18)
EndFunc   ;==>ToggleWorldMap

;~ Description: Toggle options window.
Func ToggleOptions()
	Return PerformAction(0x8D, 0x18)
EndFunc   ;==>ToggleOptions

;~ Description: Toggle quest window.
Func ToggleQuestWindow()
	Return PerformAction(0x8E, 0x18)
EndFunc   ;==>ToggleQuestWindow

;~ Description: Toggle skills window.
Func ToggleSkillWindow()
	Return PerformAction(0x8F, 0x18)
EndFunc   ;==>ToggleSkillWindow

;~ Description: Toggle mission map.
Func ToggleMissionMap()
	Return PerformAction(0xB6, 0x18)
EndFunc   ;==>ToggleMissionMap

;~ Description: Toggle friends list window.
Func ToggleFriendList()
	Return PerformAction(0xB9, 0x18)
EndFunc   ;==>ToggleFriendList

;~ Description: Toggle guild window.
Func ToggleGuildWindow()
	Return PerformAction(0xBA, 0x18)
EndFunc   ;==>ToggleGuildWindow

;~ Description: Toggle party window.
Func TogglePartyWindow()
	Return PerformAction(0xBF, 0x18)
EndFunc   ;==>TogglePartyWindow

;~ Description: Toggle score chart.
Func ToggleScoreChart()
	Return PerformAction(0xBD, 0x18)
EndFunc   ;==>ToggleScoreChart

;~ Description: Toggle layout window.
Func ToggleLayoutWindow()
	Return PerformAction(0xC1, 0x18)
EndFunc   ;==>ToggleLayoutWindow

;~ Description: Toggle minions window.
Func ToggleMinionList()
	Return PerformAction(0xC2, 0x18)
EndFunc   ;==>ToggleMinionList

;~ Description: Toggle a hero panel.
Func ToggleHeroPanel($aHero)
	If $aHero < 4 Then
		Return PerformAction(0xDB + $aHero, 0x18)
	ElseIf $aHero < 8 Then
		Return PerformAction(0xFE + $aHero, 0x18)
	EndIf
EndFunc   ;==>ToggleHeroPanel

;~ Description: Toggle hero's pet panel.
Func ToggleHeroPetPanel($aHero)
	If $aHero < 4 Then
		Return PerformAction(0xDF + $aHero, 0x18)
	ElseIf $aHero < 8 Then
		Return PerformAction(0xFA + $aHero, 0x18)
	EndIf
EndFunc   ;==>ToggleHeroPetPanel

;~ Description: Toggle pet panel.
Func TogglePetPanel()
	Return PerformAction(0xDF, 0x18)
EndFunc   ;==>TogglePetPanel

;~ Description: Toggle help window.
Func ToggleHelpWindow()
	Return PerformAction(0xE4, 0x18)
EndFunc   ;==>ToggleHelpWindow
#EndRegion Windows

#Region Targeting
;~ Description: Target an agent.
Func ChangeTarget($aAgent)
	Local $lAgentID

	If IsDllStruct($aAgent) = 0 Then
		$lAgentID = ConvertID($aAgent)
	Else
		$lAgentID = DllStructGetData($aAgent, 'ID')
	EndIf

	DllStructSetData($mChangeTarget, 2, $lAgentID)
	Enqueue($mChangeTargetPtr, 8)
EndFunc   ;==>ChangeTarget

;~ Description: Call target.
Func CallTarget($aTarget)
	Local $lTargetID

	If IsDllStruct($aTarget) = 0 Then
		$lTargetID = ConvertID($aTarget)
	Else
		$lTargetID = DllStructGetData($aTarget, 'ID')
	EndIf

	Return SendPacket(0xC, $HEADER_CALL_TARGET, 0xA, $lTargetID)
EndFunc   ;==>CallTarget

;~ Description: Clear current target.
Func ClearTarget()
	Return PerformAction(0xE3, 0x18)
EndFunc   ;==>ClearTarget

;~ Description: Target the nearest enemy.
Func TargetNearestEnemy()
	Return PerformAction(0x93, 0x18)
EndFunc   ;==>TargetNearestEnemy

;~ Description: Target the next enemy.
Func TargetNextEnemy()
	Return PerformAction(0x95, 0x18)
EndFunc   ;==>TargetNextEnemy

;~ Description: Target the next party member.
Func TargetPartyMember($aNumber)
	If $aNumber > 0 And $aNumber < 13 Then Return PerformAction(0x95 + $aNumber, 0x18)
EndFunc   ;==>TargetPartyMember

;~ Description: Target the previous enemy.
Func TargetPreviousEnemy()
	Return PerformAction(0x9E, 0x18)
EndFunc   ;==>TargetPreviousEnemy

;~ Description: Target the called target.
Func TargetCalledTarget()
	Return PerformAction(0x9F, 0x18)
EndFunc   ;==>TargetCalledTarget

;~ Description: Target yourself.
Func TargetSelf()
	Return PerformAction(0xA0, 0x18)
EndFunc   ;==>TargetSelf

;~ Description: Target the nearest ally.
Func TargetNearestAlly()
	Return PerformAction(0xBC, 0x18)
EndFunc   ;==>TargetNearestAlly

;~ Description: Target the nearest item.
Func TargetNearestItem()
	Return PerformAction(0xC3, 0x18)
EndFunc   ;==>TargetNearestItem

;~ Description: Target the next item.
Func TargetNextItem()
	Return PerformAction(0xC4, 0x18)
EndFunc   ;==>TargetNextItem

;~ Description: Target the previous item.
Func TargetPreviousItem()
	Return PerformAction(0xC5, 0x18)
EndFunc   ;==>TargetPreviousItem

;~ Description: Target the next party member.
Func TargetNextPartyMember()
	Return PerformAction(0xCA, 0x18)
EndFunc   ;==>TargetNextPartyMember

;~ Description: Target the previous party member.
Func TargetPreviousPartyMember()
	Return PerformAction(0xCB, 0x18)
EndFunc   ;==>TargetPreviousPartyMember
#EndRegion Targeting

#Region Display
;~ Description: Enable graphics rendering.
Func EnableRendering()
	MemoryWrite($mDisableRendering, 0)
EndFunc   ;==>EnableRendering

;~ Description: Disable graphics rendering.
Func DisableRendering()
	MemoryWrite($mDisableRendering, 1)
EndFunc   ;==>DisableRendering

;~ Description: Display all names.
Func DisplayAll($aDisplay)
	DisplayAllies($aDisplay)
	DisplayEnemies($aDisplay)
EndFunc   ;==>DisplayAll

;~ Description: Display the names of allies.
Func DisplayAllies($aDisplay)
	If $aDisplay Then
		Return PerformAction(0x89, 0x18)
	Else
		Return PerformAction(0x89, 0x1A)
	EndIf
EndFunc   ;==>DisplayAllies

;~ Description: Display the names of enemies.
Func DisplayEnemies($aDisplay)
	If $aDisplay Then
		Return PerformAction(0x94, 0x18)
	Else
		Return PerformAction(0x94, 0x1A)
	EndIf
EndFunc   ;==>DisplayEnemies
#EndRegion Display

#Region Chat
;~ Description: Write a message in chat (can only be seen by botter).
Func WriteChat($aMessage, $aSender = 'GWA2')
	Local $lMessage, $lSender
	Local $lAddress = 256 * $mQueueCounter + $mQueueBase

	If $mQueueCounter = $mQueueSize Then
		$mQueueCounter = 0
	Else
		$mQueueCounter = $mQueueCounter + 1
	EndIf

	If StringLen($aSender) > 19 Then
		$lSender = StringLeft($aSender, 19)
	Else
		$lSender = $aSender
	EndIf

	MemoryWrite($lAddress + 4, $lSender, 'wchar[20]')

	If StringLen($aMessage) > 100 Then
		$lMessage = StringLeft($aMessage, 100)
	Else
		$lMessage = $aMessage
	EndIf

	MemoryWrite($lAddress + 44, $lMessage, 'wchar[101]')
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', $lAddress, 'ptr', $mWriteChatPtr, 'int', 4, 'int', '')

	If StringLen($aMessage) > 100 Then WriteChat(StringTrimLeft($aMessage, 100), $aSender)
EndFunc   ;==>WriteChat

;~ Description: Send a whisper to another player.
Func SendWhisper($aReceiver, $aMessage)
	Local $lTotal = 'whisper ' & $aReceiver & ',' & $aMessage
	Local $lMessage

	If StringLen($lTotal) > 120 Then
		$lMessage = StringLeft($lTotal, 120)
	Else
		$lMessage = $lTotal
	EndIf

	SendChat($lMessage, '/')

	If StringLen($lTotal) > 120 Then SendWhisper($aReceiver, StringTrimLeft($lTotal, 120))
EndFunc   ;==>SendWhisper

;~ Description: Send a message to chat.
Func SendChat($aMessage, $aChannel = '!')
	Local $lMessage
	Local $lAddress = 256 * $mQueueCounter + $mQueueBase

	If $mQueueCounter = $mQueueSize Then
		$mQueueCounter = 0
	Else
		$mQueueCounter = $mQueueCounter + 1
	EndIf

	If StringLen($aMessage) > 120 Then
		$lMessage = StringLeft($aMessage, 120)
	Else
		$lMessage = $aMessage
	EndIf

	MemoryWrite($lAddress + 8, $aChannel & $lMessage, 'wchar[122]')
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', $lAddress, 'ptr', $mSendChatPtr, 'int', 8, 'int', '')

	If StringLen($aMessage) > 120 Then SendChat(StringTrimLeft($aMessage, 120), $aChannel)
EndFunc   ;==>SendChat
#EndRegion Chat

#Region Misc
;~ Description: Change weapon sets.
Func ChangeWeaponSet($aSet)
	Return PerformAction(128 + $aSeT, 30)
EndFunc   ;==>ChangeWeaponSet

;~ Description: Use a skill.
Func UseSkill($aSkillSlot, $aTarget = 0, $aCallTarget = False)
	Local $lTargetID

	If IsDllStruct($aTarget) = 0 Then
		$lTargetID = ConvertID($aTarget)
	Else
		$lTargetID = DllStructGetData($aTarget, 'ID')
	EndIf

	DllStructSetData($mUseSkill, 2, $aSkillSlot)
	DllStructSetData($mUseSkill, 3, $lTargetID)
	DllStructSetData($mUseSkill, 4, $aCallTarget)
	Enqueue($mUseSkillPtr, 16)
EndFunc   ;==>UseSkill

;~ Description: Cancel current action.
Func CancelAction()
	Return SendPacket(0x4, $HEADER_CANCEL_ACTION)
EndFunc   ;==>CancelAction

;~ Description: Same as hitting spacebar.
Func ActionInteract()
	Return PerformAction(0x80, 0x18)
EndFunc   ;==>ActionInteract

;~ Description: Follow a player.
Func ActionFollow()
	Return PerformAction(0xCC, 0x18)
EndFunc   ;==>ActionFollow

;~ Description: Drop environment object.
Func DropBundle()
	Return PerformAction(0xCD, 0x18)
EndFunc   ;==>DropBundle

;~ Description: Clear all hero flags.
Func ClearPartyCommands()
	Return PerformAction(0xDB, 0x18)
EndFunc   ;==>ClearPartyCommands

;~ Description: Suppress action.
Func SuppressAction($aSuppress)
	If $aSuppress Then
		Return PerformAction(0xD0, 0x18)
	Else
		Return PerformAction(0xD0, 0x1A)
	EndIf
EndFunc   ;==>SuppressAction

;~ Description: Open a chest.
Func OpenChest()
	Return SendPacket(0x8, $HEADER_CHEST_OPEN, 2)
EndFunc   ;==>OpenChest

;~ Description: Stop maintaining enchantment on target.
Func DropBuff($aSkillID, $aAgentID, $aHeroNumber = 0)
	Local $lBuffStruct = DllStructCreate('long SkillId;byte unknown1[4];long BuffId;long TargetId')
	Local $lBuffCount = GetBuffCount($aHeroNumber)
	Local $lBuffStructAddress
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			$lOffset[4] = 0x4 + 0x24 * $i
			ReDim $lOffset[6]
			For $j = 0 To $lBuffCount - 1
				$lOffset[5] = 0 + 0x10 * $j
				$lBuffStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
				DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lBuffStructAddress[0], 'ptr', DllStructGetPtr($lBuffStruct), 'int', DllStructGetSize($lBuffStruct), 'int', '')
				If (DllStructGetData($lBuffStruct, 'SkillID') == $aSkillID) And (DllStructGetData($lBuffStruct, 'TargetId') == ConvertID($aAgentID)) Then
					Return SendPacket(0x8, $HEADER_STOP_MAINTAIN_ENCH, DllStructGetData($lBuffStruct, 'BuffId'))
					ExitLoop 2
				EndIf
			Next
		EndIf
	Next
EndFunc   ;==>DropBuff

;~ Description: Take a screenshot.
Func MakeScreenshot()
	Return PerformAction(0xAE, 0x18)
EndFunc   ;==>MakeScreenshot

;~ Description: Invite a player to the party.
Func InvitePlayer($aPlayerName)
	SendChat('invite ' & $aPlayerName, '/')
EndFunc   ;==>InvitePlayer

;~ Description: Leave your party.
Func LeaveGroup($aKickHeroes = True)
	If $aKickHeroes Then KickAllHeroes()
	Return SendPacket(0x4, $HEADER_PARTY_LEAVE)
EndFunc   ;==>LeaveGroup

;~ Description: Switches to/from Hard Mode.
Func SwitchMode($aMode)
	Return SendPacket(0x8, $HEADER_MODE_SWITCH, $aMode)
EndFunc   ;==>SwitchMode

;~ Description: Resign.
Func Resign()
	SendChat('resign', '/')
EndFunc   ;==>Resign

;~ Description: Donate Kurzick or Luxon faction.
Func DonateFaction($aFaction)
	If StringLeft($aFaction, 1) = 'k' Then
		Return SendPacket(0x10, $HEADER_FACTION_DONATE, 0, 0, 0x1388)
	ElseIf StringLeft($aFaction, 1) = 'l' Then
		Return SendPacket(0x10, $HEADER_FACTION_DONATE, 0, 1, 0x1388)
	EndIf
EndFunc   ;==>DonateFaction

;~ Description: Open a dialog.
Func Dialog($aDialogID)
	Return SendPacket(0x8, $HEADER_DIALOG, $aDialogID)
EndFunc   ;==>Dialog

;~ Description: Skip a cinematic.
Func SkipCinematic()
	Return SendPacket(0x4, $HEADER_CINEMATIC_SKIP)
EndFunc   ;==>SkipCinematic

;~ Description: Change a skill on the skillbar.
Func SetSkillbarSkill($aSlot, $aSkillID, $aHeroNumber = 0)
	Return SendPacket(0x14, $HEADER_SKILL_CHANGE, GetHeroID($aHeroNumber), $aSlot - 1, $aSkillID, 0)
EndFunc   ;==>SetSkillbarSkill

;~ Description: Load all skills onto a skillbar simultaneously.
Func LoadSkillBar($aSkill1 = 0, $aSkill2 = 0, $aSkill3 = 0, $aSkill4 = 0, $aSkill5 = 0, $aSkill6 = 0, $aSkill7 = 0, $aSkill8 = 0, $aHeroNumber = 0)
	SendPacket(0x2C, $HEADER_BUILD_LOAD, GetHeroID($aHeroNumber), 8, $aSkill1, $aSkill2, $aSkill3, $aSkill4, $aSkill5, $aSkill6, $aSkill7, $aSkill8)
EndFunc   ;==>LoadSkillBar

;~ Description: Loads skill template code.
Func LoadSkillTemplate($aTemplate, $aHeroNumber = 0)
	Local $lHeroID = GetHeroID($aHeroNumber)
	Local $lSplitTemplate = StringSplit($aTemplate, "")
	Local $lAttributeStr = ""
	Local $lAttributeLevelStr = ""
	Local $lTemplateType ; 4 Bits
	Local $lVersionNumber ; 4 Bits
	Local $lProfBits ; 2 Bits -> P
	Local $lProfPrimary ; P Bits
	Local $lProfSecondary ; P Bits
	Local $lAttributesCount ; 4 Bits
	Local $lAttributesBits ; 4 Bits -> A
	;Local $lAttributes[1][2] ; A Bits + 4 Bits (for each Attribute)
	Local $lSkillsBits ; 4 Bits -> S
	Local $lSkills[8] ; S Bits * 8
	Local $lOpTail ; 1 Bit
	$aTemplate = ""
	For $i = 1 To $lSplitTemplate[0]
		$aTemplate &= Base64ToBin64($lSplitTemplate[$i])
	Next
	$lTemplateType = Bin64ToDec(StringLeft($aTemplate, 4))
	$aTemplate = StringTrimLeft($aTemplate, 4)
	If $lTemplateType <> 14 Then Return False
	$lVersionNumber = Bin64ToDec(StringLeft($aTemplate, 4))
	$aTemplate = StringTrimLeft($aTemplate, 4)
	$lProfBits = Bin64ToDec(StringLeft($aTemplate, 2)) * 2 + 4
	$aTemplate = StringTrimLeft($aTemplate, 2)
	$lProfPrimary = Bin64ToDec(StringLeft($aTemplate, $lProfBits))
	$aTemplate = StringTrimLeft($aTemplate, $lProfBits)
	If $lProfPrimary <> GetHeroProfession($aHeroNumber) Then Return False
	$lProfSecondary = Bin64ToDec(StringLeft($aTemplate, $lProfBits))
	$aTemplate = StringTrimLeft($aTemplate, $lProfBits)
	$lAttributesCount = Bin64ToDec(StringLeft($aTemplate, 4))
	$aTemplate = StringTrimLeft($aTemplate, 4)
	$lAttributesBits = Bin64ToDec(StringLeft($aTemplate, 4)) + 4
	$aTemplate = StringTrimLeft($aTemplate, 4)
	For $i = 1 To $lAttributesCount
		;Attribute ID
		$lAttributeStr &= Bin64ToDec(StringLeft($aTemplate, $lAttributesBits))
		If $i <> $lAttributesCount Then $lAttributeStr &= "|"
		$aTemplate = StringTrimLeft($aTemplate, $lAttributesBits)
		;Attribute level of above ID
		$lAttributeLevelStr &= Bin64ToDec(StringLeft($aTemplate, 4))
		If $i <> $lAttributesCount Then $lAttributeLevelStr &= "|"
		$aTemplate = StringTrimLeft($aTemplate, 4)
	Next
	$lSkillsBits = Bin64ToDec(StringLeft($aTemplate, 4)) + 8
	$aTemplate = StringTrimLeft($aTemplate, 4)
	For $i = 0 To 7
		$lSkills[$i] = Bin64ToDec(StringLeft($aTemplate, $lSkillsBits))
		$aTemplate = StringTrimLeft($aTemplate, $lSkillsBits)
	Next
	$lOpTail = Bin64ToDec($aTemplate)
	ChangeSecondProfession($lProfSecondary, $aHeroNumber)
	SetAttributes($lAttributeStr, $lAttributeLevelStr, $aHeroNumber)
	LoadSkillBar($lSkills[0], $lSkills[1], $lSkills[2], $lSkills[3], $lSkills[4], $lSkills[5], $lSkills[6], $lSkills[7], $aHeroNumber)
EndFunc   ;==>LoadSkillTemplate

;~ Description: Set attributes to the given values
Func SetAttributes($fAttsID, $fAttsLevel, $aHeroNumber = 0)
   Local $lAttsID = StringSplit(String($fAttsID), "|")
   Local $lAttsLevel = StringSplit(String($fAttsLevel), "|")

   DllStructSetData($mSetAttributes, 4, GetHeroID($aHeroNumber))
   DllStructSetData($mSetAttributes, 5, $lAttsID[0]) ;# of attributes
   DllStructSetData($mSetAttributes, 22, $lAttsID[0]) ;# of attributes

   For $i = 1 To $lAttsID[0]
	  DllStructSetData($mSetAttributes, 5 + $i, $lAttsID[$i]) ;ID ofAttributes
   Next

   For $i = 1 To $lAttsLevel[0]
	  DllStructSetData($mSetAttributes, 22 + $i, $lAttsLevel[$i]) ;Attribute Levels
   Next

   Enqueue($mSetAttributesPtr, 152)
EndFunc   ;==>SetAttributes

;~ Description: Change your secondary profession.
Func ChangeSecondProfession($aProfession, $aHeroNumber = 0)
	Return SendPacket(0xC, $HEADER_CHANGE_SECONDARY, GetHeroID($aHeroNumber), $aProfession)
EndFunc   ;==>ChangeSecondProfession

;~ Description: Sets value of GetMapIsLoaded() to 0.
Func InitMapLoad()
	MemoryWrite($mMapIsLoaded, 0)
EndFunc   ;==>InitMapLoad

;~ Description: Changes game language to english.
Func EnsureEnglish($aEnsure)
	If $aEnsure Then
		MemoryWrite($mEnsureEnglish, 1)
	Else
		MemoryWrite($mEnsureEnglish, 0)
	EndIf
EndFunc   ;==>EnsureEnglish

;~ Description: Change game language.
Func ToggleLanguage()
	DllStructSetData($mToggleLanguage, 2, 0x18)
	Enqueue($mToggleLanguagePtr, 8)
EndFunc   ;==>ToggleLanguage

;~ Description: Changes the maximum distance you can zoom out.
Func ChangeMaxZoom($aZoom = 750)
	MemoryWrite($mZoomStill, $aZoom, "float")
	MemoryWrite($mZoomMoving, $aZoom, "float")
EndFunc   ;==>ChangeMaxZoom

;~ Description: Emptys Guild Wars client memory
Func ClearMemory()
	DllCall($mKernelHandle, 'int', 'SetProcessWorkingSetSize', 'int', $mGWProcHandle, 'int', -1, 'int', -1)
EndFunc   ;==>ClearMemory

;~ Description: Changes the maximum memory Guild Wars can use.
Func SetMaxMemory($aMemory = 157286400)
	DllCall($mKernelHandle, 'int', 'SetProcessWorkingSetSizeEx', 'int', $mGWProcHandle, 'int', 1, 'int', $aMemory, 'int', 6)
EndFunc   ;==>SetMaxMemory
#EndRegion Misc

#Region Online Status
 ;~ Description: Change online status. 0 = Offline, 1 = Online, 2 = Do not disturb, 3 = Away
 Func SetPlayerStatus($aStatus)
    If ($aStatus >= 0 And $aStatus <= 3) And GetPlayerStatus() <> $aStatus Then
        DllStructSetData($mChangeStatus, 2, $aStatus)
        Enqueue($mChangeStatusPtr, 8)
        Return True
    Else
        Return False
    EndIf
EndFunc   ;==>SetPlayerStatus

Func GetPlayerStatus()
       Return MemoryRead($mCurrentStatus)
 EndFunc   ;==>GetPlayerStatus
#EndRegion Online Status

;~ Description: Internal use only.
Func Enqueue($aPtr, $aSize)
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', 256 * $mQueueCounter + $mQueueBase, 'ptr', $aPtr, 'int', $aSize, 'int', '')
	If $mQueueCounter = $mQueueSize Then
		$mQueueCounter = 0
	Else
		$mQueueCounter = $mQueueCounter + 1
	EndIf
EndFunc   ;==>Enqueue

;~ Description: Converts float to integer.
Func FloatToInt($nFloat)
	Local $tFloat = DllStructCreate("float")
	Local $tInt = DllStructCreate("int", DllStructGetPtr($tFloat))
	DllStructSetData($tFloat, 1, $nFloat)
	Return DllStructGetData($tInt, 1)
EndFunc   ;==>FloatToInt
#EndRegion Commands

#Region Queries
#Region Titles
;~ Description: Returns Hero title progress.
Func GetHeroTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x4]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetHeroTitle

;~ Description: Returns Gladiator title progress.
Func GetGladiatorTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x7C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetGladiatorTitle

;~ Description: Returns Kurzick title progress.
Func GetKurzickTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0xCC]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetKurzickTitle

;~ Description: Returns Luxon title progress.
Func GetLuxonTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0xF4]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetLuxonTitle

;~ Description: Returns drunkard title progress.
Func GetDrunkardTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x11C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetDrunkardTitle

;~ Description: Returns survivor title progress.
Func GetSurvivorTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x16C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetSurvivorTitle

;~ Description: Returns max titles
Func GetMaxTitles()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x194]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxTitles

;~ Description: Returns lucky title progress.
Func GetLuckyTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x25C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetLuckyTitle

;~ Description: Returns unlucky title progress.
Func GetUnluckyTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x284]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetUnluckyTitle

;~ Description: Returns Sunspear title progress.
Func GetSunspearTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x2AC]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetSunspearTitle

;~ Description: Returns Lightbringer title progress.
Func GetLightbringerTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x324]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetLightbringerTitle

;~ Description: Returns Commander title progress.
Func GetCommanderTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x374]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetCommanderTitle

;~ Description: Returns Gamer title progress.
Func GetGamerTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x39C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetGamerTitle

;~ Description: Returns Legendary Guardian title progress.
Func GetLegendaryGuardianTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x4DC]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetLegendaryGuardianTitle

;~ Description: Returns sweets title progress.
Func GetSweetTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x554]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetSweetTitle

;~ Description: Returns Asura title progress.
Func GetAsuraTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x5F4]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetAsuraTitle

;~ Description: Returns Deldrimor title progress.
Func GetDeldrimorTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x61C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetDeldrimorTitle

;~ Description: Returns Vanguard title progress.
Func GetVanguardTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x644]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetVanguardTitle

;~ Description: Returns Norn title progress.
Func GetNornTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x66C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetNornTitle

;~ Description: Returns mastery of the north title progress.
Func GetNorthMasteryTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x694]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetNorthMasteryTitle

;~ Description: Returns party title progress.
Func GetPartyTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x6BC]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetPartyTitle

;~ Description: Returns Zaishen title progress.
Func GetZaishenTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x6E4]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetZaishenTitle

;~ Description: Returns treasure hunter title progress.
Func GetTreasureTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x70C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetTreasureTitle

;~ Description: Returns wisdom title progress.
Func GetWisdomTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x734]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetWisdomTitle

 ;~ Description: Returns codex title progress.
Func GetCodexTitle()
    Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x75C] ;0x7B8 before apr20
    Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
    Return $lReturn[1]
 EndFunc   ;==>GetCodexTitle

 ;~ Description: Returns current Tournament points.
Func GetTournamentPoints()
    Local $lOffset[5] = [0 ,0x18, 0x2C, 0, 0x18]
    Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
    Return $lReturn[1]
EndFunc   ;==>GetTournamentPoints
#EndRegion Titles

#Region Faction
;~ Description: Returns current Kurzick faction.
Func GetKurzickFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x748]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetKurzickFaction

;~ Description: Returns max Kurzick faction.
Func GetMaxKurzickFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x7B8]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxKurzickFaction

;~ Description: Returns current Luxon faction.
Func GetLuxonFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x758]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetLuxonFaction

;~ Description: Returns max Luxon faction.
Func GetMaxLuxonFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x7BC]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxLuxonFaction

;~ Description: Returns current Balthazar faction.
Func GetBalthazarFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x798]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetBalthazarFaction

;~ Description: Returns max Balthazar faction.
Func GetMaxBalthazarFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x7C0]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxBalthazarFaction

;~ Description: Returns current Imperial faction.
Func GetImperialFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x76C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetImperialFaction

;~ Description: Returns max Imperial faction.
Func GetMaxImperialFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x7C4]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxImperialFaction
#EndRegion Faction

#Region Item
;~ Description: Returns rarity (name color) of an item.
Func GetRarity($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Local $lPtr = DllStructGetData($aItem, 'NameString')
	If $lPtr == 0 Then Return
	Return MemoryRead($lPtr, 'ushort')
EndFunc   ;==>GetRarity

;~ Description: Returns if material is Rare.
Func GetIsRareMaterial($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	If DllStructGetData($aItem, "Type") <> 11 Then Return False
	Return Not GetIsCommonMaterial($aItem)
EndFunc   ;==>GetIsRareMaterial

;~ Description: Returns if material is Common.
Func GetIsCommonMaterial($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Return BitAND(DllStructGetData($aItem, "Interaction"), 0x20) <> 0
EndFunc   ;==>GetIsCommonMaterial

;~ Description: Legacy function, use GetIsIdentified instead.
Func GetIsIDed($aItem)
	Return GetIsIdentified($aItem)
EndFunc   ;==>GetIsIDed

;~ Description: Tests if an item is identified.
Func GetIsIdentified($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Return BitAND(DllStructGetData($aItem, 'interaction'), 1) > 0
EndFunc   ;==>GetIsIdentified

;~ Description: Returns a weapon or shield's minimum required attribute.
Func GetItemReq($aItem)
	Local $lMod = GetModByIdentifier($aItem, "9827")
	Return $lMod[0]
EndFunc   ;==>GetItemReq

;~ Description: Returns a weapon or shield's required attribute.
Func GetItemAttribute($aItem)
	Local $lMod = GetModByIdentifier($aItem, "9827")
	Return $lMod[1]
EndFunc   ;==>GetItemAttribute

;~ Description: Returns an array of a the requested mod.
Func GetModByIdentifier($aItem, $aIdentifier)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Local $lReturn[2]
	Local $lString = StringTrimLeft(GetModStruct($aItem), 2)
	For $i = 0 To StringLen($lString) / 8 - 2
		If StringMid($lString, 8 * $i + 5, 4) == $aIdentifier Then
			$lReturn[0] = Int("0x" & StringMid($lString, 8 * $i + 1, 2))
			$lReturn[1] = Int("0x" & StringMid($lString, 8 * $i + 3, 2))
			ExitLoop
		EndIf
	Next
	Return $lReturn
EndFunc   ;==>GetModByIdentifier

;~ Description: Returns modstruct of an item.
Func GetModStruct($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	If DllStructGetData($aItem, 'modstruct') = 0 Then Return
	Return MemoryRead(DllStructGetData($aItem, 'modstruct'), 'Byte[' & DllStructGetData($aItem, 'modstructsize') * 4 & ']')
EndFunc   ;==>GetModStruct

;~ Description: Tests if an item is assigned to you.
Func GetAssignedToMe($aAgent)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return (DllStructGetData($aAgent, 'Owner') = GetMyID())
EndFunc   ;==>GetAssignedToMe

;~ Description: Tests if you can pick up an item.
Func GetCanPickUp($aAgent)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	If GetAssignedToMe($aAgent) Or DllStructGetData($aAgent, 'Owner') = 0 Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>GetCanPickUp

;~ Description: Returns struct of an inventory bag.
Func GetBag($aBag)
	Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x4 * $aBag]
	Local $lBagStruct = DllStructCreate('byte unknown1[4];long index;long id;ptr containerItem;long ItemsCount;ptr bagArray;ptr itemArray;long fakeSlots;long slots')
	Local $lBagPtr = MemoryReadPtr($mBasePointer, $lOffset)
	If $lBagPtr[1] = 0 Then Return
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lBagPtr[1], 'ptr', DllStructGetPtr($lBagStruct), 'int', DllStructGetSize($lBagStruct), 'int', '')
	Return $lBagStruct
EndFunc   ;==>GetBag

;~ Description: Returns item by slot.
Func GetItemBySlot($aBag, $aSlot)
	Local $lBag

	If IsDllStruct($aBag) = 0 Then
		$lBag = GetBag($aBag)
	Else
		$lBag = $aBag
	EndIf

	Local $lItemPtr = DllStructGetData($lBag, 'ItemArray')
	Local $lBuffer = DllStructCreate('ptr')
	Local $lItemStruct = DllStructCreate('long Id;long AgentId;byte Unknown1[4];ptr Bag;ptr ModStruct;long ModStructSize;ptr Customized;byte unknown2[4];byte Type;byte unknown4;short ExtraId;short Value;byte unknown4[2];short Interaction;long ModelId;ptr ModString;byte unknown5[4];ptr NameString;ptr SingleItemName;byte Unknown4[10];byte IsSalvageable;byte Unknown6;word Quantity;byte Equiped;byte Profession;byte Type2;byte Slot')
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', DllStructGetData($lBag, 'ItemArray') + 4 * ($aSlot - 1), 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', DllStructGetData($lBuffer, 1), 'ptr', DllStructGetPtr($lItemStruct), 'int', DllStructGetSize($lItemStruct), 'int', '')
	Return $lItemStruct
EndFunc   ;==>GetItemBySlot

;~ Description: Returns item struct.
Func GetItemByItemID($aItemID)
	Local $lItemStruct = DllStructCreate('long Id;long AgentId;byte Unknown1[4];ptr Bag;ptr ModStruct;long ModStructSize;ptr Customized;byte unknown2[4];byte Type;byte unknown4;short ExtraId;short Value;byte unknown4[2];short Interaction;long ModelId;ptr ModString;byte unknown5[4];ptr NameString;ptr SingleItemName;byte Unknown4[10];byte IsSalvageable;byte Unknown6;word Quantity;byte Equiped;byte Profession;byte Type2;byte Slot')
	Local $lOffset[5] = [0, 0x18, 0x40, 0xB8, 0x4 * $aItemID]
	Local $lItemPtr = MemoryReadPtr($mBasePointer, $lOffset)
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lItemPtr[1], 'ptr', DllStructGetPtr($lItemStruct), 'int', DllStructGetSize($lItemStruct), 'int', '')
	Return $lItemStruct
EndFunc   ;==>GetItemByItemID

;~ Description: Returns item by agent ID.
Func GetItemByAgentID($aAgentID)
	Local $lItemStruct = DllStructCreate('long Id;long AgentId;byte Unknown1[4];ptr Bag;ptr ModStruct;long ModStructSize;ptr Customized;byte unknown2[4];byte Type;byte unknown4;short ExtraId;short Value;byte unknown4[2];short Interaction;long ModelId;ptr ModString;byte unknown5[4];ptr NameString;ptr SingleItemName;byte Unknown4[10];byte IsSalvageable;byte Unknown6;word Quantity;byte Equiped;byte Profession;byte Type2;byte Slot')
	Local $lOffset[4] = [0, 0x18, 0x40, 0xC0]
	Local $lItemArraySize = MemoryReadPtr($mBasePointer, $lOffset)
	Local $lOffset[5] = [0, 0x18, 0x40, 0xB8, 0]
	Local $lItemPtr, $lItemID
	Local $lAgentID = ConvertID($aAgentID)

	For $lItemID = 1 To $lItemArraySize[1]
		$lOffset[4] = 0x4 * $lItemID
		$lItemPtr = MemoryReadPtr($mBasePointer, $lOffset)
		If $lItemPtr[1] = 0 Then ContinueLoop

		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lItemPtr[1], 'ptr', DllStructGetPtr($lItemStruct), 'int', DllStructGetSize($lItemStruct), 'int', '')
		If DllStructGetData($lItemStruct, 'AgentID') = $lAgentID Then Return $lItemStruct
	Next
EndFunc   ;==>GetItemByAgentID

;~ Description: Returns item by model ID.
Func GetItemByModelID($aModelID)
	Local $lItemStruct = DllStructCreate('long Id;long AgentId;byte Unknown1[4];ptr Bag;ptr ModStruct;long ModStructSize;ptr Customized;byte unknown2[4];byte Type;byte unknown4;short ExtraId;short Value;byte unknown4[2];short Interaction;long ModelId;ptr ModString;byte unknown5[4];ptr NameString;ptr SingleItemName;byte Unknown4[10];byte IsSalvageable;byte Unknown6;word Quantity;byte Equiped;byte Profession;byte Type2;byte Slot')
	Local $lOffset[4] = [0, 0x18, 0x40, 0xC0]
	Local $lItemArraySize = MemoryReadPtr($mBasePointer, $lOffset)
	Local $lOffset[5] = [0, 0x18, 0x40, 0xB8, 0]
	Local $lItemPtr, $lItemID

	For $lItemID = 1 To $lItemArraySize[1]
		$lOffset[4] = 0x4 * $lItemID
		$lItemPtr = MemoryReadPtr($mBasePointer, $lOffset)
		If $lItemPtr[1] = 0 Then ContinueLoop

		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lItemPtr[1], 'ptr', DllStructGetPtr($lItemStruct), 'int', DllStructGetSize($lItemStruct), 'int', '')
		If DllStructGetData($lItemStruct, 'ModelID') = $aModelID Then Return $lItemStruct
	Next
EndFunc   ;==>GetItemByModelID

;~ Description: Returns amount of gold in storage.
Func GetGoldStorage()
	Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x94]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetGoldStorage

;~ Description: Returns amount of gold being carried.
Func GetGoldCharacter()
	Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x90]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetGoldCharacter

;~ Description: Returns item ID of salvage kit in inventory.
Func FindSalvageKit()
	Local $lItem
	Local $lKit = 0
	Local $lUses = 101
	For $i = 1 To 4
		For $j = 1 To DllStructGetData(GetBag($i), 'Slots')
			$lItem = GetItemBySlot($i, $j)
			Switch DllStructGetData($lItem, 'ModelID')
				Case 2992
					If DllStructGetData($lItem, 'Value') / 2 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 2
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKit
EndFunc   ;==>FindSalvageKit

;~ Description: Returns item ID of expert salvage kit in inventory.
Func FindExpertSalvageKit()
	Local $lItem
	Local $lKit = 0
	Local $lUses = 101
	For $i = 1 To 4
		For $j = 1 To DllStructGetData(GetBag($i), 'Slots')
			$lItem = GetItemBySlot($i, $j)
			Switch DllStructGetData($lItem, 'ModelID')
				Case 2991
					If DllStructGetData($lItem, 'Value') / 8 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 8
					EndIf
				Case 5900
					If DllStructGetData($lItem, 'Value') / 10 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 10
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKit
EndFunc   ;==>FindExpertSalvageKit

;~ Description: Legacy function, use FindIdentificationKit instead.
Func FindIDKit()
	Return FindIdentificationKit()
EndFunc   ;==>FindIDKit

;~ Description: Returns item ID of ID kit in inventory.
Func FindIdentificationKit()
	Local $lItem
	Local $lKit = 0
	Local $lUses = 101
	For $i = 1 To 4
		For $j = 1 To DllStructGetData(GetBag($i), 'Slots')
			$lItem = GetItemBySlot($i, $j)
			Switch DllStructGetData($lItem, 'ModelID')
				Case 2989
					If DllStructGetData($lItem, 'Value') / 2 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 2
					EndIf
				Case 5899
					If DllStructGetData($lItem, 'Value') / 2.5 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 2.5
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKit
EndFunc   ;==>FindIdentificationKit

;~ Description: Returns the item ID of the quoted item.
Func GetTraderCostID()
	Return MemoryRead($mTraderCostID)
EndFunc   ;==>GetTraderCostID

;~ Description: Returns the cost of the requested item.
Func GetTraderCostValue()
	Return MemoryRead($mTraderCostValue)
EndFunc   ;==>GetTraderCostValue

;~ Description: Internal use for BuyItem()
Func GetMerchantItemsBase()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x24]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMerchantItemsBase

;~ Description: Internal use for BuyItem()
Func GetMerchantItemsSize()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x28]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMerchantItemsSize
#EndRegion Item

#Region H&H
;~ Description: Returns number of heroes you control.
Func GetHeroCount()
	Local $lOffset[5]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x4C
	$lOffset[3] = 0x54
	$lOffset[4] = 0x2C
	Local $lHeroCount = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lHeroCount[1]
EndFunc   ;==>GetHeroCount

;~ Description: Returns agent ID of a hero.
Func GetHeroID($aHeroNumber)
	If $aHeroNumber == 0 Then Return GetMyID()
	Local $lOffset[6]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x4C
	$lOffset[3] = 0x54
	$lOffset[4] = 0x24
	$lOffset[5] = 0x18 * ($aHeroNumber - 1)
	Local $lAgentID = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lAgentID[1]
EndFunc   ;==>GetHeroID

;~ Description: Returns hero number by agent ID.
Func GetHeroNumberByAgentID($aAgentID)
	Local $lAgentID
	Local $lOffset[6]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x4C
	$lOffset[3] = 0x54
	$lOffset[4] = 0x24
	For $i = 1 To GetHeroCount()
		$lOffset[5] = 0x18 * ($i - 1)
		$lAgentID = MemoryReadPtr($mBasePointer, $lOffset)
		If $lAgentID[1] == ConvertID($aAgentID) Then Return $i
	Next
	Return 0
EndFunc   ;==>GetHeroNumberByAgentID

;~ Description: Returns hero number by hero ID.
Func GetHeroNumberByHeroID($aHeroId)
	Local $lAgentID
	Local $lOffset[6]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x4C
	$lOffset[3] = 0x54
	$lOffset[4] = 0x24
	For $i = 1 To GetHeroCount()
		$lOffset[5] = 8 + 0x18 * ($i - 1)
		$lAgentID = MemoryReadPtr($mBasePointer, $lOffset)
		If $lAgentID[1] == ConvertID($aHeroId) Then Return $i
	Next
	Return 0
EndFunc   ;==>GetHeroNumberByHeroID

;~ Description: Returns hero's profession ID (when it can't be found by other means)
Func GetHeroProfession($aHeroNumber, $aSecondary = False)
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x6BC, 0]
	Local $lBuffer
	$aHeroNumber = GetHeroID($aHeroNumber)
	For $i = 0 To GetHeroCount()
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] = $aHeroNumber Then
			$lOffset[4] += 4
			If $aSecondary Then $lOffset[4] += 4
			$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
			Return $lBuffer[1]
		EndIf
		$lOffset[4] += 0x14
	Next
EndFunc   ;==>GetHeroProfession

;~ Description: Tests if a hero's skill slot is disabled.
Func GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot)
	Return BitAND(2 ^ ($aSkillSlot - 1), DllStructGetData(GetSkillbar($aHeroNumber), 'Disabled')) > 0
EndFunc   ;==>GetIsHeroSkillSlotDisabled
#EndRegion H&H

#Region Agent
;~ Description: Returns an agent struct.
Func GetAgentByID($aAgentID = -2)
	;returns dll struct if successful
	Local $lAgentPtr = GetAgentPtr($aAgentID)
	If $lAgentPtr = 0 Then Return 0
	;Offsets: 0x2C=AgentID 0x9C=Type 0xF4=PlayerNumber 0114=Energy Pips
	Local $lAgentStruct = DllStructCreate('ptr vtable;byte unknown1[24];byte unknown2[4];ptr NextAgent;byte unknown3[8];long Id;float Z;byte unknown4[8];float BoxHoverWidth;float BoxHoverHeight;byte unknown5[8];float Rotation;byte unknown6[8];long NameProperties;byte unknown7[24];float X;float Y;byte unknown8[8];float NameTagX;float NameTagY;float NameTagZ;byte unknown9[12];long Type;float MoveX;float MoveY;byte unknown10[28];long Owner;byte unknown30[8];long ExtraType;byte unknown11[24];float AttackSpeed;float AttackSpeedModifier;word PlayerNumber;byte unknown12[6];ptr Equip;byte unknown13[10];byte Primary;byte Secondary;byte Level;byte Team;byte unknown14[6];float EnergyPips;byte unknown[4];float EnergyPercent;long MaxEnergy;byte unknown15[4];float HPPips;byte unknown16[4];float HP;long MaxHP;long Effects;byte unknown17[4];byte Hex;byte unknown18[18];long ModelState;long TypeMap;byte unknown19[16];long InSpiritRange;byte unknown20[16];long LoginNumber;float ModelMode;byte unknown21[4];long ModelAnimation;byte unknown22[32];byte LastStrike;byte Allegiance;word WeaponType;word Skill;byte unknown23[4];word WeaponItemId;word OffhandItemId')
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lAgentPtr, 'ptr', DllStructGetPtr($lAgentStruct), 'int', DllStructGetSize($lAgentStruct), 'int', '')
	Return $lAgentStruct
EndFunc   ;==>GetAgentByID

;~ Description: Internal use for GetAgentByID()
Func GetAgentPtr($aAgentID)
	Local $lOffset[3] = [0, 4 * ConvertID($aAgentID), 0]
	Local $lAgentStructAddress = MemoryReadPtr($mAgentBase, $lOffset)
	Return $lAgentStructAddress[0]
EndFunc   ;==>GetAgentPtr

;~ Description: Test if an agent exists.
Func GetAgentExists($aAgentID = -2)
	Return (GetAgentPtr($aAgentID) > 0 And $aAgentID < GetMaxAgents())
EndFunc   ;==>GetAgentExists

;~ Description: Returns the target of an agent.
Func GetTarget($aAgent = -2)
	Local $lAgentID

	If IsDllStruct($aAgent) = 0 Then
		$lAgentID = ConvertID($aAgent)
	Else
		$lAgentID = DllStructGetData($aAgent, 'ID')
	EndIf

	Return MemoryRead(GetValue('TargetLogBase') + 4 * $lAgentID)
EndFunc   ;==>GetTarget

;~ Description: Returns agent by player name.
Func GetAgentByPlayerName($aPlayerName)
	For $i = 1 To GetMaxAgents()
		If GetPlayerName($i) = $aPlayerName Then
			Return GetAgentByID($i)
		EndIf
	Next
EndFunc   ;==>GetAgentByPlayerName

;~ Description: Returns agent by name.
Func GetAgentByName($aName)
	Local $lName, $lAddress

	For $i = 1 To GetMaxAgents()
		$lAddress = $mStringLogBase + 256 * $i
		$lName = MemoryRead($lAddress, 'wchar [128]')
		$lName = StringRegExpReplace($lName, '[<]{1}([^>]+)[>]{1}', '')
		If StringInStr($lName, $aName) > 0 Then Return GetAgentByID($i)
	Next

	DisplayAll(True)
	Sleep(100)
	DisplayAll(False)
	DisplayAll(True)
	Sleep(100)
	DisplayAll(False)

	For $i = 1 To GetMaxAgents()
		$lAddress = $mStringLogBase + 256 * $i
		$lName = MemoryRead($lAddress, 'wchar [128]')
		$lName = StringRegExpReplace($lName, '[<]{1}([^>]+)[>]{1}', '')
		If StringInStr($lName, $aName) > 0 Then Return GetAgentByID($i)
	Next
EndFunc   ;==>GetAgentByName

;~ Description: Returns the nearest agent to an agent.
Func GetNearestAgentToAgent($aAgent = -2)
	Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance
	Local $lAgentArray = GetAgentArray()

	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)

	Local $lID = DllStructGetData($aAgent, 'ID')

	For $i = 1 To $lAgentArray[0]
		$lDistance = (DllStructGetData($aAgent, 'X') - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + (DllStructGetData($aAgent, 'Y') - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2

		If $lDistance < $lNearestDistance Then
			If DllStructGetData($lAgentArray[$i], 'ID') == $lID Then ContinueLoop
			$lNearestAgent = $lAgentArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance))
	Return $lNearestAgent
EndFunc   ;==>GetNearestAgentToAgent

;~ Description: Returns the nearest enemy to an agent.
Func GetNearestEnemyToAgent($aAgent = -2)
	Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance
	Local $lAgentArray = GetAgentArray(0xDB)

	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)

	Local $lID = DllStructGetData($aAgent, 'ID')

	For $i = 1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], 'Allegiance') <> 3 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], 'HP') <= 0 Then ContinueLoop
		If BitAND(DllStructGetData($lAgentArray[$i], 'Effects'), 0x0010) > 0 Then ContinueLoop
		$lDistance = (DllStructGetData($aAgent, 'X') - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + (DllStructGetData($aAgent, 'Y') - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
		If $lDistance < $lNearestDistance Then
			If DllStructGetData($lAgentArray[$i], 'ID') == $lID Then ContinueLoop
			$lNearestAgent = $lAgentArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance))
	Return $lNearestAgent
EndFunc   ;==>GetNearestEnemyToAgent

;~ Description: Returns the nearest agent to a set of coordinates.
Func GetNearestAgentToCoords($aX, $aY)
	Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance
	Local $lAgentArray = GetAgentArray()

	For $i = 1 To $lAgentArray[0]
		$lDistance = ($aX - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + ($aY - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
		If $lDistance < $lNearestDistance Then
			$lNearestAgent = $lAgentArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance))
	Return $lNearestAgent
EndFunc   ;==>GetNearestAgentToCoords

;~ Description: Returns the nearest signpost to an agent.
Func GetNearestSignpostToAgent($aAgent = -2)
	Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance
	Local $lAgentArray = GetAgentArray(0x200)

	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)

	Local $lID = DllStructGetData($aAgent, 'ID')

	For $i = 1 To $lAgentArray[0]
		$lDistance = (DllStructGetData($lAgentArray[$i], 'Y') - DllStructGetData($aAgent, 'Y')) ^ 2 + (DllStructGetData($lAgentArray[$i], 'X') - DllStructGetData($aAgent, 'X')) ^ 2
		If $lDistance < $lNearestDistance Then
			If DllStructGetData($lAgentArray[$i], 'ID') == $lID Then ContinueLoop
			$lNearestAgent = $lAgentArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance))
	Return $lNearestAgent
EndFunc   ;==>GetNearestSignpostToAgent

;~ Description: Returns the nearest signpost to a set of coordinates.
Func GetNearestSignpostToCoords($aX, $aY)
	Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance
	Local $lAgentArray = GetAgentArray(0x200)

	For $i = 1 To $lAgentArray[0]
		$lDistance = ($aX - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + ($aY - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2

		If $lDistance < $lNearestDistance Then
			$lNearestAgent = $lAgentArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance))
	Return $lNearestAgent
EndFunc   ;==>GetNearestSignpostToCoords

;~ Description: Returns the nearest NPC to an agent.
Func GetNearestNPCToAgent($aAgent = -2)
	Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance
	Local $lAgentArray = GetAgentArray(0xDB)

	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)

	Local $lID = DllStructGetData($aAgent, 'ID')

	For $i = 1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], 'Allegiance') <> 6 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], 'HP') <= 0 Then ContinueLoop
		If BitAND(DllStructGetData($lAgentArray[$i], 'Effects'), 0x0010) > 0 Then ContinueLoop

		$lDistance = (DllStructGetData($aAgent, 'X') - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + (DllStructGetData($aAgent, 'Y') - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
		If $lDistance < $lNearestDistance Then
			If DllStructGetData($lAgentArray[$i], 'ID') == $lID Then ContinueLoop
			$lNearestAgent = $lAgentArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance))
	Return $lNearestAgent
EndFunc   ;==>GetNearestNPCToAgent

;~ Description: Returns the nearest NPC to a set of coordinates.
Func GetNearestNPCToCoords($aX, $aY)
	Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance
	Local $lAgentArray = GetAgentArray(0xDB)

	For $i = 1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], 'Allegiance') <> 6 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], 'HP') <= 0 Then ContinueLoop
		If BitAND(DllStructGetData($lAgentArray[$i], 'Effects'), 0x0010) > 0 Then ContinueLoop

		$lDistance = ($aX - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + ($aY - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2

		If $lDistance < $lNearestDistance Then
			$lNearestAgent = $lAgentArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance))
	Return $lNearestAgent
EndFunc   ;==>GetNearestNPCToCoords

;~ Description: Returns the nearest item to an agent.
Func GetNearestItemToAgent($aAgent = -2, $aCanPickUp = True)
	Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance
	Local $lAgentArray = GetAgentArray(0x400)

	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)

	Local $lID = DllStructGetData($aAgent, 'ID')

	For $i = 1 To $lAgentArray[0]

		If $aCanPickUp And Not GetCanPickUp($lAgentArray[$i]) Then ContinueLoop
		$lDistance = (DllStructGetData($aAgent, 'X') - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + (DllStructGetData($aAgent, 'Y') - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
		If $lDistance < $lNearestDistance Then
			If DllStructGetData($lAgentArray[$i], 'ID') == $lID Then ContinueLoop
			$lNearestAgent = $lAgentArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance))
	Return $lNearestAgent
EndFunc   ;==>GetNearestItemToAgent

;~ Description: Returns array of party members
;~ Param: an array returned by GetAgentArray. This is totally optional, but can greatly improve script speed.
Func GetParty($aAgentArray = 0)
	Local $lReturnArray[1] = [0]
	If $aAgentArray==0 Then $aAgentArray = GetAgentArray(0xDB)
	For $i = 1 To $aAgentArray[0]
		If DllStructGetData($aAgentArray[$i], 'Allegiance') == 1 Then
			If BitAND(DllStructGetData($aAgentArray[$i], 'TypeMap'), 131072) Then
				$lReturnArray[0] += 1
				ReDim $lReturnArray[$lReturnArray[0] + 1]
				$lReturnArray[$lReturnArray[0]] = $aAgentArray[$i]
			EndIf
		EndIf
	Next
	Return $lReturnArray
EndFunc   ;==>GetParty

;~ Description: Quickly creates an array of agents of a given type
Func GetAgentArray($aType = 0)
	Local $lStruct
	Local $lCount
	Local $lBuffer = ''
	DllStructSetData($mMakeAgentArray, 2, $aType)
	MemoryWrite($mAgentCopyCount, -1, 'long')
	Enqueue($mMakeAgentArrayPtr, 8)
	Local $lDeadlock = TimerInit()
	Do
		Sleep(1)
		$lCount = MemoryRead($mAgentCopyCount, 'long')
	Until $lCount >= 0 Or TimerDiff($lDeadlock) > 5000
	If $lCount < 0 Then $lCount = 0
	For $i = 1 To $lCount
		$lBuffer &= 'Byte[448];'
	Next
	$lBuffer = DllStructCreate($lBuffer)
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $mAgentCopyBase, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
	Local $lReturnArray[$lCount + 1] = [$lCount]
	For $i = 1 To $lCount
		$lReturnArray[$i] = DllStructCreate('ptr vtable;byte unknown1[24];byte unknown2[4];ptr NextAgent;byte unknown3[8];long Id;float Z;byte unknown4[8];float BoxHoverWidth;float BoxHoverHeight;byte unknown5[8];float Rotation;byte unknown6[8];long NameProperties;byte unknown7[24];float X;float Y;byte unknown8[8];float NameTagX;float NameTagY;float NameTagZ;byte unknown9[12];long Type;float MoveX;float MoveY;byte unknown10[28];long Owner;byte unknown30[8];long ExtraType;byte unknown11[24];float AttackSpeed;float AttackSpeedModifier;word PlayerNumber;byte unknown12[6];ptr Equip;byte unknown13[10];byte Primary;byte Secondary;byte Level;byte Team;byte unknown14[6];float EnergyPips;byte unknown[4];float EnergyPercent;long MaxEnergy;byte unknown15[4];float HPPips;byte unknown16[4];float HP;long MaxHP;long Effects;byte unknown17[4];byte Hex;byte unknown18[18];long ModelState;long TypeMap;byte unknown19[16];long InSpiritRange;byte unknown20[16];long LoginNumber;float ModelMode;byte unknown21[4];long ModelAnimation;byte unknown22[32];byte LastStrike;byte Allegiance;word WeaponType;word Skill;byte unknown23[4];word WeaponItemId;word OffhandItemId')
		$lStruct = DllStructCreate('byte[448]', DllStructGetPtr($lReturnArray[$i]))
		DllStructSetData($lStruct, 1, DllStructGetData($lBuffer, $i))
	Next
	Return $lReturnArray
EndFunc   ;==>GetAgentArray

Func GetPartySize()
    Local $lSize = 0, $lReturn
    Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0]
    For $i=0 To 2
        $lOffset[4] = $i * 0x10 + 0xC
        $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
        $lSize += $lReturn[1]
    Next
    Return $lSize
EndFunc

;~ 	Description: Returns different States about Party. Check with BitAND.
;~ 	0x8 = Leader starts Mission / Leader is travelling with Party
;~ 	0x10 = Hardmode enabled
;~ 	0x20 = Party defeated
;~ 	0x40 = Guild Battle
;~ 	0x80 = Party Leader
;~ 	0x100 = Observe-Mode
Func GetPartyState($aFlag)
    Local $lOffset[4] = [0, 0x18, 0x4C, 0x14]
    Local $lBitMask = MemoryReadPtr($mBasePointer,$lOffset)
    Return BitAND($lBitMask[1], $aFlag) > 0
EndFunc   ;==>GetPartyState

Func GetPartyWaitingForMission()
	Return GetPartyState(0x8)
EndFunc

Func GetIsHardMode()
	Return GetPartyState(0x10)
EndFunc

Func GetPartyDefeated()
	Return GetPartyState(0x20)
EndFunc

;~ Description Returns the "danger level" of each party member
;~ Param1: an array returned by GetAgentArray(). This is totally optional, but can greatly improve script speed.
;~ Param2: an array returned by GetParty() This is totally optional, but can greatly improve script speed.
Func GetPartyDanger($aAgentArray = 0, $aParty = 0)
	If $aAgentArray == 0 Then $aAgentArray = GetAgentArray(0xDB)
	If $aParty == 0 Then $aParty = GetParty($aAgentArray)

	Local $lReturnArray[$aParty[0]+1]
	$lReturnArray[0] = $aParty[0]
	For $i=1 To $lReturnArray[0]
		$lReturnArray[$i] = 0
	Next

	For $i=1 To $aAgentArray[0]
		If BitAND(DllStructGetData($aAgentArray[$i], 'Effects'), 0x0010) > 0 Then ContinueLoop
		If DllStructGetData($aAgentArray[$i], 'HP') <= 0 Then ContinueLoop
		If Not GetIsLiving($aAgentArray[$i]) Then ContinueLoop
		If DllStructGetData($aAgentArray[$i], "Allegiance") > 3 Then ContinueLoop	; ignore NPCs, spirits, minions, pets

		For $j=1 To $aParty[0]
			If GetTarget(DllStructGetData($aAgentArray[$i], "ID")) == DllStructGetData($aParty[$j], "ID") Then
				If GetDistance($aAgentArray[$i], $aParty[$j]) < 5000 Then
					If DllStructGetData($aAgentArray[$i], "Team") <> 0 Then
						If DllStructGetData($aAgentArray[$i], "Team") <> DllStructGetData($aParty[$j], "Team") Then
							$lReturnArray[$j] += 1
						EndIf
					ElseIf DllStructGetData($aAgentArray[$i], "Allegiance") <> DllStructGetData($aParty[$j], "Allegiance") Then
						$lReturnArray[$j] += 1
					EndIf
				EndIf
			EndIf
		Next
	Next
	Return $lReturnArray
EndFunc
;~ Description: Return the number of enemy agents targeting the given agent.
Func GetAgentDanger($aAgent = -2, $aAgentArray = 0)
	If IsDllStruct($aAgent) = 0 Then
		$aAgent = GetAgentByID($aAgent)
	EndIf

	Local $lCount = 0

	If $aAgentArray == 0 Then $aAgentArray = GetAgentArray(0xDB)

	For $i=1 To $aAgentArray[0]
		If BitAND(DllStructGetData($aAgentArray[$i], 'Effects'), 0x0010) > 0 Then ContinueLoop
		If DllStructGetData($aAgentArray[$i], 'HP') <= 0 Then ContinueLoop
		If Not GetIsLiving($aAgentArray[$i]) Then ContinueLoop
		If DllStructGetData($aAgentArray[$i], "Allegiance") > 3 Then ContinueLoop	; ignore NPCs, spirits, minions, pets
		If GetTarget(DllStructGetData($aAgentArray[$i], "ID")) == DllStructGetData($aAgent, "ID") Then
			If GetDistance($aAgentArray[$i], $aAgent) < 5000 Then
				If DllStructGetData($aAgentArray[$i], "Team") <> 0 Then
					If DllStructGetData($aAgentArray[$i], "Team") <> DllStructGetData($aAgent, "Team") Then
						$lCount += 1
					EndIf
				ElseIf DllStructGetData($aAgentArray[$i], "Allegiance") <> DllStructGetData($aAgent, "Allegiance") Then
					$lCount += 1
				EndIf
			EndIf
		EndIf
	Next
	Return $lCount
EndFunc
#EndRegion Agent

#Region AgentInfo
;~ Description: Tests if an agent is living.
Func GetIsLiving($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return DllStructGetData($aAgent, 'Type') = 0xDB
EndFunc   ;==>GetIsLiving

;~ Description: Tests if an agent is a signpost/chest/etc.
Func GetIsStatic($aAgent)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return DllStructGetData($aAgent, 'Type') = 0x200
EndFunc   ;==>GetIsStatic

;~ Description: Tests if an agent is an item.
Func GetIsMovable($aAgent)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return DllStructGetData($aAgent, 'Type') = 0x400
EndFunc   ;==>GetIsMovable

;~ Description: Returns energy of an agent. (Only self/heroes)
Func GetEnergy($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return DllStructGetData($aAgent, 'EnergyPercent') * DllStructGetData($aAgent, 'MaxEnergy')
EndFunc   ;==>GetEnergy

;~ Description: Returns health of an agent. (Must have caused numerical change in health)
Func GetHealth($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return DllStructGetData($aAgent, 'HP') * DllStructGetData($aAgent, 'MaxHP')
EndFunc   ;==>GetHealth

;~ Description: Tests if an agent is moving.
Func GetIsMoving($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	If DllStructGetData($aAgent, 'MoveX') <> 0 Or DllStructGetData($aAgent, 'MoveY') <> 0 Then Return True
	Return False
EndFunc   ;==>GetIsMoving

;~ Description: Tests if an agent is knocked down.
Func GetIsKnocked($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return DllStructGetData($aAgent, 'ModelState') = 0x450
EndFunc   ;==>GetIsKnocked

;~ Description: Tests if an agent is attacking.
Func GetIsAttacking($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Switch DllStructGetData($aAgent, 'ModelState')
		Case 0x60 ; Is Attacking
			Return True
		Case 0x440 ; Is Attacking
			Return True
		Case 0x460 ; Is Attacking
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>GetIsAttacking

;~ Description: Tests if an agent is casting.
Func GetIsCasting($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return DllStructGetData($aAgent, 'Skill') <> 0
 EndFunc   ;==>GetIsCasting

;~ Description: Tests if an agent is bleeding.
Func GetIsBleeding($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0001) > 0
EndFunc   ;==>GetIsBleeding

;~ Description: Tests if an agent has a condition.
Func GetHasCondition($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0002) > 0
EndFunc   ;==>GetHasCondition

;~ Description: Tests if an agent is dead.
Func GetIsDead($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0010) > 0
EndFunc   ;==>GetIsDead

;~ Description: Tests if an agent has a deep wound.
Func GetHasDeepWound($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0020) > 0
EndFunc   ;==>GetHasDeepWound

;~ Description: Tests if an agent is poisoned.
Func GetIsPoisoned($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0040) > 0
EndFunc   ;==>GetIsPoisoned

;~ Description: Tests if an agent is enchanted.
Func GetIsEnchanted($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0080) > 0
EndFunc   ;==>GetIsEnchanted

;~ Description: Tests if an agent has a degen hex.
Func GetHasDegenHex($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0400) > 0
EndFunc   ;==>GetHasDegenHex

;~ Description: Tests if an agent is hexed.
Func GetHasHex($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0800) > 0
EndFunc   ;==>GetHasHex

;~ Description: Tests if an agent has a weapon spell.
Func GetHasWeaponSpell($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x8000) > 0
EndFunc   ;==>GetHasWeaponSpell

;~ Description: Tests if an agent is a boss.
Func GetIsBoss($aAgent)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return BitAND(DllStructGetData($aAgent, 'TypeMap'), 1024) > 0
EndFunc   ;==>GetIsBoss

;~ Description: Returns a player's name.
Func GetPlayerName($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Local $lLogin = DllStructGetData($aAgent, 'LoginNumber')
	Local $lOffset[6] = [0, 0x18, 0x2C, 0x80C, 76 * $lLogin + 0x28, 0]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset, 'wchar[30]')
	Return $lReturn[1]
EndFunc   ;==>GetPlayerName

;~ Description: Returns the name of an agent.
Func GetAgentName($aAgent = -2)
	If IsDllStruct($aAgent) = 0 Then
		Local $lAgentID = ConvertID($aAgent)
		If $lAgentID = 0 Then Return ''
	Else
		Local $lAgentID = DllStructGetData($aAgent, 'ID')
	EndIf

	Local $lAddress = $mStringLogBase + 256 * $lAgentID
	Local $lName = MemoryRead($lAddress, 'wchar [128]')

	If $lName = '' Then
		DisplayAll(True)
		Sleep(100)
		DisplayAll(False)
	EndIf

	Local $lName = MemoryRead($lAddress, 'wchar [128]')
	$lName = StringRegExpReplace($lName, '[<]{1}([^>]+)[>]{1}', '')
	Return $lName
EndFunc   ;==>GetAgentName
#EndRegion AgentInfo

#Region Buff
;~ Description: Returns current number of buffs being maintained.
Func GetBuffCount($aHeroNumber = 0)
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			Return MemoryRead($lBuffer[0] + 0xC)
		EndIf
	Next
	Return 0
EndFunc   ;==>GetBuffCount

;~ Description: Tests if you are currently maintaining buff on target.
Func GetIsTargetBuffed($aSkillID, $aAgentID, $aHeroNumber = 0)
	Local $lBuffStruct = DllStructCreate('long SkillId;byte unknown1[4];long BuffId;long TargetId')
	Local $lBuffCount = GetBuffCount($aHeroNumber)
	Local $lBuffStructAddress
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			$lOffset[4] = 0x4 + 0x24 * $i
			ReDim $lOffset[6]
			For $j = 0 To $lBuffCount - 1
				$lOffset[5] = 0 + 0x10 * $j
				$lBuffStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
				DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lBuffStructAddress[0], 'ptr', DllStructGetPtr($lBuffStruct), 'int', DllStructGetSize($lBuffStruct), 'int', '')
				If (DllStructGetData($lBuffStruct, 'SkillID') == $aSkillID) And (DllStructGetData($lBuffStruct, 'TargetId') == ConvertID($aAgentID)) Then
					Return $j + 1
				EndIf
			Next
		EndIf
	Next
	Return 0
EndFunc   ;==>GetIsTargetBuffed

;~ Description: Returns buff struct.
Func GetBuffByIndex($aBuffNumber, $aHeroNumber = 0)
	Local $lBuffStruct = DllStructCreate('long SkillId;byte unknown1[4];long BuffId;long TargetId')
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			$lOffset[4] = 0x4 + 0x24 * $i
			ReDim $lOffset[6]
			$lOffset[5] = 0 + 0x10 * ($aBuffNumber - 1)
			$lBuffStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
			DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lBuffStructAddress[0], 'ptr', DllStructGetPtr($lBuffStruct), 'int', DllStructGetSize($lBuffStruct), 'int', '')
			Return $lBuffStruct
		EndIf
	Next
	Return 0
EndFunc   ;==>GetBuffByIndex
#EndRegion Buff

#Region Misc
;~ Description: Returns skillbar struct.
Func GetSkillbar($aHeroNumber = 0)
	Local $lSkillbarStruct = DllStructCreate('long AgentId;long AdrenalineA1;long AdrenalineB1;dword Recharge1;dword Id1;dword Event1;long AdrenalineA2;long AdrenalineB2;dword Recharge2;dword Id2;dword Event2;long AdrenalineA3;long AdrenalineB3;dword Recharge3;dword Id3;dword Event3;long AdrenalineA4;long AdrenalineB4;dword Recharge4;dword Id4;dword Event4;long AdrenalineA5;long AdrenalineB5;dword Recharge5;dword Id5;dword Event5;long AdrenalineA6;long AdrenalineB6;dword Recharge6;dword Id6;dword Event6;long AdrenalineA7;long AdrenalineB7;dword Recharge7;dword Id7;dword Event7;long AdrenalineA8;long AdrenalineB8;dword Recharge8;dword Id8;dword Event8;dword disabled;byte unknown[8];dword Casting')
	Local $lOffset[5]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x6F0
	For $i = 0 To GetHeroCount()
		$lOffset[4] = $i * 0xBC
		Local $lSkillbarStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lSkillbarStructAddress[0], 'ptr', DllStructGetPtr($lSkillbarStruct), 'int', DllStructGetSize($lSkillbarStruct), 'int', '')
		If DllStructGetData($lSkillbarStruct, 'AgentId') == GetHeroID($aHeroNumber) Then Return $lSkillbarStruct
	Next
EndFunc   ;==>GetSkillbar

;~ Description: Returns the skill ID of an equipped skill.
Func GetSkillbarSkillID($aSkillSlot, $aHeroNumber = 0)
	Return DllStructGetData(GetSkillbar($aHeroNumber), 'ID' & $aSkillSlot)
EndFunc   ;==>GetSkillbarSkillID

;~ Description: Returns the adrenaline charge of an equipped skill.
Func GetSkillbarSkillAdrenaline($aSkillSlot, $aHeroNumber = 0)
	Return DllStructGetData(GetSkillbar($aHeroNumber), 'AdrenalineA' & $aSkillSlot)
EndFunc   ;==>GetSkillbarSkillAdrenaline

;~ Description: Returns the recharge time remaining of an equipped skill in milliseconds.
Func GetSkillbarSkillRecharge($aSkillSlot, $aHeroNumber = 0)
	Local $lTimestamp = DllStructGetData(GetSkillbar($aHeroNumber), 'Recharge' & $aSkillSlot)
	If $lTimestamp == 0 Then Return 0
	Return $lTimestamp - GetSkillTimer()
EndFunc   ;==>GetSkillbarSkillRecharge

;~ Description: Returns skill struct.
Func GetSkillByID($aSkillID)
	Local $lSkillStruct = DllStructCreate('long ID;byte Unknown1[4];long campaign;long Type;long Special;long ComboReq;long Effect1;long Condition;long Effect2;long WeaponReq;byte Profession;byte Attribute;byte Unknown2[2];long PvPID;byte Combo;byte Target;byte unknown3;byte EquipType;byte Unknown4;byte Energy;byte Unknown5[2];dword Adrenaline;float Activation;float Aftercast;long Duration0;long Duration15;long Recharge;byte Unknown6[12];long Scale0;long Scale15;long BonusScale0;long BonusScale15;float AoERange;float ConstEffect;byte unknown7[44]')
	Local $lSkillStructAddress = $mSkillBase + 160 * $aSkillID
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lSkillStructAddress, 'ptr', DllStructGetPtr($lSkillStruct), 'int', DllStructGetSize($lSkillStruct), 'int', '')
	Return $lSkillStruct
EndFunc   ;==>GetSkillByID

;~ Description: Returns energy cost of a skill.
Func GetEnergyCost($aSkill)
   Local $lInitCost = DllStructGetData($aSkill, 'energy')
   Switch $lInitCost
         Case 11
            Return 15
         Case 12
            Return 25
         Case Else
            Return $lInitCost
    EndSwitch
EndFunc   ;==>GetEnergyCost

Func IsInterruptSkill($Skill)
	Switch DllStructGetData($Skill, 'ID')
		Case $You_Move_Like_a_Dwarf
			Return True
		Case $Disarm
			Return True
		Case $Disrupting_Chop
			Return True
		Case $Distracting_Blow
			Return True
		Case $Distracting_Shot
			Return True
		Case $Distracting_Strike
			Return True
		Case $Savage_Slash
			Return True
		Case $Skull_Crack
			Return True
		Case $Disrupting_Shot
			Return True
		Case $Magebane_Shot
			Return True
		Case $Punishing_Shot
			Return True
		Case $Savage_Shot
			Return True
		Case $Leech_Signet
			Return True
		Case $Psychic_Instability
			Return True
		Case $Psychic_Instability_PVP
			Return True
		Case $Simple_Thievery
			Return True
		Case $Thunderclap
			Return True
		Case $Disrupting_Stab
			Return True
		Case $Exhausting_Assault
			Return True
		Case $Lyssas_Assault
			Return True
		Case $Lyssas_Haste
			Return True
		Case $Disrupting_Lunge
			Return True
		Case $Complicate
			Return True
		Case $Cry_of_Frustration
			Return True
		Case $Psychic_Distraction
			Return True
		Case $Tease
			Return True
		Case $Web_of_Disruption
			Return True
		Case $Disrupting_Dagger
			Return True
		Case $Signet_of_Disruption
			Return True
		Case $Signet_of_Distraction
			Return True
		Case $Temple_Strike
			Return True
		Case $Power_Block
			Return True
		Case $Power_Drain
			Return True
		Case $Power_Flux
			Return True
		Case $Power_Leak
			Return True
		Case $Power_Leech
			Return True
		Case $Power_Lock
			Return True
		Case $Power_Return
			Return True
		Case $Power_Spike
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>IsInterruptSkill


;~ Description: Returns current morale.
Func GetMorale($aHeroNumber = 0)
	Local $lAgentID = GetHeroID($aHeroNumber)
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x638
	Local $lIndex = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[6]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x62C
	$lOffset[4] = 8 + 0xC * BitAND($lAgentID, $lIndex[1])
	$lOffset[5] = 0x18
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1] - 100
EndFunc   ;==>GetMorale

;~ Description: Returns effect struct or array of effects.
Func GetEffect($aSkillID = 0, $aHeroNumber = 0)
	Local $lEffectCount, $lEffectStructAddress
	Local $lReturnArray[1] = [0]

	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			$lOffset[4] = 0x1C + 0x24 * $i
			$lEffectCount = MemoryReadPtr($mBasePointer, $lOffset)
			ReDim $lOffset[6]
			$lOffset[4] = 0x14 + 0x24 * $i
			$lOffset[5] = 0
			$lEffectStructAddress = MemoryReadPtr($mBasePointer, $lOffset)

			If $aSkillID = 0 Then
				ReDim $lReturnArray[$lEffectCount[1] + 1]
				$lReturnArray[0] = $lEffectCount[1]

				For $i = 0 To $lEffectCount[1] - 1
					$lReturnArray[$i + 1] = DllStructCreate('long SkillId;long EffectType;long EffectId;long AgentId;float Duration;long TimeStamp')
					$lEffectStructAddress[1] = $lEffectStructAddress[0] + 24 * $i
					DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lEffectStructAddress[1], 'ptr', DllStructGetPtr($lReturnArray[$i + 1]), 'int', 24, 'int', '')
				Next

				ExitLoop
			Else
				Local $lReturn = DllStructCreate('long SkillId;long EffectType;long EffectId;long AgentId;float Duration;long TimeStamp')

				For $i = 0 To $lEffectCount[1] - 1
					DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lEffectStructAddress[0] + 24 * $i, 'ptr', DllStructGetPtr($lReturn), 'int', 24, 'int', '')
					If DllStructGetData($lReturn, 'SkillID') = $aSkillID Then Return $lReturn
				Next
			EndIf
		EndIf
	Next
	Return $lReturnArray
EndFunc   ;==>GetEffect

;~ Description: Returns time remaining before an effect expires, in milliseconds.
Func GetEffectTimeRemaining($aEffect)
	If Not IsDllStruct($aEffect) Then $aEffect = GetEffect($aEffect)
	If IsArray($aEffect) Then Return 0
	Return DllStructGetData($aEffect, 'Duration') * 1000 - (GetSkillTimer() - DllStructGetData($aEffect, 'TimeStamp'))
EndFunc   ;==>GetEffectTimeRemaining

;~ Description: Returns the timestamp used for effects and skills (milliseconds).
Func GetSkillTimer()
	Return MemoryRead($mSkillTimer, "long")
EndFunc   ;==>GetSkillTimer

;~ Description: Returns level of an attribute.
Func GetAttributeByID($aAttributeID, $aWithRunes = False, $aHeroNumber = 0)
	Local $lAgentID = GetHeroID($aHeroNumber)
	Local $lBuffer
	Local $lOffset[5]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0xAC
	For $i = 0 To GetHeroCount()
		$lOffset[4] = 0x3D8 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == $lAgentID Then
			If $aWithRunes Then
				$lOffset[4] = 0x3D8 * $i + 0x14 * $aAttributeID + 0xC
			Else
				$lOffset[4] = 0x3D8 * $i + 0x14 * $aAttributeID + 0x8
			EndIf
			$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
			Return $lBuffer[1]
		EndIf
	Next
EndFunc   ;==>GetAttributeByID

;~ Description: Returns amount of experience.
Func GetExperience()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x740]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetExperience

;~ Description: Tests if an area has been vanquished.
Func GetAreaVanquished()
	If GetFoesToKill() = 0 Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>GetAreaVanquished

;~ Description: Returns number of foes that have been killed so far.
Func GetFoesKilled()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x84C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetFoesKilled

;~ Description: Returns number of enemies left to kill for vanquish.
Func GetFoesToKill()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x850]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetFoesToKill

;~ Description: Returns number of agents currently loaded.
Func GetMaxAgents()
	Return MemoryRead($mMaxAgents)
EndFunc   ;==>GetMaxAgents

;~ Description: Returns your agent ID.
Func GetMyID()
	Return MemoryRead($mMyID)
EndFunc   ;==>GetMyID

;~ Description: Returns current target.
Func GetCurrentTarget()
	Return GetAgentByID(GetCurrentTargetID())
EndFunc   ;==>GetCurrentTarget

;~ Description: Returns current target ID.
Func GetCurrentTargetID()
	Return MemoryRead($mCurrentTarget)
EndFunc   ;==>GetCurrentTargetID

;~ Description: Returns current ping.
Func GetPing()
	Return MemoryRead($mPing)
EndFunc   ;==>GetPing

;~ Description: Returns current map ID.
Func GetMapID()
	Return MemoryRead($mMapID)
EndFunc   ;==>GetMapID

;~ Description: Returns current load-state.
Func GetMapLoading()
	Return MemoryRead($mMapLoading)
EndFunc   ;==>GetMapLoading

;~ Description: Returns if map has been loaded. Reset with InitMapLoad().
Func GetMapIsLoaded()
	Return MemoryRead($mMapIsLoaded) And GetAgentExists(-2)
EndFunc   ;==>GetMapIsLoaded

;~ Description: Returns current district
Func GetDistrict()
	Local $lOffset[4] = [0, 0x18, 0x44, 0x1B4]
	Local $lResult = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lResult[1]
EndFunc   ;==>GetDistrict

;~ Description: Internal use for travel functions.
Func GetRegion()
	Return MemoryRead($mRegion)
EndFunc   ;==>GetRegion

;~ Description: Internal use for travel functions.
Func GetLanguage()
	Return MemoryRead($mLanguage)
EndFunc   ;==>GetLanguage

;~ Description: Wait for map to load. Returns true if successful.
Func WaitMapLoading($aMapID = 0, $aDeadlock = 15000)
;~ 	Waits $aDeadlock for load to start, and $aDeadLock for agent to load after map is loaded.
	Local $lMapLoading
	Local $lDeadlock = TimerInit()

	InitMapLoad()

	Do
		Sleep(100)
		$lMapLoading = GetMapLoading()
		If $lMapLoading == 2 Then $lDeadlock = TimerInit()
		If TimerDiff($lDeadlock) > $aDeadlock And $aDeadlock > 0 Then Return False
	Until $lMapLoading <> 2 And GetMapIsLoaded() And (GetMapID() = $aMapID Or $aMapID = 0)

	RndSleep(500)

	Return True
EndFunc   ;==>WaitMapLoading

;~ Description: Returns quest struct.
Func GetQuestByID($aQuestID = 0)
	Local $lQuestStruct = DllStructCreate('long id;long LogState;byte unknown1[12];long MapFrom;float X;float Y;byte unknown2[8];long MapTo')
	Local $lQuestPtr, $lQuestLogSize, $lQuestID
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x534]

	$lQuestLogSize = MemoryReadPtr($mBasePointer, $lOffset)

	If $aQuestID = 0 Then
		$lOffset[1] = 0x18
		$lOffset[2] = 0x2C
		$lOffset[3] = 0x528
		$lQuestID = MemoryReadPtr($mBasePointer, $lOffset)
		$lQuestID = $lQuestID[1]
	Else
		$lQuestID = $aQuestID
	EndIf

	Local $lOffset[5] = [0, 0x18, 0x2C, 0x52C, 0]
	For $i = 0 To $lQuestLogSize[1]
		$lOffset[4] = 0x34 * $i
		$lQuestPtr = MemoryReadPtr($mBasePointer, $lOffset)
		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lQuestPtr[0], 'ptr', DllStructGetPtr($lQuestStruct), 'int', DllStructGetSize($lQuestStruct), 'int', '')
		If DllStructGetData($lQuestStruct, 'ID') = $lQuestID Then Return $lQuestStruct
	Next
EndFunc   ;==>GetQuestByID

;~ Description: Returns your characters name.
Func GetCharname()
	Return MemoryRead($mCharname, 'wchar[30]')
EndFunc   ;==>GetCharname

;~ Description: Returns if you're logged in.
Func GetLoggedIn()
	Return MemoryRead($mLoggedIn)
EndFunc   ;==>GetLoggedIn

;~ Description: Returns the number of character slots you have. Only works on character select.
Func GetCharacterSlots()
	Return MemoryRead($mCharslots)
EndFunc   ;==>GetLoggedIn

;~ Description: Returns language currently being used.
Func GetDisplayLanguage()
	Local $lOffset[6] = [0, 0x18, 0x18, 0x194, 0x4C, 0x40]
	Local $lResult = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lResult[1]
EndFunc   ;==>GetDisplayLanguage

;~ Returns how long the current instance has been active, in milliseconds.
Func GetInstanceUpTime()
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x8
	$lOffset[3] = 0x1AC
	Local $lTimer = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lTimer[1]
EndFunc   ;==>GetInstanceUpTime

;~ Returns the game client's build number
Func GetBuildNumber()
	Return $mBuildNumber
EndFunc   ;==>GetBuildNumber

Func GetProfPrimaryAttribute($aProfession)
	Switch $aProfession
		Case 1
			Return 17
		Case 2
			Return 23
		Case 3
			Return 16
		Case 4
			Return 6
		Case 5
			Return 0
		Case 6
			Return 12
		Case 7
			Return 35
		Case 8
			Return 36
		Case 9
			Return 40
		Case 10
			Return 44
	EndSwitch
EndFunc   ;==>GetProfPrimaryAttribute
#EndRegion Misc
#EndRegion Queries

#Region Other Functions
#Region Misc
;~ Description: Sleep a random amount of time.
Func RndSleep($aAmount, $aRandom = 0.05)
	Local $lRandom = $aAmount * $aRandom
	Sleep(Random($aAmount - $lRandom, $aAmount + $lRandom))
EndFunc   ;==>RndSleep

;~ Description: Sleep a period of time, plus or minus a tolerance
Func TolSleep($aAmount = 150, $aTolerance = 50)
	Sleep(Random($aAmount - $aTolerance, $aAmount + $aTolerance))
EndFunc   ;==>TolSleep

;~ Description: Returns window handle of Guild Wars.
Func GetWindowHandle()
	Return $mGWWindowHandle
EndFunc   ;==>GetWindowHandle

;~ Description: Returns the distance between two coordinate pairs.
Func ComputeDistance($aX1, $aY1, $aX2, $aY2)
	Return Sqrt(($aX1 - $aX2) ^ 2 + ($aY1 - $aY2) ^ 2)
EndFunc   ;==>ComputeDistance

;~ Description: Returns the distance between two agents.
Func GetDistance($aAgent1 = -1, $aAgent2 = -2)
	If IsDllStruct($aAgent1) = 0 Then $aAgent1 = GetAgentByID($aAgent1)
	If IsDllStruct($aAgent2) = 0 Then $aAgent2 = GetAgentByID($aAgent2)
	Return Sqrt((DllStructGetData($aAgent1, 'X') - DllStructGetData($aAgent2, 'X')) ^ 2 + (DllStructGetData($aAgent1, 'Y') - DllStructGetData($aAgent2, 'Y')) ^ 2)
EndFunc   ;==>GetDistance

;~ Description: Return the square of the distance between two agents.
Func GetPseudoDistance($aAgent1, $aAgent2)
	Return (DllStructGetData($aAgent1, 'X') - DllStructGetData($aAgent2, 'X')) ^ 2 + (DllStructGetData($aAgent1, 'Y') - DllStructGetData($aAgent2, 'Y')) ^ 2
EndFunc   ;==>GetPseudoDistance

;~ Description: Checks if a point is within a polygon defined by an array
Func GetIsPointInPolygon($aAreaCoords, $aPosX = 0, $aPosY = 0)
	Local $lPosition
	Local $lEdges = UBound($aAreaCoords)
	Local $lOddNodes = False
	If $lEdges < 3 Then Return False
	If $aPosX = 0 Then
		Local $lAgent = GetAgentByID(-2)
		$aPosX = DllStructGetData($lAgent, 'X')
		$aPosY = DllStructGetData($lAgent, 'Y')
	EndIf
	$j = $lEdges - 1
	For $i = 0 To $lEdges - 1
		If (($aAreaCoords[$i][1] < $aPosY And $aAreaCoords[$j][1] >= $aPosY) _
				Or ($aAreaCoords[$j][1] < $aPosY And $aAreaCoords[$i][1] >= $aPosY)) _
				And ($aAreaCoords[$i][0] <= $aPosX Or $aAreaCoords[$j][0] <= $aPosX) Then
			If ($aAreaCoords[$i][0] + ($aPosY - $aAreaCoords[$i][1]) / ($aAreaCoords[$j][1] - $aAreaCoords[$i][1]) * ($aAreaCoords[$j][0] - $aAreaCoords[$i][0]) < $aPosX) Then
				$lOddNodes = Not $lOddNodes
			EndIf
		EndIf
		$j = $i
	Next
	Return $lOddNodes
EndFunc   ;==>GetIsPointInPolygon

;~ Description: Internal use for handing -1 and -2 agent IDs.
Func ConvertID($aID)
	If $aID = -2 Then
		Return GetMyID()
	ElseIf $aID = -1 Then
		Return GetCurrentTargetID()
	Else
		Return $aID
	EndIf
EndFunc   ;==>ConvertID

;~ Description: Internal use only.
Func SendPacket($aSize, $aHeader, $aParam1 = 0, $aParam2 = 0, $aParam3 = 0, $aParam4 = 0, $aParam5 = 0, $aParam6 = 0, $aParam7 = 0, $aParam8 = 0, $aParam9 = 0, $aParam10 = 0)
	If GetAgentExists(-2) Then
		DllStructSetData($mPacket, 2, $aSize)
		DllStructSetData($mPacket, 3, $aHeader)
		DllStructSetData($mPacket, 4, $aParam1)
		DllStructSetData($mPacket, 5, $aParam2)
		DllStructSetData($mPacket, 6, $aParam3)
		DllStructSetData($mPacket, 7, $aParam4)
		DllStructSetData($mPacket, 8, $aParam5)
		DllStructSetData($mPacket, 9, $aParam6)
		DllStructSetData($mPacket, 10, $aParam7)
		DllStructSetData($mPacket, 11, $aParam8)
		DllStructSetData($mPacket, 12, $aParam9)
		DllStructSetData($mPacket, 13, $aParam10)
		Enqueue($mPacketPtr, 52)
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>SendPacket

;~ Description: Internal use only.
Func PerformAction($aAction, $aFlag)
	If GetAgentExists(-2) Then
		DllStructSetData($mAction, 2, $aAction)
		DllStructSetData($mAction, 3, $aFlag)
		Enqueue($mActionPtr, 12)
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>PerformAction

;~ Description: Internal use only.
Func Bin64ToDec($aBinary)
	Local $lReturn = 0

	For $i = 1 To StringLen($aBinary)
		If StringMid($aBinary, $i, 1) == 1 Then $lReturn += 2 ^ ($i - 1)
	Next

	Return $lReturn
EndFunc   ;==>Bin64ToDec

;~ Description: Internal use only.
Func Base64ToBin64($aCharacter)
	Select
		Case $aCharacter == "A"
			Return "000000"
		Case $aCharacter == "B"
			Return "100000"
		Case $aCharacter == "C"
			Return "010000"
		Case $aCharacter == "D"
			Return "110000"
		Case $aCharacter == "E"
			Return "001000"
		Case $aCharacter == "F"
			Return "101000"
		Case $aCharacter == "G"
			Return "011000"
		Case $aCharacter == "H"
			Return "111000"
		Case $aCharacter == "I"
			Return "000100"
		Case $aCharacter == "J"
			Return "100100"
		Case $aCharacter == "K"
			Return "010100"
		Case $aCharacter == "L"
			Return "110100"
		Case $aCharacter == "M"
			Return "001100"
		Case $aCharacter == "N"
			Return "101100"
		Case $aCharacter == "O"
			Return "011100"
		Case $aCharacter == "P"
			Return "111100"
		Case $aCharacter == "Q"
			Return "000010"
		Case $aCharacter == "R"
			Return "100010"
		Case $aCharacter == "S"
			Return "010010"
		Case $aCharacter == "T"
			Return "110010"
		Case $aCharacter == "U"
			Return "001010"
		Case $aCharacter == "V"
			Return "101010"
		Case $aCharacter == "W"
			Return "011010"
		Case $aCharacter == "X"
			Return "111010"
		Case $aCharacter == "Y"
			Return "000110"
		Case $aCharacter == "Z"
			Return "100110"
		Case $aCharacter == "a"
			Return "010110"
		Case $aCharacter == "b"
			Return "110110"
		Case $aCharacter == "c"
			Return "001110"
		Case $aCharacter == "d"
			Return "101110"
		Case $aCharacter == "e"
			Return "011110"
		Case $aCharacter == "f"
			Return "111110"
		Case $aCharacter == "g"
			Return "000001"
		Case $aCharacter == "h"
			Return "100001"
		Case $aCharacter == "i"
			Return "010001"
		Case $aCharacter == "j"
			Return "110001"
		Case $aCharacter == "k"
			Return "001001"
		Case $aCharacter == "l"
			Return "101001"
		Case $aCharacter == "m"
			Return "011001"
		Case $aCharacter == "n"
			Return "111001"
		Case $aCharacter == "o"
			Return "000101"
		Case $aCharacter == "p"
			Return "100101"
		Case $aCharacter == "q"
			Return "010101"
		Case $aCharacter == "r"
			Return "110101"
		Case $aCharacter == "s"
			Return "001101"
		Case $aCharacter == "t"
			Return "101101"
		Case $aCharacter == "u"
			Return "011101"
		Case $aCharacter == "v"
			Return "111101"
		Case $aCharacter == "w"
			Return "000011"
		Case $aCharacter == "x"
			Return "100011"
		Case $aCharacter == "y"
			Return "010011"
		Case $aCharacter == "z"
			Return "110011"
		Case $aCharacter == "0"
			Return "001011"
		Case $aCharacter == "1"
			Return "101011"
		Case $aCharacter == "2"
			Return "011011"
		Case $aCharacter == "3"
			Return "111011"
		Case $aCharacter == "4"
			Return "000111"
		Case $aCharacter == "5"
			Return "100111"
		Case $aCharacter == "6"
			Return "010111"
		Case $aCharacter == "7"
			Return "110111"
		Case $aCharacter == "8"
			Return "001111"
		Case $aCharacter == "9"
			Return "101111"
		Case $aCharacter == "+"
			Return "011111"
		Case $aCharacter == "/"
			Return "111111"
	EndSelect
EndFunc   ;==>Base64ToBin64
#EndRegion Misc

#Region Callback
;~ Description: Controls Event System.
Func SetEvent($aSkillActivate = '', $aSkillCancel = '', $aSkillComplete = '', $aChatReceive = '', $aLoadFinished = '')
	If $aSkillActivate <> '' Then
		WriteDetour('SkillLogStart', 'SkillLogProc')
	Else
		$mASMString = ''
		_('inc eax')
		_('mov dword[esi+10],eax')
		_('pop esi')
		WriteBinary($mASMString, GetValue('SkillLogStart'))
	EndIf

	If $aSkillCancel <> '' Then
		WriteDetour('SkillCancelLogStart', 'SkillCancelLogProc')
	Else
		$mASMString = ''
		_('push 0')
		_('push 42')
		_('mov ecx,esi')
		WriteBinary($mASMString, GetValue('SkillCancelLogStart'))
	EndIf

	If $aSkillComplete <> '' Then
		WriteDetour('SkillCompleteLogStart', 'SkillCompleteLogProc')
	Else
		$mASMString = ''
		_('mov eax,dword[edi+4]')
		_('test eax,eax')
		WriteBinary($mASMString, GetValue('SkillCompleteLogStart'))
	EndIf

	If $aChatReceive <> '' Then
		WriteDetour('ChatLogStart', 'ChatLogProc')
	Else
		$mASMString = ''
		_('add edi,E')
		_('cmp eax,B')
		WriteBinary($mASMString, GetValue('ChatLogStart'))
	EndIf

	$mSkillActivate = $aSkillActivate
	$mSkillCancel = $aSkillCancel
	$mSkillComplete = $aSkillComplete
	$mChatReceive = $aChatReceive
	$mLoadFinished = $aLoadFinished
EndFunc   ;==>SetEvent

;~ Description: Internal use for event system.
;~ modified by gigi, avoid getagentbyid, just pass agent id to callback
Func Event($hwnd, $msg, $wparam, $lparam)
	Switch $lparam
		Case 0x1
			DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $wparam, 'ptr', $mSkillLogStructPtr, 'int', 16, 'int', '')
			Call($mSkillActivate, DllStructGetData($mSkillLogStruct, 1), DllStructGetData($mSkillLogStruct, 2), DllStructGetData($mSkillLogStruct, 3), DllStructGetData($mSkillLogStruct, 4))
		Case 0x2
			DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $wparam, 'ptr', $mSkillLogStructPtr, 'int', 16, 'int', '')
			Call($mSkillCancel, DllStructGetData($mSkillLogStruct, 1), DllStructGetData($mSkillLogStruct, 2), DllStructGetData($mSkillLogStruct, 3))
		Case 0x3
			DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $wparam, 'ptr', $mSkillLogStructPtr, 'int', 16, 'int', '')
			Call($mSkillComplete, DllStructGetData($mSkillLogStruct, 1), DllStructGetData($mSkillLogStruct, 2), DllStructGetData($mSkillLogStruct, 3))
		Case 0x4
			DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $wparam, 'ptr', $mChatLogStructPtr, 'int', 512, 'int', '')
			Local $lMessage = DllStructGetData($mChatLogStruct, 2)
			Local $lChannel
			Local $lSender
			Switch DllStructGetData($mChatLogStruct, 1)
				Case 0
					$lChannel = "Alliance"
					$lSender = StringMid($lMessage, 6, StringInStr($lMessage, "</a>") - 6)
					$lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
				Case 3
					$lChannel = "All"
					$lSender = StringMid($lMessage, 6, StringInStr($lMessage, "</a>") - 6)
					$lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
				Case 9
					$lChannel = "Guild"
					$lSender = StringMid($lMessage, 6, StringInStr($lMessage, "</a>") - 6)
					$lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
				Case 11
					$lChannel = "Team"
					$lSender = StringMid($lMessage, 6, StringInStr($lMessage, "</a>") - 6)
					$lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
				Case 12
					$lChannel = "Trade"
					$lSender = StringMid($lMessage, 6, StringInStr($lMessage, "</a>") - 6)
					$lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
				Case 10
					If StringLeft($lMessage, 3) == "-> " Then
						$lChannel = "Sent"
						$lSender = StringMid($lMessage, 10, StringInStr($lMessage, "</a>") - 10)
						$lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
					Else
						$lChannel = "Global"
						$lSender = "Guild Wars"
					EndIf
				Case 13
					$lChannel = "Advisory"
					$lSender = "Guild Wars"
					$lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
				Case 14
					$lChannel = "Whisper"
					$lSender = StringMid($lMessage, 7, StringInStr($lMessage, "</a>") - 7)
					$lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
				Case Else
					$lChannel = "Other"
					$lSender = "Other"
			EndSwitch
			Call($mChatReceive, $lChannel, $lSender, $lMessage)
		Case 0x5
			Call($mLoadFinished)
	EndSwitch
EndFunc   ;==>Event
#EndRegion Callback

#Region Modification
;~ Description: Internal use only.
Func ModifyMemory()
	$mASMSize = 0
	$mASMCodeOffset = 0
	$mASMString = ''

	CreateData()
	CreateMain()
	CreateTargetLog()
	CreateSkillLog()
	CreateSkillCancelLog()
	CreateSkillCompleteLog()
	CreateChatLog()
	CreateTraderHook()
	CreateLoadFinished()
	CreateStringLog()
	CreateStringFilter1()
	CreateStringFilter2()
	CreateRenderingMod()
	CreateCommands()

	Local $lModMemory = MemoryRead(MemoryRead($mBase), 'ptr')

	If $lModMemory = 0 Then
		$mMemory = DllCall($mKernelHandle, 'ptr', 'VirtualAllocEx', 'handle', $mGWProcHandle, 'ptr', 0, 'ulong_ptr', $mASMSize, 'dword', 0x1000, 'dword', 0x40)
		$mMemory = $mMemory[0]
		MemoryWrite(MemoryRead($mBase), $mMemory)
	Else
		$mMemory = $lModMemory
	EndIf

	CompleteASMCode()

	If $lModMemory = 0 Then
		WriteBinary($mASMString, $mMemory + $mASMCodeOffset)

		WriteBinary("83F8009090", GetValue('ClickToMoveFix'))
		MemoryWrite(GetValue('QueuePtr'), GetValue('QueueBase'))
		MemoryWrite(GetValue('SkillLogPtr'), GetValue('SkillLogBase'))
		MemoryWrite(GetValue('ChatLogPtr'), GetValue('ChatLogBase'))
		MemoryWrite(GetValue('StringLogPtr'), GetValue('StringLogBase'))
	EndIf

	WriteDetour('MainStart', 'MainProc')
	WriteDetour('TargetLogStart', 'TargetLogProc')
	WriteDetour('TraderHookStart', 'TraderHookProc')
	WriteDetour('LoadFinishedStart', 'LoadFinishedProc')
	WriteDetour('RenderingMod', 'RenderingModProc')
	WriteDetour('StringLogStart', 'StringLogProc')
	WriteDetour('StringFilter1Start', 'StringFilter1Proc')
	WriteDetour('StringFilter2Start', 'StringFilter2Proc')
EndFunc   ;==>ModifyMemory

;~ Description: Internal use only.
Func WriteDetour($aFrom, $aTo)
	WriteBinary('E9' & SwapEndian(Hex(GetLabelInfo($aTo) - GetLabelInfo($aFrom) - 5)), GetLabelInfo($aFrom))
EndFunc   ;==>WriteDetour

;~ Description: Internal use only.
Func CreateData()
	_('CallbackHandle/4')
	_('QueueCounter/4')
	_('SkillLogCounter/4')
	_('ChatLogCounter/4')
	_('ChatLogLastMsg/4')
	_('MapIsLoaded/4')
	_('NextStringType/4')
	_('EnsureEnglish/4')
	_('TraderQuoteID/4')
	_('TraderCostID/4')
	_('TraderCostValue/4')
	_('DisableRendering/4')
	_('QueueBase/' & 256 * GetValue('QueueSize'))
	_('TargetLogBase/' & 4 * GetValue('TargetLogSize'))
	_('SkillLogBase/' & 16 * GetValue('SkillLogSize'))
	_('StringLogBase/' & 256 * GetValue('StringLogSize'))
	_('ChatLogBase/' & 512 * GetValue('ChatLogSize'))
	_('AgentCopyCount/4')
	_('AgentCopyBase/' & 0x1C0 * 256)
EndFunc   ;==>CreateData

;~ Description: Internal use only.
Func CreateMain()
	_('MainProc:')
	_('pushad')
	_('mov eax,dword[EnsureEnglish]')
	_('test eax,eax')
	_('jz MainMain')

	_('mov ecx,dword[BasePointer]')
	_('mov ecx,dword[ecx+18]')
	_('mov ecx,dword[ecx+18]')
	_('mov ecx,dword[ecx+194]')
	_('mov al,byte[ecx+4f]')
	_('cmp al,f')
	_('ja MainMain')
	_('mov ecx,dword[ecx+4c]')
	_('mov al,byte[ecx+3f]')
	_('cmp al,f')
	_('ja MainMain')
	_('mov eax,dword[ecx+40]')
	_('test eax,eax')
	_('jz MainMain')

	_('mov ecx,dword[ActionBase]')
	_('mov ecx,dword[ecx+170]')
	_('mov ecx,dword[ecx+20]')
	_('mov ecx,dword[ecx]')
	_('push 0')
	_('push 0')
	_('push bb')
	_('mov edx,esp')
	_('push 0')
	_('push edx')
	_('push 18')
	_('call ActionFunction')
	_('pop eax')
	_('pop ebx')
	_('pop ecx')

	_('MainMain:')
	_('mov eax,dword[QueueCounter]')
	_('mov ecx,eax')
	_('shl eax,8')
	_('add eax,QueueBase')
	_('mov ebx,dword[eax]')
	_('test ebx,ebx')
	_('jz MainExit')

	_('push ecx')
	_('mov dword[eax],0')
	_('jmp ebx')

	_('CommandReturn:')
	_('pop eax')
	_('inc eax')
	_('cmp eax,QueueSize')
	_('jnz MainSkipReset')
	_('xor eax,eax')
	_('MainSkipReset:')
	_('mov dword[QueueCounter],eax')

	_('MainExit:')
	_('popad')
	_('mov ebp,esp')
	_('sub esp,14')
	_('ljmp MainReturn')
EndFunc   ;==>CreateMain

;~ Description: Internal use only.
Func CreateTargetLog()
	_('TargetLogProc:')
	_('cmp ecx,4')
	_('jz TargetLogMain')
	_('cmp ecx,32')
	_('jz TargetLogMain')
	_('cmp ecx,3C')
	_('jz TargetLogMain')
	_('jmp TargetLogExit')

	_('TargetLogMain:')
	_('pushad')
	_('mov ecx,dword[ebp+8]')
	_('test ecx,ecx')
	_('jnz TargetLogStore')
	_('mov ecx,edx')

	_('TargetLogStore:')
	_('lea eax,dword[edx*4+TargetLogBase]')
	_('mov dword[eax],ecx')
	_('popad')

	_('TargetLogExit:')
	_('push ebx')
	_('push esi')
	_('push edi')
	_('mov edi,edx')
	_('ljmp TargetLogReturn')
EndFunc   ;==>CreateTargetLog

;~ Description: Internal use only.
Func CreateSkillLog()
	_('SkillLogProc:')
	_('pushad')

	_('mov eax,dword[SkillLogCounter]')
	_('push eax')
	_('shl eax,4')
	_('add eax,SkillLogBase')

	_('mov ecx,dword[edi]')
	_('mov dword[eax],ecx')
	_('mov ecx,dword[ecx*4+TargetLogBase]')
	_('mov dword[eax+4],ecx')
	_('mov ecx,dword[edi+4]')
	_('mov dword[eax+8],ecx')
	_('mov ecx,dword[edi+8]')
	_('mov dword[eax+c],ecx')

	_('push 1')
	_('push eax')
	_('push CallbackEvent')
	_('push dword[CallbackHandle]')
	_('call dword[PostMessage]')

	_('pop eax')
	_('inc eax')
	_('cmp eax,SkillLogSize')
	_('jnz SkillLogSkipReset')
	_('xor eax,eax')
	_('SkillLogSkipReset:')
	_('mov dword[SkillLogCounter],eax')

	_('popad')
	_('inc eax')
	_('mov dword[esi+10],eax')
	_('pop esi')
	_('ljmp SkillLogReturn')
EndFunc   ;==>CreateSkillLog

;~ Description: Internal use only.
Func CreateSkillCancelLog()
	_('SkillCancelLogProc:')
	_('pushad')

	_('mov eax,dword[SkillLogCounter]')
	_('push eax')
	_('shl eax,4')
	_('add eax,SkillLogBase')

	_('mov ecx,dword[edi]')
	_('mov dword[eax],ecx')
	_('mov ecx,dword[ecx*4+TargetLogBase]')
	_('mov dword[eax+4],ecx')
	_('mov ecx,dword[edi+4]')
	_('mov dword[eax+8],ecx')

	_('push 2')
	_('push eax')
	_('push CallbackEvent')
	_('push dword[CallbackHandle]')
	_('call dword[PostMessage]')

	_('pop eax')
	_('inc eax')
	_('cmp eax,SkillLogSize')
	_('jnz SkillCancelLogSkipReset')
	_('xor eax,eax')
	_('SkillCancelLogSkipReset:')
	_('mov dword[SkillLogCounter],eax')

	_('popad')
	_('push 0')
	_('push 42')
	_('mov ecx,esi')
	_('ljmp SkillCancelLogReturn')
EndFunc   ;==>CreateSkillCancelLog

;~ Description: Internal use only.
Func CreateSkillCompleteLog()
	_('SkillCompleteLogProc:')
	_('pushad')

	_('mov eax,dword[SkillLogCounter]')
	_('push eax')
	_('shl eax,4')
	_('add eax,SkillLogBase')

	_('mov ecx,dword[edi]')
	_('mov dword[eax],ecx')
	_('mov ecx,dword[ecx*4+TargetLogBase]')
	_('mov dword[eax+4],ecx')
	_('mov ecx,dword[edi+4]')
	_('mov dword[eax+8],ecx')

	_('push 3')
	_('push eax')
	_('push CallbackEvent')
	_('push dword[CallbackHandle]')
	_('call dword[PostMessage]')

	_('pop eax')
	_('inc eax')
	_('cmp eax,SkillLogSize')
	_('jnz SkillCompleteLogSkipReset')
	_('xor eax,eax')
	_('SkillCompleteLogSkipReset:')
	_('mov dword[SkillLogCounter],eax')

	_('popad')
	_('mov eax,dword[edi+4]')
	_('test eax,eax')
	_('ljmp SkillCompleteLogReturn')
EndFunc   ;==>CreateSkillCompleteLog

;~ Description: Internal use only.
Func CreateChatLog()
	_('ChatLogProc:')

	_('pushad')
	_('mov ecx,dword[ebx]')
	_('mov ebx,eax')
	_('mov eax,dword[ChatLogCounter]')
	_('push eax')
	_('shl eax,9')
	_('add eax,ChatLogBase')
	_('mov dword[eax],ebx')

	_('mov edi,eax')
	_('add eax,4')
	_('xor ebx,ebx')

	_('ChatLogCopyLoop:')
	_('mov dx,word[ecx]')
	_('mov word[eax],dx')
	_('add ecx,2')
	_('add eax,2')
	_('inc ebx')
	_('cmp ebx,FF')
	_('jz ChatLogCopyExit')
	_('test dx,dx')
	_('jnz ChatLogCopyLoop')

	_('ChatLogCopyExit:')
	_('push 4')
	_('push edi')
	_('push CallbackEvent')
	_('push dword[CallbackHandle]')
	_('call dword[PostMessage]')

	_('pop eax')
	_('inc eax')
	_('cmp eax,ChatLogSize')
	_('jnz ChatLogSkipReset')
	_('xor eax,eax')
	_('ChatLogSkipReset:')
	_('mov dword[ChatLogCounter],eax')
	_('popad')

	_('ChatLogExit:')
	_('add edi,E')
	_('cmp eax,B')
	_('ljmp ChatLogReturn')
EndFunc   ;==>CreateChatLog

;~ Description: Internal use only.
Func CreateTraderHook()
	_('TraderHookProc:')
	_('mov dword[TraderCostID],ecx')
	_('mov dword[TraderCostValue],edx')
	_('push eax')
	_('mov eax,dword[TraderQuoteID]')
	_('inc eax')
	_('cmp eax,200')
	_('jnz TraderSkipReset')
	_('xor eax,eax')
	_('TraderSkipReset:')
	_('mov dword[TraderQuoteID],eax')
	_('pop eax')
	_('mov ebp,esp')
	_('sub esp,8')
	_('ljmp TraderHookReturn')
EndFunc   ;==>CreateTraderHook

;~ Description: Internal use only.
Func CreateLoadFinished()
	_('LoadFinishedProc:')
	_('pushad')

	_('mov eax,1')
	_('mov dword[MapIsLoaded],eax')

	_('xor ebx,ebx')
	_('mov eax,StringLogBase')
	_('LoadClearStringsLoop:')
	_('mov dword[eax],0')
	_('inc ebx')
	_('add eax,80')
	_('cmp ebx,200')
	_('jnz LoadClearStringsLoop')

	_('xor ebx,ebx')
	_('mov eax,TargetLogBase')
	_('LoadClearTargetsLoop:')
	_('mov dword[eax],0')
	_('inc ebx')
	_('add eax,4')
	_('cmp ebx,200')
	_('jnz LoadClearTargetsLoop')

	_('push 5')
	_('push 0')
	_('push CallbackEvent')
	_('push dword[CallbackHandle]')
	_('call dword[PostMessage]')

	_('popad')
	_('mov esp,ebp')
	_('pop ebp')
	_('retn 10')
EndFunc   ;==>CreateLoadFinished

;~ Description: Internal use only.
Func CreateStringLog()
	_('StringLogProc:')
	_('pushad')
	_('mov eax,dword[NextStringType]')
	_('test eax,eax')
	_('jz StringLogExit')

	_('cmp eax,1')
	_('jnz StringLogFilter2')
	_('mov eax,dword[ebp+37c]')
	_('jmp StringLogRangeCheck')

	_('StringLogFilter2:')
	_('cmp eax,2')
	_('jnz StringLogExit')
	_('mov eax,dword[ebp+338]')

	_('StringLogRangeCheck:')
	_('mov dword[NextStringType],0')
	_('cmp eax,0')
	_('jbe StringLogExit')
	_('cmp eax,StringLogSize')
	_('jae StringLogExit')

	_('shl eax,8')
	_('add eax,StringLogBase')

	_('xor ebx,ebx')
	_('StringLogCopyLoop:')
	_('mov dx,word[ecx]')
	_('mov word[eax],dx')
	_('add ecx,2')
	_('add eax,2')
	_('inc ebx')
	_('cmp ebx,80')
	_('jz StringLogExit')
	_('test dx,dx')
	_('jnz StringLogCopyLoop')

	_('StringLogExit:')
	_('popad')
	_('mov esp,ebp')
	_('pop ebp')
	_('retn 10')
EndFunc   ;==>CreateStringLog

;~ Description: Internal use only.
Func CreateStringFilter1()
	_('StringFilter1Proc:')
	_('mov dword[NextStringType],1')

	_('push ebp')
	_('mov ebp,esp')
	_('push ecx')
	_('push esi')
	_('ljmp StringFilter1Return')
EndFunc   ;==>CreateStringFilter1

;~ Description: Internal use only.
Func CreateStringFilter2()
	_('StringFilter2Proc:')
	_('mov dword[NextStringType],2')

	_('push ebp')
	_('mov ebp,esp')
	_('push ecx')
	_('push esi')
	_('ljmp StringFilter2Return')
EndFunc   ;==>CreateStringFilter2

;~ Description: Internal use only.
Func CreateRenderingMod()
	_('RenderingModProc:')
	_('cmp dword[DisableRendering],1')
	_('jz RenderingModSkipCompare')
	_('cmp eax,ebx')
	_('ljne RenderingModReturn')
	_('RenderingModSkipCompare:')
	$mASMSize += 17
	$mASMString &= StringTrimLeft(MemoryRead(getvalue("RenderingMod") + 4, "byte[17]"), 2)

	_('cmp dword[DisableRendering],1')
	_('jz DisableRenderingProc')
	_('retn')

	_('DisableRenderingProc:')
	_('push 1')
	_('call dword[Sleep]')
	_('retn')
EndFunc   ;==>CreateRenderingMod

;~ Description: Internal use only.
Func CreateCommands()
	_('CommandUseSkill:')
	_('mov ecx,dword[MyID]')
	_('mov edx,dword[eax+C]')
	_('push edx')
	_('mov edx,dword[eax+4]')
	_('dec edx')
	_('push dword[eax+8]')
	_('call UseSkillFunction')
	_('ljmp CommandReturn')

	_('CommandMove:')
	_('lea ecx,dword[eax+4]')
	_('call MoveFunction')
	_('ljmp CommandReturn')

	_('CommandChangeTarget:')
	_('mov ecx,dword[eax+4]')
	_('xor edx,edx')
	_('call ChangeTargetFunction')
	_('ljmp CommandReturn')

	_('CommandPacketSend:')
	_('mov ecx,dword[PacketLocation]')
	_('lea edx,dword[eax+8]')
	_('push edx')
	_('mov edx,dword[eax+4]')
	_('mov eax,ecx')
	_('call PacketSendFunction')
	_('ljmp CommandReturn')

	_('CommandWriteChat:')
	_('add eax,4')
	_('mov edx,eax')
	_('xor ecx,ecx')
	_('add eax,28')
	_('push eax')
	_('call WriteChatFunction')
	_('ljmp CommandReturn')

	_('CommandSellItem:')
	_('push 0')
	_('push 0')
	_('push 0')
	_('push dword[eax+4]')
	_('push 0')
	_('add eax,8')
	_('push eax')
	_('push 1')
	_('mov ecx,b')
	_('xor edx,edx')
	_('call SellItemFunction')
	_('ljmp CommandReturn')

	_('CommandBuyItem:')
	_('add eax,4')
	_('push eax')
	_('add eax,4')
	_('push eax')
	_('push 1')
	_('push 0')
	_('push 0')
	_('push 0')
	_('push 0')
	_('mov ecx,1')
	_('mov edx,dword[eax+4]')
	_('call BuyItemFunction')
	_('ljmp CommandReturn')

	_('CommandAction:')
	_('mov ecx,dword[ActionBase]')
	_('mov ecx,dword[ecx+250]')
	_('mov ecx,dword[ecx+10]')
	_('mov ecx,dword[ecx]')
	_('push 0')
	_('push 0')
	_('push dword[eax+4]')
	_('mov edx,esp')
	_('push 0')
	_('push edx')
	_('push dword[eax+8]')
	_('call ActionFunction')
	_('pop eax')
	_('pop ebx')
	_('pop ecx')
	_('ljmp CommandReturn')

	_('CommandToggleLanguage:')
	_('mov ecx,dword[ActionBase]')
	_('mov ecx,dword[ecx+170]')
	_('mov ecx,dword[ecx+20]')
	_('mov ecx,dword[ecx]')
	_('push 0')
	_('push 0')
	_('push bb')
	_('mov edx,esp')
	_('push 0')
	_('push edx')
	_('push dword[eax+4]')
	_('call ActionFunction')
	_('pop eax')
	_('pop ebx')
	_('pop ecx')
	_('ljmp CommandReturn')

	_('CommandUseHeroSkill:')
	_('mov ecx,dword[eax+4]')
	_('mov edx,dword[eax+c]')
	_('mov eax,dword[eax+8]')
	_('push eax')
	_('call UseHeroSkillFunction')
	_('ljmp CommandReturn')

	_('CommandSendChat:')
	_('mov ecx,dword[PacketLocation]')
	_('add eax,4')
	_('push eax')
	_('mov edx,11c')
	_('mov eax,ecx')
	_('call PacketSendFunction')
	_('ljmp CommandReturn')

	_('CommandRequestQuote:')
	_('mov dword[TraderCostID],0')
	_('mov dword[TraderCostValue],0')
	_('add eax,4')
	_('push eax')
	_('push 1')
	_('push 0')
	_('push 0')
	_('push 0')
	_('push 0')
	_('mov ecx,c')
	_('xor edx,edx')
	_('call RequestQuoteFunction')
	_('ljmp CommandReturn')

	_('CommandRequestQuoteSell:')
	_('mov dword[TraderCostID],0')
	_('mov dword[TraderCostValue],0')
	_('push 0')
	_('push 0')
	_('push 0')
	_('add eax,4')
	_('push eax')
	_('push 1')
	_('push 0')
	_('mov ecx,d')
	_('xor edx,edx')
	_('call RequestQuoteFunction')
	_('ljmp CommandReturn')

	_('CommandTraderBuy:')
	_('push 0')
	_('push TraderCostID')
	_('push 1')
	_('push 0')
	_('push 0')
	_('push 0')
	_('push 0')
	_('mov ecx,c')
	_('mov edx,dword[TraderCostValue]')
	_('call TraderFunction')
	_('mov dword[TraderCostID],0')
	_('mov dword[TraderCostValue],0')
	_('ljmp CommandReturn')

	_('CommandTraderSell:')
	_('push 0')
	_('push 0')
	_('push 0')
	_('push dword[TraderCostValue]')
	_('push 0')
	_('push TraderCostID')
	_('push 1')
	_('mov ecx,d')
	_('xor edx,edx')
	_('call TraderFunction')
	_('mov dword[TraderCostID],0')
	_('mov dword[TraderCostValue],0')
	_('ljmp CommandReturn')

	_('CommandSalvage:')
	_('mov ebx,SalvageGlobal')
	_('mov ecx,dword[eax+4]')
	_('mov dword[ebx],ecx')
	_('push ecx')
	_('mov ecx,dword[eax+8]')
	_('add ebx,4')
	_('mov dword[ebx],ecx')
	_('mov edx,dword[eax+c]')
	_('mov dword[ebx],ecx')
	_('call SalvageFunction')
	_('ljmp CommandReturn')

	_('CommandMakeAgentArray:')
	_('mov eax,dword[eax+4]')
	_('xor ebx,ebx')
	_('xor edx,edx')
	_('mov edi,AgentCopyBase')

	_('AgentCopyLoopStart:')
	_('inc ebx')
	_('cmp ebx,dword[MaxAgents]')
	_('jge AgentCopyLoopExit')

	_('mov esi,dword[AgentBase]')
	_('lea esi,dword[esi+ebx*4]')
	_('mov esi,dword[esi]')
	_('test esi,esi')
	_('jz AgentCopyLoopStart')

	_('cmp eax,0')
	_('jz CopyAgent')
	_('cmp eax,dword[esi+9C]')
	_('jnz AgentCopyLoopStart')

	_('CopyAgent:')
	_('mov ecx,1C0')
	_('clc')
	_('repe movsb')
	_('inc edx')
	_('jmp AgentCopyLoopStart')

	_('AgentCopyLoopExit:')
	_('mov dword[AgentCopyCount],edx')
	_('ljmp CommandReturn')

	_('CommandChangeStatus:')
	_('mov ecx,dword[eax+4]')
	_('call ChangeStatusFunction')
	_('ljmp CommandReturn')
EndFunc   ;==>CreateCommands
#EndRegion Modification

#Region Assembler
;~ Description: Internal use only.
Func _($aASM)
	;quick and dirty x86assembler unit:
	;relative values stringregexp
	;static values hardcoded
	Local $lBuffer
	Select
		Case StringRight($aASM, 1) = ':'
			SetValue('Label_' & StringLeft($aASM, StringLen($aASM) - 1), $mASMSize)
		Case StringInStr($aASM, '/') > 0
			SetValue('Label_' & StringLeft($aASM, StringInStr($aASM, '/') - 1), $mASMSize)
			Local $lOffset = StringRight($aASM, StringLen($aASM) - StringInStr($aASM, '/'))
			$mASMSize += $lOffset
			$mASMCodeOffset += $lOffset
		Case StringLeft($aASM, 5) = 'nop x'
			$lBuffer = Int(Number(StringTrimLeft($aASM, 5)))
			$mASMSize += $lBuffer
			For $i = 1 To $lBuffer
				$mASMString &= '90'
			Next
		Case StringLeft($aASM, 5) = 'ljmp '
			$mASMSize += 5
			$mASMString &= 'E9{' & StringRight($aASM, StringLen($aASM) - 5) & '}'
		Case StringLeft($aASM, 5) = 'ljne '
			$mASMSize += 6
			$mASMString &= '0F85{' & StringRight($aASM, StringLen($aASM) - 5) & '}'
		Case StringLeft($aASM, 4) = 'jmp ' And StringLen($aASM) > 7
			$mASMSize += 2
			$mASMString &= 'EB(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
		Case StringLeft($aASM, 4) = 'jae '
			$mASMSize += 2
			$mASMString &= '73(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
		Case StringLeft($aASM, 3) = 'jz '
			$mASMSize += 2
			$mASMString &= '74(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
		Case StringLeft($aASM, 4) = 'jnz '
			$mASMSize += 2
			$mASMString &= '75(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
		Case StringLeft($aASM, 4) = 'jbe '
			$mASMSize += 2
			$mASMString &= '76(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
		Case StringLeft($aASM, 3) = 'ja '
			$mASMSize += 2
			$mASMString &= '77(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
		Case StringLeft($aASM, 3) = 'jl '
			$mASMSize += 2
			$mASMString &= '7C(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
		Case StringLeft($aASM, 4) = 'jge '
			$mASMSize += 2
			$mASMString &= '7D(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
		Case StringLeft($aASM, 4) = 'jle '
			$mASMSize += 2
			$mASMString &= '7E(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
		Case StringRegExp($aASM, 'mov eax,dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 5
			$mASMString &= 'A1[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'mov ebx,dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= '8B1D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'mov ecx,dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= '8B0D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'mov edx,dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= '8B15[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'mov esi,dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= '8B35[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'mov edi,dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= '8B3D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'cmp ebx,dword\[[a-z,A-Z]{4,}\]')
			$mASMSize += 6
			$mASMString &= '3B1D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'lea eax,dword[[]ecx[*]8[+][a-z,A-Z]{4,}[]]')
			$mASMSize += 7
			$mASMString &= '8D04CD[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
		Case StringRegExp($aASM, 'lea edi,dword\[edx\+[a-z,A-Z]{4,}\]')
			$mASMSize += 7
			$mASMString &= '8D3C15[' & StringMid($aASM, 19, StringLen($aASM) - 19) & ']'
		Case StringRegExp($aASM, 'cmp dword[[][a-z,A-Z]{4,}[]],[-[:xdigit:]]')
			$lBuffer = StringInStr($aASM, ",")
			$lBuffer = ASMNumber(StringMid($aASM, $lBuffer + 1), True)
			If @extended Then
				$mASMSize += 7
				$mASMString &= '833D[' & StringMid($aASM, 11, StringInStr($aASM, ",") - 12) & ']' & $lBuffer
			Else
				$mASMSize += 10
				$mASMString &= '813D[' & StringMid($aASM, 11, StringInStr($aASM, ",") - 12) & ']' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'cmp ecx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 6
			$mASMString &= '81F9[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'cmp ebx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 6
			$mASMString &= '81FB[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'cmp eax,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= '3D[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'add eax,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= '05[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov eax,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= 'B8[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov ebx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= 'BB[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov esi,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= 'BE[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov edi,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= 'BF[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov edx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= 'BA[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],ecx')
			$mASMSize += 6
			$mASMString &= '890D[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'fstp dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= 'D91D[' & StringMid($aASM, 12, StringLen($aASM) - 12) & ']'
		Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],edx')
			$mASMSize += 6
			$mASMString &= '8915[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],eax')
			$mASMSize += 5
			$mASMString &= 'A3[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'lea eax,dword[[]edx[*]4[+][a-z,A-Z]{4,}[]]')
			$mASMSize += 7
			$mASMString &= '8D0495[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
		Case StringRegExp($aASM, 'mov eax,dword[[]ecx[*]4[+][a-z,A-Z]{4,}[]]')
			$mASMSize += 7
			$mASMString &= '8B048D[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
		Case StringRegExp($aASM, 'mov ecx,dword[[]ecx[*]4[+][a-z,A-Z]{4,}[]]')
			$mASMSize += 7
			$mASMString &= '8B0C8D[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
		Case StringRegExp($aASM, 'push dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= 'FF35[' & StringMid($aASM, 12, StringLen($aASM) - 12) & ']'
		Case StringRegExp($aASM, 'push [a-z,A-Z]{4,}\z')
			$mASMSize += 5
			$mASMString &= '68[' & StringMid($aASM, 6, StringLen($aASM) - 5) & ']'
		Case StringRegExp($aASM, 'call dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= 'FF15[' & StringMid($aASM, 12, StringLen($aASM) - 12) & ']'
		Case StringLeft($aASM, 5) = 'call ' And StringLen($aASM) > 8
			$mASMSize += 5
			$mASMString &= 'E8{' & StringMid($aASM, 6, StringLen($aASM) - 5) & '}'
		Case StringRegExp($aASM, 'mov dword\[[a-z,A-Z]{4,}\],[-[:xdigit:]]{1,8}\z')
			$lBuffer = StringInStr($aASM, ",")
			$mASMSize += 10
			$mASMString &= 'C705[' & StringMid($aASM, 11, $lBuffer - 12) & ']' & ASMNumber(StringMid($aASM, $lBuffer + 1))
		Case StringRegExp($aASM, 'push [-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 6), True)
			If @extended Then
				$mASMSize += 2
				$mASMString &= '6A' & $lBuffer
			Else
				$mASMSize += 5
				$mASMString &= '68' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'mov eax,[-[:xdigit:]]{1,8}\z')
			$mASMSize += 5
			$mASMString &= 'B8' & ASMNumber(StringMid($aASM, 9))
		Case StringRegExp($aASM, 'mov ebx,[-[:xdigit:]]{1,8}\z')
			$mASMSize += 5
			$mASMString &= 'BB' & ASMNumber(StringMid($aASM, 9))
		Case StringRegExp($aASM, 'mov ecx,[-[:xdigit:]]{1,8}\z')
			$mASMSize += 5
			$mASMString &= 'B9' & ASMNumber(StringMid($aASM, 9))
		Case StringRegExp($aASM, 'mov edx,[-[:xdigit:]]{1,8}\z')
			$mASMSize += 5
			$mASMString &= 'BA' & ASMNumber(StringMid($aASM, 9))
		Case StringRegExp($aASM, 'add eax,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83C0' & $lBuffer
			Else
				$mASMSize += 5
				$mASMString &= '05' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'add ebx,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83C3' & $lBuffer
			Else
				$mASMSize += 6
				$mASMString &= '81C3' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'add ecx,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83C1' & $lBuffer
			Else
				$mASMSize += 6
				$mASMString &= '81C1' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'add edx,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83C2' & $lBuffer
			Else
				$mASMSize += 6
				$mASMString &= '81C2' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'add edi,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83C7' & $lBuffer
			Else
				$mASMSize += 6
				$mASMString &= '81C7' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'cmp ebx,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83FB' & $lBuffer
			Else
				$mASMSize += 6
				$mASMString &= '81FB' & $lBuffer
			EndIf
		Case Else
			Local $lOpCode
			Switch $aASM
				Case 'nop'
					$lOpCode = '90'
				Case 'pushad'
					$lOpCode = '60'
				Case 'popad'
					$lOpCode = '61'
				Case 'mov ebx,dword[eax]'
					$lOpCode = '8B18'
				Case 'test eax,eax'
					$lOpCode = '85C0'
				Case 'test ebx,ebx'
					$lOpCode = '85DB'
				Case 'test ecx,ecx'
					$lOpCode = '85C9'
				Case 'mov dword[eax],0'
					$lOpCode = 'C70000000000'
				Case 'push eax'
					$lOpCode = '50'
				Case 'push ebx'
					$lOpCode = '53'
				Case 'push ecx'
					$lOpCode = '51'
				Case 'push edx'
					$lOpCode = '52'
				Case 'push ebp'
					$lOpCode = '55'
				Case 'push esi'
					$lOpCode = '56'
				Case 'push edi'
					$lOpCode = '57'
				Case 'jmp ebx'
					$lOpCode = 'FFE3'
				Case 'pop eax'
					$lOpCode = '58'
				Case 'pop ebx'
					$lOpCode = '5B'
				Case 'pop edx'
					$lOpCode = '5A'
				Case 'pop ecx'
					$lOpCode = '59'
				Case 'pop esi'
					$lOpCode = '5E'
				Case 'inc eax'
					$lOpCode = '40'
				Case 'inc ecx'
					$lOpCode = '41'
				Case 'inc ebx'
					$lOpCode = '43'
				Case 'dec edx'
					$lOpCode = '4A'
				Case 'mov edi,edx'
					$lOpCode = '8BFA'
				Case 'mov ecx,esi'
					$lOpCode = '8BCE'
				Case 'mov ecx,edi'
					$lOpCode = '8BCF'
				Case 'xor eax,eax'
					$lOpCode = '33C0'
				Case 'xor ecx,ecx'
					$lOpCode = '33C9'
				Case 'xor edx,edx'
					$lOpCode = '33D2'
				Case 'xor ebx,ebx'
					$lOpCode = '33DB'
				Case 'mov edx,eax'
					$lOpCode = '8BD0'
				Case 'mov ebp,esp'
					$lOpCode = '8BEC'
				Case 'sub esp,8'
					$lOpCode = '83EC08'
				Case 'sub esp,14'
					$lOpCode = '83EC14'
				Case 'cmp ecx,4'
					$lOpCode = '83F904'
				Case 'cmp ecx,32'
					$lOpCode = '83F932'
				Case 'cmp ecx,3C'
					$lOpCode = '83F93C'
				Case 'mov ecx,edx'
					$lOpCode = '8BCA'
				Case 'mov eax,ecx'
					$lOpCode = '8BC1'
				Case 'mov ecx,dword[ebp+8]'
					$lOpCode = '8B4D08'
				Case 'mov ecx,dword[esp+1F4]'
					$lOpCode = '8B8C24F4010000'
				Case 'mov ecx,dword[edi+4]'
					$lOpCode = '8B4F04'
				Case 'mov ecx,dword[edi+8]'
					$lOpCode = '8B4F08'
				Case 'mov eax,dword[edi+4]'
					$lOpCode = '8B4704'
				Case 'mov dword[eax+4],ecx'
					$lOpCode = '894804'
				Case 'mov dword[eax+8],ecx'
					$lOpCode = '894808'
				Case 'mov dword[eax+C],ecx'
					$lOpCode = '89480C'
				Case 'mov dword[esi+10],eax'
					$lOpCode = '894610'
				Case 'mov ecx,dword[edi]'
					$lOpCode = '8B0F'
				Case 'mov dword[eax],ecx'
					$lOpCode = '8908'
				Case 'mov dword[eax],ebx'
					$lOpCode = '8918'
				Case 'mov edx,dword[eax+4]'
					$lOpCode = '8B5004'
				Case 'mov edx,dword[eax+c]'
					$lOpCode = '8B500C'
				Case 'mov edx,dword[esi+1c]'
					$lOpCode = '8B561C'
				Case 'push dword[eax+8]'
					$lOpCode = 'FF7008'
				Case 'lea eax,dword[eax+18]'
					$lOpCode = '8D4018'
				Case 'lea ecx,dword[eax+4]'
					$lOpCode = '8D4804'
				Case 'lea edx,dword[eax+4]'
					$lOpCode = '8D5004'
				Case 'lea edx,dword[eax+8]'
					$lOpCode = '8D5008'
				Case 'mov ecx,dword[eax+4]'
					$lOpCode = '8B4804'
				Case 'mov ecx,dword[eax+8]'
					$lOpCode = '8B4808'
				Case 'mov eax,dword[eax+8]'
					$lOpCode = '8B4008'
				Case 'mov eax,dword[eax+4]'
					$lOpCode = '8B4004'
				Case 'push dword[eax+4]'
					$lOpCode = 'FF7004'
				Case 'push dword[eax+c]'
					$lOpCode = 'FF700C'
				Case 'mov esp,ebp'
					$lOpCode = '8BE5'
				Case 'mov esp,ebp'
					$lOpCode = '8BE5'
				Case 'pop ebp'
					$lOpCode = '5D'
				Case 'retn 10'
					$lOpCode = 'C21000'
				Case 'cmp eax,2'
					$lOpCode = '83F802'
				Case 'cmp eax,0'
					$lOpCode = '83F800'
				Case 'cmp eax,B'
					$lOpCode = '83F80B'
				Case 'cmp eax,200'
					$lOpCode = '3D00020000'
				Case 'shl eax,4'
					$lOpCode = 'C1E004'
				Case 'shl eax,8'
					$lOpCode = 'C1E008'
				Case 'shl eax,6'
					$lOpCode = 'C1E006'
				Case 'shl eax,7'
					$lOpCode = 'C1E007'
				Case 'shl eax,8'
					$lOpCode = 'C1E008'
				Case 'shl eax,9'
					$lOpCode = 'C1E009'
				Case 'mov edi,eax'
					$lOpCode = '8BF8'
				Case 'mov dx,word[ecx]'
					$lOpCode = '668B11'
				Case 'mov dx,word[edx]'
					$lOpCode = '668B12'
				Case 'mov word[eax],dx'
					$lOpCode = '668910'
				Case 'test dx,dx'
					$lOpCode = '6685D2'
				Case 'cmp word[edx],0'
					$lOpCode = '66833A00'
				Case 'cmp eax,ebx'
					$lOpCode = '3BC3'
				Case 'cmp eax,ecx'
					$lOpCode = '3BC1'
				Case 'mov eax,dword[esi+8]'
					$lOpCode = '8B4608'
				Case 'mov ecx,dword[eax]'
					$lOpCode = '8B08'
				Case 'mov ebx,edi'
					$lOpCode = '8BDF'
				Case 'mov ebx,eax'
					$lOpCode = '8BD8'
				Case 'mov eax,edi'
					$lOpCode = '8BC7'
				Case 'mov al,byte[ebx]'
					$lOpCode = '8A03'
				Case 'test al,al'
					$lOpCode = '84C0'
				Case 'mov eax,dword[ecx]'
					$lOpCode = '8B01'
				Case 'lea ecx,dword[eax+180]'
					$lOpCode = '8D8880010000'
				Case 'mov ebx,dword[ecx+14]'
					$lOpCode = '8B5914'
				Case 'mov eax,dword[ebx+c]'
					$lOpCode = '8B430C'
				Case 'mov ecx,eax'
					$lOpCode = '8BC8'
				Case 'cmp eax,-1'
					$lOpCode = '83F8FF'
				Case 'mov al,byte[ecx]'
					$lOpCode = '8A01'
				Case 'mov ebx,dword[edx]'
					$lOpCode = '8B1A'
				Case 'lea edi,dword[edx+ebx]'
					$lOpCode = '8D3C1A'
				Case 'mov ah,byte[edi]'
					$lOpCode = '8A27'
				Case 'cmp al,ah'
					$lOpCode = '3AC4'
				Case 'mov dword[edx],0'
					$lOpCode = 'C70200000000'
				Case 'mov dword[ebx],ecx'
					$lOpCode = '890B'
				Case 'cmp edx,esi'
					$lOpCode = '3BD6'
				Case 'cmp ecx,900000'
					$lOpCode = '81F900009000'
				Case 'mov edi,dword[edx+4]'
					$lOpCode = '8B7A04'
				Case 'cmp ebx,edi'
					$lOpCode = '3BDF'
				Case 'mov dword[edx],ebx'
					$lOpCode = '891A'
				Case 'lea edi,dword[edx+8]'
					$lOpCode = '8D7A08'
				Case 'mov dword[edi],ecx'
					$lOpCode = '890F'
				Case 'retn'
					$lOpCode = 'C3'
				Case 'mov dword[edx],-1'
					$lOpCode = 'C702FFFFFFFF'
				Case 'cmp eax,1'
					$lOpCode = '83F801'
				Case 'mov eax,dword[ebp+37c]'
					$lOpCode = '8B857C030000'
				Case 'mov eax,dword[ebp+338]'
					$lOpCode = '8B8538030000'
				Case 'mov ecx,dword[ebx+250]'
					$lOpCode = '8B8B50020000'
				Case 'mov ecx,dword[ebx+194]'
					$lOpCode = '8B8B94010000'
				Case 'mov ecx,dword[ebx+18]'
					$lOpCode = '8B5918'
				Case 'mov ecx,dword[ebx+40]'
					$lOpCode = '8B5940'
				Case 'mov ebx,dword[ecx+10]'
					$lOpCode = '8B5910'
				Case 'mov ebx,dword[ecx+18]'
					$lOpCode = '8B5918'
				Case 'mov ebx,dword[ecx+4c]'
					$lOpCode = '8B594C'
				Case 'mov ecx,dword[ebx]'
					$lOpCode = '8B0B'
				Case 'mov edx,esp'
					$lOpCode = '8BD4'
				Case 'mov ecx,dword[ebx+170]'
					$lOpCode = '8B8B70010000'
				Case 'cmp eax,dword[esi+9C]'
					$lOpCode = '3B869C000000'
				Case 'mov ebx,dword[ecx+20]'
					$lOpCode = '8B5920'
				Case 'mov ecx,dword[ecx]'
					$lOpCode = '8B09'
				Case 'mov eax,dword[ecx+40]'
					$lOpCode = '8B4140'
				Case 'mov ecx,dword[ecx+10]'
					$lOpCode = '8B4910'
				Case 'mov ecx,dword[ecx+18]'
					$lOpCode = '8B4918'
				Case 'mov ecx,dword[ecx+20]'
					$lOpCode = '8B4920'
				Case 'mov ecx,dword[ecx+4c]'
					$lOpCode = '8B494C'
				Case 'mov ecx,dword[ecx+170]'
					$lOpCode = '8B8970010000'
				Case 'mov ecx,dword[ecx+194]'
					$lOpCode = '8B8994010000'
				Case 'mov ecx,dword[ecx+250]'
					$lOpCode = '8B8950020000'
				Case 'mov al,byte[ecx+4f]'
					$lOpCode = '8A414F'
				Case 'mov al,byte[ecx+3f]'
					$lOpCode = '8A413F'
				Case 'cmp al,f'
					$lOpCode = '3C0F'
				Case 'lea esi,dword[esi+ebx*4]'
					$lOpCode = '8D349E'
				Case 'mov esi,dword[esi]'
					$lOpCode = '8B36'
				Case 'test esi,esi'
					$lOpCode = '85F6'
				Case 'clc'
					$lOpCode = 'F8'
				Case 'repe movsb'
					$lOpCode = 'F3A4'
				Case 'inc edx'
					$lOpCode = '42'
				Case Else
					MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
					Exit
			EndSwitch
			$mASMSize += 0.5 * StringLen($lOpCode)
			$mASMString &= $lOpCode
	EndSelect
EndFunc   ;==>_

;~ Description: Internal use only.
Func CompleteASMCode()
	Local $lInExpression = False
	Local $lExpression
	Local $lTempASM = $mASMString
	Local $lCurrentOffset = Dec(Hex($mMemory)) + $mASMCodeOffset
	Local $lToken

	For $i = 1 To $mLabels[0][0]
		If StringLeft($mLabels[$i][0], 6) = 'Label_' Then
			$mLabels[$i][0] = StringTrimLeft($mLabels[$i][0], 6)
			$mLabels[$i][1] = $mMemory + $mLabels[$i][1]
		EndIf
	Next

	$mASMString = ''
	For $i = 1 To StringLen($lTempASM)
		$lToken = StringMid($lTempASM, $i, 1)
		Switch $lToken
			Case '(', '[', '{'
				$lInExpression = True
			Case ')'
				$mASMString &= Hex(GetLabelInfo($lExpression) - Int($lCurrentOffset) - 1, 2)
				$lCurrentOffset += 1
				$lInExpression = False
				$lExpression = ''
			Case ']'
				$mASMString &= SwapEndian(Hex(GetLabelInfo($lExpression), 8))
				$lCurrentOffset += 4
				$lInExpression = False
				$lExpression = ''
			Case '}'
				$mASMString &= SwapEndian(Hex(GetLabelInfo($lExpression) - Int($lCurrentOffset) - 4, 8))
				$lCurrentOffset += 4
				$lInExpression = False
				$lExpression = ''
			Case Else
				If $lInExpression Then
					$lExpression &= $lToken
				Else
					$mASMString &= $lToken
					$lCurrentOffset += 0.5
				EndIf
		EndSwitch
	Next
EndFunc   ;==>CompleteASMCode

;~ Description: Internal use only.
Func GetLabelInfo($aLabel)
	Local $lValue = GetValue($aLabel)
	If $lValue = -1 Then Exit MsgBox(0, 'Label', 'Label: ' & $aLabel & ' not provided')
	Return $lValue ;Dec(StringRight($lValue, 8))
EndFunc   ;==>GetLabelInfo

;~ Description: Internal use only.
Func ASMNumber($aNumber, $aSmall = False)
	If $aNumber >= 0 Then
		$aNumber = Dec($aNumber)
	EndIf
	If $aSmall And $aNumber <= 127 And $aNumber >= -128 Then
		Return SetExtended(1, Hex($aNumber, 2))
	Else
		Return SetExtended(0, SwapEndian(Hex($aNumber, 8)))
	EndIf
EndFunc   ;==>ASMNumber
#EndRegion Assembler
#EndRegion Other Functions

#Region All Skill IDs, Global Variables
; SKILL TYPES
Global $Stance = 3;
Global $Hex = 4;
Global $Spell = 5;
Global $Enchantment = 6;
Global $Signet = 7;
Global $Condition = 8;
Global $Well = 9;
Global $Skill = 10;
Global $Ward = 11;
Global $Glyph = 12;
Global $Attack = 14;
Global $Shout = 15;
Global $Preparation = 19;
Global $Trap = 21;
Global $Ritual = 22;
Global $ItemSpell = 24;
Global $WeaponSpell = 25;
Global $Chant = 27;
Global $EchoRefrain = 28;
Global $Disguise = 29;

; PROFESSIONS
Global $None = 0
Global $Warrior = 1
Global $Ranger = 2
Global $Monk = 3
Global $Necromancer = 4
Global $Mesmer = 5
Global $Elementalist = 6
Global $Assassin = 7
Global $Ritualist = 8
Global $Paragon = 9
Global $Dervish = 10

; ATTRIBUTES
Global $Fast_Casting = 0;
Global $Illusion_Magic = 1;
Global $Domination_Magic = 2;
Global $Inspiration_Magic = 3;
Global $Blood_Magic = 4;
Global $Death_Magic = 5;
Global $Soul_Reaping = 6;
Global $Curses = 7;
Global $Air_Magic = 8;
Global $Earth_Magic = 9;
Global $Fire_Magic = 10;
Global $Water_Magic = 11;
Global $Energy_Storage = 12;
Global $Healing_Prayers = 13;
Global $Smiting_Prayers = 14;
Global $Protection_Prayers = 15;
Global $Divine_Favor = 16;
Global $Strength = 17;
Global $Axe_Mastery = 18;
Global $Hammer_Mastery = 19;
Global $Swordsmanship = 20;
Global $Tactics = 21;
Global $Beast_Mastery = 22;
Global $Expertise = 23;
Global $Wilderness_Survival = 24;
Global $Marksmanship = 25;
Global $Dagger_Mastery = 29;
Global $Deadly_Arts = 30;
Global $Shadow_Arts = 31;
Global $Communing = 32;
Global $Restoration_Magic = 33;
Global $Channeling_Magic = 34;
Global $Critical_Strikes = 35;
Global $Spawning_Power = 36;
Global $Spear_Mastery = 37;
Global $Command = 38;
Global $Motivation = 39;
Global $Leadership = 40;
Global $Scythe_Mastery = 41;
Global $Wind_Prayers = 42;
Global $Earth_Prayers = 43;
Global $Mysticism = 44;
Global $AttrID_None = 0xFF

; RANGES
Global $Adjacent = 156
Global $Nearby = 240
Global $Area = 312
Global $Earshot = 1000
Global $Spell_casting = 1085
Global $Spirit = 2500
Global $Compass = 5000

; SKILL TARGETS
Global $target_self = 0
Global $target_none = 0
Global $target_spirit = 1
Global $target_animal = 1
Global $target_corpse = 1
Global $target_ally = 3
Global $target_otherally = 4
Global $target_enemy = 5
Global $target_dead_ally = 6
Global $target_minion = 14
Global $target_ground = 16

;SKILL IDs
Global $No_Skill = 0;
Global $Healing_Signet = 1;
Global $Resurrection_Signet = 2;
Global $Signet_of_Capture = 3;
Global $BAMPH = 4;
Global $Power_Block = 5;
Global $Mantra_of_Earth = 6;
Global $Mantra_of_Flame = 7;
Global $Mantra_of_Frost = 8;
Global $Mantra_of_Lightning = 9;
Global $Hex_Breaker = 10;
Global $Distortion = 11;
Global $Mantra_of_Celerity = 12;
Global $Mantra_of_Recovery = 13;
Global $Mantra_of_Persistence = 14;
Global $Mantra_of_Inscriptions = 15;
Global $Mantra_of_Concentration = 16;
Global $Mantra_of_Resolve = 17;
Global $Mantra_of_Signets = 18;
Global $Fragility = 19;
Global $Confusion = 20;
Global $Inspired_Enchantment = 21;
Global $Inspired_Hex = 22;
Global $Power_Spike = 23;
Global $Power_Leak = 24;
Global $Power_Drain = 25;
Global $Empathy = 26;
Global $Shatter_Delusions = 27;
Global $Backfire = 28;
Global $Blackout = 29;
Global $Diversion = 30;
Global $Conjure_Phantasm = 31;
Global $Illusion_of_Weakness = 32;
Global $Illusionary_Weaponry = 33;
Global $Sympathetic_Visage = 34;
Global $Ignorance = 35;
Global $Arcane_Conundrum = 36;
Global $Illusion_of_Haste = 37;
Global $Channeling = 38;
Global $Energy_Surge = 39;
Global $Ether_Feast = 40;
Global $Ether_Lord = 41;
Global $Energy_Burn = 42;
Global $Clumsiness = 43;
Global $Phantom_Pain = 44;
Global $Ethereal_Burden = 45;
Global $Guilt = 46;
Global $Ineptitude = 47;
Global $Spirit_of_Failure = 48;
Global $Mind_Wrack = 49;
Global $Wastrels_Worry = 50;
Global $Shame = 51;
Global $Panic = 52;
Global $Migraine = 53;
Global $Crippling_Anguish = 54;
Global $Fevered_Dreams = 55;
Global $Soothing_Images = 56;
Global $Cry_of_Frustration = 57;
Global $Signet_of_Midnight = 58;
Global $Signet_of_Weariness = 59;
Global $Signet_of_Illusions_beta_version = 60;
Global $Leech_Signet = 61;
Global $Signet_of_Humility = 62;
Global $Keystone_Signet = 63;
Global $Mimic = 64;
Global $Arcane_Mimicry = 65;
Global $Spirit_Shackles = 66;
Global $Shatter_Hex = 67;
Global $Drain_Enchantment = 68;
Global $Shatter_Enchantment = 69;
Global $Disappear = 70;
Global $Unnatural_Signet_alpha_version = 71;
Global $Elemental_Resistance = 72;
Global $Physical_Resistance = 73;
Global $Echo = 74;
Global $Arcane_Echo = 75;
Global $Imagined_Burden = 76;
Global $Chaos_Storm = 77;
Global $Epidemic = 78;
Global $Energy_Drain = 79;
Global $Energy_Tap = 80;
Global $Arcane_Thievery = 81;
Global $Mantra_of_Recall = 82;
Global $Animate_Bone_Horror = 83;
Global $Animate_Bone_Fiend = 84;
Global $Animate_Bone_Minions = 85;
Global $Grenths_Balance = 86;
Global $Veratas_Gaze = 87;
Global $Veratas_Aura = 88;
Global $Deathly_Chill = 89;
Global $Veratas_Sacrifice = 90;
Global $Well_of_Power = 91;
Global $Well_of_Blood = 92;
Global $Well_of_Suffering = 93;
Global $Well_of_the_Profane = 94;
Global $Putrid_Explosion = 95;
Global $Soul_Feast = 96;
Global $Necrotic_Traversal = 97;
Global $Consume_Corpse = 98;
Global $Parasitic_Bond = 99;
Global $Soul_Barbs = 100;
Global $Barbs = 101;
Global $Shadow_Strike = 102;
Global $Price_of_Failure = 103;
Global $Death_Nova = 104;
Global $Deathly_Swarm = 105;
Global $Rotting_Flesh = 106;
Global $Virulence = 107;
Global $Suffering = 108;
Global $Life_Siphon = 109;
Global $Unholy_Feast = 110;
Global $Awaken_the_Blood = 111;
Global $Desecrate_Enchantments = 112;
Global $Tainted_Flesh = 113;
Global $Aura_of_the_Lich = 114;
Global $Blood_Renewal = 115;
Global $Dark_Aura = 116;
Global $Enfeeble = 117;
Global $Enfeebling_Blood = 118;
Global $Blood_is_Power = 119;
Global $Blood_of_the_Master = 120;
Global $Spiteful_Spirit = 121;
Global $Malign_Intervention = 122;
Global $Insidious_Parasite = 123;
Global $Spinal_Shivers = 124;
Global $Wither = 125;
Global $Life_Transfer = 126;
Global $Mark_of_Subversion = 127;
Global $Soul_Leech = 128;
Global $Defile_Flesh = 129;
Global $Demonic_Flesh = 130;
Global $Barbed_Signet = 131;
Global $Plague_Signet = 132;
Global $Dark_Pact = 133;
Global $Order_of_Pain = 134;
Global $Faintheartedness = 135;
Global $Shadow_of_Fear = 136;
Global $Rigor_Mortis = 137;
Global $Dark_Bond = 138;
Global $Infuse_Condition = 139;
Global $Malaise = 140;
Global $Rend_Enchantments = 141;
Global $Lingering_Curse = 142;
Global $Strip_Enchantment = 143;
Global $Chilblains = 144;
Global $Signet_of_Agony = 145;
Global $Offering_of_Blood = 146;
Global $Dark_Fury = 147;
Global $Order_of_the_Vampire = 148;
Global $Plague_Sending = 149;
Global $Mark_of_Pain = 150;
Global $Feast_of_Corruption = 151;
Global $Taste_of_Death = 152;
Global $Vampiric_Gaze = 153;
Global $Plague_Touch = 154;
Global $Vile_Touch = 155;
Global $Vampiric_Touch = 156;
Global $Blood_Ritual = 157;
Global $Touch_of_Agony = 158;
Global $Weaken_Armor = 159;
Global $Windborne_Speed = 160;
Global $Lightning_Storm = 161;
Global $Gale = 162;
Global $Whirlwind = 163;
Global $Elemental_Attunement = 164;
Global $Armor_of_Earth = 165;
Global $Kinetic_Armor = 166;
Global $Eruption = 167;
Global $Magnetic_Aura = 168;
Global $Earth_Attunement = 169;
Global $Earthquake = 170;
Global $Stoning = 171;
Global $Stone_Daggers = 172;
Global $Grasping_Earth = 173;
Global $Aftershock = 174;
Global $Ward_Against_Elements = 175;
Global $Ward_Against_Melee = 176;
Global $Ward_Against_Foes = 177;
Global $Ether_Prodigy = 178;
Global $Incendiary_Bonds = 179;
Global $Aura_of_Restoration = 180;
Global $Ether_Renewal = 181;
Global $Conjure_Flame = 182;
Global $Inferno = 183;
Global $Fire_Attunement = 184;
Global $Mind_Burn = 185;
Global $Fireball = 186;
Global $Meteor = 187;
Global $Flame_Burst = 188;
Global $Rodgorts_Invocation = 189;
Global $Mark_of_Rodgort = 190;
Global $Immolate = 191;
Global $Meteor_Shower = 192;
Global $Phoenix = 193;
Global $Flare = 194;
Global $Lava_Font = 195;
Global $Searing_Heat = 196;
Global $Fire_Storm = 197;
Global $Glyph_of_Elemental_Power = 198;
Global $Glyph_of_Energy = 199;
Global $Glyph_of_Lesser_Energy = 200;
Global $Glyph_of_Concentration = 201;
Global $Glyph_of_Sacrifice = 202;
Global $Glyph_of_Renewal = 203;
Global $Rust = 204;
Global $Lightning_Surge = 205;
Global $Armor_of_Frost = 206;
Global $Conjure_Frost = 207;
Global $Water_Attunement = 208;
Global $Mind_Freeze = 209;
Global $Ice_Prison = 210;
Global $Ice_Spikes = 211;
Global $Frozen_Burst = 212;
Global $Shard_Storm = 213;
Global $Ice_Spear = 214;
Global $Maelstrom = 215;
Global $Iron_Mist = 216;
Global $Crystal_Wave = 217;
Global $Obsidian_Flesh = 218;
Global $Obsidian_Flame = 219;
Global $Blinding_Flash = 220;
Global $Conjure_Lightning = 221;
Global $Lightning_Strike = 222;
Global $Chain_Lightning = 223;
Global $Enervating_Charge = 224;
Global $Air_Attunement = 225;
Global $Mind_Shock = 226;
Global $Glimmering_Mark = 227;
Global $Thunderclap = 228;
Global $Lightning_Orb = 229;
Global $Lightning_Javelin = 230;
Global $Shock = 231;
Global $Lightning_Touch = 232;
Global $Swirling_Aura = 233;
Global $Deep_Freeze = 234;
Global $Blurred_Vision = 235;
Global $Mist_Form = 236;
Global $Water_Trident = 237;
Global $Armor_of_Mist = 238;
Global $Ward_Against_Harm = 239;
Global $Smite = 240;
Global $Life_Bond = 241;
Global $Balthazars_Spirit = 242;
Global $Strength_of_Honor = 243;
Global $Life_Attunement = 244;
Global $Protective_Spirit = 245;
Global $Divine_Intervention = 246;
Global $Symbol_of_Wrath = 247;
Global $Retribution = 248;
Global $Holy_Wrath = 249;
Global $Essence_Bond = 250;
Global $Scourge_Healing = 251;
Global $Banish = 252;
Global $Scourge_Sacrifice = 253;
Global $Vigorous_Spirit = 254;
Global $Watchful_Spirit = 255;
Global $Blessed_Aura = 256;
Global $Aegis = 257;
Global $Guardian = 258;
Global $Shield_of_Deflection = 259;
Global $Aura_of_Faith = 260;
Global $Shield_of_Regeneration = 261;
Global $Shield_of_Judgment = 262;
Global $Protective_Bond = 263;
Global $Pacifism = 264;
Global $Amity = 265;
Global $Peace_and_Harmony = 266;
Global $Judges_Insight = 267;
Global $Unyielding_Aura = 268;
Global $Mark_of_Protection = 269;
Global $Life_Barrier = 270;
Global $Zealots_Fire = 271;
Global $Balthazars_Aura = 272;
Global $Spell_Breaker = 273;
Global $Healing_Seed = 274;
Global $Mend_Condition = 275;
Global $Restore_Condition = 276;
Global $Mend_Ailment = 277;
Global $Purge_Conditions = 278;
Global $Divine_Healing = 279;
Global $Heal_Area = 280;
Global $Orison_of_Healing = 281;
Global $Word_of_Healing = 282;
Global $Dwaynas_Kiss = 283;
Global $Divine_Boon = 284;
Global $Healing_Hands = 285;
Global $Heal_Other = 286;
Global $Heal_Party = 287;
Global $Healing_Breeze = 288;
Global $Vital_Blessing = 289;
Global $Mending = 290;
Global $Live_Vicariously = 291;
Global $Infuse_Health = 292;
Global $Signet_of_Devotion = 293;
Global $Signet_of_Judgment = 294;
Global $Purge_Signet = 295;
Global $Bane_Signet = 296;
Global $Blessed_Signet = 297;
Global $Martyr = 298;
Global $Shielding_Hands = 299;
Global $Contemplation_of_Purity = 300;
Global $Remove_Hex = 301;
Global $Smite_Hex = 302;
Global $Convert_Hexes = 303;
Global $Light_of_Dwayna = 304;
Global $Resurrect = 305;
Global $Rebirth = 306;
Global $Reversal_of_Fortune = 307;
Global $Succor = 308;
Global $Holy_Veil = 309;
Global $Divine_Spirit = 310;
Global $Draw_Conditions = 311;
Global $Holy_Strike = 312;
Global $Healing_Touch = 313;
Global $Restore_Life = 314;
Global $Vengeance = 315;
Global $To_the_Limit = 316;
Global $Battle_Rage = 317;
Global $Defy_Pain = 318;
Global $Rush = 319;
Global $Hamstring = 320;
Global $Wild_Blow = 321;
Global $Power_Attack = 322;
Global $Desperation_Blow = 323;
Global $Thrill_of_Victory = 324;
Global $Distracting_Blow = 325;
Global $Protectors_Strike = 326;
Global $Griffons_Sweep = 327;
Global $Pure_Strike = 328;
Global $Skull_Crack = 329;
Global $Cyclone_Axe = 330;
Global $Hammer_Bash = 331;
Global $Bulls_Strike = 332;
Global $I_Will_Avenge_You = 333;
Global $Axe_Rake = 334;
Global $Cleave = 335;
Global $Executioners_Strike = 336;
Global $Dismember = 337;
Global $Eviscerate = 338;
Global $Penetrating_Blow = 339;
Global $Disrupting_Chop = 340;
Global $Swift_Chop = 341;
Global $Axe_Twist = 342;
Global $For_Great_Justice = 343;
Global $Flurry = 344;
Global $Defensive_Stance = 345;
Global $Frenzy = 346;
Global $Endure_Pain = 347;
Global $Watch_Yourself = 348;
Global $Sprint = 349;
Global $Belly_Smash = 350;
Global $Mighty_Blow = 351;
Global $Crushing_Blow = 352;
Global $Crude_Swing = 353;
Global $Earth_Shaker = 354;
Global $Devastating_Hammer = 355;
Global $Irresistible_Blow = 356;
Global $Counter_Blow = 357;
Global $Backbreaker = 358;
Global $Heavy_Blow = 359;
Global $Staggering_Blow = 360;
Global $Dolyak_Signet = 361;
Global $Warriors_Cunning = 362;
Global $Shield_Bash = 363;
Global $Charge = 364;
Global $Victory_is_Mine = 365;
Global $Fear_Me = 366;
Global $Shields_Up = 367;
Global $I_Will_Survive = 368;
Global $Dont_Believe_Their_Lies = 369;
Global $Berserker_Stance = 370;
Global $Balanced_Stance = 371;
Global $Gladiators_Defense = 372;
Global $Deflect_Arrows = 373;
Global $Warriors_Endurance = 374;
Global $Dwarven_Battle_Stance = 375;
Global $Disciplined_Stance = 376;
Global $Wary_Stance = 377;
Global $Shield_Stance = 378;
Global $Bulls_Charge = 379;
Global $Bonettis_Defense = 380;
Global $Hundred_Blades = 381;
Global $Sever_Artery = 382;
Global $Galrath_Slash = 383;
Global $Gash = 384;
Global $Final_Thrust = 385;
Global $Seeking_Blade = 386;
Global $Riposte = 387;
Global $Deadly_Riposte = 388;
Global $Flourish = 389;
Global $Savage_Slash = 390;
Global $Hunters_Shot = 391;
Global $Pin_Down = 392;
Global $Crippling_Shot = 393;
Global $Power_Shot = 394;
Global $Barrage = 395;
Global $Dual_Shot = 396;
Global $Quick_Shot = 397;
Global $Penetrating_Attack = 398;
Global $Distracting_Shot = 399;
Global $Precision_Shot = 400;
Global $Splinter_Shot_monster_skill = 401;
Global $Determined_Shot = 402;
Global $Called_Shot = 403;
Global $Poison_Arrow = 404;
Global $Oath_Shot = 405;
Global $Debilitating_Shot = 406;
Global $Point_Blank_Shot = 407;
Global $Concussion_Shot = 408;
Global $Punishing_Shot = 409;
Global $Call_of_Ferocity = 410;
Global $Charm_Animal = 411;
Global $Call_of_Protection = 412;
Global $Call_of_Elemental_Protection = 413;
Global $Call_of_Vitality = 414;
Global $Call_of_Haste = 415;
Global $Call_of_Healing = 416;
Global $Call_of_Resilience = 417;
Global $Call_of_Feeding = 418;
Global $Call_of_the_Hunter = 419;
Global $Call_of_Brutality = 420;
Global $Call_of_Disruption = 421;
Global $Revive_Animal = 422;
Global $Symbiotic_Bond = 423;
Global $Throw_Dirt = 424;
Global $Dodge = 425;
Global $Savage_Shot = 426;
Global $Antidote_Signet = 427;
Global $Incendiary_Arrows = 428;
Global $Melandrus_Arrows = 429;
Global $Marksmans_Wager = 430;
Global $Ignite_Arrows = 431;
Global $Read_the_Wind = 432;
Global $Kindle_Arrows = 433;
Global $Choking_Gas = 434;
Global $Apply_Poison = 435;
Global $Comfort_Animal = 436;
Global $Bestial_Pounce = 437;
Global $Maiming_Strike = 438;
Global $Feral_Lunge = 439;
Global $Scavenger_Strike = 440;
Global $Melandrus_Assault = 441;
Global $Ferocious_Strike = 442;
Global $Predators_Pounce = 443;
Global $Brutal_Strike = 444;
Global $Disrupting_Lunge = 445;
Global $Troll_Unguent = 446;
Global $Otyughs_Cry = 447;
Global $Escape = 448;
Global $Practiced_Stance = 449;
Global $Whirling_Defense = 450;
Global $Melandrus_Resilience = 451;
Global $Dryders_Defenses = 452;
Global $Lightning_Reflexes = 453;
Global $Tigers_Fury = 454;
Global $Storm_Chaser = 455;
Global $Serpents_Quickness = 456;
Global $Dust_Trap = 457;
Global $Barbed_Trap = 458;
Global $Flame_Trap = 459;
Global $Healing_Spring = 460;
Global $Spike_Trap = 461;
Global $Winter = 462;
Global $Winnowing = 463;
Global $Edge_of_Extinction = 464;
Global $Greater_Conflagration = 465;
Global $Conflagration = 466;
Global $Fertile_Season = 467;
Global $Symbiosis = 468;
Global $Primal_Echoes = 469;
Global $Predatory_Season = 470;
Global $Frozen_Soil = 471;
Global $Favorable_Winds = 472;
Global $High_Winds = 473;
Global $Energizing_Wind = 474;
Global $Quickening_Zephyr = 475;
Global $Natures_Renewal = 476;
Global $Muddy_Terrain = 477;
Global $Bleeding = 478;
Global $Blind = 479;
Global $Burning = 480;
Global $Crippled = 481;
Global $Deep_Wound = 482;
Global $Disease = 483;
Global $Poison = 484;
Global $Dazed = 485;
Global $Weakness = 486;
Global $Cleansed = 487;
Global $Eruption_environment = 488;
Global $Fire_Storm_environment = 489;
Global $Fount_Of_Maguuma = 491;
Global $Healing_Fountain = 492;
Global $Icy_Ground = 493;
Global $Maelstrom_environment = 494;
Global $Mursaat_Tower_skill = 495;
Global $Quicksand_environment_effect = 496;
Global $Curse_of_the_Bloodstone = 497;
Global $Chain_Lightning_environment = 498;
Global $Obelisk_Lightning = 499;
Global $Tar = 500;
Global $Siege_Attack = 501;
Global $Scepter_of_Orrs_Aura = 503;
Global $Scepter_of_Orrs_Power = 504;
Global $Burden_Totem = 505;
Global $Splinter_Mine_skill = 506;
Global $Entanglement = 507;
Global $Dwarven_Powder_Keg = 508;
Global $Seed_of_Resurrection = 509;
Global $Deafening_Roar = 510;
Global $Brutal_Mauling = 511;
Global $Crippling_Attack = 512;
Global $Breaking_Charm = 514;
Global $Charr_Buff = 515;
Global $Claim_Resource = 516;
Global $Dozen_Shot = 524;
Global $Nibble = 525;
Global $Reflection = 528;
Global $Giant_Stomp = 530;
Global $Agnars_Rage = 531;
Global $Crystal_Haze = 533;
Global $Crystal_Bonds = 534;
Global $Jagged_Crystal_Skin = 535;
Global $Crystal_Hibernation = 536;
Global $Hunger_of_the_Lich = 539;
Global $Embrace_the_Pain = 540;
Global $Life_Vortex = 541;
Global $Oracle_Link = 542;
Global $Guardian_Pacify = 543;
Global $Soul_Vortex = 544;
Global $Spectral_Agony = 546;
Global $Undead_sensitivity_to_Light = 554;
Global $Titans_get_plus_Health_regen_and_set_enemies_on_fire_each_time_he_is_hit = 558;
Global $Resurrect_Resurrect_Gargoyle = 560;
Global $Wurm_Siege = 563;
Global $Shiver_Touch = 566;
Global $Spontaneous_Combustion = 567;
Global $Vanish = 568;
Global $Victory_or_Death = 569;
Global $Mark_of_Insecurity = 570;
Global $Disrupting_Dagger = 571;
Global $Deadly_Paradox = 572;
Global $Holy_Blessing = 575;
Global $Statues_Blessing = 576;
Global $Domain_of_Energy_Draining = 580;
Global $Domain_of_Health_Draining = 582;
Global $Domain_of_Slow = 583;
Global $Divine_Fire = 584;
Global $Swamp_Water = 585;
Global $Janthirs_Gaze = 586;
Global $Stormcaller_skill = 589;
Global $Knock = 590;
Global $Blessing_of_the_Kurzicks = 593;
Global $Chimera_of_Intensity = 596;
Global $Life_Stealing_effect = 657;
Global $Jaundiced_Gaze = 763;
Global $Wail_of_Doom = 764;
Global $Heros_Insight = 765;
Global $Gaze_of_Contempt = 766;
Global $Berserkers_Insight = 767;
Global $Slayers_Insight = 768;
Global $Vipers_Defense = 769;
Global $Return = 770;
Global $Aura_of_Displacement = 771;
Global $Generous_Was_Tsungrai = 772;
Global $Mighty_Was_Vorizun = 773;
Global $To_the_Death = 774;
Global $Death_Blossom = 775;
Global $Twisting_Fangs = 776;
Global $Horns_of_the_Ox = 777;
Global $Falling_Spider = 778;
Global $Black_Lotus_Strike = 779;
Global $Fox_Fangs = 780;
Global $Moebius_Strike = 781;
Global $Jagged_Strike = 782;
Global $Unsuspecting_Strike = 783;
Global $Entangling_Asp = 784;
Global $Mark_of_Death = 785;
Global $Iron_Palm = 786;
Global $Resilient_Weapon = 787;
Global $Blind_Was_Mingson = 788;
Global $Grasping_Was_Kuurong = 789;
Global $Vengeful_Was_Khanhei = 790;
Global $Flesh_of_My_Flesh = 791;
Global $Splinter_Weapon = 792;
Global $Weapon_of_Warding = 793;
Global $Wailing_Weapon = 794;
Global $Nightmare_Weapon = 795;
Global $Sorrows_Flame = 796;
Global $Sorrows_Fist = 797;
Global $Blast_Furnace = 798;
Global $Beguiling_Haze = 799;
Global $Enduring_Toxin = 800;
Global $Shroud_of_Silence = 801;
Global $Expose_Defenses = 802;
Global $Power_Leech = 803;
Global $Arcane_Languor = 804;
Global $Animate_Vampiric_Horror = 805;
Global $Cultists_Fervor = 806;
Global $Reapers_Mark = 808;
Global $Shatterstone = 809;
Global $Protectors_Defense = 810;
Global $Run_as_One = 811;
Global $Defiant_Was_Xinrae = 812;
Global $Lyssas_Aura = 813;
Global $Shadow_Refuge = 814;
Global $Scorpion_Wire = 815;
Global $Mirrored_Stance = 816;
Global $Discord = 817;
Global $Well_of_Weariness = 818;
Global $Vampiric_Spirit = 819;
Global $Depravity = 820;
Global $Icy_Veins = 821;
Global $Weaken_Knees = 822;
Global $Burning_Speed = 823;
Global $Lava_Arrows = 824;
Global $Bed_of_Coals = 825;
Global $Shadow_Form = 826;
Global $Siphon_Strength = 827;
Global $Vile_Miasma = 828;
Global $Ray_of_Judgment = 830;
Global $Primal_Rage = 831;
Global $Animate_Flesh_Golem = 832;
Global $Reckless_Haste = 834;
Global $Blood_Bond = 835;
Global $Ride_the_Lightning = 836;
Global $Energy_Boon = 837;
Global $Dwaynas_Sorrow = 838;
Global $Retreat = 839;
Global $Poisoned_Heart = 840;
Global $Fetid_Ground = 841;
Global $Arc_Lightning = 842;
Global $Gust = 843;
Global $Churning_Earth = 844;
Global $Liquid_Flame = 845;
Global $Steam = 846;
Global $Boon_Signet = 847;
Global $Reverse_Hex = 848;
Global $Lacerating_Chop = 849;
Global $Fierce_Blow = 850;
Global $Sun_and_Moon_Slash = 851;
Global $Splinter_Shot = 852;
Global $Melandrus_Shot = 853;
Global $Snare = 854;
Global $Kilroy_Stonekin = 856;
Global $Adventurers_Insight = 857;
Global $Dancing_Daggers = 858;
Global $Conjure_Nightmare = 859;
Global $Signet_of_Disruption = 860;
Global $Ravenous_Gaze = 862;
Global $Order_of_Apostasy = 863;
Global $Oppressive_Gaze = 864;
Global $Lightning_Hammer = 865;
Global $Vapor_Blade = 866;
Global $Healing_Light = 867;
Global $Coward = 869;
Global $Pestilence = 870;
Global $Shadowsong = 871;
Global $Shadowsong_attack = 872;
Global $Resurrect_monster_skill = 873;
Global $Consuming_Flames = 874;
Global $Chains_of_Enslavement = 875;
Global $Signet_of_Shadows = 876;
Global $Lyssas_Balance = 877;
Global $Visions_of_Regret = 878;
Global $Illusion_of_Pain = 879;
Global $Stolen_Speed = 880;
Global $Ether_Signet = 881;
Global $Signet_of_Disenchantment = 882;
Global $Vocal_Minority = 883;
Global $Searing_Flames = 884;
Global $Shield_Guardian = 885;
Global $Restful_Breeze = 886;
Global $Signet_of_Rejuvenation = 887;
Global $Whirling_Axe = 888;
Global $Forceful_Blow = 889;
Global $None_Shall_Pass = 891;
Global $Quivering_Blade = 892;
Global $Seeking_Arrows = 893;
Global $Rampagers_Insight = 894;
Global $Hunters_Insight = 895;
Global $Oath_of_Healing = 897;
Global $Overload = 898;
Global $Images_of_Remorse = 899;
Global $Shared_Burden = 900;
Global $Soul_Bind = 901;
Global $Blood_of_the_Aggressor = 902;
Global $Icy_Prism = 903;
Global $Furious_Axe = 904;
Global $Auspicious_Blow = 905;
Global $On_Your_Knees = 906;
Global $Dragon_Slash = 907;
Global $Marauders_Shot = 908;
Global $Focused_Shot = 909;
Global $Spirit_Rift = 910;
Global $Union = 911;
Global $Tranquil_Was_Tanasen = 913;
Global $Consume_Soul = 914;
Global $Spirit_Light = 915;
Global $Lamentation = 916;
Global $Rupture_Soul = 917;
Global $Spirit_to_Flesh = 918;
Global $Spirit_Burn = 919;
Global $Destruction = 920;
Global $Dissonance = 921;
Global $Dissonance_attack = 922;
Global $Disenchantment = 923;
Global $Disenchantment_attack = 924;
Global $Recall = 925;
Global $Sharpen_Daggers = 926;
Global $Shameful_Fear = 927;
Global $Shadow_Shroud = 928;
Global $Shadow_of_Haste = 929;
Global $Auspicious_Incantation = 930;
Global $Power_Return = 931;
Global $Complicate = 932;
Global $Shatter_Storm = 933;
Global $Unnatural_Signet = 934;
Global $Rising_Bile = 935;
Global $Envenom_Enchantments = 936;
Global $Shockwave = 937;
Global $Ward_of_Stability = 938;
Global $Icy_Shackles = 939;
Global $Blessed_Light = 941;
Global $Withdraw_Hexes = 942;
Global $Extinguish = 943;
Global $Signet_of_Strength = 944;
Global $Trappers_Focus = 946;
Global $Brambles = 947;
Global $Desperate_Strike = 948;
Global $Way_of_the_Fox = 949;
Global $Shadowy_Burden = 950;
Global $Siphon_Speed = 951;
Global $Deaths_Charge = 952;
Global $Power_Flux = 953;
Global $Expel_Hexes = 954;
Global $Rip_Enchantment = 955;
Global $Spell_Shield = 957;
Global $Healing_Whisper = 958;
Global $Ethereal_Light = 959;
Global $Release_Enchantments = 960;
Global $Lacerate = 961;
Global $Spirit_Transfer = 962;
Global $Restoration = 963;
Global $Vengeful_Weapon = 964;
Global $Spear_of_Archemorus = 966;
Global $Argos_Cry = 971;
Global $Jade_Fury = 972;
Global $Blinding_Powder = 973;
Global $Mantis_Touch = 974;
Global $Exhausting_Assault = 975;
Global $Repeating_Strike = 976;
Global $Way_of_the_Lotus = 977;
Global $Mark_of_Instability = 978;
Global $Mistrust = 979;
Global $Feast_of_Souls = 980;
Global $Recuperation = 981;
Global $Shelter = 982;
Global $Weapon_of_Shadow = 983;
Global $Torch_Enchantment = 984;
Global $Caltrops = 985;
Global $Nine_Tail_Strike = 986;
Global $Way_of_the_Empty_Palm = 987;
Global $Temple_Strike = 988;
Global $Golden_Phoenix_Strike = 989;
Global $Expunge_Enchantments = 990;
Global $Deny_Hexes = 991;
Global $Triple_Chop = 992;
Global $Enraged_Smash = 993;
Global $Renewing_Smash = 994;
Global $Tiger_Stance = 995;
Global $Standing_Slash = 996;
Global $Famine = 997;
Global $Torch_Hex = 998;
Global $Torch_Degeneration_Hex = 999;
Global $Blinding_Snow = 1000;
Global $Avalanche_skill = 1001;
Global $Snowball = 1002;
Global $Mega_Snowball = 1003;
Global $Yuletide = 1004;
Global $Ice_Fort = 1006;
Global $Yellow_Snow = 1007;
Global $Hidden_Rock = 1008;
Global $Snow_Down_the_Shirt = 1009;
Global $Mmmm_Snowcone = 1010;
Global $Holiday_Blues = 1011;
Global $Icicles = 1012;
Global $Ice_Breaker = 1013;
Global $Lets_Get_Em = 1014;
Global $Flurry_of_Ice = 1015;
Global $Critical_Eye = 1018;
Global $Critical_Strike = 1019;
Global $Blades_of_Steel = 1020;
Global $Jungle_Strike = 1021;
Global $Wild_Strike = 1022;
Global $Leaping_Mantis_Sting = 1023;
Global $Black_Mantis_Thrust = 1024;
Global $Disrupting_Stab = 1025;
Global $Golden_Lotus_Strike = 1026;
Global $Critical_Defenses = 1027;
Global $Way_of_Perfection = 1028;
Global $Dark_Apostasy = 1029;
Global $Locusts_Fury = 1030;
Global $Shroud_of_Distress = 1031;
Global $Heart_of_Shadow = 1032;
Global $Impale = 1033;
Global $Seeping_Wound = 1034;
Global $Assassins_Promise = 1035;
Global $Signet_of_Malice = 1036;
Global $Dark_Escape = 1037;
Global $Crippling_Dagger = 1038;
Global $Star_Strike = 1039;
Global $Spirit_Walk = 1040;
Global $Unseen_Fury = 1041;
Global $Flashing_Blades = 1042;
Global $Dash = 1043;
Global $Dark_Prison = 1044;
Global $Palm_Strike = 1045;
Global $Assassin_of_Lyssa = 1046;
Global $Mesmer_of_Lyssa = 1047;
Global $Revealed_Enchantment = 1048;
Global $Revealed_Hex = 1049;
Global $Disciple_of_Energy = 1050;
Global $Accumulated_Pain = 1052;
Global $Psychic_Distraction = 1053;
Global $Ancestors_Visage = 1054;
Global $Recurring_Insecurity = 1055;
Global $Kitahs_Burden = 1056;
Global $Psychic_Instability = 1057;
Global $Psychic_Instability_PVP = 3185;
Global $Chaotic_Power = 1058;
Global $Hex_Eater_Signet = 1059;
Global $Celestial_Haste = 1060;
Global $Feedback = 1061;
Global $Arcane_Larceny = 1062;
Global $Chaotic_Ward = 1063;
Global $Favor_of_the_Gods = 1064;
Global $Dark_Aura_blessing = 1065;
Global $Spoil_Victor = 1066;
Global $Lifebane_Strike = 1067;
Global $Bitter_Chill = 1068;
Global $Taste_of_Pain = 1069;
Global $Defile_Enchantments = 1070;
Global $Shivers_of_Dread = 1071;
Global $Star_Servant = 1072;
Global $Necromancer_of_Grenth = 1073;
Global $Ritualist_of_Grenth = 1074;
Global $Vampiric_Swarm = 1075;
Global $Blood_Drinker = 1076;
Global $Vampiric_Bite = 1077;
Global $Wallows_Bite = 1078;
Global $Enfeebling_Touch = 1079;
Global $Disciple_of_Ice = 1080;
Global $Teinais_Wind = 1081;
Global $Shock_Arrow = 1082;
Global $Unsteady_Ground = 1083;
Global $Sliver_Armor = 1084;
Global $Ash_Blast = 1085;
Global $Dragons_Stomp = 1086;
Global $Unnatural_Resistance = 1087;
Global $Second_Wind = 1088;
Global $Cloak_of_Faith = 1089;
Global $Smoldering_Embers = 1090;
Global $Double_Dragon = 1091;
Global $Disciple_of_the_Air = 1092;
Global $Teinais_Heat = 1093;
Global $Breath_of_Fire = 1094;
Global $Star_Burst = 1095;
Global $Glyph_of_Essence = 1096;
Global $Teinais_Prison = 1097;
Global $Mirror_of_Ice = 1098;
Global $Teinais_Crystals = 1099;
Global $Celestial_Storm = 1100;
Global $Monk_of_Dwayna = 1101;
Global $Aura_of_the_Grove = 1102;
Global $Cathedral_Collapse = 1103;
Global $Miasma = 1104;
Global $Acid_Trap = 1105;
Global $Shield_of_Saint_Viktor = 1106;
Global $Urn_of_Saint_Viktor = 1107;
Global $Aura_of_Light = 1112;
Global $Kirins_Wrath = 1113;
Global $Spirit_Bond = 1114;
Global $Air_of_Enchantment = 1115;
Global $Warriors_Might = 1116;
Global $Heavens_Delight = 1117;
Global $Healing_Burst = 1118;
Global $Kareis_Healing_Circle = 1119;
Global $Jameis_Gaze = 1120;
Global $Gift_of_Health = 1121;
Global $Battle_Fervor = 1122;
Global $Life_Sheath = 1123;
Global $Star_Shine = 1124;
Global $Disciple_of_Fire = 1125;
Global $Empathic_Removal = 1126;
Global $Warrior_of_Balthazar = 1127;
Global $Resurrection_Chant = 1128;
Global $Word_of_Censure = 1129;
Global $Spear_of_Light = 1130;
Global $Stonesoul_Strike = 1131;
Global $Shielding_Branches = 1132;
Global $Drunken_Blow = 1133;
Global $Leviathans_Sweep = 1134;
Global $Jaizhenju_Strike = 1135;
Global $Penetrating_Chop = 1136;
Global $Yeti_Smash = 1137;
Global $Disciple_of_the_Earth = 1138;
Global $Ranger_of_Melandru = 1139;
Global $Storm_of_Swords = 1140;
Global $You_Will_Die = 1141;
Global $Auspicious_Parry = 1142;
Global $Strength_of_the_Oak = 1143;
Global $Silverwing_Slash = 1144;
Global $Destroy_Enchantment = 1145;
Global $Shove = 1146;
Global $Base_Defense = 1147;
Global $Carrier_Defense = 1148;
Global $The_Chalice_of_Corruption = 1149;
Global $Song_of_the_Mists = 1151;
Global $Demonic_Agility = 1152;
Global $Blessing_of_the_Kirin = 1153;
Global $Juggernaut_Toss = 1155;
Global $Aura_of_the_Juggernaut = 1156;
Global $Star_Shards = 1157;
Global $Turtle_Shell = 1172;
Global $Blood_of_zu_Heltzer = 1175;
Global $Afflicted_Soul_Explosion = 1176;
Global $Dark_Chain_Lightning = 1179;
Global $Corrupted_Breath = 1181;
Global $Renewing_Corruption = 1182;
Global $Corrupted_Dragon_Spores = 1183;
Global $Corrupted_Dragon_Scales = 1184;
Global $Construct_Possession = 1185;
Global $Siege_Turtle_Attack = 1186;
Global $Of_Royal_Blood = 1189;
Global $Passage_to_Tahnnakai = 1190;
Global $Sundering_Attack = 1191;
Global $Zojuns_Shot = 1192;
Global $Predatory_Bond = 1194;
Global $Heal_as_One = 1195;
Global $Zojuns_Haste = 1196;
Global $Needling_Shot = 1197;
Global $Broad_Head_Arrow = 1198;
Global $Glass_Arrows = 1199;
Global $Archers_Signet = 1200;
Global $Savage_Pounce = 1201;
Global $Enraged_Lunge = 1202;
Global $Bestial_Mauling = 1203;
Global $Energy_Drain_effect = 1204;
Global $Poisonous_Bite = 1205;
Global $Pounce = 1206;
Global $Celestial_Stance = 1207;
Global $Sheer_Exhaustion = 1208;
Global $Bestial_Fury = 1209;
Global $Life_Drain = 1210;
Global $Vipers_Nest = 1211;
Global $Equinox = 1212;
Global $Tranquility = 1213;
Global $Clamor_of_Souls = 1215;
Global $Ritual_Lord = 1217;
Global $Cruel_Was_Daoshen = 1218;
Global $Protective_Was_Kaolai = 1219;
Global $Attuned_Was_Songkai = 1220;
Global $Resilient_Was_Xiko = 1221;
Global $Lively_Was_Naomei = 1222;
Global $Anguished_Was_Lingwah = 1223;
Global $Draw_Spirit = 1224;
Global $Channeled_Strike = 1225;
Global $Spirit_Boon_Strike = 1226;
Global $Essence_Strike = 1227;
Global $Spirit_Siphon = 1228;
Global $Explosive_Growth = 1229;
Global $Boon_of_Creation = 1230;
Global $Spirit_Channeling = 1231;
Global $Armor_of_Unfeeling = 1232;
Global $Soothing_Memories = 1233;
Global $Mend_Body_and_Soul = 1234;
Global $Dulled_Weapon = 1235;
Global $Binding_Chains = 1236;
Global $Painful_Bond = 1237;
Global $Signet_of_Creation = 1238;
Global $Signet_of_Spirits = 1239;
Global $Soul_Twisting = 1240;
Global $Celestial_Summoning = 1241;
Global $Ghostly_Haste = 1244;
Global $Gaze_from_Beyond = 1245;
Global $Ancestors_Rage = 1246;
Global $Pain = 1247;
Global $Pain_attack = 1248;
Global $Displacement = 1249;
Global $Preservation = 1250;
Global $Life = 1251;
Global $Earthbind = 1252;
Global $Bloodsong = 1253;
Global $Bloodsong_attack = 1254;
Global $Wanderlust = 1255;
Global $Wanderlust_attack = 1256;
Global $Spirit_Light_Weapon = 1257;
Global $Brutal_Weapon = 1258;
Global $Guided_Weapon = 1259;
Global $Meekness = 1260;
Global $Frigid_Armor = 1261;
Global $Healing_Ring = 1262;
Global $Renew_Life = 1263;
Global $Doom = 1264;
Global $Wielders_Boon = 1265;
Global $Soothing = 1266;
Global $Vital_Weapon = 1267;
Global $Weapon_of_Quickening = 1268;
Global $Signet_of_Rage = 1269;
Global $Fingers_of_Chaos = 1270;
Global $Echoing_Banishment = 1271;
Global $Suicidal_Impulse = 1272;
Global $Impossible_Odds = 1273;
Global $Battle_Scars = 1274;
Global $Riposting_Shadows = 1275;
Global $Meditation_of_the_Reaper = 1276;
Global $Blessed_Water = 1280;
Global $Defiled_Water = 1281;
Global $Stone_Spores = 1282;
Global $Haiju_Lagoon_Water = 1287;
Global $Aspect_of_Exhaustion = 1288;
Global $Aspect_of_Exposure = 1289;
Global $Aspect_of_Surrender = 1290;
Global $Aspect_of_Death = 1291;
Global $Aspect_of_Soothing = 1292;
Global $Aspect_of_Pain = 1293;
Global $Aspect_of_Lethargy = 1294;
Global $Aspect_of_Depletion_energy_loss = 1295;
Global $Aspect_of_Failure = 1296;
Global $Aspect_of_Shadows = 1297;
Global $Scorpion_Aspect = 1298;
Global $Aspect_of_Fear = 1299;
Global $Aspect_of_Depletion_energy_depletion_damage = 1300;
Global $Aspect_of_Decay = 1301;
Global $Aspect_of_Torment = 1302;
Global $Nightmare_Aspect = 1303;
Global $Spiked_Coral = 1304;
Global $Shielding_Urn = 1305;
Global $Extensive_Plague_Exposure = 1306;
Global $Forests_Binding = 1307;
Global $Exploding_Spores = 1308;
Global $Suicide_Energy = 1309;
Global $Suicide_Health = 1310;
Global $Nightmare_Refuge = 1311;
Global $Rage_of_the_Sea = 1315;
Global $Sugar_Rush = 1323;
Global $Torment_Slash = 1324;
Global $Spirit_of_the_Festival = 1325;
Global $Trade_Winds = 1326;
Global $Dragon_Blast = 1327;
Global $Imperial_Majesty = 1328;
Global $Extend_Conditions = 1333;
Global $Hypochondria = 1334;
Global $Wastrels_Demise = 1335;
Global $Spiritual_Pain = 1336;
Global $Drain_Delusions = 1337;
Global $Persistence_of_Memory = 1338;
Global $Symbols_of_Inspiration = 1339;
Global $Symbolic_Celerity = 1340;
Global $Frustration = 1341;
Global $Tease = 1342;
Global $Ether_Phantom = 1343;
Global $Web_of_Disruption = 1344;
Global $Enchanters_Conundrum = 1345;
Global $Signet_of_Illusions = 1346;
Global $Discharge_Enchantment = 1347;
Global $Hex_Eater_Vortex = 1348;
Global $Mirror_of_Disenchantment = 1349;
Global $Simple_Thievery = 1350;
Global $Animate_Shambling_Horror = 1351;
Global $Order_of_Undeath = 1352;
Global $Putrid_Flesh = 1353;
Global $Feast_for_the_Dead = 1354;
Global $Jagged_Bones = 1355;
Global $Contagion = 1356;
Global $Ulcerous_Lungs = 1358;
Global $Pain_of_Disenchantment = 1359;
Global $Mark_of_Fury = 1360;
Global $Corrupt_Enchantment = 1362;
Global $Signet_of_Sorrow = 1363;
Global $Signet_of_Suffering = 1364;
Global $Signet_of_Lost_Souls = 1365;
Global $Well_of_Darkness = 1366;
Global $Blinding_Surge = 1367;
Global $Chilling_Winds = 1368;
Global $Lightning_Bolt = 1369;
Global $Storm_Djinns_Haste = 1370;
Global $Stone_Striker = 1371;
Global $Sandstorm = 1372;
Global $Stone_Sheath = 1373;
Global $Ebon_Hawk = 1374;
Global $Stoneflesh_Aura = 1375;
Global $Glyph_of_Restoration = 1376;
Global $Ether_Prism = 1377;
Global $Master_of_Magic = 1378;
Global $Glowing_Gaze = 1379;
Global $Savannah_Heat = 1380;
Global $Flame_Djinns_Haste = 1381;
Global $Freezing_Gust = 1382;
Global $Sulfurous_Haze = 1384;
Global $Sentry_Trap_skill = 1386;
Global $Judges_Intervention = 1390;
Global $Supportive_Spirit = 1391;
Global $Watchful_Healing = 1392;
Global $Healers_Boon = 1393;
Global $Healers_Covenant = 1394;
Global $Balthazars_Pendulum = 1395;
Global $Words_of_Comfort = 1396;
Global $Light_of_Deliverance = 1397;
Global $Scourge_Enchantment = 1398;
Global $Shield_of_Absorption = 1399;
Global $Reversal_of_Damage = 1400;
Global $Mending_Touch = 1401;
Global $Critical_Chop = 1402;
Global $Agonizing_Chop = 1403;
Global $Flail = 1404;
Global $Charging_Strike = 1405;
Global $Headbutt = 1406;
Global $Lions_Comfort = 1407;
Global $Rage_of_the_Ntouka = 1408;
Global $Mokele_Smash = 1409;
Global $Overbearing_Smash = 1410;
Global $Signet_of_Stamina = 1411;
Global $Youre_All_Alone = 1412;
Global $Burst_of_Aggression = 1413;
Global $Enraging_Charge = 1414;
Global $Crippling_Slash = 1415;
Global $Barbarous_Slice = 1416;
Global $Vial_of_Purified_Water = 1417;
Global $Disarm_Trap = 1418;
Global $Feeding_Frenzy_skill = 1419;
Global $Quake_Of_Ahdashim = 1420;
Global $Create_Light_of_Seborhin = 1422;
Global $Unlock_Cell = 1423;
Global $Wave_of_Torment = 1430;
Global $Corsairs_Net = 1433;
Global $Corrupted_Healing = 1434;
Global $Corrupted_Strength = 1436;
Global $Desert_Wurm_disguise = 1437;
Global $Junundu_Feast = 1438;
Global $Junundu_Strike = 1439;
Global $Junundu_Smash = 1440;
Global $Junundu_Siege = 1441;
Global $Junundu_Tunnel = 1442;
Global $Leave_Junundu = 1443;
Global $Summon_Torment = 1444;
Global $Signal_Flare = 1445;
Global $The_Elixir_of_Strength = 1446;
Global $Ehzah_from_Above = 1447;
Global $Last_Rites_of_Torment = 1449;
Global $Abaddons_Conspiracy = 1450;
Global $Hungers_Bite = 1451;
Global $Call_to_the_Torment = 1454;
Global $Command_of_Torment = 1455;
Global $Abaddons_Favor = 1456;
Global $Abaddons_Chosen = 1457;
Global $Enchantment_Collapse = 1458;
Global $Call_of_Sacrifice = 1459;
Global $Enemies_Must_Die = 1460;
Global $Earth_Vortex = 1461;
Global $Frost_Vortex = 1462;
Global $Rough_Current = 1463;
Global $Turbulent_Flow = 1464;
Global $Prepared_Shot = 1465;
Global $Burning_Arrow = 1466;
Global $Arcing_Shot = 1467;
Global $Strike_as_One = 1468;
Global $Crossfire = 1469;
Global $Barbed_Arrows = 1470;
Global $Scavengers_Focus = 1471;
Global $Toxicity = 1472;
Global $Quicksand = 1473;
Global $Storms_Embrace = 1474;
Global $Trappers_Speed = 1475;
Global $Tripwire = 1476;
Global $Kournan_Guardsman_Uniform = 1477;
Global $Renewing_Surge = 1478;
Global $Offering_of_Spirit = 1479;
Global $Spirits_Gift = 1480;
Global $Death_Pact_Signet = 1481;
Global $Reclaim_Essence = 1482;
Global $Banishing_Strike = 1483;
Global $Mystic_Sweep = 1484;
Global $Eremites_Attack = 1485;
Global $Reap_Impurities = 1486;
Global $Twin_Moon_Sweep = 1487;
Global $Victorious_Sweep = 1488;
Global $Irresistible_Sweep = 1489;
Global $Pious_Assault = 1490;
Global $Mystic_Twister = 1491;
Global $Grenths_Fingers = 1493;
Global $Aura_of_Thorns = 1495;
Global $Balthazars_Rage = 1496;
Global $Dust_Cloak = 1497;
Global $Staggering_Force = 1498;
Global $Pious_Renewal = 1499;
Global $Mirage_Cloak = 1500;
Global $Arcane_Zeal = 1502;
Global $Mystic_Vigor = 1503;
Global $Watchful_Intervention = 1504;
Global $Vow_of_Piety = 1505;
Global $Vital_Boon = 1506;
Global $Heart_of_Holy_Flame = 1507;
Global $Extend_Enchantments = 1508;
Global $Faithful_Intervention = 1509;
Global $Sand_Shards = 1510;
Global $Lyssas_Haste = 1512;
Global $Guiding_Hands = 1513;
Global $Fleeting_Stability = 1514;
Global $Armor_of_Sanctity = 1515;
Global $Mystic_Regeneration = 1516;
Global $Vow_of_Silence = 1517;
Global $Avatar_of_Balthazar = 1518;
Global $Avatar_of_Dwayna = 1519;
Global $Avatar_of_Grenth = 1520;
Global $Avatar_of_Lyssa = 1521;
Global $Avatar_of_Melandru = 1522;
Global $Meditation = 1523;
Global $Eremites_Zeal = 1524;
Global $Natural_Healing = 1525;
Global $Imbue_Health = 1526;
Global $Mystic_Healing = 1527;
Global $Dwaynas_Touch = 1528;
Global $Pious_Restoration = 1529;
Global $Signet_of_Pious_Light = 1530;
Global $Intimidating_Aura = 1531;
Global $Mystic_Sandstorm = 1532;
Global $Winds_of_Disenchantment = 1533;
Global $Rending_Touch = 1534;
Global $Crippling_Sweep = 1535;
Global $Wounding_Strike = 1536;
Global $Wearying_Strike = 1537;
Global $Lyssas_Assault = 1538;
Global $Chilling_Victory = 1539;
Global $Conviction = 1540;
Global $Enchanted_Haste = 1541;
Global $Pious_Concentration = 1542;
Global $Pious_Haste = 1543;
Global $Whirling_Charge = 1544;
Global $Test_of_Faith = 1545;
Global $Blazing_Spear = 1546;
Global $Mighty_Throw = 1547;
Global $Cruel_Spear = 1548;
Global $Harriers_Toss = 1549;
Global $Unblockable_Throw = 1550;
Global $Spear_of_Lightning = 1551;
Global $Wearying_Spear = 1552;
Global $Anthem_of_Fury = 1553;
Global $Crippling_Anthem = 1554;
Global $Defensive_Anthem = 1555;
Global $Godspeed = 1556;
Global $Anthem_of_Flame = 1557;
Global $Go_for_the_Eyes = 1558;
Global $Anthem_of_Envy = 1559;
Global $Song_of_Power = 1560;
Global $Zealous_Anthem = 1561;
Global $Aria_of_Zeal = 1562;
Global $Lyric_of_Zeal = 1563;
Global $Ballad_of_Restoration = 1564;
Global $Chorus_of_Restoration = 1565;
Global $Aria_of_Restoration = 1566;
Global $Song_of_Concentration = 1567;
Global $Anthem_of_Guidance = 1568;
Global $Energizing_Chorus = 1569;
Global $Song_of_Purification = 1570;
Global $Hexbreaker_Aria = 1571;
Global $Brace_Yourself = 1572;
Global $Awe = 1573;
Global $Enduring_Harmony = 1574;
Global $Blazing_Finale = 1575;
Global $Burning_Refrain = 1576;
Global $Finale_of_Restoration = 1577;
Global $Mending_Refrain = 1578;
Global $Purifying_Finale = 1579;
Global $Bladeturn_Refrain = 1580;
Global $Glowing_Signet = 1581;
Global $Leaders_Zeal = 1583;
Global $Leaders_Comfort = 1584;
Global $Signet_of_Synergy = 1585;
Global $Angelic_Protection = 1586;
Global $Angelic_Bond = 1587;
Global $Cautery_Signet = 1588;
Global $Stand_Your_Ground = 1589;
Global $Lead_the_Way = 1590;
Global $Make_Haste = 1591;
Global $We_Shall_Return = 1592;
Global $Never_Give_Up = 1593;
Global $Help_Me = 1594;
Global $Fall_Back = 1595;
Global $Incoming = 1596;
Global $Theyre_on_Fire = 1597;
Global $Never_Surrender = 1598;
Global $Its_just_a_flesh_wound = 1599;
Global $Barbed_Spear = 1600;
Global $Vicious_Attack = 1601;
Global $Stunning_Strike = 1602;
Global $Merciless_Spear = 1603;
Global $Disrupting_Throw = 1604;
Global $Wild_Throw = 1605;
Global $Curse_of_the_Staff_of_the_Mists = 1606;
Global $Aura_of_the_Staff_of_the_Mists = 1607;
Global $Power_of_the_Staff_of_the_Mists = 1608;
Global $Scepter_of_Ether = 1609;
Global $Summoning_of_the_Scepter = 1610;
Global $Rise_From_Your_Grave = 1611;
Global $Corsair_Disguise = 1613;
Global $Queen_Heal = 1616;
Global $Queen_Wail = 1617;
Global $Queen_Armor = 1618;
Global $Queen_Bite = 1619;
Global $Queen_Thump = 1620;
Global $Queen_Siege = 1621;
Global $Dervish_of_the_Mystic = 1624;
Global $Dervish_of_the_Wind = 1625;
Global $Paragon_of_Leadership = 1626;
Global $Paragon_of_Motivation = 1627;
Global $Dervish_of_the_Blade = 1628;
Global $Paragon_of_Command = 1629;
Global $Paragon_of_the_Spear = 1630;
Global $Dervish_of_the_Earth = 1631;
Global $Malicious_Strike = 1633;
Global $Shattering_Assault = 1634;
Global $Golden_Skull_Strike = 1635;
Global $Black_Spider_Strike = 1636;
Global $Golden_Fox_Strike = 1637;
Global $Deadly_Haste = 1638;
Global $Assassins_Remedy = 1639;
Global $Foxs_Promise = 1640;
Global $Feigned_Neutrality = 1641;
Global $Hidden_Caltrops = 1642;
Global $Assault_Enchantments = 1643;
Global $Wastrels_Collapse = 1644;
Global $Lift_Enchantment = 1645;
Global $Augury_of_Death = 1646;
Global $Signet_of_Toxic_Shock = 1647;
Global $Signet_of_Twilight = 1648;
Global $Way_of_the_Assassin = 1649;
Global $Shadow_Walk = 1650;
Global $Deaths_Retreat = 1651;
Global $Shadow_Prison = 1652;
Global $Swap = 1653;
Global $Shadow_Meld = 1654;
Global $Price_of_Pride = 1655;
Global $Air_of_Disenchantment = 1656;
Global $Signet_of_Clumsiness = 1657;
Global $Symbolic_Posture = 1658;
Global $Toxic_Chill = 1659;
Global $Well_of_Silence = 1660;
Global $Glowstone = 1661;
Global $Mind_Blast = 1662;
Global $Elemental_Flame = 1663;
Global $Invoke_Lightning = 1664;
Global $Battle_Cry = 1665;
Global $Energy_Shrine_Bonus = 1667;
Global $Northern_Health_Shrine_Bonus = 1668;
Global $Southern_Health_Shrine_Bonus = 1669;
Global $Curse_of_Silence = 1671;
Global $To_the_Pain_Hero_Battles = 1672;
Global $Edge_of_Reason = 1673;
Global $Depths_of_Madness_environment_effect = 1674;
Global $Cower_in_Fear = 1675;
Global $Dreadful_Pain = 1676;
Global $Veiled_Nightmare = 1677;
Global $Base_Protection = 1678;
Global $Kournan_Siege_Flame = 1679;
Global $Drake_Skin = 1680;
Global $Skale_Vigor = 1681;
Global $Pahnai_Salad_item_effect = 1682;
Global $Pensive_Guardian = 1683;
Global $Scribes_Insight = 1684;
Global $Holy_Haste = 1685;
Global $Glimmer_of_Light = 1686;
Global $Zealous_Benediction = 1687;
Global $Defenders_Zeal = 1688;
Global $Signet_of_Mystic_Wrath = 1689;
Global $Signet_of_Removal = 1690;
Global $Dismiss_Condition = 1691;
Global $Divert_Hexes = 1692;
Global $Counterattack = 1693;
Global $Magehunter_Strike = 1694;
Global $Soldiers_Strike = 1695;
Global $Decapitate = 1696;
Global $Magehunters_Smash = 1697;
Global $Soldiers_Stance = 1698;
Global $Soldiers_Defense = 1699;
Global $Frenzied_Defense = 1700;
Global $Steady_Stance = 1701;
Global $Steelfang_Slash = 1702;
Global $Sunspear_Battle_Call = 1703;
Global $Earth_Shattering_Blow = 1705;
Global $Corrupt_Power = 1706;
Global $Words_of_Madness = 1707;
Global $Gaze_of_MoavuKaal = 1708;
Global $Presence_of_the_Skale_Lord = 1709;
Global $Madness_Dart = 1710;
Global $Reform_Carvings = 1715;
Global $Sunspear_Siege = 1717;
Global $Soul_Torture = 1718;
Global $Screaming_Shot = 1719;
Global $Keen_Arrow = 1720;
Global $Rampage_as_One = 1721;
Global $Forked_Arrow = 1722;
Global $Disrupting_Accuracy = 1723;
Global $Experts_Dexterity = 1724;
Global $Roaring_Winds = 1725;
Global $Magebane_Shot = 1726;
Global $Natural_Stride = 1727;
Global $Hekets_Rampage = 1728;
Global $Smoke_Trap = 1729;
Global $Infuriating_Heat = 1730;
Global $Vocal_Was_Sogolon = 1731;
Global $Destructive_Was_Glaive = 1732;
Global $Wielders_Strike = 1733;
Global $Gaze_of_Fury = 1734;
Global $Gaze_of_Fury_attack = 1735;
Global $Spirits_Strength = 1736;
Global $Wielders_Zeal = 1737;
Global $Sight_Beyond_Sight = 1738;
Global $Renewing_Memories = 1739;
Global $Wielders_Remedy = 1740;
Global $Ghostmirror_Light = 1741;
Global $Signet_of_Ghostly_Might = 1742;
Global $Signet_of_Binding = 1743;
Global $Caretakers_Charge = 1744;
Global $Anguish = 1745;
Global $Anguish_attack = 1746;
Global $Empowerment = 1747;
Global $Recovery = 1748;
Global $Weapon_of_Fury = 1749;
Global $Xinraes_Weapon = 1750;
Global $Warmongers_Weapon = 1751;
Global $Weapon_of_Remedy = 1752;
Global $Rending_Sweep = 1753;
Global $Onslaught = 1754;
Global $Mystic_Corruption = 1755;
Global $Grenths_Grasp = 1756;
Global $Veil_of_Thorns = 1757;
Global $Harriers_Grasp = 1758;
Global $Vow_of_Strength = 1759;
Global $Ebon_Dust_Aura = 1760;
Global $Zealous_Vow = 1761;
Global $Heart_of_Fury = 1762;
Global $Zealous_Renewal = 1763;
Global $Attackers_Insight = 1764;
Global $Rending_Aura = 1765;
Global $Featherfoot_Grace = 1766;
Global $Reapers_Sweep = 1767;
Global $Harriers_Haste = 1768;
Global $Focused_Anger = 1769;
Global $Natural_Temper = 1770;
Global $Song_of_Restoration = 1771;
Global $Lyric_of_Purification = 1772;
Global $Soldiers_Fury = 1773;
Global $Aggressive_Refrain = 1774;
Global $Energizing_Finale = 1775;
Global $Signet_of_Aggression = 1776;
Global $Remedy_Signet = 1777;
Global $Signet_of_Return = 1778;
Global $Make_Your_Time = 1779;
Global $Cant_Touch_This = 1780;
Global $Find_Their_Weakness = 1781;
Global $The_Power_Is_Yours = 1782;
Global $Slayers_Spear = 1783;
Global $Swift_Javelin = 1784;
Global $Skale_Hunt = 1790;
Global $Mandragor_Hunt = 1791;
Global $Skree_Battle = 1792;
Global $Insect_Hunt = 1793;
Global $Corsair_Bounty = 1794;
Global $Plant_Hunt = 1795;
Global $Undead_Hunt = 1796;
Global $Eternal_Suffering = 1797;
Global $Eternal_Languor = 1800;
Global $Eternal_Lethargy = 1803;
Global $Thirst_of_the_Drought = 1808;
Global $Lightbringer = 1813;
Global $Lightbringers_Gaze = 1814;
Global $Lightbringer_Signet = 1815;
Global $Sunspear_Rebirth_Signet = 1816;
Global $Wisdom = 1817;
Global $Maddened_Strike = 1818;
Global $Maddened_Stance = 1819;
Global $Spirit_Form = 1820;
Global $Monster_Hunt = 1822;
Global $Elemental_Hunt = 1826;
Global $Demon_Hunt = 1831;
Global $Minotaur_Hunt = 1832;
Global $Heket_Hunt = 1837;
Global $Kournan_Bounty = 1839;
Global $Dhuum_Battle = 1844;
Global $Menzies_Battle = 1845;
Global $Monolith_Hunt = 1847;
Global $Margonite_Battle = 1849;
Global $Titan_Hunt = 1851;
Global $Giant_Hunt = 1853;
Global $Kournan_Siege = 1855;
Global $Lose_your_Head = 1856;
Global $Altar_Buff = 1859;
Global $Choking_Breath = 1861;
Global $Junundu_Bite = 1862;
Global $Blinding_Breath = 1863;
Global $Burning_Breath = 1864;
Global $Junundu_Wail = 1865;
Global $Capture_Point = 1866;
Global $Approaching_the_Vortex = 1867;
Global $Avatar_of_Sweetness = 1871;
Global $Corrupted_Lands = 1873;
Global $Unknown_Junundu_Ability = 1876;
Global $Torment_Slash_Smothering_Tendrils = 1880;
Global $Bonds_of_Torment = 1881;
Global $Shadow_Smash = 1882;
Global $Consume_Torment = 1884;
Global $Banish_Enchantment = 1885;
Global $Summoning_Shadows = 1886;
Global $Lightbringers_Insight = 1887;
Global $Repressive_Energy = 1889;
Global $Enduring_Torment = 1890;
Global $Shroud_of_Darkness = 1891;
Global $Demonic_Miasma = 1892;
Global $Enraged = 1893;
Global $Touch_of_Aaaaarrrrrrggghhh = 1894;
Global $Wild_Smash = 1895;
Global $Unyielding_Anguish = 1896;
Global $Jadoths_Storm_of_Judgment = 1897;
Global $Anguish_Hunt = 1898;
Global $Avatar_of_Holiday_Cheer = 1899;
Global $Side_Step = 1900;
Global $Jack_Frost = 1901;
Global $Avatar_of_Grenth_snow_fighting_skill = 1902;
Global $Avatar_of_Dwayna_snow_fighting_skill = 1903;
Global $Steady_Aim = 1904;
Global $Rudis_Red_Nose = 1905;
Global $Volatile_Charr_Crystal = 1911;
Global $Hard_mode = 1912;
Global $Sugar_Jolt = 1916;
Global $Rollerbeetle_Racer = 1917;
Global $Ram = 1918;
Global $Harden_Shell = 1919;
Global $Rollerbeetle_Dash = 1920;
Global $Super_Rollerbeetle = 1921;
Global $Rollerbeetle_Echo = 1922;
Global $Distracting_Lunge = 1923;
Global $Rollerbeetle_Blast = 1924;
Global $Spit_Rocks = 1925;
Global $Lunar_Blessing = 1926;
Global $Lucky_Aura = 1927;
Global $Spiritual_Possession = 1928;
Global $Water = 1929;
Global $Pig_Form = 1930;
Global $Beetle_Metamorphosis = 1931;
Global $Golden_Egg_item_effect = 1934;
Global $Infernal_Rage = 1937;
Global $Putrid_Flames = 1938;
Global $Flame_Call = 1940;
Global $Whirling_Fires = 1942;
Global $Charr_Siege_Attack_What_Must_Be_Done = 1943;
Global $Charr_Siege_Attack_Against_the_Charr = 1944;
Global $Birthday_Cupcake_skill = 1945;
Global $Blessing_of_the_Luxons = 1947;
Global $Shadow_Sanctuary = 1948;
Global $Ether_Nightmare = 1949;
Global $Signet_of_Corruption = 1950;
Global $Elemental_Lord = 1951;
Global $Selfless_Spirit = 1952;
Global $Triple_Shot = 1953;
Global $Save_Yourselves = 1954;
Global $Aura_of_Holy_Might = 1955;
Global $Spear_of_Fury = 1957;
Global $Fire_Dart = 1983;
Global $Ice_Dart = 1984;
Global $Poison_Dart = 1985;
Global $Vampiric_Assault = 1986;
Global $Lotus_Strike = 1987;
Global $Golden_Fang_Strike = 1988;
Global $Falling_Lotus_Strike = 1990;
Global $Sadists_Signet = 1991;
Global $Signet_of_Distraction = 1992;
Global $Signet_of_Recall = 1993;
Global $Power_Lock = 1994;
Global $Waste_Not_Want_Not = 1995;
Global $Sum_of_All_Fears = 1996;
Global $Withering_Aura = 1997;
Global $Cacophony = 1998;
Global $Winters_Embrace = 1999;
Global $Earthen_Shackles = 2000;
Global $Ward_of_Weakness = 2001;
Global $Glyph_of_Swiftness = 2002;
Global $Cure_Hex = 2003;
Global $Smite_Condition = 2004;
Global $Smiters_Boon = 2005;
Global $Castigation_Signet = 2006;
Global $Purifying_Veil = 2007;
Global $Pulverizing_Smash = 2008;
Global $Keen_Chop = 2009;
Global $Knee_Cutter = 2010;
Global $Grapple = 2011;
Global $Radiant_Scythe = 2012;
Global $Grenths_Aura = 2013;
Global $Signet_of_Pious_Restraint = 2014;
Global $Farmers_Scythe = 2015;
Global $Energetic_Was_Lee_Sa = 2016;
Global $Anthem_of_Weariness = 2017;
Global $Anthem_of_Disruption = 2018;
Global $Freezing_Ground = 2020;
Global $Fire_Jet = 2022;
Global $Ice_Jet = 2023;
Global $Poison_Jet = 2024;
Global $Fire_Spout = 2027;
Global $Ice_Spout = 2028;
Global $Poison_Spout = 2029;
Global $Summon_Spirits = 2051;
Global $Shadow_Fang = 2052;
Global $Calculated_Risk = 2053;
Global $Shrinking_Armor = 2054;
Global $Aneurysm = 2055;
Global $Wandering_Eye = 2056;
Global $Foul_Feast = 2057;
Global $Putrid_Bile = 2058;
Global $Shell_Shock = 2059;
Global $Glyph_of_Immolation = 2060;
Global $Patient_Spirit = 2061;
Global $Healing_Ribbon = 2062;
Global $Aura_of_Stability = 2063;
Global $Spotless_Mind = 2064;
Global $Spotless_Soul = 2065;
Global $Disarm = 2066;
Global $I_Meant_to_Do_That = 2067;
Global $Rapid_Fire = 2068;
Global $Sloth_Hunters_Shot = 2069;
Global $Aura_Slicer = 2070;
Global $Zealous_Sweep = 2071;
Global $Pure_Was_Li_Ming = 2072;
Global $Weapon_of_Aggression = 2073;
Global $Chest_Thumper = 2074;
Global $Hasty_Refrain = 2075;
Global $Cracked_Armor = 2077;
Global $Berserk = 2078;
Global $Fleshreavers_Escape = 2079;
Global $Chomp = 2080;
Global $Twisting_Jaws = 2081;
Global $Mandragors_Charge = 2083;
Global $Rock_Slide = 2084;
Global $Avalanche_effect = 2085;
Global $Snaring_Web = 2086;
Global $Ceiling_Collapse = 2087;
Global $Trample = 2088;
Global $Wurm_Bile = 2089 ;
Global $Critical_Agility = 2101;
Global $Cry_of_Pain = 2102;
Global $Necrosis = 2103;
Global $Intensity = 2104;
Global $Seed_of_Life = 2105;
Global $Call_of_the_Eye = 2106;
Global $Whirlwind_Attack = 2107;
Global $Never_Rampage_Alone = 2108;
Global $Eternal_Aura = 2109;
Global $Vampirism = 2110;
Global $Vampirism_attack = 2111;
Global $Theres_Nothing_to_Fear = 2112;
Global $Ursan_Rage_Blood_Washes_Blood = 2113;
Global $Ursan_Strike_Blood_Washes_Blood = 2114;
Global $Sneak_Attack = 2116;
Global $Firebomb_Explosion = 2117;
Global $Firebomb = 2118;
Global $Shield_of_Fire = 2119;
Global $Spirit_World_Retreat = 2122;
Global $Shattered_Spirit = 2124;
Global $Spirit_Roar = 2125;
Global $Spirit_Senses = 2126;
Global $Unseen_Aggression = 2127;
Global $Volfen_Pounce_Curse_of_the_Nornbear = 2128;
Global $Volfen_Claw_Curse_of_the_Nornbear = 2129;
Global $Volfen_Bloodlust_Curse_of_the_Nornbear = 2131;
Global $Volfen_Agility_Curse_of_the_Nornbear = 2132;
Global $Volfen_Blessing_Curse_of_the_Nornbear = 2133;
Global $Charging_Spirit = 2134;
Global $Trampling_Ox = 2135;
Global $Smoke_Powder_Defense = 2136;
Global $Confusing_Images = 2137;
Global $Hexers_Vigor = 2138;
Global $Masochism = 2139;
Global $Piercing_Trap = 2140;
Global $Companionship = 2141;
Global $Feral_Aggression = 2142;
Global $Disrupting_Shot = 2143;
Global $Volley = 2144;
Global $Expert_Focus = 2145;
Global $Pious_Fury = 2146;
Global $Crippling_Victory = 2147;
Global $Sundering_Weapon = 2148;
Global $Weapon_of_Renewal = 2149;
Global $Maiming_Spear = 2150;
Global $Temporal_Sheen = 2151;
Global $Flux_Overload = 2152;
Global $Phase_Shield_effect = 2154;
Global $Phase_Shield = 2155;
Global $Vitality_Transfer = 2156;
Global $Golem_Strike = 2157;
Global $Bloodstone_Slash = 2158;
Global $Energy_Blast_golem = 2159;
Global $Chaotic_Energy = 2160;
Global $Golem_Fire_Shield = 2161;
Global $The_Way_of_Duty = 2162;
Global $The_Way_of_Kinship = 2163;
Global $Diamondshard_Mist_environment_effect = 2164;
Global $Diamondshard_Grave = 2165;
Global $The_Way_of_Strength = 2166;
Global $Diamondshard_Mist = 2167;
Global $Raven_Blessing_A_Gate_Too_Far = 2168;
Global $Raven_Flight_A_Gate_Too_Far = 2170;
Global $Raven_Shriek_A_Gate_Too_Far = 2171;
Global $Raven_Swoop_A_Gate_Too_Far = 2172;
Global $Raven_Talons_A_Gate_Too_Far = 2173;
Global $Aspect_of_Oak = 2174;
Global $Tremor = 2176;
Global $Pyroclastic_Shot = 2180;
Global $Rolling_Shift = 2184;
Global $Powder_Keg_Explosion = 2185;
Global $Signet_of_Deadly_Corruption = 2186;
Global $Way_of_the_Master = 2187;
Global $Defile_Defenses = 2188;
Global $Angorodons_Gaze = 2189;
Global $Magnetic_Surge = 2190;
Global $Slippery_Ground = 2191;
Global $Glowing_Ice = 2192;
Global $Energy_Blast = 2193;
Global $Distracting_Strike = 2194;
Global $Symbolic_Strike = 2195;
Global $Soldiers_Speed = 2196;
Global $Body_Blow = 2197;
Global $Body_Shot = 2198;
Global $Poison_Tip_Signet = 2199;
Global $Signet_of_Mystic_Speed = 2200;
Global $Shield_of_Force = 2201;
Global $Mending_Grip = 2202;
Global $Spiritleech_Aura = 2203;
Global $Rejuvenation = 2204;
Global $Agony = 2205;
Global $Ghostly_Weapon = 2206;
Global $Inspirational_Speech = 2207;
Global $Burning_Shield = 2208;
Global $Holy_Spear = 2209;
Global $Spear_Swipe = 2210;
Global $Alkars_Alchemical_Acid = 2211;
Global $Light_of_Deldrimor = 2212;
Global $Ear_Bite = 2213;
Global $Low_Blow = 2214;
Global $Brawling_Headbutt = 2215;
Global $Dont_Trip = 2216;
Global $By_Urals_Hammer = 2217;
Global $Drunken_Master = 2218;
Global $Great_Dwarf_Weapon = 2219;
Global $Great_Dwarf_Armor = 2220;
Global $Breath_of_the_Great_Dwarf = 2221;
Global $Snow_Storm = 2222;
Global $Black_Powder_Mine = 2223;
Global $Summon_Mursaat = 2224;
Global $Summon_Ruby_Djinn = 2225;
Global $Summon_Ice_Imp = 2226;
Global $Summon_Naga_Shaman = 2227;
Global $Deft_Strike = 2228;
Global $Signet_of_Infection = 2229;
Global $Tryptophan_Signet = 2230;
Global $Ebon_Battle_Standard_of_Courage = 2231;
Global $Ebon_Battle_Standard_of_Wisdom = 2232;
Global $Ebon_Battle_Standard_of_Honor = 2233;
Global $Ebon_Vanguard_Sniper_Support = 2234;
Global $Ebon_Vanguard_Assassin_Support = 2235;
Global $Well_of_Ruin = 2236;
Global $Atrophy = 2237;
Global $Spear_of_Redemption = 2238;
Global $Gelatinous_Material_Explosion = 2240;
Global $Gelatinous_Corpse_Consumption = 2241;
Global $Gelatinous_Absorption = 2243;
Global $Unstable_Ooze_Explosion = 2244;
Global $Unstable_Aura = 2246;
Global $Unstable_Pulse = 2247;
Global $Polymock_Power_Drain = 2248;
Global $Polymock_Block = 2249;
Global $Polymock_Glyph_of_Concentration = 2250;
Global $Polymock_Ether_Signet = 2251;
Global $Polymock_Glyph_of_Power = 2252;
Global $Polymock_Overload = 2253;
Global $Polymock_Glyph_Destabilization = 2254;
Global $Polymock_Mind_Wreck = 2255;
Global $Order_of_Unholy_Vigor = 2256;
Global $Order_of_the_Lich = 2257;
Global $Master_of_Necromancy = 2258;
Global $Animate_Undead = 2259;
Global $Polymock_Deathly_Chill = 2260;
Global $Polymock_Rising_Bile = 2261;
Global $Polymock_Rotting_Flesh = 2262;
Global $Polymock_Lightning_Strike = 2263;
Global $Polymock_Lightning_Orb = 2264;
Global $Polymock_Lightning_Djinns_Haste = 2265;
Global $Polymock_Flare = 2266;
Global $Polymock_Immolate = 2267;
Global $Polymock_Meteor = 2268;
Global $Polymock_Ice_Spear = 2269;
Global $Polymock_Icy_Prison = 2270;
Global $Polymock_Mind_Freeze = 2271;
Global $Polymock_Ice_Shard_Storm = 2272;
Global $Polymock_Frozen_Trident = 2273;
Global $Polymock_Smite = 2274;
Global $Polymock_Smite_Hex = 2275;
Global $Polymock_Bane_Signet = 2276;
Global $Polymock_Stone_Daggers = 2277;
Global $Polymock_Obsidian_Flame = 2278;
Global $Polymock_Earthquake = 2279;
Global $Polymock_Frozen_Armor = 2280;
Global $Polymock_Glyph_Freeze = 2281;
Global $Polymock_Fireball = 2282;
Global $Polymock_Rodgorts_Invocation = 2283;
Global $Polymock_Calculated_Risk = 2284;
Global $Polymock_Recurring_Insecurity = 2285;
Global $Polymock_Backfire = 2286;
Global $Polymock_Guilt = 2287;
Global $Polymock_Lamentation = 2288;
Global $Polymock_Spirit_Rift = 2289;
Global $Polymock_Painful_Bond = 2290;
Global $Polymock_Signet_of_Clumsiness = 2291;
Global $Polymock_Migraine = 2292;
Global $Polymock_Glowing_Gaze = 2293;
Global $Polymock_Searing_Flames = 2294;
Global $Polymock_Signet_of_Revenge = 2295;
Global $Polymock_Signet_of_Smiting = 2296;
Global $Polymock_Stoning = 2297;
Global $Polymock_Eruption = 2298;
Global $Polymock_Shock_Arrow = 2299;
Global $Polymock_Mind_Shock = 2300;
Global $Polymock_Piercing_Light_Spear = 2301;
Global $Polymock_Mind_Blast = 2302;
Global $Polymock_Savannah_Heat = 2303;
Global $Polymock_Diversion = 2304;
Global $Polymock_Lightning_Blast = 2305;
Global $Polymock_Poisoned_Ground = 2306;
Global $Polymock_Icy_Bonds = 2307;
Global $Polymock_Sandstorm = 2308;
Global $Polymock_Banish = 2309;
Global $Mergoyle_Form = 2310;
Global $Skale_Form = 2311;
Global $Gargoyle_Form = 2312;
Global $Ice_Imp_Form = 2313;
Global $Fire_Imp_Form = 2314;
Global $Kappa_Form = 2315;
Global $Aloe_Seed_Form = 2316;
Global $Earth_Elemental_Form = 2317;
Global $Fire_Elemental_Form = 2318;
Global $Ice_Elemental_Form = 2319;
Global $Mirage_Iboga_Form = 2320;
Global $Wind_Rider_Form = 2321;
Global $Naga_Shaman_Form = 2322;
Global $Mantis_Dreamweaver_Form = 2323;
Global $Ruby_Djinn_Form = 2324;
Global $Gaki_Form = 2325;
Global $Stone_Rain_Form = 2326;
Global $Mursaat_Elementalist_Form = 2327;
Global $Crystal_Shield = 2328;
Global $Crystal_Snare = 2329;
Global $Paranoid_Indignation = 2330;
Global $Searing_Breath = 2331;
Global $Brawling = 2333;
Global $Brawling_Block = 2334;
Global $Brawling_Jab = 2335;
Global $Brawling_Straight_Right = 2337;
Global $Brawling_Hook = 2338;
Global $Brawling_Uppercut = 2340;
Global $Brawling_Combo_Punch = 2341;
Global $Brawling_Headbutt_Brawling_skill = 2342;
Global $STAND_UP = 2343;
Global $Call_of_Destruction = 2344;
Global $Lava_Ground = 2346;
Global $Lava_Wave = 2347;
Global $Charr_Siege_Attack_Assault_on_the_Stronghold = 2352;
Global $Finish_Him = 2353;
Global $Dodge_This = 2354;
Global $I_Am_The_Strongest = 2355;
Global $I_Am_Unstoppable = 2356;
Global $A_Touch_of_Guile = 2357;
Global $You_Move_Like_a_Dwarf = 2358;
Global $You_Are_All_Weaklings = 2359;
Global $Feel_No_Pain = 2360;
Global $Club_of_a_Thousand_Bears = 2361;
Global $Lava_Blast = 2364;
Global $Thunderfist_Strike = 2365;
Global $Alkars_Concoction = 2367;
Global $Murakais_Consumption = 2368;
Global $Murakais_Censure = 2369;
Global $Murakais_Calamity = 2370;
Global $Murakais_Storm_of_Souls = 2371;
Global $Edification = 2372;
Global $Heart_of_the_Norn = 2373;
Global $Ursan_Blessing = 2374;
Global $Ursan_Strike = 2375;
Global $Ursan_Rage = 2376;
Global $Ursan_Roar = 2377;
Global $Ursan_Force = 2378;
Global $Volfen_Blessing = 2379;
Global $Volfen_Claw = 2380;
Global $Volfen_Pounce = 2381;
Global $Volfen_Bloodlust = 2382;
Global $Volfen_Agility = 2383;
Global $Raven_Blessing = 2384;
Global $Raven_Talons = 2385;
Global $Raven_Swoop = 2386;
Global $Raven_Shriek = 2387;
Global $Raven_Flight = 2388;
Global $Totem_of_Man = 2389;
Global $Murakais_Call = 2391;
Global $Spawn_Pods = 2392;
Global $Enraged_Blast = 2393;
Global $Spawn_Hatchling = 2394;
Global $Ursan_Roar_Blood_Washes_Blood = 2395;
Global $Ursan_Force_Blood_Washes_Blood = 2396;
Global $Ursan_Aura = 2397;
Global $Consume_Flames = 2398;
Global $Charr_Flame_Keeper_Form = 2401;
Global $Titan_Form = 2402;
Global $Skeletal_Mage_Form = 2403;
Global $Smoke_Wraith_Form = 2404;
Global $Bone_Dragon_Form = 2405;
Global $Dwarven_Arcanist_Form = 2407;
Global $Dolyak_Rider_Form = 2408;
Global $Extract_Inscription = 2409;
Global $Charr_Shaman_Form = 2410;
Global $Mindbender = 2411;
Global $Smooth_Criminal = 2412;
Global $Technobabble = 2413;
Global $Radiation_Field = 2414;
Global $Asuran_Scan = 2415;
Global $Air_of_Superiority = 2416;
Global $Mental_Block = 2417;
Global $Pain_Inverter = 2418;
Global $Healing_Salve = 2419;
Global $Ebon_Escape = 2420;
Global $Weakness_Trap = 2421;
Global $Winds = 2422;
Global $Dwarven_Stability = 2423;
Global $StoutHearted = 2424;
Global $Decipher_Inscriptions = 2426;
Global $Rebel_Yell = 2427;
Global $Asuran_Flame_Staff = 2429;
Global $Aura_of_the_Bloodstone = 2430;
Global $Haunted_Ground = 2433;
Global $Asuran_Bodyguard = 2434;
Global $Energy_Channel = 2437;
Global $Hunt_Rampage_Asura = 2438;
Global $Boss_Bounty = 2440;
Global $Hunt_Point_Bonus_Asura = 2441;
Global $Time_Attack = 2444;
Global $Dwarven_Raider = 2445;
Global $Great_Dwarfs_Blessing = 2449;
Global $Hunt_Rampage_Deldrimor = 2450;
Global $Hunt_Point_Bonus = 2453;
Global $Vanguard_Patrol = 2457;
Global $Vanguard_Commendation = 2461;
Global $Hunt_Rampage_Ebon_Vanguard = 2462;
Global $Norn_Hunting_Party = 2469;
Global $Strength_of_the_Norn = 2473;
Global $Hunt_Rampage_Norn = 2474;
Global $Gloat = 2483;
Global $Metamorphosis = 2484;
Global $Inner_Fire = 2485;
Global $Elemental_Shift = 2486;
Global $Dryders_Feast = 2487;
Global $Fungal_Explosion = 2488;
Global $Blood_Rage = 2489;
Global $Parasitic_Bite = 2490;
Global $False_Death = 2491;
Global $Ooze_Combination = 2492;
Global $Ooze_Division = 2493;
Global $Bear_Form = 2494;
Global $Spore_Explosion = 2496;
Global $Dormant_Husk = 2497;
Global $Monkey_See_Monkey_Do = 2498;
Global $Tengus_Mimicry = 2500;
Global $Tongue_Lash = 2501;
Global $Soulrending_Shriek = 2502;
Global $Siege_Devourer = 2504;
Global $Siege_Devourer_Feast = 2505;
Global $Devourer_Bite = 2506;
Global $Siege_Devourer_Swipe = 2507;
Global $Devourer_Siege = 2508;
Global $HYAHHHHH = 2509;
Global $Dismount_Siege_Devourer = 2513;
Global $The_Masters_Mark = 2514;
Global $The_Snipers_Spear = 2515;
Global $Mount = 2516;
Global $Reverse_Polarity_Fire_Shield = 2517;
Global $Tengus_Gaze = 2518;
Global $Armor_of_Salvation_item_effect = 2520;
Global $Grail_of_Might_item_effect = 2521;
Global $Essence_of_Celerity_item_effect = 2522;
Global $Duncans_Defense = 2527;
Global $Invigorating_Mist = 2536;
Global $Courageous_Was_Saidra = 2537;
Global $Animate_Undead_Palawa_Joko = 2538;
Global $Order_of_Unholy_Vigor_Palawa_Joko = 2539;
Global $Order_of_the_Lich_Palawa_Joko = 2540;
Global $Golem_Boosters = 2541;
Global $Tongue_Whip = 2544;
Global $Lit_Torch = 2545;
Global $Dishonorable = 2546;
Global $Veteran_Asuran_Bodyguard = 2548;
Global $Veteran_Dwarven_Raider = 2549;
Global $Veteran_Vanguard_Patrol = 2550;
Global $Veteran_Norn_Hunting_Party = 2551 ;
Global $Candy_Corn_skill = 2604;
Global $Candy_Apple_skill = 2605;
Global $Anton_disguise = 2606;
Global $Erys_Vasburg_disguise = 2607;
Global $Olias_disguise = 2608;
Global $Argo_disguise = 2609;
Global $Mhenlo_disguise = 2610;
Global $Lukas_disguise = 2611;
Global $Aidan_disguise = 2612;
Global $Kahmu_disguise = 2613;
Global $Razah_disguise = 2614;
Global $Morgahn_disguise = 2615;
Global $Nika_disguise = 2616;
Global $Seaguard_Hala_disguise = 2617;
Global $Livia_disguise = 2618;
Global $Cynn_disguise = 2619;
Global $Tahlkora_disguise = 2620;
Global $Devona_disguise = 2621;
Global $Zho_disguise = 2622;
Global $Melonni_disguise = 2623;
Global $Xandra_disguise = 2624;
Global $Hayda_disguise = 2625 ;
Global $Pie_Induced_Ecstasy = 2649;
Global $Togo_disguise = 2651;
Global $Turai_Ossa_disguise = 2652;
Global $Gwen_disguise = 2653;
Global $Saul_DAlessio_disguise = 2654;
Global $Dragon_Empire_Rage = 2655;
Global $Call_to_the_Spirit_Realm = 2656;
Global $Hide = 2658;
Global $Feign_Death = 2659;
Global $Flee = 2660;
Global $Throw_Rock = 2661;
Global $Siege_Strike = 2663;
Global $Spike_Trap_spell = 2664;
Global $Barbed_Bomb = 2665;
Global $Balm_Bomb = 2667;
Global $Explosives = 2668;
Global $Rations = 2669;
Global $Form_Up_and_Advance = 2670;
Global $Spectral_Agony_hex = 2672;
Global $Stun_Bomb = 2673;
Global $Banner_of_the_Unseen = 2674;
Global $Signet_of_the_Unseen = 2675;
Global $For_Elona = 2676;
Global $Giant_Stomp_Turai_Ossa = 2677;
Global $Whirlwind_Attack_Turai_Ossa = 2678;
Global $Journey_to_the_North = 2699;
Global $Rat_Form = 2701;
Global $Party_Time = 2712;
Global $Awakened_Head_Form = 2841;
Global $Spider_Form = 2842;
Global $Golem_Form = 2844;
Global $Norn_Form = 2846;
Global $Rift_Warden_Form = 2848;
Global $Snowman_Form = 2851;
Global $Energy_Drain_PvP = 2852;
Global $Energy_Tap_PvP = 2853;
Global $PvP_effect = 2854;
Global $Ward_Against_Melee_PvP = 2855;
Global $Lightning_Orb_PvP = 2856;
Global $Aegis_PvP = 2857;
Global $Watch_Yourself_PvP = 2858;
Global $Enfeeble_PvP = 2859;
Global $Ether_Renewal_PvP = 2860;
Global $Penetrating_Attack_PvP = 2861;
Global $Shadow_Form_PvP = 2862;
Global $Discord_PvP = 2863;
Global $Sundering_Attack_PvP = 2864;
Global $Ritual_Lord_PvP = 2865;
Global $Flesh_of_My_Flesh_PvP = 2866;
Global $Ancestors_Rage_PvP = 2867;
Global $Splinter_Weapon_PvP = 2868;
Global $Assassins_Remedy_PvP = 2869;
Global $Blinding_Surge_PvP = 2870;
Global $Light_of_Deliverance_PvP = 2871;
Global $Death_Pact_Signet_PvP = 2872;
Global $Mystic_Sweep_PvP = 2873;
Global $Eremites_Attack_PvP = 2874;
Global $Harriers_Toss_PvP = 2875;
Global $Defensive_Anthem_PvP = 2876;
Global $Ballad_of_Restoration_PvP = 2877;
Global $Song_of_Restoration_PvP = 2878;
Global $Incoming_PvP = 2879;
Global $Never_Surrender_PvP = 2880;
Global $Mantra_of_Inscriptions_PvP = 2882;
Global $For_Great_Justice_PvP = 2883;
Global $Mystic_Regeneration_PvP = 2884;
Global $Enfeebling_Blood_PvP = 2885;
Global $Summoning_Sickness = 2886;
Global $Signet_of_Judgment_PvP = 2887;
Global $Chilling_Victory_PvP = 2888;
Global $Unyielding_Aura_PvP = 2891;
Global $Spirit_Bond_PvP = 2892;
Global $Weapon_of_Warding_PvP = 2893;
Global $Smiters_Boon_PvP = 2895;
Global $Battle_Fervor_Deactivating_ROX = 2896;
Global $Cloak_of_Faith_Deactivating_ROX = 2897;
Global $Dark_Aura_Deactivating_ROX = 2898;
Global $Reactor_Blast = 2902;
Global $Reactor_Blast_Timer = 2903;
Global $Jade_Brotherhood_Disguise = 2904;
Global $Internal_Power_Engaged = 2905;
Global $Target_Acquisition = 2906;
Global $NOX_Beam = 2907;
Global $NOX_Field_Dash = 2908;
Global $NOXion_Buster = 2909;
Global $Countdown = 2910;
Global $Bit_Golem_Breaker = 2911;
Global $Bit_Golem_Rectifier = 2912;
Global $Bit_Golem_Crash = 2913;
Global $Bit_Golem_Force = 2914;
Global $NOX_Phantom = 2916;
Global $NOX_Thunder = 2917;
Global $NOX_Lock_On = 2918;
Global $NOX_Driver = 2919;
Global $NOX_Fire = 2920;
Global $NOX_Knuckle = 2921;
Global $NOX_Divider_Drive = 2922;
Global $Sloth_Hunters_Shot_PvP = 2925;
Global $Experts_Dexterity_PvP = 2959;
Global $Signet_of_Spirits_PvP = 2965;
Global $Signet_of_Ghostly_Might_PvP = 2966;
Global $Avatar_of_Grenth_PvP = 2967;
Global $Oversized_Tonic_Warning = 2968;
Global $Read_the_Wind_PvP = 2969;
Global $Blue_Rock_Candy_Rush = 2971;
Global $Green_Rock_Candy_Rush = 2972;
Global $Red_Rock_Candy_Rush = 2973;
Global $Fall_Back_PVP = 3037;
Global $Well_Supplied = 3174;
#EndRegion All Skill IDs, Global Variables

#Region All Map Names, Global Variables
Global Enum _
		$ATTR_FAST_CASTING, $ATTR_ILLUSION_MAGIC, $ATTR_DOMINATION_MAGIC, $ATTR_INSPIRATION_MAGIC, _
		$ATTR_BLOOD_MAGIC, $ATTR_DEATH_MAGIC, $ATTR_SOUL_REAPING, $ATTR_CURSES, _
		$ATTR_AIR_MAGIC, $ATTR_EARTH_MAGIC, $ATTR_FIRE_MAGIC, $ATTR_WATER_MAGIC, $ATTR_ENERGY_STORAGE, _
		$ATTR_HEALING_PRAYERS, $ATTR_SMITING_PRAYERS, $ATTR_PROTECTION_PRAYERS, $ATTR_DIVINE_FAVOR, _
		$ATTR_STRENGTH, $ATTR_AXE_MASTERY, $ATTR_HAMMER_MASTERY, $ATTR_SWORDSMANSHIP, $ATTR_TACTICS, _
		$ATTR_BEAST_MASTERY, $ATTR_EXPERTISE, $ATTR_WILDERNESS_SURVIVAL, $ATTR_MARKSMANSHIP, _
		$ATTR_DAGGER_MASTERY = 29, $ATTR_DEADLY_ARTS, $ATTR_SHADOW_ARTS, _
		$ATTR_COMMUNING, $ATTR_RESTORATION_MAGIC, $ATTR_CHANNELING_MAGIC, _
		$ATTR_CRITICAL_STRIKES, _
		$ATTR_SPAWNING_POWER, _
		$ATTR_SPEAR_MASTERY, $ATTR_COMMAND, $ATTR_MOTIVATION, $ATTR_LEADERSHIP, _
		$ATTR_SCYTHE_MASTERY, $ATTR_WIND_PRAYERS, $ATTR_EARTH_PRAYERS, $ATTR_MYSTICISM, _
		$ATTR_PVE, $ATTR_PVE2, _
		$ATTR_NONE = 0xFF

Global $ATTR_NAME[47]
$ATTR_NAME[$ATTR_FAST_CASTING] = "Fast Casting"
$ATTR_NAME[$ATTR_ILLUSION_MAGIC] = "Illusion Magic"
$ATTR_NAME[$ATTR_DOMINATION_MAGIC] = "Domination Magic"
$ATTR_NAME[$ATTR_INSPIRATION_MAGIC] = "Inspiration Magic"
$ATTR_NAME[$ATTR_BLOOD_MAGIC] = "Blood Magic"
$ATTR_NAME[$ATTR_DEATH_MAGIC] = "Death Magic"
$ATTR_NAME[$ATTR_SOUL_REAPING] = "Soul Reaping"
$ATTR_NAME[$ATTR_CURSES] = "Curses"
$ATTR_NAME[$ATTR_AIR_MAGIC] = "Air Magic"
$ATTR_NAME[$ATTR_EARTH_MAGIC] = "Earth Magic"
$ATTR_NAME[$ATTR_FIRE_MAGIC] = "Fire Magic"
$ATTR_NAME[$ATTR_WATER_MAGIC] = "Water Magic"
$ATTR_NAME[$ATTR_ENERGY_STORAGE] = "Energy Storage"
$ATTR_NAME[$ATTR_HEALING_PRAYERS] = "Healing Prayers"
$ATTR_NAME[$ATTR_SMITING_PRAYERS] = "Smiting Prayers"
$ATTR_NAME[$ATTR_PROTECTION_PRAYERS] = "Protection Prayers"
$ATTR_NAME[$ATTR_DIVINE_FAVOR] = "Divine Favor"
$ATTR_NAME[$ATTR_STRENGTH] = "Strength"
$ATTR_NAME[$ATTR_AXE_MASTERY] = "Axe Mastery"
$ATTR_NAME[$ATTR_HAMMER_MASTERY] = "Hammer Mastery"
$ATTR_NAME[$ATTR_SWORDSMANSHIP] = "Swordsmanship"
$ATTR_NAME[$ATTR_TACTICS] = "Tactics"
$ATTR_NAME[$ATTR_BEAST_MASTERY] = "Beast Mastery"
$ATTR_NAME[$ATTR_EXPERTISE] = "Expertise"
$ATTR_NAME[$ATTR_WILDERNESS_SURVIVAL] = "Wilderness Survival"
$ATTR_NAME[$ATTR_MARKSMANSHIP] = "Marksmanship"
$ATTR_NAME[$ATTR_DAGGER_MASTERY] = "Dagger Mastery"
$ATTR_NAME[$ATTR_DEADLY_ARTS] = "Deadly Arts"
$ATTR_NAME[$ATTR_SHADOW_ARTS] = "Shadow Arts"
$ATTR_NAME[$ATTR_COMMUNING] = "Communing"
$ATTR_NAME[$ATTR_RESTORATION_MAGIC] = "Restoration Magic"
$ATTR_NAME[$ATTR_CHANNELING_MAGIC] = "Channeling Magic"
$ATTR_NAME[$ATTR_CRITICAL_STRIKES] = "Critical Strikes"
$ATTR_NAME[$ATTR_SPAWNING_POWER] = "Spawning Power"
$ATTR_NAME[$ATTR_SPEAR_MASTERY] = "Spear Mastery"
$ATTR_NAME[$ATTR_COMMAND] = "Command"
$ATTR_NAME[$ATTR_MOTIVATION] = "Motivation"
$ATTR_NAME[$ATTR_LEADERSHIP] = "Leadership"
$ATTR_NAME[$ATTR_SCYTHE_MASTERY] = "Scythe Mastery"
$ATTR_NAME[$ATTR_WIND_PRAYERS] = "Wind Prayers"
$ATTR_NAME[$ATTR_EARTH_PRAYERS] = "Earth Prayers"
$ATTR_NAME[$ATTR_MYSTICISM] = "Mysticism"
$ATTR_NAME[$ATTR_PVE] = "PVE"
$ATTR_NAME[$ATTR_PVE2] = "PVE"

#Region ModStruct_headpiece
Global Const $MODSTRUCT_HEADPIECE_DOMINATION_MAGIC = "3F"
Global Const $MODSTRUCT_HEADPIECE_FAST_CASTING = "40"
Global Const $MODSTRUCT_HEADPIECE_ILLUSION_MAGIC = "41"
Global Const $MODSTRUCT_HEADPIECE_INSPIRATION_MAGIC = "42"

Global Const $MODSTRUCT_HEADPIECE_BLOOD_MAGIC = "43"
Global Const $MODSTRUCT_HEADPIECE_CURSES = "44"
Global Const $MODSTRUCT_HEADPIECE_DEATH_MAGIC = "45"
Global Const $MODSTRUCT_HEADPIECE_SOUL_REAPING = "46"

Global Const $MODSTRUCT_HEADPIECE_AIR_MAGIC = "47"
Global Const $MODSTRUCT_HEADPIECE_EARTH_MAGIC = "48"
Global Const $MODSTRUCT_HEADPIECE_ENERGY_STORAGE = "49"
Global Const $MODSTRUCT_HEADPIECE_FIRE_MAGIC = "4A"
Global Const $MODSTRUCT_HEADPIECE_WATER_MAGIC = "4B"

Global Const $MODSTRUCT_HEADPIECE_DIVINE_FAVOR = "4C"
Global Const $MODSTRUCT_HEADPIECE_HEALING_PRAYERS = "4D"
Global Const $MODSTRUCT_HEADPIECE_PROTECTION_PRAYERS = "4E"
Global Const $MODSTRUCT_HEADPIECE_SMITING_PRAYERS = "4F"

Global Const $MODSTRUCT_HEADPIECE_AXE_MASTERY = "50"
Global Const $MODSTRUCT_HEADPIECE_HAMMER_MASTERY = "51"
Global Const $MODSTRUCT_HEADPIECE_SWORDSMANSHIP = "53"
Global Const $MODSTRUCT_HEADPIECE_STRENGTH = "54"
Global Const $MODSTRUCT_HEADPIECE_TACTICS = "55"

Global Const $MODSTRUCT_HEADPIECE_BEAST_MASTERY = "56"
Global Const $MODSTRUCT_HEADPIECE_MARKSMANSHIP = "57"
Global Const $MODSTRUCT_HEADPIECE_EXPERTISE = "58"
Global Const $MODSTRUCT_HEADPIECE_WILDERNESS_SURVIVAL = "59"
#EndRegion ModStruct_headpiece

#Region Map_IDs
Global $MAP_ID[860]
$MAP_ID[0] = 859
$MAP_ID[4] = "Guild Hall - Warrior's Isle"
$MAP_ID[5] = "Guild Hall - Hunter's Isle"
$MAP_ID[6] = "Guild Hall - Wizard's Isle"
$MAP_ID[10] = "Bloodstone Fen outpost"
$MAP_ID[11] = "The Wilds outpost"
$MAP_ID[12] = "Aurora Glade outpost"
$MAP_ID[14] = "Gates of Kryta outpost"
$MAP_ID[15] = "D'Alessio Seaboard outpost"
$MAP_ID[16] = "Divinity Coast outpost"
$MAP_ID[19] = "Sanctum Cay outpost"
$MAP_ID[20] = "Droknar's Forge"
$MAP_ID[21] = "The Frost Gate outpost"
$MAP_ID[22] = "Ice Caves of Sorrow outpost"
$MAP_ID[23] = "Thunderhead Keep outpost"
$MAP_ID[24] = "Iron Mines of Moladune outpost"
$MAP_ID[25] = "Borlis Pass outpost"
$MAP_ID[28] = "The Great Northern Wall outpost"
$MAP_ID[29] = "Fort Ranik outpost"
$MAP_ID[30] = "Ruins of Surmia outpost"
$MAP_ID[32] = "Nolani Academy outpost"
$MAP_ID[35] = "Ember Light Camp"
$MAP_ID[36] = "Grendich Courthouse"
$MAP_ID[38] = "Augury Rock outpost"
$MAP_ID[39] = "Sardelac Sanitarium"
$MAP_ID[40] = "Piken Square"
$MAP_ID[49] = "Henge of Denravi"
$MAP_ID[51] = "Senjis Corner"
$MAP_ID[52] = "Burning Isle"
$MAP_ID[55] = "Lions Arch"
$MAP_ID[57] = "Bergen Hot Springs"
$MAP_ID[73] = "Riverside Province outpost"
$MAP_ID[77] = "House zu Heltzer"
$MAP_ID[81] = "Ascalon City"
$MAP_ID[82] = "Tomb of the Primeval Kings"
$MAP_ID[85] = "Ascalon Arena outpost"
$MAP_ID[109] = "The Amnoon Oasis"
$MAP_ID[116] = "Dunes of Despair outpost"
$MAP_ID[117] = "Thirsty River outpost"
$MAP_ID[118] = "Elona Reach outpost"
;~ $MAP_ID[119] = "Augury Rock outpost"
$MAP_ID[120] = "The Dragon's Lair outpost"
$MAP_ID[122] = "Ring of Fire outpost"
$MAP_ID[123] = "Abaddon's Mouth outpost"
$MAP_ID[124] = "Hell's Precipice outpost"
$MAP_ID[129] = "Lutgardis Conservatory"
$MAP_ID[130] = "Vasburg Armory"
$MAP_ID[131] = "Serenity Temple"
$MAP_ID[132] = "Ice Tooth Cave"
$MAP_ID[133] = "Beacons Perch"
$MAP_ID[134] = "Yaks Bend"
$MAP_ID[135] = "Frontier Gate"
$MAP_ID[136] = "Beetletun"
$MAP_ID[137] = "Fishermens Haven"
$MAP_ID[138] = "Temple of the Ages"
$MAP_ID[139] = "Ventaris Refuge"
$MAP_ID[140] = "Druids Overlook"
$MAP_ID[141] = "Maguuma Stade"
$MAP_ID[142] = "Quarrel Falls"
$MAP_ID[148] = "Ascalon City outpost"
$MAP_ID[152] = "Heroes Audience"
$MAP_ID[153] = "Seekers Passage"
$MAP_ID[154] = "Destinys Gorge"
$MAP_ID[155] = "Camp Rankor"
$MAP_ID[156] = "The Granite Citadel"
$MAP_ID[157] = "Marhans Grotto"
$MAP_ID[158] = "Port Sledge"
$MAP_ID[159] = "Copperhammer Mines"
$MAP_ID[163] = "Pre-Searing: The Barradin Estate"
$MAP_ID[164] = "Pre-Searing: Ashford Abbey"
$MAP_ID[165] = "Pre-Searing: Foibles Fair"
$MAP_ID[166] = "Pre-Searing: Fort Ranik"
$MAP_ID[176] = "Guild Hall - Frozen Isle"
$MAP_ID[177] = "Guild Hall - Nomad's Isle"
$MAP_ID[178] = "Guild Hall - Druid's Isle"
$MAP_ID[179] = "Guild Hall - Isle of the Dead"
$MAP_ID[181] = "Shiverpeak Arena outpost"
$MAP_ID[188] = "Random Arenas outpost"
$MAP_ID[189] = "Team Arenas outpost"
$MAP_ID[193] = "Cavalon"
$MAP_ID[194] = "Kaineng Center"
$MAP_ID[204] = "Unwaking Waters - Kurzick"
$MAP_ID[206] = "Deldrimor War Camp"
$MAP_ID[213] = "Zen Daijun outpost"
$MAP_ID[214] = "Minister Chos Estate outpost"
$MAP_ID[216] = "Nahpui Quarter outpost"
$MAP_ID[217] = "Tahnnakai Temple outpost"
$MAP_ID[218] = "Arborstone outpost"
$MAP_ID[219] = "Boreas Seabed outpost"
$MAP_ID[220] = "Sunjiang District outpost"
$MAP_ID[222] = "The Eternal Grove outpost"
$MAP_ID[224] = "Gyala Hatchery outpost"
$MAP_ID[225] = "Raisu Palace outpost"
$MAP_ID[226] = "Imperial Sanctum outpost"
$MAP_ID[227] = "Unwaking Waters Luxon"
$MAP_ID[230] = "Amatz Basin outpost"
;~ $MAP_ID[233] = "Raisu Palace outpost"
$MAP_ID[234] = "The Aurios Mines outpost"
$MAP_ID[242] = "Shing Jea Monastery"
$MAP_ID[243] = "Shing Jea Arena outpost"
$MAP_ID[248] = "Great Temple of Balthazar"
$MAP_ID[249] = "Tsumei Village"
$MAP_ID[250] = "Seitung Harbor"
$MAP_ID[251] = "Ran Musu Gardens"
$MAP_ID[253] = "Dwayna Vs Grenth outpost"
$MAP_ID[266] = "Urgoz's Warren outpost"
$MAP_ID[272] = "Altrumm Ruins outpost"
$MAP_ID[273] = "Zos Shivros Channel outpost"
$MAP_ID[274] = "Dragons Throat outpost"
$MAP_ID[275] = "Guild Hall - Isle of Weeping Stone"
$MAP_ID[276] = "Guild Hall - Isle of Jade"
$MAP_ID[277] = "Harvest Temple"
$MAP_ID[278] = "Breaker Hollow"
$MAP_ID[279] = "Leviathan Pits"
$MAP_ID[281] = "Zaishen Challenge outpost"
$MAP_ID[282] = "Zaishen Elite outpost"
$MAP_ID[283] = "Maatu Keep"
$MAP_ID[284] = "Zin Ku Corridor"
$MAP_ID[286] = "Brauer Academy"
$MAP_ID[287] = "Durheim Archives"
$MAP_ID[288] = "Bai Paasu Reach"
$MAP_ID[289] = "Seafarer's Rest"
$MAP_ID[291] = "Vizunah Square Local Quarter"
$MAP_ID[292] = "Vizunah Square Foreign Quarter"
$MAP_ID[293] = "Fort Aspenwood - Luxon"
$MAP_ID[294] = "Fort Aspenwood - Kurzick"
$MAP_ID[295] = "The Jade Quarry - Luxon"
$MAP_ID[296] = "The Jade Quarry - Kurzick"
$MAP_ID[297] = "Unwaking Waters Luxon"
$MAP_ID[298] = "Unwaking Waters Kurzick"
$MAP_ID[303] = "The Marketplace"
$MAP_ID[307] = "The Deep outpost"
$MAP_ID[328] = "Saltspray Beach - Luxon"
$MAP_ID[329] = "Saltspray Beach - Kurzick"
$MAP_ID[330] = "Heroes Ascent outpost"
$MAP_ID[331] = "Grenz Frontier - Luxon"
$MAP_ID[332] = "Grenz Frontier - Kurzick"
$MAP_ID[333] = "The Ancestral Lands - Luxon"
$MAP_ID[334] = "The Ancestral Lands - Kurzick"
$MAP_ID[335] = "Etnaran Keys - Luxon"
$MAP_ID[336] = "Etnaran Keys - Kurzick"
$MAP_ID[337] = "Kaanai Canyon - Luxon"
$MAP_ID[338] = "Kaanai Canyon - Kurzick"
$MAP_ID[348] = "Tanglewood Copse"
$MAP_ID[349] = "Saint Anjeka's Shrine"
$MAP_ID[350] = "Eredon Terrace"
$MAP_ID[359] = "Imperial Isle"
$MAP_ID[360] = "Guild Hall - Isle of Meditation"
$MAP_ID[368] = "Dragon Arena outpost"
$MAP_ID[376] = "Camp Hojanu"
$MAP_ID[378] = "Wehhan Terraces"
$MAP_ID[381] = "Yohlon Haven"
$MAP_ID[387] = "Sunspear Sanctuary"
$MAP_ID[388] = "Aspenwood Gate - Kurzick"
$MAP_ID[389] = "Aspenwood Gate - Luxon"
$MAP_ID[390] = "Jade Flats Kurzick"
$MAP_ID[391] = "Jade Flats Luxon"
$MAP_ID[393] = "Chantry of Secrets"
$MAP_ID[396] = "Mihanu Township"
$MAP_ID[398] = "Basalt Grotto"
$MAP_ID[403] = "Honur Hill"
$MAP_ID[407] = "Yahnur Market"
$MAP_ID[414] = "The Kodash Bazaar"
$MAP_ID[421] = "Venta Cemetery outpost"
$MAP_ID[424] = "Kodonur Crossroads outpost"
$MAP_ID[425] = "Rilohn Refuge outpost"
$MAP_ID[426] = "Pogahn Passage outpost"
$MAP_ID[427] = "Moddok Crevice outpost"
$MAP_ID[428] = "Tihark Orchard outpost"
$MAP_ID[431] = "Sunspear Great Hall"
$MAP_ID[433] = "Dzagonur Bastion outpost"
$MAP_ID[434] = "Dasha Vestibule outpost"
$MAP_ID[435] = "Grand Court of Sebelkeh outpost"
$MAP_ID[438] = "Bone Palace"
$MAP_ID[440] = "The Mouth of Torment"
$MAP_ID[442] = "Lair of the Forgotten"
$MAP_ID[449] = "Kamadan Jewel of Istan"
$MAP_ID[450] = "Gate of Torment"
$MAP_ID[457] = "Beknur Harbor"
$MAP_ID[467] = "Rollerbeetle Racing outpost"
$MAP_ID[469] = "Gate of Fear"
$MAP_ID[473] = "Gate of Secrets"
$MAP_ID[474] = "Gate of Anguish"
$MAP_ID[476] = "Jennurs Horde outpost"
$MAP_ID[477] = "Nundu Bay outpost"
$MAP_ID[478] = "Gate of Desolation outpost"
$MAP_ID[479] = "Champions Dawn"
$MAP_ID[480] = "Ruins of Morah outpost"
$MAP_ID[487] = "Beknur Harbor"
$MAP_ID[489] = "Kodlonu Hamlet"
$MAP_ID[491] = "Jokanur Diggings outpost"
$MAP_ID[492] = "Blacktide Den outpost"
$MAP_ID[493] = "Consulate Docks outpost"
$MAP_ID[494] = "Gate of Pain outpost"
$MAP_ID[495] = "Gate of Madness outpost"
$MAP_ID[496] = "Abaddons Gate outpost"
$MAP_ID[497] = "Sunspear Arena outpost"
$MAP_ID[502] = "The Astralarium"
$MAP_ID[529] = "Guild Hall - Uncharted Isle"
$MAP_ID[530] = "Guild Hall - Isle of Wurms"
$MAP_ID[537] = "Guild Hall - Corrupted Isle"
$MAP_ID[538] = "Guild Hall - Isle of Solitude"
$MAP_ID[544] = "Chahbek Village outpost"
$MAP_ID[545] = "Remains of Sahlahja outpost"
$MAP_ID[549] = "Hero Battles outpost"
$MAP_ID[554] = "Dajkah Inlet outpost"
$MAP_ID[555] = "The Shadow Nexus outpost"
$MAP_ID[559] = "Gate of the Nightfallen Lands"
$MAP_ID[624] = "Vlox's Falls"
$MAP_ID[638] = "Gadd's Encampment"
$MAP_ID[639] = "Umbral Grotto"
$MAP_ID[640] = "Rata Sum"
$MAP_ID[641] = "Tarnished Haven"
$MAP_ID[642] = "Eye of the North outpost"
$MAP_ID[643] = "Sifhalla"
$MAP_ID[644] = "Gunnar's Hold"
$MAP_ID[645] = "Olafstead"
$MAP_ID[648] = "Doomlore Shrine"
$MAP_ID[650] = "Longeye's Ledge"
$MAP_ID[652] = "Central Transfer Chamber"
$MAP_ID[675] = "Boreal Station"
$MAP_ID[721] = "Costume Brawl outpost"
$MAP_ID[795] = "Zaishen Menagerie outpost"
$MAP_ID[796] = "Codex Arena outpost"
$MAP_ID[808] = "Lions Arch - Halloween"
$MAP_ID[809] = "Lions Arch - Wintersday"
$MAP_ID[810] = "Lions Arch - Canthan New Year"
$MAP_ID[811] = "Ascalon City - Wintersday"
$MAP_ID[812] = "Droknars Forge - Halloween"
$MAP_ID[813] = "Droknars Forge - Wintersday"
$MAP_ID[814] = "Tomb of the Primeval Kings - Halloween"
$MAP_ID[815] = "Shing Jea Monastery - Dragon Festival"
$MAP_ID[816] = "Shing Jea Monastery - Canthan New Year"
;~ $MAP_ID[817] = "Kaineng Center = 817
$MAP_ID[818] = "Kamadan Jewel of Istan - Halloween"
$MAP_ID[819] = "Kamadan Jewel of Istan - Wintersday"
$MAP_ID[820] = "Kamadan Jewel of Istan - Canthan New Year"
$MAP_ID[821] = "Eye of the North outpost - Wintersday"
$MAP_ID[857] = "Embark Beach"
#EndRegion Map_IDs

#EndRegion All Map Names, Global Variables

#Region Attributes
Func GetProfessionByAttribute($aAttr)
	Switch $aAttr
		Case $ATTR_FAST_CASTING, $ATTR_ILLUSION_MAGIC, $ATTR_DOMINATION_MAGIC, $ATTR_INSPIRATION_MAGIC
			Return $PROF_MESMER
		Case $ATTR_BLOOD_MAGIC, $ATTR_DEATH_MAGIC, $ATTR_SOUL_REAPING, $ATTR_CURSES
			Return $PROF_NECROMANCER
		Case $ATTR_AIR_MAGIC, $ATTR_EARTH_MAGIC, $ATTR_FIRE_MAGIC, $ATTR_WATER_MAGIC, $ATTR_ENERGY_STORAGE
			Return $PROF_ELEMENTALIST
		Case $ATTR_HEALING_PRAYERS, $ATTR_PROTECTION_PRAYERS, $ATTR_DIVINE_FAVOR, $ATTR_SMITING_PRAYERS
			Return $PROF_MONK
		Case $ATTR_STRENGTH, $ATTR_AXE_MASTERY, $ATTR_HAMMER_MASTERY, $ATTR_SWORDSMANSHIP, $ATTR_TACTICS
			Return $PROF_WARRIOR
		Case $ATTR_BEAST_MASTERY, $ATTR_EXPERTISE, $ATTR_WILDERNESS_SURVIVAL, $ATTR_MARKSMANSHIP
			Return $PROF_RANGER
		Case $ATTR_DAGGER_MASTERY, $ATTR_DEADLY_ARTS, $ATTR_SHADOW_ARTS, $ATTR_CRITICAL_STRIKES
			Return $PROF_ASSASSIN
		Case $ATTR_COMMUNING, $ATTR_RESTORATION_MAGIC, $ATTR_CHANNELING_MAGIC, $ATTR_SPAWNING_POWER
			Return $PROF_RITUALIST
		Case $ATTR_SPEAR_MASTERY, $ATTR_COMMAND, $ATTR_MOTIVATION, $ATTR_LEADERSHIP
			Return $PROF_PARAGON
		Case $ATTR_SCYTHE_MASTERY, $ATTR_WIND_PRAYERS, $ATTR_EARTH_PRAYERS, $ATTR_MYSTICISM
			Return $PROF_DERVISH
		Case Else
			Return $PROF_NONE
	EndSwitch
EndFunc   ;==>GetProfessionByAttribute

Func GetSecondaryAttributesByProfession($aProf)
	Local $ret[5]
	Switch $aProf
		Case $PROF_NONE
			$ret[0] = 1
		Case $PROF_MESMER
			$ret[0] = 3
			$ret[1] = $ATTR_DOMINATION_MAGIC
			$ret[2] = $ATTR_ILLUSION_MAGIC
			$ret[3] = $ATTR_INSPIRATION_MAGIC
		Case $PROF_NECROMANCER
			$ret[0] = 3
			$ret[1] = $ATTR_BLOOD_MAGIC
			$ret[2] = $ATTR_DEATH_MAGIC
			$ret[3] = $ATTR_CURSES
		Case $PROF_ELEMENTALIST
			$ret[0] = 4
			$ret[1] = $ATTR_AIR_MAGIC
			$ret[2] = $ATTR_EARTH_MAGIC
			$ret[3] = $ATTR_FIRE_MAGIC
			$ret[4] = $ATTR_WATER_MAGIC
		Case $PROF_MONK
			$ret[0] = 3
			$ret[1] = $ATTR_HEALING_PRAYERS
			$ret[2] = $ATTR_PROTECTION_PRAYERS
			$ret[3] = $ATTR_SMITING_PRAYERS
		Case $PROF_WARRIOR
			$ret[0] = 4
			$ret[1] = $ATTR_AXE_MASTERY
			$ret[2] = $ATTR_HAMMER_MASTERY
			$ret[3] = $ATTR_SWORDSMANSHIP
			$ret[4] = $ATTR_TACTICS
		Case $PROF_RANGER
			$ret[0] = 3
			$ret[1] = $ATTR_BEAST_MASTERY
			$ret[2] = $ATTR_WILDERNESS_SURVIVAL
			$ret[3] = $ATTR_MARKSMANSHIP
		Case $PROF_ASSASSIN
			$ret[0] = 3
			$ret[1] = $ATTR_DAGGER_MASTERY
			$ret[2] = $ATTR_DEADLY_ARTS
			$ret[3] = $ATTR_SHADOW_ARTS
		Case $PROF_RITUALIST
			$ret[0] = 3
			$ret[1] = $ATTR_COMMUNING
			$ret[2] = $ATTR_RESTORATION_MAGIC
			$ret[3] = $ATTR_CHANNELING_MAGIC
		Case $PROF_PARAGON
			$ret[0] = 3
			$ret[1] = $ATTR_SPEAR_MASTERY
			$ret[2] = $ATTR_COMMAND
			$ret[3] = $ATTR_MOTIVATION
		Case $PROF_DERVISH
			$ret[0] = 3
			$ret[1] = $ATTR_SCYTHE_MASTERY
			$ret[2] = $ATTR_WIND_PRAYERS
			$ret[3] = $ATTR_EARTH_PRAYERS
	EndSwitch
	Return $ret
EndFunc   ;==>GetSecondaryAttributesByProfession

Func GetAttributeByMod($aMod)
	Switch $aMod
		Case $MODSTRUCT_HEADPIECE_DOMINATION_MAGIC
			Return $ATTR_DOMINATION_MAGIC
		Case $MODSTRUCT_HEADPIECE_FAST_CASTING
			Return $ATTR_FAST_CASTING
		Case $MODSTRUCT_HEADPIECE_ILLUSION_MAGIC
			Return $ATTR_ILLUSION_MAGIC
		Case $MODSTRUCT_HEADPIECE_INSPIRATION_MAGIC
			Return $ATTR_INSPIRATION_MAGIC
		Case $MODSTRUCT_HEADPIECE_BLOOD_MAGIC
			Return $ATTR_BLOOD_MAGIC
		Case $MODSTRUCT_HEADPIECE_CURSES
			Return $ATTR_CURSES
		Case $MODSTRUCT_HEADPIECE_DEATH_MAGIC
			Return $ATTR_DEATH_MAGIC
		Case $MODSTRUCT_HEADPIECE_SOUL_REAPING
			Return $ATTR_SOUL_REAPING
		Case $MODSTRUCT_HEADPIECE_AIR_MAGIC
			Return $ATTR_AIR_MAGIC
		Case $MODSTRUCT_HEADPIECE_EARTH_MAGIC
			Return $ATTR_EARTH_MAGIC
		Case $MODSTRUCT_HEADPIECE_ENERGY_STORAGE
			Return $ATTR_ENERGY_STORAGE
		Case $MODSTRUCT_HEADPIECE_FIRE_MAGIC
			Return $ATTR_FIRE_MAGIC
		Case $MODSTRUCT_HEADPIECE_WATER_MAGIC
			Return $ATTR_WATER_MAGIC
		Case $MODSTRUCT_HEADPIECE_DIVINE_FAVOR
			Return $ATTR_DIVINE_FAVOR
		Case $MODSTRUCT_HEADPIECE_HEALING_PRAYERS
			Return $ATTR_HEALING_PRAYERS
		Case $MODSTRUCT_HEADPIECE_PROTECTION_PRAYERS
			Return $ATTR_PROTECTION_PRAYERS
		Case $MODSTRUCT_HEADPIECE_SMITING_PRAYERS
			Return $ATTR_SMITING_PRAYERS
		Case $MODSTRUCT_HEADPIECE_AXE_MASTERY
			Return $ATTR_AXE_MASTERY
		Case $MODSTRUCT_HEADPIECE_HAMMER_MASTERY
			Return $ATTR_HAMMER_MASTERY
		Case $MODSTRUCT_HEADPIECE_SWORDSMANSHIP
			Return $ATTR_SWORDSMANSHIP
		Case $MODSTRUCT_HEADPIECE_STRENGTH
			Return $ATTR_STRENGTH
		Case $MODSTRUCT_HEADPIECE_TACTICS
			Return $ATTR_TACTICS
		Case $MODSTRUCT_HEADPIECE_BEAST_MASTERY
			Return $ATTR_BEAST_MASTERY
		Case $MODSTRUCT_HEADPIECE_MARKSMANSHIP
			Return $ATTR_MARKSMANSHIP
		Case $MODSTRUCT_HEADPIECE_EXPERTISE
			Return $ATTR_EXPERTISE
		Case $MODSTRUCT_HEADPIECE_WILDERNESS_SURVIVAL
			Return $ATTR_WILDERNESS_SURVIVAL
		Case Else
			Return $ATTR_NONE
	EndSwitch
EndFunc   ;==>GetAttributeByMod

Func GetIsCasterProfession($aAgent = -2)
	Switch GetAgentPrimaryProfession($aAgent)
		Case $PROF_NONE
			Return False
		Case $PROF_WARRIOR
			Return False
		Case $PROF_RANGER
			Return False
		Case $PROF_MONK
			Return True
		Case $PROF_NECROMANCER
			Return True
		Case $PROF_MESMER
			Return True
		Case $PROF_ELEMENTALIST
			Return True
		Case $PROF_ASSASSIN
			Return False
		Case $PROF_RITUALIST
			Return True
		Case $PROF_PARAGON
			Return False
		Case $PROF_DERVISH
			Return False
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>GetIsCasterProfession

Func GetAgentPrimaryProfession($aAgent = -2)
	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
	Return DllStructGetData($aAgent, 'Primary')
EndFunc   ;==>GetAgentPrimaryProfession

Func GetAgentSecondaryProfession($aAgent = -2)
	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
	Return DllStructGetData($aAgent, 'Secondary')
EndFunc   ;==>GetAgentSecondaryProfession

Func GetAgentProfessionsName($aAgent = -2)
	Return GetProfessionName(GetAgentPrimaryProfession($aAgent)) & "/" & GetProfessionName(GetAgentSecondaryProfession($aAgent))
EndFunc   ;==>GetAgentProfessionsName

Func GetProfessionName($aProf)
	Switch $aProf
		Case $PROF_NONE
			Return "x"
		Case $PROF_WARRIOR
			Return "W"
		Case $PROF_RANGER
			Return "R"
		Case $PROF_MONK
			Return "Mo"
		Case $PROF_NECROMANCER
			Return "N"
		Case $PROF_MESMER
			Return "Me"
		Case $PROF_ELEMENTALIST
			Return "E"
		Case $PROF_ASSASSIN
			Return "A"
		Case $PROF_RITUALIST
			Return "Rt"
		Case $PROF_PARAGON
			Return "P"
		Case $PROF_DERVISH
			Return "D"
	EndSwitch
EndFunc   ;==>GetProfessionName

Func GetProfessionFullName($aProf)
	Switch $aProf
		Case $PROF_NONE
			Return "x"
		Case $PROF_WARRIOR
			Return "Warrior"
		Case $PROF_RANGER
			Return "Ranger"
		Case $PROF_MONK
			Return "Monk"
		Case $PROF_NECROMANCER
			Return "Necromancer"
		Case $PROF_MESMER
			Return "Mesmer"
		Case $PROF_ELEMENTALIST
			Return "Elementalist"
		Case $PROF_ASSASSIN
			Return "Assassin"
		Case $PROF_RITUALIST
			Return "Ritualist"
		Case $PROF_PARAGON
			Return "Paragon"
		Case $PROF_DERVISH
			Return "Dervish"
	EndSwitch
EndFunc   ;==>GetProfessionFullName
#EndRegion Attributes
