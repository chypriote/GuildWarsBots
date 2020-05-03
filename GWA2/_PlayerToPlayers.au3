#include-once

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

	MemoryWrite($lAddress + 12, $aChannel & $lMessage, 'wchar[122]')
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', $lAddress, 'ptr', $mSendChatPtr, 'int', 8, 'int', '')
EndFunc   ;==>SendChat
#EndRegion Chat

#Region Trade
Func TradePlayer($aAgent)
	Local $lAgentID

	If IsDllStruct($aAgent) = 0 Then
		$lAgentID = ConvertID($aAgent)
	Else
		$lAgentID = DllStructGetData($aAgent, 'ID')
	EndIf
	SendPacket(0x08, $HEADER_TRADE_PLAYER, $lAgentID)
EndFunc   ;==>TradePlayer

Func AcceptTrade()
	Return SendPacket(0x4, $HEADER_TRADE_ACCEPT)
EndFunc   ;==>AcceptTrade

;~ Description: Like pressing the "Accept" button in a trade. Can only be used after both players have submitted their offer.
Func SubmitOffer($aGold = 0)
	Return SendPacket(0x8, $HEADER_TRADE_SUBMIT_OFFER, $aGold)
EndFunc   ;==>SubmitOffer

;~ Description: Like pressing the "Cancel" button in a trade.
Func CancelTrade()
	Return SendPacket(0x4, $HEADER_TRADE_CANCEL)
EndFunc   ;==>CancelTrade

;~ Description: Like pressing the "Change Offer" button.
Func ChangeOffer()
	Return SendPacket(0x4, $HEADER_TRADE_CHANGE_OFFER)
EndFunc   ;==>ChangeOffer

;~ $aItemID = ID of the item or item agent, $aQuantity = Quantity
Func OfferItem($lItemID, $aQuantity = 1)
;~ 	Local $lItemID
;~ 	$lItemID = GetBagItemIDByModelID($aModelID)
	Return SendPacket(0xC, $HEADER_TRADE_OFFER_ITEM, $lItemID, $aQuantity)
EndFunc   ;==>OfferItem

; Return 1 Trade windows exist; Return 3 Offer; Return 7 Accepted Trade
Func TradeWinExist()
	Local $lOffset = [0, 0x18, 0x58, 0]
	Return MemoryReadPtr($mBasePointer, $lOffset)[1]
EndFunc   ;==>TradeWinExist

Func TradeOfferItemExist()
	Local $lOffset = [0, 0x18, 0x58, 0x28, 0]
	Return MemoryReadPtr($mBasePointer, $lOffset)[1]
EndFunc   ;==>TradeOfferItemExist

Func TradeOfferMoneyExist()
	Local $lOffset = [0, 0x18, 0x58, 0x24]
	Return MemoryReadPtr($mBasePointer, $lOffset)[1]
EndFunc   ;==>TradeOfferMoneyExist

Func ToggleTradePatch($aEnable = True)
	If $aEnable Then
		MemoryWrite($MTradeHackAddress, 0xC3, "BYTE")
	Else
		MemoryWrite($MTradeHackAddress, 0x55, "BYTE")
	EndIf
EndFunc   ;==>ToggleTradePatch
#EndRegion Trade

#Region Guild
;~ Description: invite guild
Func InviteGuild($charName)
	If GetAgentExists(-2) Then
		DllStructSetData($mInviteGuild, 1, GetValue('CommandPacketSend'))
		DllStructSetData($mInviteGuild, 2, 0x4C)
		DllStructSetData($mInviteGuild, 3, 0xBC)
		DllStructSetData($mInviteGuild, 4, 0x01)
		DllStructSetData($mInviteGuild, 5, $charName)
		DllStructSetData($mInviteGuild, 6, 0x02)
		Enqueue(DllStructGetPtr($mInviteGuild), DllStructGetSize($mInviteGuild))
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>InviteGuild

;~ Description: invite guest
Func InviteGuest($charName)
	If GetAgentExists(-2) Then
		DllStructSetData($mInviteGuild, 1, GetValue('CommandPacketSend'))
		DllStructSetData($mInviteGuild, 2, 0x4C)
		DllStructSetData($mInviteGuild, 3, 0xBC)
		DllStructSetData($mInviteGuild, 4, 0x01)
		DllStructSetData($mInviteGuild, 5, $charName)
		DllStructSetData($mInviteGuild, 6, 0x01)
		Enqueue(DllStructGetPtr($mInviteGuild), DllStructGetSize($mInviteGuild))
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>InviteGuest
#EndRegion Guild

#Region Groups
;~ Description: Invite a player to the party.
Func InvitePlayer($aPlayerName)
	SendChat('invite ' & $aPlayerName, '/')
EndFunc   ;==>InvitePlayer

;~ Description: Leave your party.
Func LeaveGroup($aKickHeroes = True)
	If $aKickHeroes Then KickAllHeroes()
	Return SendPacket(0x4, $HEADER_PARTY_LEAVE)
EndFunc   ;==>LeaveGroup
#EndRegion Groups
