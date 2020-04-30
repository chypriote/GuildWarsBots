;###########################
;#  by chypriote           #
;#                         #
;###########################
; v2.0
;
; This file contains all headers that gwa2 uses to communicate with the gameservers directly.
;
; The headers are named variables. The names should indicate what the header is about.
; The comments give a litte more detail about what the header does.
;
; This makes the source code of gwa2 a little more readable. Also it allows to update headers more easily, as they
; are all now in a small separate place as a list to work yourself through.
; If you need to update the headers, the comments give hints about what action to trigger while recording CtoGS packets.

#include-once
;=QUEST=
Global Const $HEADER_QUEST_ACCEPT = 0x42 ;Accepts a quest from the NPC
Global Const $HEADER_QUEST_REWARD = 0x42 ;Retrieves Quest reward from NPC
Global Const $HEADER_QUEST_ABANDON = 0x12 ;Abandons the quest

;=HERO=
Global Const $HEADER_HERO_AGGRESSION  = 0x17 ;Sets the heroes aggression level
Global Const $HEADER_HERO_LOCK = 0x1A ;Locks the heroes target
Global Const $HEADER_HERO_TOGGLE_SKILL = 0x1A ;Enables or disables the heroes skill
Global Const $HEADER_HERO_CLEAR_FLAG = 0x1A ;Clears the heroes position flag
Global Const $HEADER_HERO_PLACE_FLAG = 0x1A ;Sets the heroes position flag, hero runs to position
Global Const $HEADER_HERO_ADD = 0x21 ;Adds hero to party
Global Const $HEADER_HERO_KICK = 0x22 ;Kicks hero from party
Global Const $HEADER_HEROES_KICK = 0x22 ;Kicks ALL heroes from party

;=PARTY=
Global Const $HEADER_PARTY_PLACE_FLAG = 0x1E ;Sets the party position flag, all party-npcs runs to position
Global Const $HEADER_PARTY_CLEAR_FLAG = 0x1E ;Clears the party position flag
Global Const $HEADER_HENCHMAN_ADD = 0xA7 ;Adds henchman to party
Global Const $HEADER_PARTY_LEAVE = 0xAA ;Leaves the party
Global Const $HEADER_HENCHMAN_KICK = 0xB0 ;Kicks a henchman from party

;=TARGET=
Global Const $HEADER_CALL_TARGET = 0x28 ;Calls the target without attacking (Ctrl+Shift+Space)
Global Const $HEADER_ATTACK_AGENT = 0x2D ;Attacks agent (Space IIRC)
Global Const $HEADER_CANCEL_ACTION = 0x2F ;Cancels the current action
Global Const $HEADER_NPC_TALK = 0x40 ;talks/goes to npc
Global Const $HEADER_SIGNPOST_RUN = 0x58 ;Runs to signpost

;=DROP=
Global Const $HEADER_ITEM_DROP = 0x33 ;Drops item from inventory to ground
Global Const $HEADER_GOLD_DROP = 0x36 ;Drops gold from inventory to ground

;=BUFFS=
Global Const $HEADER_STOP_MAINTAIN_ENCH = 0x30 ;Drops buff, cancel enchantmant, whatever you call it

;=ITEMS=
Global Const $HEADER_ITEM_EQUIP = 0x37 ;Equips item from inventory/chest/no idea
Global Const $HEADER_ITEM_PICKUP = 0x46 ;Picks up an item from ground
Global Const $HEADER_ITEM_DESTROY = 0x70 ;Destroys the item
Global Const $HEADER_ITEM_ID = 0x73 ;Identifies item in inventory
Global Const $HEADER_ITEM_MOVE = 0x79 ;Moves item in inventory
Global Const $HEADER_ITEMS_ACCEPT_UNCLAIMED = 0x77 ;Accepts ITEMS not picked up in missions
Global Const $HEADER_SALVAGE_MATS = 0x7F ;Salvages materials from item
Global Const $HEADER_SALVAGE_MODS = 0x81 ;Salvages mods from item
Global Const $HEADER_ITEM_USE = 0x85 ;Uses item from inventory/chest
Global Const $HEADER_UPGRADE = 0x84 ;used by gwapi. is it even useful? NOT TESTED
Global Const $HEADER_UPGRADE_ARMOR_1 = 0x81 ;used by gwapi. is it even useful? NOT TESTED
Global Const $HEADER_UPGRADE_ARMOR_2 = 0x84 ;used by gwapi. is it even useful? NOT TESTED

;=TRADE=
Global Const $HEADER_TRADE_PLAYER = 0x4F ;Send trade request to player
Global Const $HEADER_TRADE_OFFER_ITEM = 0x02 ;Add item to trade window
Global Const $HEADER_TRADE_SUBMIT_OFFER = 0x03 ;Submit offer
Global Const $HEADER_TRADE_CHANGE_OFFER = 0x06 ;Change offer
Global Const $HEADER_TRADE_CANCEL = 0x01 ;Cancel trade
Global Const $HEADER_TRADE_ACCEPT = 0x07 ;Accept trade

;=TRAVEL=
Global Const $HEADER_MAP_TRAVEL = 0xB9 ;Travels to outpost via worldmap
Global Const $HEADER_GUILDHALL_TRAVEL = 0xB8 ;Travels to guild hall
Global Const $HEADER_GUILDHALL_LEAVE = 0xBA ;Leaves Guildhall

;=FACTION=
Global Const $HEADER_FACTION_DONATE = 0x3C ;Donates kurzick/luxon faction to ally

;=TITLE=
Global Const $HEADER_TITLE_DISPLAY = 0x5F ;Displays title (from Gigis Vaettir Bot)
Global Const $HEADER_TITLE_CLEAR = 0x60 ;Hides title (from Gigis Vaettir Bot)

;=DIALOG=
Global Const $HEADER_DIALOG = 0x42 ;Sends a dialog to NPC
Global Const $HEADER_CINEMATIC_SKIP = 0x6A ;Skips the cinematic

;=SKILL / BUILD=
Global Const $HEADER_SKILL_CHANGE = 0x63 ;legacy
Global Const $HEADER_SET_SKILLBAR_SKILL = 0x63 ;Changes a skill on the skillbar
Global Const $HEADER_BUILD_LOAD = 0x64 ;legacy
Global Const $HEADER_LOAD_SKILLBAR = 0x64 ;Loads a complete build
Global Const $HEADER_CHANGE_SECONDARY = 0x48 ;Changes Secondary class (from Build window, not class changer)
;= Not touched
Global Const $HEADER_SKILL_USE_ALLY = 0x49 ;used by gwapi. appears to have changed
Global Const $HEADER_SKILL_USE_FOE = 0x49 ;used by gwapi. appears to have changed
Global Const $HEADER_SKILL_USE_ID = 0x49 ;
Global Const $HEADER_SET_ATTRIBUTES = 0x10 ;hidden in init stuff like sendchat

;=CHEST=
Global Const $HEADER_CHEST_OPEN = 0x5A ;Opens a chest (with key AFAIK)
Global Const $HEADER_GOLD_MOVE = 0x83 ;legacy
Global Const $HEADER_CHANGE_GOLD = 0x83 ;Moves Gold (from chest to inventory, and otherway around IIRC)

;=MISSION=
Global Const $HEADER_MODE_SWITCH = 0xA3 ;Toggles hard- and normal mode
Global Const $HEADER_MISSION_ENTER = 0xAD ;Enter a mission/challenge
Global Const $HEADER_MISSION_FOREIGN_ENTER = 0xAD ;Enters a foreign mission/challenge (no idea honestly)
Global Const $HEADER_OUTPOST_RETURN = 0xAF ;Returns to outpost after /resign

;=CHAT=
Global Const $HEADER_SEND_CHAT = 0x6B ;Needed for sending messages in chat

;=OTHER CONSTANTS=
Global Const $HEADER_OPEN_GB_WINDOW = 0xA0
Global Const $HEADER_CLOSE_GB_WINDOW = 0xA1
Global Const $HEADER_START_RATING_GVG = 0xAC
Global Const $HEADER_OPEN_SKILLS = 0x42
Global Const $HEADER_EQUIP_BAG = 0x72
Global Const $HEADER_USE_ITEM = 0x85
Global Const $HEADER_USE_SKILL = 0x4D
Global Const $HEADER_HOM_DIALOG = 0x5A
Global Const $HEADER_PROFESSION_ULOCK = 0x42
Global Const $HEADER_GO_PLAYER = 0x3A
#EndRegion Headers

;Missing
;Global Const $HEADER_INVITE_TARGET
;Global Const $HEADER_INVITE_CANCEL
;Global Const $HEADER_INVITE_ACCEPT
;Global Const $HEADER_AGENT_FOLLOW 
;Global Const $HEADER_ITEM_MOVE_EX
