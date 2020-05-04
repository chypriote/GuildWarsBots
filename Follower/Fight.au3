#include-once

#include <_Loot.au3>

Global $SkillEnergy[8] = [0, 15, 5, 5, 10, 15, 5, 5]
; Change the next lines to your skill casting times in milliseconds. use ~250 for shouts/stances, ~1000 for attack skills:
Global $SkillCastTime[8] = [1000, 1000, 750, 750, 750, 750, 250, 1000]
; Change the next lines to your skill adrenaline count (1 to 8). leave as 0 for skills without adren
Global $SkillAdrenaline[8] = [0, 0, 0, 0, 0, 0, 0, 0]

#Region Move
Func AttackMove($x, $y, $enemy = False, $loot = True)
    Local $timer = TimerInit(), $iBlocked = 0, $jBlocked
    $msg = $enemy ? "Hunting " & $enemy : "Hunting"
    Out($msg)

    Do
        $jBlocked = 0
        Do
            Move($x, $y)
            RndSleep(250)
            $jBlocked += 1
        Until EnemyInRange() Or ReachedDestination($x, $y) Or $jBlocked > 50
        If $jBlocked > 50 Then Out("I got stuck")

        If EnemyInRange() Then
            Fight()
            If $loot Then Loot()
        EndiF

        $iBlocked += 1
    Until ReachedDestination($x, $y) Or $iBlocked > 20
    RndSleep(250)
EndFunc ;AttackMove

Func TakeBlessing($x, $y)
    Out("Taking blessing")
    GoNearestNPCToCoords($x, $y)
EndFunc ;TakeBlessing
#EndRegion

#Region Fight
Func Fight($enemy = False)
    Out($enemy ? "Fighting " & $enemy : "Fighting")

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
        $recharge = DllStructGetData(GetSkillBar(), "Recharge" & $i + 1)
        $adrenaline = DllStructGetData(GetSkillBar(), "Adrenaline" & $i + 1)

        If $recharge = 0 And GetEnergy() >= $SkillEnergy[$i] And $adrenaline >= ($SkillAdrenaline[$i] * 25 - 25) Then
            $useSkill = $i + 1
            UseSkill($useSkill, GetCurrentTarget())
            RndSleep($SkillCastTime[$i] + 500)
        EndIf
    Next
EndFunc ;UseSkill
#EndRegion Fight

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
