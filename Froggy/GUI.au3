#include-once

#Region ### START Koda GUI section ### Form=s
Global $frmMain = GUICreate("Froggy v2.0", 390, 312, 200, 124)
GUISetFont(9, 400, 0, "Arial")
Global $edtLog = _GUICtrlRichEdit_Create($frmMain, "", 128, 8, 254, 167, BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_READONLY))
	_GUICtrlRichEdit_SetFont($edtLog, 9, "Arial")
	_GUICtrlRichEdit_SetCharColor($edtLog, "65280")
	_GUICtrlRichEdit_SetText($edtLog, StringFormat("Froggy Bot\n"))
Global $charname = GUICtrlCreateCombo('', 8, 8, 110, 24)
	GUICtrlSetData($charname, GetLoggedCharNames())
Global $btnStart = GUICtrlCreateButton("Start", 8, 40, 110, 25)
	GUICtrlSetOnEvent($btnStart, "BotStartup")

Global $grpSettings = GUICtrlCreateGroup("Settings", 8, 72, 110, 104)
	GUICtrlSetFont($grpSettings, 9, 800, 0, "Arial")
Global $Rendering = GUICtrlCreateCheckbox("Render", 16, 88, 76, 17)
	GUICtrlSetOnEvent($Rendering, "ToggleRendering")
	GUICtrlSetFont($Rendering, 9, -1, 0, "Arial")

Global $Purge = GUICtrlCreateCheckbox("Purge", 16, 104, 90, 17)
	GUICtrlSetOnEvent($Purge, "Purgehook")
	GUICtrlSetFont($Purge, 9, -1, 0, "Arial")

GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $grpGeneralStats = GUICtrlCreateGroup("General Statistics", 8, 184, 182, 120)
	GUICtrlSetFont($grpGeneralStats, 9, 800, 0, "Arial")
Global $lblRunNum = GUICtrlCreateLabel("Run Number:", 16, 200, 80, 20)
	GUICtrlSetFont($lblRunNum, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblRunNum, 0x0078D7)
Global $lblRunNumData = GUICtrlCreateLabel("1", 120, 200, 64, 16, $SS_CENTER)
	GUICtrlSetFont($lblRunNumData, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblRunNumData, 0x0078D7)

Global $lblDeldrimor = GUICtrlCreateLabel("Deldrimor:", 16, 216, 90, 20)
	GUICtrlSetFont($lblDeldrimor, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblDeldrimor, 0x0078D7)
Global $lblDeldrimorData = GUICtrlCreateLabel("0", 120, 216, 64, 16, $SS_CENTER)
	GUICtrlSetFont($lblDeldrimorData, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblDeldrimorData, 0x0078D7)

Global $lblAsura = GUICtrlCreateLabel("Asura Points:", 16, 232, 76, 20)
	GUICtrlSetFont($lblAsura, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblAsura, 0x0078D7)
Global $lblAsuraData = GUICtrlCreateLabel("0", 120, 232, 64, 16, $SS_CENTER)
	GUICtrlSetFont($lblAsuraData, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblAsuraData, 0x0078D7)

Global $lblLockpicks = GUICtrlCreateLabel("Lockpicks:", 16, 248, 76, 20)
	GUICtrlSetFont($lblLockpicks, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblLockpicks, 0x0078D7)
Global $lblLockpicksData = GUICtrlCreateLabel("0", 120, 248, 64, 16, $SS_CENTER)
	GUICtrlSetFont($lblLockpicksData, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblLockpicksData, 0x0078D7)

Global $lblCurrentRun = GUICtrlCreateLabel("Run Time:", 16, 264, 76, 20)
	GUICtrlSetFont($lblCurrentRun, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblCurrentRun, 0x0078D7)
Global $lblCurrentRunData = GUICtrlCreateLabel("00:00:00", 120, 264, 64, 16, $SS_CENTER)
	GUICtrlSetFont($lblCurrentRunData, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblCurrentRunData, 0x0078D7)

GUICtrlCreateGroup("", -99, -99, 1, 1)

Global $lblTotalRun = GUICtrlCreateLabel("Total Run Time:", 16, 280, 96, 20)
	GUICtrlSetFont($lblTotalRun, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblTotalRun, 0x0078D7)
Global $lblTotalRunData = GUICtrlCreateLabel("00:00:00", 120, 280, 64, 16, $SS_CENTER)
	GUICtrlSetFont($lblTotalRunData, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblTotalRunData, 0x0078D7)

Global $grpDropStats = GUICtrlCreateGroup("Drop Statistics", 198, 184, 182, 120)
	GUICtrlSetFont($grpDropStats, 9, 800, 0, "Arial")

Global $lblFroggy = GUICtrlCreateLabel("Froggies: ", 206, 200, 90, 20)
	GUICtrlSetFont($lblFroggy, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblFroggy, 0x808000)
Global $lblFroggyData = GUICtrlCreateLabel("0", 310, 200, 64, 30, $SS_CENTER)
	GUICtrlSetFont($lblFroggyData, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblFroggyData, 0x808000)
Global $lblGold = GUICtrlCreateLabel("Gold Items: ", 206, 216, 90, 20)
	GUICtrlSetFont($lblGold, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblGold, 0x808000)
Global $lblGoldData = GUICtrlCreateLabel("0", 310, 216, 64, 30, $SS_CENTER)
	GUICtrlSetFont($lblGoldData, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblGoldData, 0x808000)
Global $lblLockpicksDrop = GUICtrlCreateLabel("Lockpicks:", 206, 232, 76, 20)
	GUICtrlSetFont($lblLockpicksDrop, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblLockpicksDrop, 0x808000)
Global $lblLockpicksDropData = GUICtrlCreateLabel("0", 310, 232, 64, 30, $SS_CENTER)
	GUICtrlSetFont($lblLockpicksDropData, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblLockpicksDropData, 0x808000)
Global $lblChests = GUICtrlCreateLabel("Chests Opened:", 206, 248, 96, 20)
	GUICtrlSetFont($lblChests, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblChests, 0x808000)
Global $lblChestsData = GUICtrlCreateLabel("0", 310, 248, 64, 23, $SS_CENTER)
	GUICtrlSetFont($lblChestsData, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblChestsData, 0x808000)
Global $lblBlackDye = GUICtrlCreateLabel("Black Dye:", 206, 264, 96, 20)
	GUICtrlSetFont($lblBlackDye, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblBlackDye, 0x808000)
Global $lblBlackDyeData = GUICtrlCreateLabel("0", 310, 264, 64, 23, $SS_CENTER)
	GUICtrlSetFont($lblBlackDyeData, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblBlackDyeData, 0x808000)
Global $lblTomes = GUICtrlCreateLabel("Tomes: ", 206, 280, 90, 20)
	GUICtrlSetFont($lblTomes, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblTomes, 0x808000)
Global $lblTomesData = GUICtrlCreateLabel("0", 310, 280, 64, 30, $SS_CENTER)
	GUICtrlSetFont($lblTomesData, 9, -1, 0, "Arial")
	GUICtrlSetColor($lblTomesData, 0x808000)

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

GUISetOnEvent($GUI_EVENT_CLOSE, "ExitBot")

#Region Toggles
Func ToggleSell()
	$Sell_Items = Not $Sell_Items
EndFunc ;==> ToggleSellItems

Func Purgehook()
	Out("PurgeHook")
	Enablerendering()
	Sleep(3000)
	Disablerendering()
Endfunc
#EndRegion

#Region Infos
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
#EndRegion
