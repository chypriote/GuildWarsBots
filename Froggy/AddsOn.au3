#include-once
#RequireAdmin
;#include "GWA2_Headers.au3"
#include <Array.au3>
#include "GWA2.au3"


;GENERAL THNX to miracle444 for his work with GWA2

;=================================================================================================
; Function:
; Description:		Globals from GWCA still working in GWA2
; Parameter(s):
;
; Requirement(s):
; Return Value(s):
; Author(s):		GWCA team
;=================================================================================================

Global Enum $HEROMODE_Fight, $HEROMODE_Guard, $HEROMODE_Avoid

Global Enum $enemies

Global Enum $DYE_Blue = 2, $DYE_Green, $DYE_Purple, $DYE_Red, $DYE_Yellow, $DYE_Brown, $DYE_Orange, $DYE_Silver, $DYE_Black, $DYE_Gray, $DYE_White

Global Enum $EQUIP_Weapon, $EQUIP_Offhand, $EQUIP_Chest, $EQUIP_Legs, $EQUIP_Head, $EQUIP_Feet, $EQUIP_Hands

Global Enum $REGION_International = -2, $REGION_America = 0, $REGION_Korea, $REGION_Europe, $REGION_China, $REGION_Japan

Global Enum $LANGUAGE_English = 0, $LANGUAGE_French = 2, $LANGUAGE_German, $LANGUAGE_Italian, $LANGUAGE_Spanish, $LANGUAGE_Polish = 9, $LANGUAGE_Russian

Global Const $FLAG_RESET = 0x7F800000; unflagging heores

Global $DroknardIsHere = 0


Global $intSkillEnergy[8] = [1, 15, 5, 5, 10, 15, 5, 5]
; Change the next lines to your skill casting times in milliseconds. use ~250 for shouts/stances, ~1000 for attack skills:
Global $intSkillCastTime[8] = [1000, 1250, 1250, 1250, 1250, 1000,  250, 1000]
; Change the next lines to your skill adrenaline count (1 to 8). leave as 0 for skills without adren
Global $intSkillAdrenaline[8] = [0, 0, 0, 0, 0, 0, 0, 0]

Global $totalskills = 7

Global $iItems_Picked = 0

Global $DeadOnTheRun = 0



Global $lItemExtraStruct = DllStructCreate( _ ; haha obsolete and wrong^^
		"byte rarity;" & _  ;Display Color $RARITY_White = 0x3D, $RARITY_Blue = 0x3F, $RARITY_Purple = 0x42, $RARITY_Gold = 0x40, $RARITY_Green = 0x43
		"byte unknown1[3];" & _
		"byte modifier;" & _ ;Display Mods (hex values): 30 = Display first mod only (Insignia, 31 = Insignia + "of" Rune, 32 = Insignia + [Rune], 33 = ...
		"byte unknown2[13];" & _ ;[13]
		"byte lastModifier")
Global $lItemExtraStructPtr = DllStructGetPtr($lItemExtraStruct)
Global $lItemExtraStructSize = DllStructGetSize($lItemExtraStruct)
#comments-start
Global $lItemNameStruct = DllStructCreate("byte rarity;"& _; Colour of the item (can be used as rarity); follow $lItemExtraStruct ->same pointer
		"byte ModMode;" & _;
		"byte ModCount;" & _;Number of Mods in the item
		"byte Name[4];" & _;Name ID of the item
		"byte Prefix[4];" & _; Depending on Item, Insignia, Axe Haft, Sword Hilt etc.
		"byte Suffix1[4];" & _; Depending on Item, Rune, Axe Grip, Sword Pommel etc.
		"byte Suffix2[4]"); (Runes Only) Quality of the Suffix (e.g. superior)

Global $lItemNameStructPtr = DllStructGetPtr($lItemNameStruct)
Global $lItemNameStructSize = DllStructGetSize($lItemNameStruct)
#comments-end

;-------> Item Extra Req Struct Definition
Global $lItemExtraReqStruct = DllStructCreate( _
		"byte requirement;" & _
		"byte attribute");Skill Template Format
Global $lItemExtraReqStructPtr = DllStructGetPtr($lItemExtraReqStruct)
Global $lItemExtraReqStructSize = DllStructGetSize($lItemExtraReqStruct)
;-------> Item Mod Struct definition
Global $lItemModStruct = DllStructCreate( _
		"byte unknown1[28];" & _
		"byte armor")
Global $lItemModStructPtr = DllStructGetPtr($lItemModStruct)
Global $lItemModStructSize = DllStructGetSize($lItemModStruct)

Global $BAG_SLOTS[18] = [0, 20, 5, 10, 10, 20, 41, 12, 20, 20, 20, 20, 20, 20, 20, 20, 20, 9]

#Region Constants

;Type (see: http://wiki.gamerevision.com/index.php/Item_Type)
Global Const $TYPE_SALVAGE				= 0
Global Const $TYPE_LEADHAND				= 1
Global Const $TYPE_AXE					= 2
Global Const $TYPE_BAG					= 3
Global Const $TYPE_BOOTS				= 4
Global Const $TYPE_BOW					= 5
Global Const $TYPE_BUNDLE				= 6
Global Const $TYPE_CHESTPIECE			= 7
Global Const $TYPE_RUNE_AND_MOD			= 8
Global Const $TYPE_USABLE				= 9
Global Const $TYPE_DYE					= 10
Global Const $TYPE_MATERIAL_AND_ZCOINS	= 11
Global Const $TYPE_OFFHAND				= 12
Global Const $TYPE_GLOVES				= 13
Global Const $TYPE_CELESTIAL_SIGIL		= 14
Global Const $TYPE_HAMMER				= 15
Global Const $TYPE_HEADPIECE			= 16
Global Const $TYPE_TROPHY_2				= 17	; SalvageItem / CC Shards?
Global Const $TYPE_KEY					= 18
Global Const $TYPE_LEGGINS				= 19
Global Const $TYPE_GOLD_COINS			= 20
Global Const $TYPE_QUEST_ITEM			= 21
Global Const $TYPE_WAND					= 22
Global Const $TYPE_SHIELD				= 24
Global Const $TYPE_STAFF				= 26
Global Const $TYPE_SWORD				= 27
Global Const $TYPE_KIT					= 29	; + Keg Ale
Global Const $TYPE_TROPHY				= 30
Global Const $TYPE_SCROLL				= 31
Global Const $TYPE_DAGGERS				= 32
Global Const $TYPE_PRESENT				= 33
Global Const $TYPE_MINIPET				= 34
Global Const $TYPE_SCYTHE				= 35
Global Const $TYPE_SPEAR				= 36
Global Const $TYPE_BOOKS				= 43	; Encrypted Charr Battle Plan/Decoder, Golem User Manual, Books
Global Const $TYPE_COSTUME_BODY			= 44
Global Const $TYPE_COSTUME_HEADPICE		= 45
Global Const $TYPE_NOT_EQUIPPED			= 46

;Material
Global Const $MODEL_ID_BONES			= 921
Global Const $MODEL_ID_DUST				= 929
Global Const $MODEL_ID_IRON				= 948
Global Const $MODEL_ID_FEATHERS			= 933
Global Const $MODEL_ID_PLANT_FIBRES		= 934
Global Const $MODEL_ID_SCALES			= 953
Global Const $MODEL_ID_CHITIN			= 954
Global Const $MODEL_ID_GRANITE			= 955
Global Const $MODEL_ID_MONSTROUS_EYE	= 931
Global Const $MODEL_ID_MONSTROUS_FANG	= 932
Global Const $MODEL_ID_MONSTROUS_CLAW	= 923
Global Const $MODEL_ID_RUBY				= 937
Global Const $MODEL_ID_SAPPHIRE			= 938

;Kits
Global Const $MODEL_ID_CHEAP_SALVAGE_KIT	= 2992
Global Const $MODEL_ID_SALVAGE_KIT			= 5900
Global Const $MODEL_ID_CHEAP_ID_KIT			= 2989
Global Const $MODEL_ID_ID_KIT				= 5899

;Scrolls
Global Const $MODEL_ID_UWSCROLL		= 3746
Global Const $MODEL_ID_FOWSCROLL	= 22280

;Misc
Global Const $MODEL_ID_GOLD_COINS	= 2511
Global Const $MODEL_ID_LOCKPICK		= 22751
Global Const $MODEL_ID_DYE			= 146
Global Const $EXTRA_ID_BLACK		= 10
Global Const $EXTRA_ID_WHITE		= 12

;Event
Global Const $MODEL_ID_TOTS					= 28434
Global Const $MODEL_ID_GOLDEN_EGGS			= 22752
Global Const $MODEL_ID_BUNNIES				= 22644
Global Const $MODEL_ID_GROG					= 30855
Global Const $MODEL_ID_SHAMROCK_ALE			= 22190
Global Const $MODEL_ID_CLOVER				= 22191
Global Const $MODEL_ID_PIE					= 28436
Global Const $MODEL_ID_CIDER				= 28435
Global Const $MODEL_ID_POPPERS				= 21810
Global Const $MODEL_ID_ROCKETS				= 21809
Global Const $MODEL_ID_CUPCAKES				= 22269
Global Const $MODEL_ID_SPARKLER				= 21813
Global Const $MODEL_ID_HONEYCOMB			= 26784
Global Const $MODEL_ID_VICTORY_TOKEN		= 18345
Global Const $MODEL_ID_LUNAR_TOKEN			= 21833
Global Const $MODEL_ID_HUNTERS_ALE			= 910
Global Const $MODEL_ID_PUMPKIN_COOKIE		= 28433
Global Const $MODEL_ID_KRYTAN_BRANDY		= 35124
Global Const $MODEL_ID_BLUE_DRINK			= 21812
Global Const $MODEL_ID_FRUITCAKE			= 21492
Global Const $MODEL_ID_SPIKED_EGGNOGG		= 6366
Global Const $MODEL_ID_EGGNOGG				= 6375
Global Const $MODEL_ID_SNOWMAN_SUMMONER		= 6376
Global Const $MODEL_ID_FROSTY_TONIC			= 30648
Global Const $MODEL_ID_MISCHIEVOUS_TONIC	= 31020
Global Const $MODEL_ID_DELICIOUS_CAKE		= 36681
Global Const $MODEL_ID_ICED_TEA				= 36682
Global Const $MODEL_ID_PARTY_BEACON			= 36683

;Tomes - E = ELITE | R = REGULAR
Global Const $MODEL_ID_TOME_E_SIN		= 21786
Global Const $MODEL_ID_TOME_E_MES		= 21787
Global Const $MODEL_ID_TOME_E_NEC		= 21788
Global Const $MODEL_ID_TOME_E_ELE		= 21789
Global Const $MODEL_ID_TOME_E_MONK		= 21790
Global Const $MODEL_ID_TOME_E_WAR		= 21791
Global Const $MODEL_ID_TOME_E_RANGER	= 21792
Global Const $MODEL_ID_TOME_E_DERV		= 21793
Global Const $MODEL_ID_TOME_E_RIT		= 21794
Global Const $MODEL_ID_TOME_E_PARA		= 21795
Global Const $MODEL_ID_TOME_R_SIN		= 21796
Global Const $MODEL_ID_TOME_R_MES		= 21797
Global Const $MODEL_ID_TOME_R_NEC		= 21798
Global Const $MODEL_ID_TOME_R_ELE		= 21799
Global Const $MODEL_ID_TOME_R_MONK		= 21800
Global Const $MODEL_ID_TOME_R_WAR		= 21801
Global Const $MODEL_ID_TOME_R_RANGER	= 21802
Global Const $MODEL_ID_TOME_R_DERV		= 21803
Global Const $MODEL_ID_TOME_R_RIT		= 21804
Global Const $MODEL_ID_TOME_R_PARA		= 21805

;Conditions
Global Const $EFFECT_ID_BLEEDING	= 478
Global Const $EFFECT_ID_BLIND		= 479
Global Const $EFFECT_ID_BURNING		= 480
Global Const $EFFECT_ID_CRIPPLED	= 481
Global Const $EFFECT_ID_DEEP_WOUND	= 482
Global Const $EFFECT_ID_DISEASE		= 483
Global Const $EFFECT_ID_POISON		= 484
Global Const $EFFECT_ID_DAZED		= 485
Global Const $EFFECT_ID_WEAKNESS	= 486


;Arrays for pickung up common stuff (things that do not drop from enemies (i.e. rice wine etc.)) are not listed.
Global Const $EVENT_ID_ARRAY[29] =	[28,	$MODEL_ID_TOTS, $MODEL_ID_GOLDEN_EGGS, $MODEL_ID_BUNNIES, $MODEL_ID_GROG, $MODEL_ID_SHAMROCK_ALE, $MODEL_ID_CLOVER, $MODEL_ID_PIE, $MODEL_ID_CIDER, $MODEL_ID_POPPERS, $MODEL_ID_ROCKETS, $MODEL_ID_CUPCAKES,  _
											$MODEL_ID_SPARKLER, $MODEL_ID_HONEYCOMB, $MODEL_ID_VICTORY_TOKEN, $MODEL_ID_LUNAR_TOKEN, $MODEL_ID_HUNTERS_ALE, $MODEL_ID_PUMPKIN_COOKIE, $MODEL_ID_KRYTAN_BRANDY, $MODEL_ID_BLUE_DRINK, $MODEL_ID_FRUITCAKE, _
											$MODEL_ID_SPIKED_EGGNOGG, $MODEL_ID_EGGNOGG, $MODEL_ID_SNOWMAN_SUMMONER, $MODEL_ID_FROSTY_TONIC, $MODEL_ID_MISCHIEVOUS_TONIC, $MODEL_ID_DELICIOUS_CAKE, $MODEL_ID_ICED_TEA, $MODEL_ID_PARTY_BEACON]
Global Const $ALCOHOL_ID_ARRAY[9] = [8, $MODEL_ID_GROG, $MODEL_ID_SHAMROCK_ALE, $MODEL_ID_CIDER, $MODEL_ID_HUNTERS_ALE, $MODEL_ID_KRYTAN_BRANDY, $MODEL_ID_SPIKED_EGGNOGG, $MODEL_ID_EGGNOGG, $MODEL_ID_ICED_TEA]
Global Const $SWEETS_ID_ARAY[9] = [8, $MODEL_ID_GOLDEN_EGGS, $MODEL_ID_BUNNIES, $MODEL_ID_PIE, $MODEL_ID_HONEYCOMB, $MODEL_ID_PUMPKIN_COOKIE, $MODEL_ID_BLUE_DRINK, $MODEL_ID_FRUITCAKE, $MODEL_ID_DELICIOUS_CAKE]
Global Const $PARTY_ID_ARAY[8] = [7, $MODEL_ID_POPPERS, $MODEL_ID_ROCKETS, $MODEL_ID_SPARKLER, $MODEL_ID_SNOWMAN_SUMMONER, $MODEL_ID_FROSTY_TONIC, $MODEL_ID_MISCHIEVOUS_TONIC, $MODEL_ID_PARTY_BEACON]
Global Const $MATERIAL_ID_ARRAY[14] = [13, $MODEL_ID_BONES, $MODEL_ID_DUST, $MODEL_ID_IRON, $MODEL_ID_FEATHERS, $MODEL_ID_PLANT_FIBRES, $MODEL_ID_SCALES, $MODEL_ID_CHITIN, $MODEL_ID_GRANITE, $MODEL_ID_MONSTROUS_EYE, $MODEL_ID_MONSTROUS_FANG, $MODEL_ID_MONSTROUS_CLAW, $MODEL_ID_RUBY, $MODEL_ID_SAPPHIRE]
Global Const $TOME_ID_ARRAY[3] = [2, $MODEL_ID_TOME_E_SIN, $MODEL_ID_TOME_R_PARA]	;lowest ID and highest ID

;Hero IDs [ID, "short Name"]
Global Enum $HERO_ID_Norgu = 1, $HERO_ID_Goren, $HERO_ID_Tahlkora, $HERO_ID_Master, $HERO_ID_Jin, $HERO_ID_Koss, $HERO_ID_Dunkoro, $HERO_ID_Sousuke, $HERO_ID_Melonni, $HERO_ID_Zhed, $HERO_ID_Morgahn, $HERO_ID_Margrid, $HERO_ID_Zenmai, $HERO_ID_Olias, $HERO_ID_Razah, $HERO_ID_Mox, $HERO_ID_Keiran, $HERO_ID_Jora, $HERO_ID_Brandor, $HERO_ID_Anton, $HERO_ID_Livia, $HERO_ID_Hayda, $HERO_ID_Kahmu, $HERO_ID_Gwen, $HERO_ID_Xandra, $HERO_ID_Vekk, $HERO_ID_Ogden, $HERO_ID_MERCENARY_1, $HERO_ID_MERCENARY_2, $HERO_ID_MERCENARY_3, $HERO_ID_MERCENARY_4, $HERO_ID_MERCENARY_5, $HERO_ID_MERCENARY_6, $HERO_ID_MERCENARY_7, $HERO_ID_MERCENARY_8, $HERO_ID_Miku , $HERO_ID_Zei_Ri
Global Const $HERO_ID[38][2] = [ [37, 1], [1, "Norgu"], [2, "Goren"], [3, "Tahlkora"], [4, "Master"], [5, "Jin"], [6, "Koss"], [7, "Dunkoro"], [8, "Sousuke"], [9, "Melonni"], [10, "Zhed"], [11, "Morgahn"], [12, "Margrid"], [13, "Zenmai"], [14, "Olias"], [15, "Razah"], [16, "Mox"], [17, "Keiran"], [18, "Jora"], [19, "Brandor"], [20, "Anton"], [21, "Livia"], [22, "Hayda"], [23, "Kahmu"], [24, "Gwen"], [25, "Xandra"], [26, "Vekk"], [27, "Ogden"], [28, "Mercenary Hero 1"], [29, "Mercenary Hero 2"], [30, "Mercenary Hero 3"], [31, "Mercenary Hero 4"], [32, "Mercenary Hero 5"], [33, "Mercenary Hero 6"], [34, "Mercenary Hero 7"], [35, "Mercenary Hero 8"], [36, "Miku"], [37, "Zei Ri"] ]
#Endregion


#Region Runes & Insignas
;~ link: http://www.gamerevision.com/showthread.php?7563-Rune-Trader-Price-Check&highlight=insignia
;~ 				Autor Ralle1976 [Team Awesome]
;~
;~				 $array_Runes_[x][0] = ModelID
;~				 $array_Runes_[x][1] = Name
;~ 				 $array_Runes_[x][2] = Mod Pos.
;~				 $array_Runes_[x][3] = Modstring

Global $array_Runes[184][4] = [ _
		 [15545, "Dervish Rune of Minor Earth Prayers", 8,  "012BE821"], _
		 [15545, "Dervish Rune of Minor Mysticism", 8,  "012CE821"], _
		 [15545, "Dervish Rune of Minor Scythe Mastery", 8,  "0129E821"], _
		 [15545, "Dervish Rune of Minor Wind Prayers", 8,  "012AE821"], _
		 [15546, "Dervish Rune of Major Earth Prayers", 8,  "022BE8210703"], _
		 [15546, "Dervish Rune of Major Mysticism", 8,  "022CE8210703"], _
		 [15546, "Dervish Rune of Major Scythe Mastery", 8,  "0229E8210703"], _
		 [15546, "Dervish Rune of Major Wind Prayers", 8,  "022AE8210703"], _
		 [15547, "Dervish Rune of Superior Earth Prayers", 8,  "032BE8210903"], _
		 [15547, "Dervish Rune of Superior Mysticism", 8,  "032CE8210903"], _
		 [15547, "Dervish Rune of Superior Scythe Mastery", 8,  "0329E8210903"], _
		 [15547, "Dervish Rune of Superior Wind Prayers", 8,  "032AE8210903"], _
		 [15548, "Paragon Rune of Minor Command", 8,  "0126E821"], _
		 [15548, "Paragon Rune of Minor Leadership", 8,  "0128E821"], _
		 [15548, "Paragon Rune of Minor Motivation", 8,  "0127E821"], _
		 [15548, "Paragon Rune of Minor Spear Mastery", 8,  "0125E821"], _
		 [15549, "Paragon Rune of Major Command", 8,  "0226E8210D03"], _
		 [15549, "Paragon Rune of Major Leadership", 8,  "0228E8210D03"], _
		 [15549, "Paragon Rune of Major Motivation", 8,  "0227E8210D03"], _
		 [15549, "Paragon Rune of Major Spear Mastery", 8,  "0225E8210D03"], _
		 [15550, "Paragon Rune of Superior Command", 8,  "0326E8210F03"], _
		 [15550, "Paragon Rune of Superior Leadership", 8,  "0328E8210F03"], _
		 [15550, "Paragon Rune of Superior Motivation", 8,  "0327E8210F03"], _
		 [15550, "Paragon Rune of Superior Spear Mastery", 8,  "0325E8210F03"], _
		 [19124, "Vanguard's Insignia [Assassin]", 8,  "DE010824"], _
		 [19125, "Infiltrator's Insignia [Assassin]", 8,  "DF010824"], _
		 [19126, "Saboteur's Insignia [Assassin]", 8,  "E0010824"], _
		 [19127, "Nightstalker's Insignia [Assassin]", 8,  "E1010824"], _
		 [19128, "Artificer's Insignia [Mesmer]", 8,  "E2010824"], _
		 [19129, "Prodigy's Insignia [Mesmer]", 8,  "E3010824"], _
		 [19130, "Virtuoso's Insignia [Mesmer]", 8,  "E4010824"], _
		 [19131, "Radiant Insignia", 8,  "E5010824"], _
		 [19132, "Survivor Insignia", 8,  "E6010824"], _
		 [19133, "Stalwart Insignia", 8,  "E7010824"], _
		 [19134, "Brawler's Insignia", 8,  "E8010824"], _
		 [19135, "Blessed Insignia", 8,  "E9010824"], _
		 [19136, "Herald's Insignia", 8,  "EA010824"], _
		 [19137, "Sentry's Insignia", 8,  "EB010824"], _
		 [19138, "Bloodstained Insignia [Necromancer]", 8,  "0A020824"], _
		 [19139, "Tormentor's Insignia [Necromancer]", 8,  "EC010824"], _
		 [19140, "Undertaker's Insignia [Necromancer]", 8,  "ED010824"], _
		 [19141, "Bonelace Insignia [Necromancer]", 8,  "EE010824"], _
		 [19142, "Minion Master's Insignia [Necromancer]", 8,  "EF010824"], _
		 [19143, "Blighter's Insignia [Necromancer]", 8,  "F0010824"], _
		 [19144, "Prismatic Insignia [Elementalist]", 8,  "F1010824"], _
		 [19145, "Hydromancer Insignia [Elementalist]", 8,  "F2010824"], _
		 [19146, "Geomancer Insignia [Elementalist]", 8,  "F3010824"], _
		 [19147, "Pyromancer Insignia [Elementalist]", 8,  "F4010824"], _
		 [19148, "Aeromancer Insignia [Elementalist]", 8,  "F5010824"], _
		 [19149, "Wanderer's Insignia [Monk]", 8,  "F6010824"], _
		 [19150, "Disciple's Insignia [Monk]", 8,  "F7010824"], _
		 [19151, "Anchorite's Insignia [Monk]", 8,  "F8010824"], _
		 [19152, "Knight's Insignia [Warrior]", 8,  "F9010824"], _
		 [19153, "Lieutenant's Insignia [Warrior]", 8,  "08020824"], _
		 [19154, "Stonefist Insignia [Warrior]", 8,  "09020824"], _
		 [19155, "Dreadnought Insignia [Warrior]", 8,  "FA010824"], _
		 [19156, "Sentinel's Insignia [Warrior]", 8,  "FB010824"], _
		 [19157, "Frostbound Insignia [Ranger]", 8,  "FC010824"], _
		 [19158, "Earthbound Insignia [Ranger]", 8,  "FD010824"], _
		 [19159, "Pyrebound Insignia [Ranger]", 8,  "FE010824"], _
		 [19160, "Stormbound Insignia [Ranger]", 8,  "FF010824"], _
		 [19161, "Beastmaster's Insignia [Ranger]", 8,  "00020824"], _
		 [19162, "Scout's Insignia [Ranger]", 8,  "01020824"], _
		 [19163, "Windwalker Insignia [Dervish]", 8,  "02020824"], _
		 [19164, "Forsaken Insignia [Dervish]", 8,  "03020824"], _
		 [19165, "Shaman's Insignia [Ritualist]", 8,  "04020824"], _
		 [19166, "Ghost Forge Insignia [Ritualist]", 8,  "05020824"], _
		 [19167, "Mystic's Insignia [Ritualist]", 8,  "06020824"], _
		 [19168, "Centurion's Insignia [Paragon]", 8,  "07020824"], _
		 [3612, "Mesmer Rune of Major Domination Magic", 8,  "0202E8216B01"], _
		 [3612, "Mesmer Rune of Major Fast Casting", 8,  "0200E8216B01"], _
		 [3612, "Mesmer Rune of Major Illusion Magic", 8,  "0201E8216B01"], _
		 [3612, "Mesmer Rune of Major Inspiration Magic", 8,  "0203E8216B01"], _
		 [5549, "Mesmer Rune of Superior Domination Magic", 8,  "0302E8217701"], _
		 [5549, "Mesmer Rune of Superior Fast Casting", 8,  "0300E8217701"], _
		 [5549, "Mesmer Rune of Superior Illusion Magic", 8,  "0301E8217701"], _
		 [5549, "Mesmer Rune of Superior Inspiration Magic", 8,  "0303E8217701"], _
		 [5550, "Rune of Clarity", 8,  "01087827"], _
		 [5550, "Rune of Major Vigor", 8,  "C202E927"], _
		 [5550, "Rune of Purity", 8,  "05067827"], _
		 [5550, "Rune of Recovery", 8,  "07047827"], _
		 [5550, "Rune of Restoration", 8,  "00037827"], _
		 [5551, "Rune of Superior Vigor", 8,  "C202EA27"], _
		 [5552, "Necromancer Rune of Major Blood Magic", 8,  "0204E8216D01"], _
		 [5552, "Necromancer Rune of Major Curses", 8,  "0207E8216D01"], _
		 [5552, "Necromancer Rune of Major Death Magic", 8,  "0205E8216D01"], _
		 [5552, "Necromancer Rune of Major Soul Reaping", 8,  "0206E8216D01"], _
		 [5553, "Necromancer Rune of Superior Blood Magic", 8,  "0304E8217901"], _
		 [5553, "Necromancer Rune of Superior Curses", 8,  "0307E8217901"], _
		 [5553, "Necromancer Rune of Superior Death Magic", 8,  "0305E8217901"], _
		 [5553, "Necromancer Rune of Superior Soul Reaping", 8,  "0306E8217901"], _
		 [5554, "Elementalist Rune of Major Air Magic", 8,  "0208E8216F01"], _
		 [5554, "Elementalist Rune of Major Earth Magic", 8,  "0209E8216F01"], _
		 [5554, "Elementalist Rune of Major Energy Storage", 8,  "020CE8216F01"], _
		 [5554, "Elementalist Rune of Major Fire Magic", 8,  "020AE8216F01"], _
		 [5554, "Elementalist Rune of Major Water Magic", 8,  "020BE8216F01"], _
		 [5555, "Elementalist Rune of Superior Air Magic", 8,  "0308E8217B01"], _
		 [5555, "Elementalist Rune of Superior Earth Magic", 8,  "0309E8217B01"], _
		 [5555, "Elementalist Rune of Superior Energy Storage", 8,  "030CE8217B01"], _
		 [5555, "Elementalist Rune of Superior Fire Magic", 8,  "030AE8217B01"], _
		 [5555, "Elementalist Rune of Superior Water Magic", 8,  "030BE8217B01"], _
		 [5556, "Monk Rune of Major Healing Prayers", 8,  "020DE8217101"], _
		 [5556, "Monk Rune of Major Protection Prayers", 8,  "020FE8217101"], _
		 [5556, "Monk Rune of Major Smiting Prayers", 8,  "020EE8217101"], _
		 [5556, "Monk Rune of Major Divine Favor", 8,  "0210E8217101"], _
		 [5557, "Monk Rune of Superior Divine Favor", 8,  "0310E8217D01"], _
		 [5557, "Monk Rune of Superior Healing Prayers", 8,  "030DE8217D01"], _
		 [5557, "Monk Rune of Superior Protection Prayers", 8,  "030FE8217D01"], _
		 [5557, "Monk Rune of Superior Smiting Prayers", 8,  "030EE8217D01"], _
		 [903, "Warrior Rune of Minor Absorption", 8,  "EA02E827"], _
		 [903, "Warrior Rune of Minor Axe Mastery", 8,  "0112E821"], _
		 [903, "Warrior Rune of Minor Hammer Mastery", 8,  "0113E821"], _
		 [903, "Warrior Rune of Minor Strength", 8,  "0111E821"], _
		 [903, "Warrior Rune of Minor Swordsmanship", 8,  "0114E821"], _
		 [903, "Warrior Rune of Minor Tactics", 8,  "0115E821"], _
		 [5558, "Warrior Rune of Major Absorption", 8,  "EA02E927"], _
		 [5558, "Warrior Rune of Major Axe Mastery", 8,  "0212E8217301"], _
		 [5558, "Warrior Rune of Major Hammer Mastery", 8,  "0213E8217301"], _
		 [5558, "Warrior Rune of Major Strength", 8,  "0211E8217301"], _
		 [5558, "Warrior Rune of Major Swordsmanship", 8,  "0214E8217301"], _
		 [5558, "Warrior Rune of Major Tactics", 8,  "0215E8217301"], _
		 [5559, "Warrior Rune of Superior Absorption", 8,  "EA02EA27"], _
		 [5559, "Warrior Rune of Superior Axe Mastery", 8,  "0312E8217F01"], _
		 [5559, "Warrior Rune of Superior Hammer Mastery", 8,  "0313E8217F01"], _
		 [5559, "Warrior Rune of Superior Strength", 8,  "0311E8217F01"], _
		 [5559, "Warrior Rune of Superior Swordsmanship", 8,  "0314E8217F01"], _
		 [5559, "Warrior Rune of Superior Tactics", 8,  "0315E8217F01"], _
		 [5560, "Ranger Rune of Major Beast Mastery", 8,  "0216E8217501"], _
		 [5560, "Ranger Rune of Major Expertise", 8,  "0217E8217501"], _
		 [5560, "Ranger Rune of Major Marksmanship", 8,  "0219E8217501"], _
		 [5560, "Ranger Rune of Major Wilderness Survival", 8,  "0218E8217501"], _
		 [5561, "Ranger Rune of Superior Beast Mastery", 8,  "0316E8218101"], _
		 [5561, "Ranger Rune of Superior Expertise", 8,  "0317E8218101"], _
		 [5561, "Ranger Rune of Superior Marksmanship", 8,  "0319E8218101"], _
		 [5561, "Ranger Rune of Superior Marksmanship", 8,  "0319E8218101"], _
		 [5561, "Ranger Rune of Superior Wilderness Survival", 8,  "0318E8218101"], _
		 [6324, "Assassin Rune of Minor Critical Strikes", 8,  "0123E821"], _
		 [6324, "Assassin Rune of Minor Dagger Mastery", 8,  "011DE821"], _
		 [6324, "Assassin Rune of Minor Deadly Arts", 8,  "011EE821"], _
		 [6324, "Assassin Rune of Minor Shadow Arts", 8,  "011FE821"], _
		 [6325, "Assassin Rune of Major Critical Strikes", 8,  "0223E8217902"], _
		 [6325, "Assassin Rune of Major Dagger Mastery", 8,  "021DE8217902"], _
		 [6325, "Assassin Rune of Major Deadly Arts", 8,  "021EE8217902"], _
		 [6325, "Assassin Rune of Major Shadow Arts", 8,  "021FE8217902"], _
		 [6326, "Assassin Rune of Superior Critical Strikes", 8,  "0323E8217B02"], _
		 [6326, "Assassin Rune of Superior Dagger Mastery", 8,  "031DE8217B02"], _
		 [6326, "Assassin Rune of Superior Deadly Arts", 8,  "031EE8217B02"], _
		 [6326, "Assassin Rune of Superior Shadow Arts", 8,  "031FE8217B02"], _
		 [6327, "Ritualist Rune of Minor Channeling Magic", 8,  "0122E821"], _
		 [6327, "Ritualist Rune of Minor Communing", 8,  "0120E821"], _
		 [6327, "Ritualist Rune of Minor Restoration Magic", 8,  "0121E821"], _
		 [6327, "Ritualist Rune of Minor Spawning Power", 8,  "0124E821"], _
		 [6328, "Ritualist Rune of Major Channeling Magic", 8,  "0222E8217F02"], _
		 [6328, "Ritualist Rune of Major Communing", 8,  "0220E8217F02"], _
		 [6328, "Ritualist Rune of Major Restoration Magic", 8,  "0221E8217F02"], _
		 [6328, "Ritualist Rune of Major Spawning Power", 8,  "0224E8217F02"], _
		 [6329, "Ritualist Rune of Superior Channeling Magic", 8,  "0322E8218102"], _
		 [6329, "Ritualist Rune of Superior Communing", 8,  "0320E8218102"], _
		 [6329, "Ritualist Rune of Superior Restoration Magic", 8,  "0321E8218102"], _
		 [6329, "Ritualist Rune of Superior Spawning Power", 8,  "0324E8218102"], _
		 [898, "Rune of Attunement", 8,  "0200D822"], _
		 [898, "Rune of Minor Vigor", 8,  "C202E827"], _
		 [898, "Rune of Vitae", 8,  "000A4823"], _
		 [899, "Mesmer Rune of Minor Domination Magic", 8,  "0102E821"], _
		 [899, "Mesmer Rune of Minor Fast Casting", 8,  "0100E821"], _
		 [899, "Mesmer Rune of Minor Illusion Magic", 8,  "0101E821"], _
		 [899, "Mesmer Rune of Minor Inspiration Magic", 8,  "0103E821"], _
		 [900, "Necromancer Rune of Minor Blood Magic", 8,  "0104E821"], _
		 [900, "Necromancer Rune of Minor Curses", 8,  "0107E821"], _
		 [900, "Necromancer Rune of Minor Death Magic", 8,  "0105E821"], _
		 [900, "Necromancer Rune of Minor Soul Reaping", 8,  "0106E821"], _
		 [901, "Elementalist Rune of Minor Air Magic", 8,  "0108E821"], _
		 [901, "Elementalist Rune of Minor Earth Magic", 8,  "0109E821"], _
		 [901, "Elementalist Rune of Minor Energy Storage", 8,  "010CE821"], _
		 [901, "Elementalist Rune of Minor Water Magic", 8,  "010BE821"], _
		 [901, "Elementalist Rune of Minor Fire Magic", 8,  "010AE821"], _
		 [902, "Monk Rune of Minor Divine Favor", 8,  "0110E821"], _
		 [902, "Monk Rune of Minor Healing Prayers", 8,  "010DE821"], _
		 [902, "Monk Rune of Minor Protection Prayers", 8,  "010FE821"], _
		 [902, "Monk Rune of Minor Smiting Prayers", 8,  "010EE821"], _
		 [904, "Ranger Rune of Minor Beast Mastery", 8,  "0116E821"], _
		 [904, "Ranger Rune of Minor Expertise", 8,  "0117E821"], _
		 [904, "Ranger Rune of Minor Marksmanship", 8,  "0119E821"], _
		 [904, "Ranger Rune of Minor Wilderness Survival", 8,  "0118E821"]]
#EndRegion


#Region H&H

Func MoveHero($aX, $aY, $HeroID, $Random = 75); Parameter1 = heroID (1-7) reset flags $aX = 0x7F800000, $aY = 0x7F800000

	Switch $HeroID
		Case "All"
			CommandAll(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 1
			CommandHero1(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 2
			CommandHero2(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 3
			CommandHero3(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 4
			CommandHero4(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 5
			CommandHero5(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 6
			CommandHero6(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 7
			CommandHero7(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
	EndSwitch
EndFunc   ;==>MoveHero

Func CommandHero1($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_PLACE_FLAG, MEMORYREAD($lHeroStruct[1] + 0x4), $aX, $aY, 0)
EndFunc   ;==>CommandHero1

Func CommandHero2($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_PLACE_FLAG, MEMORYREAD($lHeroStruct[1] + 0x28), $aX, $aY, 0)
EndFunc   ;==>CommandHero2

Func CommandHero3($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_PLACE_FLAG, MEMORYREAD($lHeroStruct[1] + 0x4C), $aX, $aY, 0)
EndFunc   ;==>CommandHero3

Func CommandHero4($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_PLACE_FLAG, MEMORYREAD($lHeroStruct[1] + 0x70), $aX, $aY, 0)
EndFunc   ;==>CommandHero4

Func CommandHero5($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_PLACE_FLAG, MEMORYREAD($lHeroStruct[1] + 0x94), $aX, $aY, 0)
EndFunc   ;==>CommandHero5

Func CommandHero6($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_PLACE_FLAG, MEMORYREAD($lHeroStruct[1] + 0xB8), $aX, $aY, 0)
EndFunc   ;==>CommandHero6

Func CommandHero7($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_PLACE_FLAG, MEMORYREAD($lHeroStruct[1] + 0xDC), $aX, $aY, 0)
EndFunc   ;==>CommandHero7

#Region Trade with Players

Func TradePlayer($aAgent)
	Local $lAgentID

	If IsDllStruct($aAgent) = 0 Then
		$lAgentID = ConvertID($aAgent)
	Else
		$lAgentID = DllStructGetData($aAgent, 'ID')
	EndIf
	SendPacket(0x08, $HEADER_TRADE_PLAYER, $lAgentID)
EndFunc   ;==>TradePlayer

Func SubmitOffer($aAmount);Parameter = gold amount to offer. Like pressing the "Submit Offer" button, but also including the amount of gold offered.
	SendPacket(0x08, $HEADER_TRADE_SUBMIT_OFFER, $aAmount)
EndFunc   ;==>SubmitOffer

Func ChangeOffer();No parameters. Like pressing the "Change Offer" button.
	SendPacket(0x04, $HEADER_TRADE_CHANGE_OFFER)
EndFunc   ;==>ChangeOffer

Func OfferItem($aItem, $aAmount = 0); not tested! need feedback
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
	SendPacket(0xC, $HEADER_TRADE_OFFER_ITEM, $lItemID, $lAmount)
EndFunc   ;==>OfferItem

Func CancelTrade();No parameters. Like pressing the "Cancel" button in a trade.
	SendPacket(0x04, $HEADER_TRADE_CANCEL)
EndFunc   ;==>CancelTrade

Func AcceptTrade();No parameters. Like pressing the "Accept" button in a trade. Can only be used after both players have submitted their offer.
	SendPacket(0x04, $HEADER_TRADE_ACCEPT)
EndFunc   ;==>AcceptTrade

#EndRegion Trade with Players


#Region Item related commands

;=================================================================================================
; Function:			PickUpItems($iItems = -1, $fMaxDistance = 1012)
; Description:		PickUp defined number of items in defined area around default = 1012
; Parameter(s):		$iItems:	number of items to be picked
;					$fMaxDistance:	area within items should be picked up
; Requirement(s):	GW must be running and Memory must have been scanned for pointers (see Initialize())
; Return Value(s):	On Success - Returns $iItemsPicked (number of items picked)
; Author(s):		GWCA team, recoded by ddarek, thnx to The ArkanaProject
;=================================================================================================
Func PickupItems($iItems = -1, $fMaxDistance = 1012)
	Local $aItemID, $lNearestDistance, $lDistance
	$tDeadlock = TimerInit()
	Do
		$aItem = GetNearestItemToAgent(-2)
		$lDistance = @extended

		$aItemID = DllStructGetData($aItem, 'ID')
		If $aItemID = 0 Or $lDistance > $fMaxDistance Or TimerDiff($tDeadlock) > 30000 Then ExitLoop
		PickUpItem($aItem)
		$tDeadlock2 = TimerInit()
		Do
			Sleep(500)
			If TimerDiff($tDeadlock2) > 5000 Then ContinueLoop 2
		Until DllStructGetData(GetAgentById($aItemID), 'ID') == 0
		$iItems_Picked += 1
		;UpdateStatus("Picked total " & $iItems_Picked & " items")
	Until $iItems_Picked = $iItems
	Return $iItems_Picked
EndFunc   ;==>PickupItems

;=================================================================================================
; Function:			GetNearestItemToAgent($aAgent)
; Description:		Get nearest item lying on floor around $aAgent ($aAgent = -2 ourself), necessary to work with PickUpItems func
; Parameter(s):		$aAgent: ID of Agent
; Requirement(s):	GW must be running and Memory must have been scanned for pointers (see Initialize())
; Return Value(s):	On Success - Returns ID of nearest item
;					@extended  - distance to item
; Author(s):		GWCA team, recoded by ddarek
;=================================================================================================

#CS
Func GetNearestItemToAgent($aAgent)
	Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance, $lAgentToCompare

	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	For $i = 1 To GetMaxAgents()
		$lAgentToCompare = GetAgentByID($i)

	If DllStructGetData($lAgentToCompare, 'Type') <> 0x400 Then ContinueLoop
		$lDistance = (DllStructGetData($lAgentToCompare, 'Y') - DllStructGetData($aAgent, 'Y')) ^ 2 + (DllStructGetData($lAgentToCompare, 'X') - DllStructGetData($aAgent, 'X')) ^ 2
		If $lDistance < $lNearestDistance Then
			$lNearestAgent = $lAgentToCompare
			$lNearestDistance = $lDistance
		EndIf
	Next
	SetExtended(Sqrt($lNearestDistance)) ;this could be used to retrieve the distance also
	Return $lNearestAgent
EndFunc   ;==>GetNearestItemToAgent
#CE

Func GetNearestItemByModelId($ModelId, $aAgent = -2 )
Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance, $lAgentToCompare

	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)

	For $i = 1 To GetMaxAgents()
		$lAgentToCompare = GetAgentByID($i)
		If DllStructGetData($lAgentToCompare, 'Type') <> 0x400 Then ContinueLoop
		If DllStructGetData(GetItemByAgentID($i), 'ModelID') <> $ModelId Then ContinueLoop
		$lDistance = (DllStructGetData($lAgentToCompare, 'Y') - DllStructGetData($aAgent, 'Y')) ^ 2 + (DllStructGetData($lAgentToCompare, 'X') - DllStructGetData($aAgent, 'X')) ^ 2
		If $lDistance < $lNearestDistance Then
			$lNearestAgent = $lAgentToCompare
			$lNearestDistance = $lDistance
		EndIf

	Next
	Return $lNearestAgent; return struct of Agent not item!
EndFunc   ;==>GetNearestItemByModelId


Func GetNumberOfFoesInRangeOfAgent($aAgent = -2, $fMaxDistance = 1012)
	Local $lDistance, $lCount = 0

	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	For $i = 1 To GetMaxAgents()
		$lAgentToCompare = GetAgentByID($i)
		If GetIsDead($lAgentToCompare) <> 0 Then ContinueLoop
		If DllStructGetData($lAgentToCompare, 'Allegiance') = 0x3 Then
			$lDistance = GetDistance($lAgentToCompare, $aAgent)
			If $lDistance < $fMaxDistance Then
				$lCount += 1
				;ConsoleWrite("Counts: " &$lCount & @CRLF)
			EndIf
		EndIf
	Next
	Return $lCount
EndFunc   ;==>GetNumberOfFoesInRangeOfAgent

Func GetNumberOfAlliesInRangeOfAgent($aAgent = -2, $fMaxDistance = 1012)
	Local $lDistance, $lCount = 0

	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	For $i = 1 To GetMaxAgents()
		$lAgentToCompare = GetAgentByID($i)
		If GetIsDead($lAgentToCompare) <> 0 Then ContinueLoop
		If DllStructGetData($lAgentToCompare, 'Allegiance') = 0x1 Then
			$lDistance = GetDistance($lAgentToCompare, $aAgent)
			If $lDistance < $fMaxDistance Then
				$lCount += 1
				;ConsoleWrite("Counts: " &$lCount & @CRLF)
			EndIf
		EndIf
	Next
	Return $lCount
EndFunc   ;==>GetNumberOfAlliesInRangeOfAgent

Func GetNumberOfItemsInRangeOfAgent($aAgent = -2, $fMaxDistance = 1012)
	Local $lDistance, $lCount = 0

	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	For $i = 1 To GetMaxAgents()
		$lAgentToCompare = GetAgentByID($i)
		If DllStructGetData($lAgentToCompare, 'Type') = 0x400 Then
			$lDistance = GetDistance($lAgentToCompare, $aAgent)
			If $lDistance < $fMaxDistance Then
				$lCount += 1
				;ConsoleWrite("Counts: " &$lCount & @CRLF)
			EndIf
		EndIf
	Next
	Return $lCount
EndFunc   ;==>GetNumberOfItemsInRangeOfAgent

Func GetNearestEnemyToCoords($aX, $aY)
	Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance, $lAgentToCompare

	For $i = 1 To GetMaxAgents()
		$lAgentToCompare = GetAgentByID($i)
		If DllStructGetData($lAgentToCompare, 'HP') < 0.005 Or DllStructGetData($lAgentToCompare, 'Allegiance') <> 0x3 Then ContinueLoop

		$lDistance = ($aX - DllStructGetData($lAgentToCompare, 'X')) ^ 2 + ($aY - DllStructGetData($lAgentToCompare, 'Y')) ^ 2
		If $lDistance < $lNearestDistance Then
			$lNearestAgent = $lAgentToCompare
			$lNearestDistance = $lDistance
		EndIf
	Next

	Return $lNearestAgent
EndFunc   ;==>GetNearestAgentToCoords
#Endregion


#Region Inventory

Func GetExtraItemInfoBySlot($aBag, $aSlot)
	$item = GetItembySlot($aBag, $aSlot)
	$lItemExtraPtr = DllStructGetData($item, "ModPtr")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraPtr, 'ptr', $lItemExtraStructPtr, 'int', $lItemExtraStructSize, 'int', '')
	Return $lItemExtraStruct
	;ConsoleWrite($rarity & @CRLF)
EndFunc   ;==>GetExtraInfoBySlot

Func GetEtraItemInfoByItemId($aItem)
	$item = GetItemByItemID($aItem)
	$lItemExtraPtr = DllStructGetData($item, "ModPtr")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraPtr, 'ptr', $lItemExtraStructPtr, 'int', $lItemExtraStructSize, 'int', '')
	Return $lItemExtraStruct
EndFunc   ;==>GetEtraInfoByItemId

Func GetEtraItemInfoByAgentId($aItem)
	$item = GetItemByAgentID($aItem)
	$lItemExtraPtr = DllStructGetData($item, "ModPtr")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraPtr, 'ptr', $lItemExtraStructPtr, 'int', $lItemExtraStructSize, 'int', '')
	Return $lItemExtraStruct
EndFunc   ;==>GetEtraInfoByAgentId

Func GetEtraItemInfoByModelId($aItem)
	$item = GetItemByModelID($aItem)
	$lItemExtraPtr = DllStructGetData($item, "ModPtr")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraPtr, 'ptr', $lItemExtraStructPtr, 'int', $lItemExtraStructSize, 'int', '')
	Return $lItemExtraStruct
EndFunc   ;==>GetEtraInfoByModelId

Func GetExtraItemReqBySlot($aBag, $aSlot)
	$item = GetItembySlot($aBag, $aSlot)
	$lItemExtraReqPtr = DllStructGetData($item, "extraItemReq")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraReqPtr, 'ptr', $lItemExtraReqStructPtr, 'int', $lItemExtraReqStructSize, 'int', '')
	Return $lItemExtraReqStruct
	;ConsoleWrite($rarity & @CRLF)
EndFunc   ;==>GetExtraItemReqBySlot

Func GetEtraItemReqByItemId($aItem)
	$item = GetItemByItemID($aItem)
	$lItemExtraReqPtr = DllStructGetData($item, "extraItemReq")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraReqPtr, 'ptr', $lItemExtraReqStructPtr, 'int', $lItemExtraReqStructSize, 'int', '')
	Return $lItemExtraReqStruct
EndFunc   ;==>GetEtraItemReqByItemId

Func GetEtraItemReqByAgentId($aItem)
	$item = GetItemByAgentID($aItem)
	$lItemExtraReqPtr = DllStructGetData($item, "extraItemReq")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraReqPtr, 'ptr', $lItemExtraReqStructPtr, 'int', $lItemExtraReqStructSize, 'int', '')
	Return $lItemExtraReqStruct
EndFunc   ;==>GetEtraItemReqByAgentId

Func GetEtraItemReqByModelId($aItem)
	$item = GetItemByModelID($aItem)
	$lItemExtraReqPtr = DllStructGetData($item, "extraItemReq")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraReqPtr, 'ptr', $lItemExtraReqStructPtr, 'int', $lItemExtraReqStructSize, 'int', '')
	Return $lItemExtraReqStruct
EndFunc   ;==>GetEtraItemReqByModelId

Func FindEmptySlot($bagIndex) ;Parameter = bag index to start searching from. Returns integer with item slot. This function also searches the storage. If any of the returns = 0, then no empty slots were found
	Local $lItemInfo, $aSlot

	For $aSlot = 1 To DllStructGetData(GetBag($bagIndex), 'Slots')
		Sleep(40)
		ConsoleWrite("Checking: " & $bagIndex & ", " & $aSlot & @CRLF)
		$lItemInfo = GetItemBySlot($bagIndex, $aSlot)
		If DllStructGetData($lItemInfo, 'ID') = 0 Then
			ConsoleWrite($bagIndex & ", " & $aSlot & "  <-Empty! " & @CRLF)
			SetExtended($aSlot)
			ExitLoop
		EndIf
	Next
	Return 0
EndFunc   ;==>FindEmptySlot
#Region Misc

Func GetHPPips($aAgent = -2); Thnx to The Arkana Project
   If IsDllStruct($aAgent) == 0 Then $aAgent = GetAgentByID($aAgent)
   Return Round(DllStructGetData($aAgent, 'hppips') * DllStructGetData($aAgent, 'maxhp') / 2, 0)
EndFunc


Func GetTeam($aTeam); Thnx to The Arkana Project. Only works in PvP!
	Local $lTeamNumber
	Local $lTeam[1][2]
	Local $lTeamSmall[1] = [0]
	Local $lAgent
	If IsString($aTeam) Then
		Switch $aTeam
			Case "Blue"
				$lTeamNumber = 1
			Case "Red"
				$lTeamNumber = 2
			Case "Yellow"
				$lTeamNumber = 3
			Case "Purple"
				$lTeamNumber = 4
			Case "Cyan"
				$lTeamNumber = 5
			Case Else
				$lTeamNumber = 0
		EndSwitch
	Else
		$lTeamNumber = $aTeam
	EndIf
	$lTeam[0][0] = 0
	$lTeam[0][1] = $lTeamNumber
	If $lTeamNumber == 0 Then Return $lTeamSmall
	For $i = 1 To GetMaxAgents()
		$lAgent = GetAgentByID($i)
		If DllStructGetData($lAgent, 'ID') == 0 Then ContinueLoop
		If GetIsLiving($lAgent) And DllStructGetData($lAgent, 'Team') == $lTeamNumber And (DllStructGetData($lAgent, 'LoginNumber') <> 0 Or StringRight(GetAgentName($lAgent), 9) == "Henchman]") Then
			$lTeam[0][0] += 1
			ReDim $lTeam[$lTeam[0][0]+1][2]
			$lTeam[$lTeam[0][0]][0] = DllStructGetData($lAgent, 'id')
			$lTeam[$lTeam[0][0]][1] = DllStructGetData($lAgent, 'PlayerNumber')
		EndIf
	Next
	_ArraySort($lTeam, 0, 1, 0, 1)
	Redim $lTeamSmall[$lTeam[0][0]+1]
	For $i = 0 To $lTeam[0][0]
		$lTeamSmall[$i] = $lTeam[$i][0]
	Next
	Return $lTeamSmall
EndFunc

Func FormatName($aAgent); Thnx to The Arkana Project. Only works in PvP!
	If IsDllStruct($aAgent) == 0 Then $aAgent = GetAgentByID($aAgent)
	Local $lString
	Switch DllStructGetData($aAgent, 'Primary')
		Case 1
			$lString &= "W"
		Case 2
			$lString &= "R"
		Case 3
			$lString &= "Mo"
		Case 4
			$lString &= "N"
		Case 5
			$lString &= "Me"
		Case 6
			$lString &= "E"
		Case 7
			$lString &= "A"
		Case 8
			$lString &= "Rt"
		Case 9
			$lString &= "P"
		Case 10
			$lString &= "D"
	EndSwitch
	Switch DllStructGetData($aAgent, 'Secondary')
		Case 1
			$lString &= "/W"
		Case 2
			$lString &= "/R"
		Case 3
			$lString &= "/Mo"
		Case 4
			$lString &= "/N"
		Case 5
			$lString &= "/Me"
		Case 6
			$lString &= "/E"
		Case 7
			$lString &= "/A"
		Case 8
			$lString &= "/Rt"
		Case 9
			$lString &= "/P"
		Case 10
			$lString &= "/D"
	EndSwitch
	$lString &= " - "
	If DllStructGetData($aAgent, 'LoginNumber') > 0 Then
		$lString &= GetPlayerName($aAgent)
	Else
		$lString &= StringReplace(GetAgentName($aAgent), "Corpse of ", "")
	EndIf
	Return $lString
EndFunc



; #FUNCTION: Death ==============================================================================================================
; Description ...: Checks the dead
; Syntax.........: Death()
; Parameters ....:
; Author(s):		Syc0n
; ===============================================================================================================================
Func Death()
	If DllStructGetData(GetAgentByID(-2), "Effects") = 0x0010 Then
		Return 1	; Whatever you want to put here in case of death
	Else
		Return 0
	EndIf
EndFunc   ;==>Death

; #FUNCTION: RndSlp =============================================================================================================
; Description ...: RandomSleep (5% Variation) with Deathcheck
; Syntax.........: RndSlp(§wert)
; Parameters ....: $val = Sleeptime
; Author(s):		Syc0n
; ===============================================================================================================================

Func RNDSLP($val)
	$wert = Random($val * 0.95, $val * 1.05, 1)
	If $wert > 45000 Then
		For $i = 0 To 6
			Sleep($wert / 6)
			DEATH()
		Next
	ElseIf $wert > 36000 Then
		For $i = 0 To 5
			Sleep($wert / 5)
			DEATH()
		Next
	ElseIf $wert > 27000 Then
		For $i = 0 To 4
			Sleep($wert / 4)
			DEATH()
		Next
	ElseIf $wert > 18000 Then
		For $i = 0 To 3
			Sleep($wert / 3)
			DEATH()
		Next
	ElseIf $wert >= 9000 Then
		For $i = 0 To 2
			Sleep($wert / 2)
			DEATH()
		Next
	Else
		Sleep($wert)
		DEATH()
	EndIf
EndFunc   ;==>RndSlp

; #FUNCTION: Slp ================================================================================================================
; Description ...: Sleep with Deathcheck
; Syntax.........: Slp(§wert)
; Parameters ....: $wert = Sleeptime
; ===============================================================================================================================

Func SLP($val)
	If $val > 45000 Then
		For $i = 0 To 6
			Sleep($val / 6)
			DEATH()
		Next
	ElseIf $val > 36000 Then
		For $i = 0 To 5
			Sleep($val / 5)
			DEATH()
		Next
	ElseIf $val > 27000 Then
		For $i = 0 To 4
			Sleep($val / 4)
			DEATH()
		Next
	ElseIf $val > 18000 Then
		For $i = 0 To 3
			Sleep($val / 3)
			DEATH()
		Next
	ElseIf $val >= 9000 Then
		For $i = 0 To 2
			Sleep($val / 2)
			DEATH()
		Next
	Else
		Sleep($val)
		DEATH()
	EndIf
EndFunc   ;==>Slp

Func _FloatToInt($fFloat)
	Local $tFloat, $tInt

	$tFloat = DllStructCreate("float")
	$tInt = DllStructCreate("int", DllStructGetPtr($tFloat))
	DllStructSetData($tFloat, 1, $fFloat)
	Return DllStructGetData($tInt, 1)

EndFunc   ;==>_FloatToInt

Func _IntToFloat($fInt)
	Local $tFloat, $tInt

	$tInt = DllStructCreate("int")
	$tFloat = DllStructCreate("float", DllStructGetPtr($tInt))
	DllStructSetData($tInt, 1, $fInt)
	Return DllStructGetData($tFloat, 1)

EndFunc   ;==>_IntToFloat


Func PingSleep($msExtra = 0)
	$ping = GetPing()
	Sleep($ping + $msExtra)
EndFunc   ;==>PingSleep

Func ComputeDistanceEx($x1, $y1, $x2, $y2)
	Return Sqrt(($y2 - $y1) ^ 2 + ($x2 - $x1) ^ 2)
	$dist = Sqrt(($y2 - $y1) ^ 2 + ($x2 - $x1) ^ 2)
	ConsoleWrite("Distance: " & $dist & @CRLF)

EndFunc   ;==>ComputeDistanceEx

Func GoNearestNPCToCoords($aX, $aY)
	Local $NPC
	MoveTo($aX, $aY)
	$NPC = GetNearestNPCToCoords($aX, $aY)
	Do
		RndSleep(250)
		GoNPC($NPC)
	Until GetDistance($NPC, -2) < 250
	RndSleep(500)
EndFunc

#EndRegion Misc




#Region Inventory
Func ClearInventory()
	Local $aItem, $RuneOrInsignia, $Timer
	If CountFreeSlots($UseBags) >= 8 Then Return
	Out("Cleaning Inventory")
	If GetMapID() <> $MAP_ID_BALTH_TEMPLE Then TravelTo($MAP_ID_BALTH_TEMPLE)
	If GetGoldCharacter() >= 80000 Then DepositGold(30000)
	GoToNPC(GetNearestNPCToCoords(-4861, -7441)) ;Ai Tei [Merchant]
	For $lBag = 1 To $UseBags
		If Not IdentifyBag($lBag) Then
			If FindIdentificationKit() = 0 then
			   BuySuperiorIDKit()
			Endif
			$Timer = TimerInit()
			Do
				Sleep(250)
			Until FindIdentificationKit() Or TimerDiff($Timer) > 5000
			IdentifyBag($lBag)
		EndIf
	Next
	For $i = 0 To 1	;2 iterations: 1st just sell, 2nd salvage and sell
		For $lBag = 1 To 4 ; allows the use of 4 bags, change to protect bags
			For $lSlot = 1 To DllStructGetData(GetBag($lBag), 'Slots')
				$aItem = GetItemBySlot($lBag, $lSlot)
				If ItemHasUsefulRuneOrInsignia($aItem) Then
					$RuneOrInsignia = @extended
					If $i == 0 Then ContinueLoop	;doing runes stuff at the end so that there's no risk of no inventory space left
					$Timer = TimerInit()
					Do
						If FindSuperiorSalvageKit(16) == 0 Then BuyItem(4, 1, 2000)
						StartSalvageSuperiorKit($aItem, 16)
						Sleep(GetPing() + 800)
						SalvageMod($RuneOrInsignia)
						Sleep(GetPing() + 800)
						If Not ItemHasUsefulRuneOrInsignia(GetItemBySlot($lBag, $lSlot)) Then ExitLoop
						$RuneOrInsignia = @extended
					Until TimerDiff($Timer) > 10000
					$aItem = GetItemBySlot($lBag, $lSlot)	;getting current item at ($lBag, $lSlot) after salvaging runes/insignias
				EndIf
				If CanSell($aItem) Then
					SellItem($aItem)
					$Timer = TimerInit()
					Do
						Sleep(250)
					Until DllStructGetData(GetItemBySlot($lBag, $lSlot), 'ID') == 0 Or TimerDiff($Timer) > 10000
				EndIf
			Next
		Next
	Next
	MoveTo(-4700, -7250)	;so you don't get stuck at Merchant
	GoToNPC(GetNearestNPCToCoords(-4822, -7730)) ;Rune Trader
	For $lBag = 1 To $UseBags
		For $lSlot = 1 To DllStructGetData(GetBag($lBag), 'Slots')
			$aItem = GetItemBySlot($lBag, $lSlot)
			If DllStructGetData($aItem, 'type') == $TYPE_RUNE_AND_MOD Then
				If GetGoldCharacter() >= 50000 Then DepositGold(90000)
				TraderRequestSell($aItem)
				Sleep(GetPing() + 800)
				TraderSell()
				Sleep(GetPing() + 800)
			EndIf
		Next
	Next

	If CountFreeSlots($UseBags) <= 5 Then
		$pick_up_golds = False
		$pick_up_purples = False
	EndIf
EndFunc	;==>CheckInventory

Func CountFreeSlots($NumOfBags = 4)
	Local $FreeSlots, $Slots

	For $Bag = 1 To $NumOfBags
		$Slots += DllStructGetData(GetBag($Bag), 'Slots')
		$Slots -= DllStructGetData(GetBag($Bag), 'ItemsCount')
	Next

	Return $Slots
EndFunc   ;==>CountFreeSlots

Func CountTotalSlots($NumOfBags = 4)
	Local $FreeSlots, $Slots

	For $Bag = 1 To $NumOfBags
		$Slots += DllStructGetData(GetBag($Bag), 'Slots')
	Next

	Return $Slots
EndFunc   ;==>CountFreeSlots

Func FindSuperiorSalvageKit($iBags = 16)
   If GetMapLoading() == $INSTANCETYPE_LOADING Then Disconnected()
   Local $Item
   Local $Kit = 0
   Local $Uses = 101
   For $Bag = 1 To $iBags
	  For $Slot = 1 To DllStructGetData(GetBag($Bag), 'Slots')
		 $Item = GetItemBySlot($Bag, $Slot)
		 Switch DllStructGetData($Item, 'ModelID')
			Case 5900
			  $Kit = DllStructGetData($Item, 'ID')
			  ExitLoop 2
			Case Else
			  ContinueLoop
		 EndSwitch
	 Next
   Next
   Return $Kit
EndFunc   ;==>FindSuperiorSalvageKit
#EndRegion Inventory

Func CanSell($aItem)
	Local $Rarity = GetRarity($aItem)
	Local $aQuantity = DllStructGetData($aItem, 'Quantity')
	Local $aModelID = DllStructGetData($aItem, 'ModelID')
	Local $aType = DllStructGetData($aItem, 'Type')
	Local $aReq = GetItemReq($aItem)

;Staff_Head = 896; Staff_Wrapping = 908; Shield_Handle = 15554; Focus_Core = 15551; ID_Wand = 15552; Bow_String = 894; Bow_Grip = 906; Sword_Hilt = 897; Sword_Pommel = 909; Axe_Haft = 893
; Axe_Grip = 905; Dagger_Tang = 6323; Dagger_Handle = 6331; Hammer_Haft = 895; Hammer_Grip = 907; Scythe_Snathe = 15543; Scythe_Grip = 15553; Spearhead = 15544; Spear_Grip = 15555
; Inscriptions_Martial = 15540; Inscriptions_Focus_Shield = 15541; Inscriptions_All = 15542; Inscriptions_General = 17059; Inscriptions_Spellcasting = 19122; Inscriptions_Focus_Items = 19123

   Switch $aModelID
	  Case 896, 908, 15542, 1151, 15554, 15551 ; select mods and inscriptions (see list above and adjust as needed) - salvaged manually (bot won't salavage them)
		 Return False
	  Case 19185 	;kabob
		 Return False
	  Case 1175, 1176, 1152, 1153, 920, 0 ; picked up from other bot not sure which those items are
		 Return False
	  Case 146, 22751 ; prevents selling dyes (146) and lockpicks (22751)
		 Return False
	  Case 2989, 5899, 2992, 2992, 2991, 5900 ; prevents selling ID (2989->5899) and salvage kits (2992->2991->5900)
		 Return False
	  Endswitch

   Switch $Rarity
	  Case $Rarity_Gold
		 Switch $aReq
			Case 9
			   Return False
			Case 10, 11, 12
			   Switch $aModelID
				  Case 944, 945, 950, 951, 24897	;Echovald Shield, Gothic Defender, Brass Knuckles (24897)
					  Return False
				  Case 794, 866, 775, 776, 789, 858, 866	;oni blade and paper fans
					  Return False
				  Case 1953, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969, 1970, 1971, 1972, 1973, 1974, 1975 ; All Froggy's
					  Return False
				  Case Else
					 Switch $aType
						Case $TYPE_RUNE_AND_MOD, $TYPE_USABLE
						   Return False
					 EndSwitch
			   Endswitch
   		 Endswitch
   Endswitch

   Return True

EndFunc	;==>CanSell

Func ItemHasUsefulRuneOrInsignia($aItem)
	If DllStructGetData($aItem, 'Type') <> $TYPE_SALVAGE Then Return False
	;things that should be kept
	Local $lWhiteListInsignias[11] = [10, "Survivor Insignia", "Radiant Insignia", "Blessed Insignia", _
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
		If $index == 0 Then $ListToUse = $lWhiteListInsignias
		If $index == 1 Then $ListToUse = $lWhiteListRunes
		For $i = 0 To 183	;all runes and insignias from "_Runes_and_Insignias.au3"
			For $j = 1 To $ListToUse[0]
				If $array_Runes[$i][1] == $ListToUse[$j] Then
					If StringInStr($lModStruct, $array_Runes[$i][3]) > 0 Then
						SetExtended($index)
						Return True
					EndIf
				EndIf
			Next
		Next
	Next
	Return False
EndFunc	;==>ItemHasUsefulRuneOrInsignia

;~ Description: Slightly modified version of GWA²'s StartSalvage(), but only uses superior salvage kits. Starts a salvaging session of an item.
;~ $aBag defines up to which bag it will look for salvage kits -> 16 = complete inventory and complete chest | 4 = inventory only
Func StartSalvageSuperiorKit($aItem, $aBag = 16)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x690]
	Local $lSalvageSessionID = MemoryReadPtr($mBasePointer, $lOffset)

	If IsDllStruct($aItem) = 0 Then
		Local $lItemID = $aItem
	Else
		Local $lItemID = DllStructGetData($aItem, 'ID')
	EndIf

	Local $lSalvageKit = FindSuperiorSalvageKit($aBag)
	If $lSalvageKit = 0 Then Return

	DllStructSetData($mSalvage, 2, $lItemID)
	DllStructSetData($mSalvage, 3, $lSalvageKit)
	DllStructSetData($mSalvage, 4, $lSalvageSessionID[1])

	Enqueue($mSalvagePtr, 16)
EndFunc   ;==>StartSalvageSuperiorKit


  Func Sell($bagIndex, $numOfSlots)
 	$numOfSlots = DllStructGetData($bag, 'slots')
	Sleep(Random(150, 250))
 	For $i = 0 To $numOfSlots - 1
 		$aItem = GetItemBySlot($bagIndex, $i)
 		If CanSell($aItem) Then
 			SellItem($aItem)
 			Sleep(Random(500, 550))
 		EndIf
 	Next
 EndFunc   ;==>Sell

Func StoreGolds()
	GoldIs(1, 20)
	GoldIs(2, 10)
	GoldIs(3, 15)
	GoldIs(4, 15)
EndFunc

Func GoldIs($bagIndex, $numOfSlots)
   For $i = 1 To CountTotalSlots
	  ConsoleWrite("Checking items: " & $bagIndex & ", " & $i & @CRLF)
	  $aItem = GetItemBySlot($bagIndex, $i)
	  If DllStructGetData($aItem, 'ID') <> 0 And GetRarity($aItem) = $RARITY_Gold Then
		 Do
		   For $bag = 8 To 12; Storage panels are form 8 till 16 (I have only standard amount plus aniversary one)
			   $slot = FindEmptySlot($bag)
			   $slot = @extended
			   If $slot <> 0 Then
				   $FULL = False
				   $nSlot = $slot
				   ExitLoop 2; finding first empty $slot in $bag and jump out
			   Else
				   $FULL = True; no empty slots :(
			   EndIf
			   Sleep(400)
		   Next
		 Until $FULL = True
		 If $FULL = False Then
		   MoveItem($aItem, $bag, $nSlot)
		   ConsoleWrite("Gold item moved ...."& @CRLF)
		   Sleep(Random(450, 550))
		 EndIf
	  EndIf
   Next
EndFunc   ;==>GoldIs

Func GetPicksCount();Counts Lockpicks in your inventory
	Local $AmountPicks
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4 ;change 1 To 16 if you want to count storage also or 1 to 4 for just personal inv.  Will display on GUI
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 22751 Then
				$AmountPicks += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $AmountPicks
EndFunc   ; Counts Lockpicks in your inventory to include chest

