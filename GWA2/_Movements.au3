#include-once

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

	Return SendPacket(0x8, $HEADER_GO_PLAYER, $lAgentID)
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
	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), DllStructGetData($aAgent, 'X'), DllStructGetData($aAgent, 'Y')) < 250 Or $lBlocked > 14
	Sleep(GetPing() + Random(1500, 2000, 1))
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
		Return PerformAction(0xA2, 0x1E)
	Else
		Return PerformAction(0xA2, 0x20)
	EndIf
EndFunc   ;==>TurnLeft

;~ Description: Turn character to the right.
Func TurnRight($aTurn)
	If $aTurn Then
		Return PerformAction(0xA3, 0x1E)
	Else
		Return PerformAction(0xA3, 0x20)
	EndIf
EndFunc   ;==>TurnRight

;~ Description: Move backwards.
Func MoveBackward($aMove)
	If $aMove Then
		Return PerformAction(0xAC, 0x1E)
	Else
		Return PerformAction(0xAC, 0x20)
	EndIf
EndFunc   ;==>MoveBackward

;~ Description: Run forwards.
Func MoveForward($aMove)
	If $aMove Then
		Return PerformAction(0xAD, 0x1E)
	Else
		Return PerformAction(0xAD, 0x20)
	EndIf
EndFunc   ;==>MoveForward

;~ Description: Strafe to the left.
Func StrafeLeft($aStrafe)
	If $aStrafe Then
		Return PerformAction(0x91, 0x1E)
	Else
		Return PerformAction(0x91, 0x20)
	EndIf
EndFunc   ;==>StrafeLeft

;~ Description: Strafe to the right.
Func StrafeRight($aStrafe)
	If $aStrafe Then
		Return PerformAction(0x92, 0x1E)
	Else
		Return PerformAction(0x92, 0x20)
	EndIf
EndFunc   ;==>StrafeRight

;~ Description: Auto-run.
Func ToggleAutoRun()
	Return PerformAction(0xB7, 0x1E)
EndFunc   ;==>ToggleAutoRun

;~ Description: Turn around.
Func ReverseDirection()
	Return PerformAction(0xB1, 0x1E)
EndFunc   ;==>ReverseDirection
#EndRegion Movement

#Region Travel
;~ Description: Map travel to an outpost.
Func TravelTo($aMapID, $aDis = 0)
	;returns true if successful
	If GetMapID() = $aMapID And $aDis = 0 And GetMapLoading() = 0 Then Return True
	ZoneMap($aMapID, $aDis)
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
