
#include <Array.au3>
#include <ButtonConstants.au3>
#include <Date.au3>
#include <EditConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <GuiRichEdit.au3>
#include <ScrollBarsConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include "GWA2_Headers.au3"
#include "GWA2.au3"

#RequireAdmin
;#include "GWA2_Headers.au3"


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
Global Const $TYPE_ID [10] = [$TYPE_STAFF, $TYPE_WAND, $TYPE_SHIELD, $TYPE_SPEAR, $TYPE_SWORD, $TYPE_AXE, $TYPE_BOW, $TYPE_HAMMER, $TYPE_DAGGERS, $TYPE_SCYTHE]

#Endregion



#Region Runes & Insignas
Global $array_armormods[184][4] = [ _
	[15545, "Dervish Rune of Minor Earth Prayers", 8,  "012BE821"], _
	[15545, "Dervish Rune of Minor Mysticism", 8,  "012CE821"], _
	[15545, "Dervish Rune of Minor Scythe Mastery", 8,  "0129E821"], _
	[15545, "Dervish Rune of Minor Wind Prayers", 8,  "012AE821"], _
	[15546, "Dervish Rune of Major Earth Prayers", 8,  "022BE8210703"], _
	[15546, "Dervish Rune of Major Mysticism", 8,  "022CE8210703"], _
	[15546, "Dervish Rune of Major Scythe Mastery", 8,  "0229E8210703"], _
	[15546, "Dervish Rune of Major Wind Prayers", 8,  "022AE8210703"], _
	[15547, "Dervish Rune of Superior Earth Prayers", 8,  "032BE8210903"], _  ; 32BE8210903 3025
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
	[19163, "Windwalker Insignia [Dervish]", 8,  "02020824"], _  ; 040430A5060518A7
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
Global $array_weaponmods[127][14] = [ _
	[ "+7 armor vs Physical",   "07005821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+7 Armor vs Elemental",   "07002821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +5",   "05000821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "HCT20",   "00140828",   "" , 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "HCT10",   "000A0822",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "HSR20",   "00142828",   "" , 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "HSR10",   "000AA823",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+20% Enchantment Duration",   "1400B822",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Item's attribute +1 (Chance: 20%",   "00143828",   "" , 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+30 HP",   "001E4823",   "" , 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], _
	[ "+45 HP while Enchanted",   "002D6823",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+45 HP while in a Stance",   "002D8823",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+60 HP while Hexed",   "003C7823",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Highly salvageable",   "32000826",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Improved sale value",   "3200F805",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Energy +5",   "0500D822",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Energy +5 (HP>50%)",   "05320823",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Energy +5 (while Enchanted)",   "0500F822",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Energy +7 (HP<50%)",   "07321823",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Energy +7 (while hexed)",   "07002823",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Energy +15 (-1 energy regen)",   "0F00D822",   "0100C820", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "-20% Bleeding",   "00005828",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "-20% Blind",   "00015828",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "-20% Crippled",   "00035828",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "-20% Dazed",   "00075828",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "-20% Deep Wound",   "00045828",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "-20% DiseaseInscribable",   "00055828",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "-20% Disease",   "E3017824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "-20% Poison",   "00065828",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "-20% Weakness",   "00085828",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage 20% (HP<50%)",   "14328822",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage 20% (while Hexed)",   "14009822",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage +15% (-1 energy regen)",   "0F003822",   "0100C820", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage +15% (-1 HP regen)",   "0F003822",   "0100E820", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage +15% (HP> 50%)",   "0F327822",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage +15% (while Enchanted)",   "0F006822",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage +15% (while in a Stance)",   "0F00A822",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage +15% (vs Hexed Foes)",   "0F005822",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage +15% (-10 AL while attacking)",   "0A001820",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage +15% (Energy -5)",   "0500B820",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Barbed",   "DE016824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Crippling",   "E1016824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Cruel",   "E2016824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Ebon",   "000BB824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Fiery",   "0005B824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Furious",   "0A00B823",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Heavy",   "E601824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Icy",   "0003B824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Poisonous",   "E4016824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Shocking",   "0004B824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Silencing",   "E5016824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Sundering",   "1414F823",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Vampiric (+3)",   "00032825",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Vampiric (+5)",   "00052825",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Zealous",   "01001825",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+ 20% (vs Charr)",   "00018080",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+ 20% (vs Demons)",   "00088080",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+ 20% (vs Dragons",   "00098080",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+ 20% (vs Dwarves)",   "00068080",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+ 20% (vs Giants)",   "00058080",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+ 20% (vs Ogres",   "000A8080",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+ 20% (vs Plants)",   "00038080",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+ 20% (vs Skeletons)",   "00048080",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+ 20% (vs Tengu)",   "00078080",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+ 20% (vs Trolls)",   "00028080",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+ 20% (vs Undead)",   "00008080",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +5 (HP> 50%)",   "0532A821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +10 (HP< 50%)",   "0A32B821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +5 (while Enchanted)",   "05009821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +5 (while attacking)",   "05007821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +5 (while casting)",   "05008821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +5 (vs Elemental)",   "05002821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +5 (vs Physical)",   "05005821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +5 (Energy -5)",   "0500B820",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +5 (Health -20)",   "1400D820",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ " Armor +10 (while Hexed)",   "0A00C821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+10 Armor vs.Undead",   "0A004821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+10 Armor vs.Charr",   "0A014821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+10 Armor vs.Trolls",   "0A024821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+10 Armor vs.Plants",   "0A034821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+10 Armor vs.Skeletons",   "0A044821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+10 Armor vs.Giants",   "0A054821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+10 Armor vs.Dwarves",   "0A064821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+10 Armor vs.Tengu",   "0A074821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+10 Armor vs.Demons",   "0A084821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+10 Armor vs.Dragons",   "0A094821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "+10 Armor vs.Ogres",   "0A0A4821",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +10 (vs Blunt)",   "0A0018A1",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +10 (vs Cold)",   "0A0318A1",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +10 (vs Earth)",   "0A0B18A1",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +10 (vs Fire)",   "0A0518A1",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +10 (vs Lightning)",   "0A0418A1",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +10 (vs Piercing)",   "0A0118A1",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Armor +10 (vs Slashing)",   "0A0218A1",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage -2 (while Enchanted",   "02008820",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage -2 (while in a Stance",   "0200A820",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage -3 (while Hexed",   "03009820",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Damage -5 (Chance: 20%",   "05147820",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Axe Mastery +1 (20% chance)",   "14121824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Marksmanship +1 (20% chance)",   "14191824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Dagger Mastery +1 (20% chance)",   "141D1824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Hammer Mastery +1 (20% chance)",   "14131824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Scythe Mastery +1 (20% chance)",   "14291824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Spear Mastery +1 (20% chance)",   "14251824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Swordmanship +1 (20% chance)",   "14141824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Air Magic +1 (20% chance)",   "14081824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Blood Magic +1 (20% chance)",   "14041824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Channeling Magic +1 (20% chance)",   "14221824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Communing Magic +1 (20% chance)",   "14201824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Curse Magic +1 (20% chance)",   "14071824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Death Magic +1 (20% chance)",   "14051824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Divine Favor  +1 (20% chance)",   "14101824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Domination Magic +1 (20% chance)",   "14021824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Earth Magic +1 (20% chance)",   "14091824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Fire Magic +1 (20% chance)",   "140A1824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Healing Prayers +1 (20% chance)",   "140D1824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Illusion Magic +1 (20% chance)",   "14011824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Inspiration  +1 (20% chance)",   "14031824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Protection Prayers +1 (20% chance)",   "140F1824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Restoration Magic +1 (20% chance)",   "14211824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Smiting Prayers +1 (20% chance)",   "140E1824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Soul Reaping +1 (20% chance)",   "14061824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Spawning Magic +1 (20% chance)",   "14241824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
	[ "Water Magic +1 (20% chance)",   "140B1824",   "" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
#EndRegion


; Bogroot Growths Froggy Bot by LogicDoor

Opt("GUIOnEventMode", 1)
#Region ### START Koda GUI section ### Form=s
$X_GUI = 8
$Y_GUI = 8
$Width_GUI = 390
$Height_GUI = 312
$iSpacing= 8

Global $frmMain = GUICreate("Froggy v0.6 - By logicdoor", 390, 312, 100, 112)
GUISetFont(9, 400, 0, "Arial")
Global $edtLog = _GUICtrlRichEdit_Create($frmMain, "", 128, 47, 254, 130, BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_READONLY))
_GUICtrlRichEdit_SetFont($edtLog, 9, "Arial")
_GUICtrlRichEdit_SetCharColor($edtLog, "65280")
_GUICtrlRichEdit_SetText($edtLog, StringFormat("#########################\r\n\r\nFroggy Bot v0.6 By logicdoor. Enjoy\r\n\r\n#########################\r\n\r\n"))
Global $charname = GUICtrlCreateInput('WinGetProcess("Guild Wars")', 232, 8, 156, 24)
Global $btnStart = GUICtrlCreateButton("Start", $X_GUI, $Y_GUI, 113, 25)
Global $grpGeneralStats = GUICtrlCreateGroup("Settings", $X_GUI, 40, 110, 136)
Global $Render  = GUICtrlCreateCheckbox("Render", $X_GUI+8, 56, 76, 17)

GUICtrlSetOnEvent(-1, "ToggleRendering")
GUICtrlSetFont($Render, 9, -1, 0, "Arial")

Global $Purge = GUICtrlCreateCheckbox("Purge",     $X_GUI+$iSpacing, 72, 70, 17)
GUICtrlSetOnEvent(-1, "Purgehook")
GUICtrlSetFont($Purge, 9, -1, 0, "Arial")

Global $Use_Scrolls = GUICtrlCreateCheckbox("Scrolls", $X_GUI+$iSpacing, 88, 70, 17)
GUICtrlSetOnEvent(-1, "ToggleScrolls")
GUICtrlSetFont($Use_Scrolls, 9, -1, 0, "Arial")

Global $Use_Stones = GUICtrlCreateCheckbox("Stones", $X_GUI+$iSpacing, 104, 80, 17)
GUICtrlSetOnEvent(-1, "ToggleStones")
GUICtrlSetFont($Use_Stones, 9, -1, 0, "Arial")

Global $Open_Chests  = GUICtrlCreateCheckbox("Open Chests", $X_GUI+$iSpacing, 120, 90, 17)
guictrlsetstate ($Open_Chests, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "ToggleOpenChests")
GUICtrlSetFont($Open_Chests, 9, -1, 0, "Arial")

Global $Store_Golds  = GUICtrlCreateCheckbox("Store Golds",      $X_GUI+$iSpacing, 136, 90, 17)
GUICtrlSetOnEvent(-1, "ToggleStore")
GUICtrlSetFont($Store_Golds, 9, -1, 0, "Arial")

Global $Sell_Items   = GUICtrlCreateCheckbox("Auto-Sell",       $X_GUI+$iSpacing, 152, 70, 17)
GUICtrlSetOnEvent(-1, "ToggleSell")
GUICtrlSetFont($Sell_Items, 9, -1, 0, "Arial")

GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $grpGeneralStats = GUICtrlCreateGroup("General Statistics", $X_GUI, 184, 182, 120)
GUICtrlSetFont($grpGeneralStats, 9, 800, 0, "Arial")

Global $lblRunNum = GUICtrlCreateLabel("Run Number:", $X_GUI+$iSpacing, 200, 80, 20)
GUICtrlSetFont($lblRunNum, 9, -1, 0, "Arial")
GUICtrlSetColor($lblRunNum, 0x0078D7)
Global $lblRunNumData = GUICtrlCreateLabel("1", 120, 200, 64, 16, $SS_CENTER)
GUICtrlSetFont($lblRunNumData, 9, -1, 0, "Arial")
GUICtrlSetColor($lblRunNumData, 0x0078D7)

Global $lblDeldrimor = GUICtrlCreateLabel("Deldrimor:", $X_GUI+$iSpacing, 216, 90, 20)
GUICtrlSetFont($lblDeldrimor, 9, -1, 0, "Arial")
GUICtrlSetColor($lblDeldrimor, 0x0078D7)
Global $lblDeldrimorData = GUICtrlCreateLabel("0", 120, 216, 64, 16, $SS_CENTER)
GUICtrlSetFont($lblDeldrimorData, 9, -1, 0, "Arial")
GUICtrlSetColor($lblDeldrimorData, 0x0078D7)

Global $lblAsura = GUICtrlCreateLabel("Asura Points:", $X_GUI+$iSpacing, 232, 76, 20)
GUICtrlSetFont($lblAsura, 9, -1, 0, "Arial")
GUICtrlSetColor($lblAsura, 0x0078D7)
Global $lblAsuraData = GUICtrlCreateLabel("0", 120, 232, 64, 16, $SS_CENTER)
GUICtrlSetFont($lblAsuraData, 9, -1, 0, "Arial")
GUICtrlSetColor($lblAsuraData, 0x0078D7)

Global $lblLockpicks = GUICtrlCreateLabel("Lockpicks:", $X_GUI+$iSpacing, 248, 76, 20)
GUICtrlSetFont($lblLockpicks, 9, -1, 0, "Arial")
GUICtrlSetColor($lblLockpicks, 0x0078D7)
Global $lblLockpicksData = GUICtrlCreateLabel("0", 120, 248, 64, 16, $SS_CENTER)
GUICtrlSetFont($lblLockpicksData, 9, -1, 0, "Arial")
GUICtrlSetColor($lblLockpicksData, 0x0078D7)

Global $lblCurrentRun = GUICtrlCreateLabel("Run Time:", $X_GUI+$iSpacing, 264, 76, 20)
GUICtrlSetFont($lblCurrentRun, 9, -1, 0, "Arial")
GUICtrlSetColor($lblCurrentRun, 0x0078D7)
Global $lblCurrentRunData = GUICtrlCreateLabel("00:00:00", 120, 264, 64, 16, $SS_CENTER)
GUICtrlSetFont($lblCurrentRunData, 9, -1, 0, "Arial")
GUICtrlSetColor($lblCurrentRunData, 0x0078D7)
GUICtrlCreateGroup("", -99, -99, 1, 1)

Global $lblTotalRun = GUICtrlCreateLabel("Total Run Time:", $X_GUI+$iSpacing, 280, 96, 20)
GUICtrlSetFont($lblTotalRun, 9, -1, 0, "Arial")
GUICtrlSetColor($lblTotalRun, 0x0078D7)
Global $lblTotalRunData = GUICtrlCreateLabel("00:00:00", 120, 280, 64, 16, $SS_CENTER)
GUICtrlSetFont($lblTotalRunData, 9, -1, 0, "Arial")
GUICtrlSetColor($lblTotalRunData, 0x0078D7)

Global $grpDropStats = GUICtrlCreateGroup("Drop Statistics", $X_GUI+24*$iSpacing, 184, 182, 120)
GUICtrlSetFont($grpDropStats, 9, 800, 0, "Arial")
   Global $lblFroggy = GUICtrlCreateLabel("Froggies: ", $X_GUI+25*$iSpacing, 200, 90, 20)
   GUICtrlSetFont($lblFroggy, 9, -1, 0, "Arial")
   GUICtrlSetColor($lblFroggy, 0x808000)
   Global $lblFroggyData = GUICtrlCreateLabel("0", 310, 200, 64, 30, $SS_CENTER)
   GUICtrlSetFont($lblFroggyData, 9, -1, 0, "Arial")
   GUICtrlSetColor($lblFroggyData, 0x808000)

   Global $lblGold = GUICtrlCreateLabel("Gold Items: ", $X_GUI+25*$iSpacing, 216, 90, 20)
   GUICtrlSetFont($lblGold, 9, -1, 0, "Arial")
   GUICtrlSetColor($lblGold, 0x808000)
   Global $lblGoldData = GUICtrlCreateLabel("0", 310, 216, 64, 30, $SS_CENTER)
   GUICtrlSetFont($lblGoldData, 9, -1, 0, "Arial")
   GUICtrlSetColor($lblGoldData, 0x808000)

   Global $lblLockpicksDrop = GUICtrlCreateLabel("Lockpicks:", $X_GUI+25*$iSpacing, 232, 76, 20)
   GUICtrlSetFont($lblLockpicksDrop, 9, -1, 0, "Arial")
   GUICtrlSetColor($lblLockpicksDrop, 0x808000)
   Global $lblLockpicksDropData = GUICtrlCreateLabel("0", 310, 232, 64, 30, $SS_CENTER)
   GUICtrlSetFont($lblLockpicksDropData, 9, -1, 0, "Arial")
   GUICtrlSetColor($lblLockpicksDropData, 0x808000)

   Global $lblChests = GUICtrlCreateLabel("Chests Opened:", $X_GUI+25*$iSpacing, 248, 96, 20)
   GUICtrlSetFont($lblChests, 9, -1, 0, "Arial")
   GUICtrlSetColor($lblChests, 0x808000)
   Global $lblChestsData = GUICtrlCreateLabel("0", 310, 248, 64, 23, $SS_CENTER)
   GUICtrlSetFont($lblChestsData, 9, -1, 0, "Arial")
   GUICtrlSetColor($lblChestsData, 0x808000)

   Global $lblBlackDye = GUICtrlCreateLabel("Black Dye:", $X_GUI+25*$iSpacing, 264, 96, 20)
   GUICtrlSetFont($lblBlackDye, 9, -1, 0, "Arial")
   GUICtrlSetColor($lblBlackDye, 0x808000)
   Global $lblBlackDyeData = GUICtrlCreateLabel("0", 310, 264, 64, 23, $SS_CENTER)
   GUICtrlSetFont($lblBlackDyeData, 9, -1, 0, "Arial")
   GUICtrlSetColor($lblBlackDyeData, 0x808000)

   Global $lblTomes = GUICtrlCreateLabel("Tomes: ", $X_GUI+25*$iSpacing, 280, 90, 20)
   GUICtrlSetFont($lblTomes, 9, -1, 0, "Arial")
   GUICtrlSetColor($lblTomes, 0x008000)
   Global $lblTomesData = GUICtrlCreateLabel("0", 310, 280, 64, 30, $SS_CENTER)
   GUICtrlSetFont($lblTomesData, 9, -1, 0, "Arial")
   GUICtrlSetColor($lblTomesData, 0x008000)

GUICtrlCreateGroup("", -99, -99, 1, 1)

Global $lblCoordsData = GUICtrlCreateLabel("", 136, 12, 90, 24, BitOR($GUI_SS_DEFAULT_INPUT,$ES_CENTER))
GUICtrlSetFont($lblCoordsData, 9, -1, 0, "Arial")
GUICtrlSetColor($lblCoordsData, 0x008000)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
GUICtrlSetOnEvent($btnStart, "BotStartup")
GUISetOnEvent($GUI_EVENT_CLOSE, "ExitBot")

; Globals
Global Const $GuildWars = WinGetProcess("Guild Wars")
Global Const $iGaddsEncampmentMapID = 638
Global Const $iSplarkflyMapID = 558
Global Const $iBogrootGrowthsLevel1MapID = 615
Global Const $iBogrootGrowthsLevel2MapID = 616
Global Const $MAP_ID_BALTH_TEMPLE = 248
Global Const $AsuranBuffArr[5] = [2434, 2435, 2436, 2481, 2548]
Global Const $DwarvenBuffArr[9] = [2445, 2446, 2447, 2448, 2549, 2565, 2566, 2567, 2568]
Global $nMerchant[7] = ["Merchant", "Marchand", "Runen-Händler", "Mercante", "Mercader", "Kupiec", "Merchunt"]  ; use if playing in a different language
Global $nRuneTrader[7] = ["Rune Trader", "Vente de runes", "Runen-Händler", "Venditore di rune", "Comerciante de runas", "Handlarz runami", "Roone-a Traeder" ] ; use if playing in a different language]
Global $nXunlai[7] = ["Xunlai Chest", "Coffre Xunlai", "Xunlai-Truhe", "Forziere Xunlai", "Arcón Xunlai", "Skrzynia Xunlai", "Xoonlaeee Chest"] ; use if playing in a different language
Global $nChest[7] = ["Locked Chest", "Coffre scellé", "Verschlossene Truhe", "Forziere Sigillato", "Cofre Cerrado", "Zamknięta Skrzynia", "Lucked Chest"] ; use if playing in a different language
Global $bRunning = false
Global $iCurrentRun = 0
Global $nCurrentRunTime = 0
Global $bAsuraBlessing = false
Global $bDwarvenBlessing = false
Global $hTekksWar = 0x339
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
Global $iCoords[2]
Global $coords[2]
Global $iBlocked

; Config
Global $nMinSleep = 60000 * 20 ; 20 Minutes
Global $nMaxSleep = 60000 * 60 ; 60 Minutes
Global $bGetKreweBuff = true
Global $iRunNum = 99
Global $RenderingEnabled = True
Global $Ident = False
Global $UseBags = 4 ; sets number of bags to be used
Global $Sell_Items = False
Global $Open_Chests = True
Global $Use_Scrolls = False
Global $Use_Stones = False
Global $Store_Golds = False
Global $Purge = False

Global $ColLabels[11] = ["Staff", "Wand",  "Offhand", "Shield", "Spear", "Sword", "Axe", "Bow", "Hammer", "Daggers", "Scythe"]
Global $iSpacing = 8

#comments-start
Global $frmSelection = GUICreate("Mod Selection", 774, 660, 600, 112)
GUICtrlSetFont($frmSelection, 9, -1, 0, "Arial")

GUICtrlCreateTab(1, 0, 774, 660)


GUICtrlCreateTabItem("General Mods")
	  Global $grpEnergy = GUICtrlCreateGroup("", 0, 14, 774, 660)
	  For $j = 3 to 13
		 GUICtrlCreateLabel($ColLabels[$j-3], $X_GUI + 60+(50 * $j), 40 , $iSpacing*6, $iSpacing*2, $ES_CENTER)
		 For $i = 0 To 29
			 If $j = 3 then GUICtrlCreateLabel($array_weaponmods[$i][0], $X_GUI+$iSpacing*2, 60 + (16 * $i),200, $iSpacing*2)
			 $array_weaponmods[$i][$j-3] = GUICtrlCreateCheckbox("", $X_GUI + 72+(50 * $j), 60 + (16 * $i), $iSpacing*2, $iSpacing*2, $ES_CENTER)
			 If $array_weaponmods[$i][$j] = 0 then guictrlsetstate (-1, $GUI_CHECKED)
			 Next
		  Next
GUICtrlCreateTabItem("") ; end tabitem definition

GUICtrlCreateTabItem("Damage")
	  Global $grpEnergy = GUICtrlCreateGroup("", 0, 14, 774, 660)
	  For $j = 3 to 13
		 GUICtrlCreateLabel($ColLabels[$j-3], $X_GUI + 60+(50 * $j), 40 , $iSpacing*5, $iSpacing*2, $ES_CENTER)
		 For $i = 30 To 65
			 If $j = 3 then GUICtrlCreateLabel($array_weaponmods[$i][0], $X_GUI+$iSpacing*2, 60 + (16 * ($i - 30)),200, $iSpacing*2)
			 $array_weaponmods[$i][$j-3] = GUICtrlCreateCheckbox("", $X_GUI + 72+(50 * $j), 60 + (16 * ($i - 30)), $iSpacing*2, $iSpacing*2, $ES_CENTER)
			 If $array_weaponmods[$i][$j] = 0 then guictrlsetstate ($array_weaponmods[$i][$j], $GUI_CHECKED)
			 Next
		  Next

GUICtrlCreateTabItem("") ; end tabitem definition

GUICtrlCreateTabItem("Armor")
	  Global $grpEnergy = GUICtrlCreateGroup("", 0, 14, 774, 660)
	  For $j = 3 to 13
		 GUICtrlCreateLabel($ColLabels[$j-3], $X_GUI + 60+(50 * $j), 40 , $iSpacing*5, $iSpacing*2, $ES_CENTER)
		 For $i = 66 To 97
			 If $j = 3 then GUICtrlCreateLabel($array_weaponmods[$i][0], $X_GUI+$iSpacing*2, 60 + (16 * ($i - 66)),200, $iSpacing*2)
			 $array_weaponmods[$i][$j-3] = GUICtrlCreateCheckbox("", $X_GUI + 72+(50 * $j), 60 + (16 * ($i - 66)), $iSpacing*2, $iSpacing*2, $ES_CENTER)
			 If $array_weaponmods[$i][$j] = 0 then guictrlsetstate ($array_weaponmods[$i][$j], $GUI_CHECKED)
			 Next
		  Next

GUICtrlCreateTabItem("") ; end tabitem definition

GUICtrlCreateTabItem("Mastery")
	  Global $grpEnergy = GUICtrlCreateGroup("", 0, 14, 774, 660)
	  For $j = 3 to 13
		 GUICtrlCreateLabel($ColLabels[$j-3], $X_GUI + 60+(50 * $j), 40 , $iSpacing*5, $iSpacing*2, $ES_CENTER)
		 For $i = 98 To 123
			 If $j = 3 then GUICtrlCreateLabel($array_weaponmods[$i][0], $X_GUI+$iSpacing*2, 60 + (16 * ($i - 98)),200, $iSpacing*2)
			 $array_weaponmods[$i][$j-3] = GUICtrlCreateCheckbox("", $X_GUI + 72+(50 * $j), 60 + (16 * ($i - 98)), $iSpacing*2, $iSpacing*2, $ES_CENTER)
			 If $array_weaponmods[$i][$j] = 0 then guictrlsetstate ($array_weaponmods[$i][$j], $GUI_CHECKED)
			 Next
		  Next

GUICtrlCreateTabItem("") ; end tabitem definition
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetOnEvent($GUI_EVENT_CLOSE, "ExitBot")

GUISetState()

#comments-end


Main()

Func Main()
	While 1
		 For $i = 0 To 123
			   For $j = 3 to 13
				  If $array_weaponmods[$i][$j] = 1 then
					 GUIctrlsetstate ($array_weaponmods[$i][$j], $GUI_CHECKED)
				  Else
					 GUICtrlSetState($array_weaponmods[$i][$j], $GUI_UNCHECKED)
				  EndIf
			   Next
		 Next

		Sleep(100)
		While $bRunning And $iCurrentRun < $iRunNum
			GUICtrlSetData($lblLockpicksData, GetPicksCount())
			If $iCurrentRun = 0  And GetMapID() <> $iSplarkflyMapID And GetMapID() <> $iBogrootGrowthsLevel1MapID And GetMapID() <> $iBogrootGrowthsLevel2MapID = 616 Then
				If $Sell_Items = True then ClearInventory() ; sells once at the start no matter how many free slots are available (can be used to declutter any character)
				Setup()
			EndIf
			$iCurrentRun += 1
			GUICtrlSetData($lblRunNumData, $iCurrentRun)

			$OpenedChestAgentIDs[0] = ""
			ReDim $OpenedChestAgentIDs[1]

			If GetMapID() = $iSplarkflyMapID then
			   If $iCurrentRun = 1 then RunToBogroot()
			   TakeQuest()
			Endif

			Global $nCurrentRunTime = TimerInit()
			AdlibRegister("CurrentRunTime", 1000)

			If GetMapID() = $iBogrootGrowthsLevel1MapID then
			   BogrootLvl1()
			Endif

			If GetMapID() = $iBogrootGrowthsLevel2MapID then  ; allows the bot to start straight from level 2
			   BogrootLvl2()
			   Boss()
			Endif
		Wend
	Wend
 EndFunc

Func Setup()
   If GetMapID() <> $iGaddsEncampmentMapID Then
	  Out("Not at Gadds Encampment, Travelling.")
	  TravelTo($iGaddsEncampmentMapID)
   EndIf
   AbandonQuest($hTekksWar)
   BeforeRun()
   TakeAzuranBlessing()
   RunToBogroot()
EndFunc

Func BotStartup()
	GUICtrlSetState($btnStart, $GUI_DISABLE)
	GUICtrlSetState($charname, $GUI_DISABLE)
	$sInitMethod = GUICtrlRead($charname)
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
	AdlibRegister("Coords", 1000)
	AdlibRegister("DeldrimorPoints", 1000)
	AdlibRegister("AsuraPoints", 1000)
	AdlibRegister("DropCounts", 1000)
	AdlibRegister("Lockpicks", 1000)
	AdlibRegister("CheckPartyDead", 500)
;	GUICtrlSetData($lblLockpicksData, $iLockpicks)
;	GUICtrlSetData($lblChestsData, $iChestCount)
	$bRunning = True
 EndFunc

Func BeforeRun()
	SwitchMode (2)
	Out("Moving to Sparkfly")
	MoveTo(-10018, -21892)
	MoveTo(-9550, -20400)
	TolSleep(500)
	Do
		Move(-9451, -19766)
	Until WaitMapLoading($iSplarkflyMapID)
	Out("Loaded Sparkfly")
 EndFunc

Func TakeAzuranBlessing()
	If $bGetKreweBuff Then
		Out("Getting Asuran Blessing")
		$aAsuraKrewe = GetNearestNPCToCoords(-9021, -19906)
		GoToNPC($aAsuraKrewe)
		TolSleep(500)
		Do
			TolSleep(200)
			Dialog(0x84)
			sleep(2000)
			For $i = 0 to UBound($AsuranBuffArr) - 1
				If IsDllStruct(GetEffect($AsuranBuffArr[$i])) Then
					$bAsuraBlessing = True
					Out("Asuran Blessing Received")
					ExitLoop 2
				EndIf
			Next
			Out("Unable To Get Asuran Blessing")
			ExitLoop
		Until $bAsuraBlessing
	EndIf
 EndFunc

Func RunToBogroot()
	Out("Running To Bogroot")
	Local $aWaypoints[16][4] = [ _
	[-7746, -16039, 1500, "Raptor Group"], _
	[-6804, -10431, 1500, "Ferothrax Group"], _
	[-4001, -6599, 1500, "Angorodon Group"], _
	[-805, -3997, 1500, "Raptor Group 2"], _
	[2244, -1934, 1500, "Ferothrax Group 2"], _
	[4904, 281, 1500, "Raptor Group 3"], _
	[8014, 2151, 1500, "Cutting"], _
	[11344, 2137, 1500, "Ferothrax Group 3"], _
	[10322, 6297, 1500, "Raptor Group 4"], _
	[11650, 10117, 1500, "Moving to Simiam Group"], _
	[13227, 10518, 1500, "Simiam Group"], _
	[13011, 14609, 1500, "Moving to Simiam Group 2"], _
	[13292, 18200, 1500, "Simiam Group 2"], _
	[12965, 20463, 1500, "Moving to Simiam Group 3"], _
	[11874, 21508, 1500, "Simiam Group 3"], _
	[11874, 21508, 1500, "Simiam Group 3"]]
	MoveandAggro($aWaypoints)

	$NearestWaypoint = GetNearestWaypointIndex($aWaypoints)

	If $DeadOnTheRun = 1 then
	   Out("Party wipe, restarting at"& $aWaypoints[$NearestWaypoint][3])
	   $DeadOnTheRun = 0
	   MoveandAggro($aWaypoints)
    Endif

 EndFunc

Func TakeQuest()
	TolSleep(2000)
	MoveTo(12396, 22007)
	Out("Taking Quest: Tekks")
	$aTekks = GetNearestNPCToCoords(12561, 22614)
	GoToNPC($aTekks)
	Do
		TolSleep(500)
		AcceptQuest($hTekksWar)
		Dialog($TekksDialog)
	Until IsDllStruct(GetQuestByID($hTekksWar))
	Out("Starting Run Num: " & $iCurrentRun)
    Out("Moving to Bogroot Portal.")
	MoveTo(11197, 23820)
	MoveTo(12470, 25036)
	MoveTo(12968, 26219)
	Do
		Move(13097, 26393)
	Until WaitMapLoading($iBogrootGrowthsLevel1MapID)
	TolSleep(3000)
 EndFunc

Func Out($sMessage)
	ConsoleWrite($sMessage & @CRLF)
	_GUICtrlRichEdit_SetFont($edtLog, 8, "Trebuchet MS")
	_GUICtrlRichEdit_AppendText($edtLog, $sMessage & @CRLF)
	_GUICtrlEdit_Scroll($edtLog, $SB_SCROLLCARET)
 EndFunc

 Func BogrootLvl1 ()
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
	[7360, -17361, 1500, "Moving to Level 2 Portal"], _
	[7552, -18776, 1500, "Moving to Level 2 Portal"]]

    $NearestWaypoint = GetNearestWaypointIndex($aWaypointsLevel1)
    If $NearestWaypoint <3  then
	   Out("Aggro Frog Fight")
	   MoveTo(17026, 2168)
	   AggroMoveToEx(18092, 4590)
	   Out("Moving to Beacon of Droknar")
	   MoveTo(19099, 7762)
	   Out("Getting Dwarven Blessing")
	   GetDwarvenBlessing(19099, 7762)
    Else
	   Out("Starting mid-level at " & $aWaypointsLevel1[$NearestWaypoint][3])
    Endif

    UseScroll()
	UseStones()
	MoveandAggro($aWaypointsLevel1)
	If $DeadOnTheRun = 1 then
	   Out("Party wipe, restarting at"& $aWaypointsLevel1[$NearestWaypoint][3])
	   $DeadOnTheRun = 0
	   MoveandAggro($aWaypointsLevel1)
    Endif

	Out("Travelling to Bogroot Growths - Level 2.")
	Do
		Move(7665, -19050)
	Until WaitMapLoading($iBogrootGrowthsLevel2MapID)

Endfunc

Func BogrootLvl2 ()
	; Level 2
	$DeadOnTheRun = 0
	Local $aWaypointsLevel2[27][4] = [ _
	[-10970, -4264, 1500, "Blooming Nettles"], _
	[-11165, -2066, 1500, "Blooming/Nettle Spores"], _
	[-11014, -1144, 1500, "Blooming/Nettle Spores"], _
	[-8609, 638, 1500, "Moving to Fungal/Nettle Spores"], _
	[-7306, 2604, 1500, "Fungal/Nettle Spores"], _
	[-6212, 3200, 1500, "Ayahuasca/Nettle Spores"], _
	[-4002, 4884, 1500, "Moving to Ayahuasca/Incubus"], _
	[-2428, 5925, 1500, "Moving to Ayahuasca/Incubus"], _
	[-2824, 6859, 1500, "Ayahuasca/Incubus"], _
	[-2586, 7549, 1500, "Ayahuasca/Incubus"], _
	[-480, 8281, 1500, "Moving to East Side of Bogroot"], _
	[-145, 10806, 1500, "Moving to Shrine"], _
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

	$NearestWaypoint = GetNearestWaypointIndex($aWaypointsLevel2)
	$Me = GetAgentByID()

	If $NearestWaypoint = 0 then
	   Out("Starting level 2 at "& $aWaypointsLevel2[$NearestWaypoint][3])
	   Out("Clearing Spawn")
	   AggroMoveToEx(-11330, -5483)
	   Out("Moving to Beacon of Droknar")
	   MoveTo(-11132, -5546)
	   Out("Getting Dwarven Blessing")
	   GetDwarvenBlessing(-11132, -5546)
    Else
	   Out("Starting mid-level at " & $aWaypointsLevel2[$NearestWaypoint][3])
    Endif

    UseScroll()
    UseStones()
    MoveandAggro($aWaypointsLevel2)

    If $DeadOnTheRun = 1 then
	   Out("Party wipe, restarting at"& $aWaypointsLevel2[$NearestWaypoint][3])
	   $DeadOnTheRun = 0
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
	MoveTo(17482, -6661)	;so you don't get stuck at Boss Lock
EndFunc

	; Boss
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

	$NearestWaypoint = GetNearestWaypointIndex($aWaypointsBoss)

    UseScroll()
	MoveandAggro($aWaypointsBoss)

    If $DeadOnTheRun = 1 then
	   Out("Party wipe, restarting at"& $aWaypointsBoss[$NearestWaypoint][3])
	   $DeadOnTheRun = 0
	   MoveandAggro($aWaypointsBoss)
    Endif

	$NearestEnemy = GetNearestEnemyToAgent($aPlayerAgent)
	$NearestDistance = @extended
	If $NearestDistance > 4000 Then
	  Out("Boss Group Dead")

	  Sleep(2000)

	  Out("Accepting Quest Reward")
	  Do
		 $Tekks = GetNearestNPCToCoords(14618, -17828)
		 GoNPC($Tekks)
		 TolSleep(1000)
		 Dialog($TekksComplete)
	  Until Not IsDllStruct(GetQuestByID($hTekksWar))

	  TolSleep(800)

	  Out("Bogroot Chest")
	  MoveTo(14876, -19033)
	  $BogrootChest = GetNearestSignpostToCoords(14876, -19033)
	  GoToSignpost($BogrootChest)
	  TolSleep(5000)
	  Out("Pick Up Drops")
	  PickupLootEx(6000)
   EndIf

   If $Sell_Items = True and CountFreeSlots($UseBags) <6 Then
	  ClearInventory() ; only clears inventory if less than 6 free slots
	  Setup()
   Else
	  Out("Wait for Reload")
	  Do
		 Sleep(200)
	  Until WaitMapLoading($iSplarkflyMapID)
   Endif

   AdlibUnregister("CurrentRunTime")

   TolSleep(3000)

EndFunc

Func GetDwarvenBlessing($iX, $iY)
	$aBeaconofDroknar = GetNearestNPCToCoords($iX, $iY)
	GoToNPC($aBeaconofDroknar)
	TolSleep(500)

	Do
		TolSleep(200)
		Dialog(0x84)
		sleep(2000)
		For $i = 0 to UBound($DwarvenBuffArr) - 1
			If IsDllStruct(GetEffect($DwarvenBuffArr[$i])) Then
				$bDwarvenBlessing = True
				Out("Dwarven Blessing Received")
				ExitLoop 2
			EndIf
		Next
		Out("Unable To Get Dwarven Blessing")
		ExitLoop
	Until $bDwarvenBlessing
EndFunc

Func MoveandAggro($aWaypoints)
	$iStart = GetNearestWaypointIndex($aWaypoints)
	$iFinish = UBound($aWaypoints) - 1
	$iStep = 1
	$Me = GetAgentByID()
	For $i = $iStart to $iFinish step $iStep
		Out("Moving to waypoint - " &  $aWaypoints[$i][3])
		Local $nWaypointX = $aWaypoints[$i][0]
		Local $nWaypointY = $aWaypoints[$i][1]
		Local $nRange = $aWaypoints[$i][2]
		AggroMoveToEx($nWaypointX, $nWaypointY, $nRange)
	Next
 EndFunc

; returns the index of the nearest waypoint in an array of waypoints
Func GetNearestWaypointIndex($aWaypoints)
	Local $lNearestWaypoint, $lNearestDistance = 100000000
	Local $lDistance
	Local $iFinish = UBound($aWaypoints) - 1
	$Me = GetAgentByID()
	For $index = 0 To $iFinish
		Local $nWaypointX = $aWaypoints[$index][0]
		Local $nWaypointY = $aWaypoints[$index][1]
		$lDistance = (DllStructGetData($Me, 'X') - $nWaypointX) ^ 2 + (DllStructGetData($Me, 'Y') - $nWaypointY) ^ 2
		If $lDistance < $lNearestDistance Then
			$lNearestWaypoint = $Index
			$lNearestDistance = $lDistance
		EndIf
	Next
	Return $lNearestWaypoint
 EndFunc   ;==>GetNearestWaypointIndex

Func AggroMoveToEx($x, $y, $z = 1200) ;Reduced from 2000
   $random = 50
   $iBlocked = 0
   Move($x, $y, $random)
   $Me = GetAgentByID()
   $coords[0] = DllStructGetData($Me, 'X')
   $coords[1] = DllStructGetData($Me, 'Y')
  If $Open_Chests = True Then  ; tests if chests was checked
	   CheckForChest()
  EndIf
   Do
		 RndSleep(250)
		 $oldCoords = $coords
		 local $timeragro = TimerInit()
		 local $timeragro = TimerInit()
		 $nearestenemy = GetNearestEnemyToAgent(-2)
		 $lDistance = GetDistance($nearestenemy, -2)
		 If $lDistance < $z AND DllStructGetData($nearestenemy, 'ID') <> 0 Then
			Attack($nearestenemy)
			Fight(1000)
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
			Move($x, $y, $Random)
		 EndIf
   Until ComputeDistance($coords[0], $coords[1], $x, $y) < 250 Or $iBlocked > 60 Or ($DeadOnTheRun = 1 and $iBogrootGrowthsLevel2MapID = 616)
   If $iBlocked > 60 Then Fight(1000)
   $aOldWaypointX = $x
   $aOldWaypointY = $y
   If $Open_Chests = True Then
	  CheckForChest()
   EndIf
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
	If CountFreeSlots() = 0 then
		Out("Inventory full")
	Else
		PickUpLootEX()
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
	PickupLootEx()
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



#Region Loot

Func CheckForChest()
   Local $AgentArray, $lAgent, $lExtraType
   Local $ChestFound = False
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
	PickUpLootEX(3300)
 EndFunc   ;==>CheckForChest

Func PickupLootEx($iMaxDist = 2000, $bCanPickup = True)
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
 EndFunc

Func CanPickUpEx($aItem, $bCanPickup)
	If Not $bCanPickup Then Return True
	$aModelID = DllStructGetData($aItem, 'modelid')
	$aExtraID = DllStructGetData($aItem,'extraid')
	$aRarity = GetRarity($aItem)
	$aType = DllStructGetData($aItem,'Type')
	$aItemID = DllStructGetData($aItem, "id")
	$aReq = GetItemReq($aItem)

   Switch $aRarity
	  Case 2624 ; Gold Items
			$iGoldCount += 1
			Return True
;	  Case 2627 ; Green Items
;			$iUniqueCount += 1
;			Return True
   EndSwitch

   Switch $aModelID
	  Case 1953, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969, 1970, 1971, 1972, 1973, 1974, 1975 ; All Froggy's
		 $iFroggyCount += 1
		 Return True
	  Case 935, 936 ; 935 = Diamond, 936 = Onyx Gemstone
		 Return True
	  Case 146 ; Dyes
		 If $aExtraID = 10 then; Black dye
			$iBlackDyeCount += 1
			Return True
		 Else
			Return False
		 Endif
	  Case 22751 ; Lockpick
		 $iLockpickCount += 1
		 Return True
	  Case 3256, 3746, 5594, 5595, 5611, 21233, 22279, 22280 ; Scrolls
		 $iScrollCount += 1
		 Return True
	  Case 21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795, 21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805 ; Tomes
		 $iTomeCount += 1
		 Return True
	  Case 910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 19172, 19173, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682 _  ; alcohol
			, 15528, 15479, 19170, 21492, 21812, 22644, 30208, 31150, 35125, 36681 _  ; sweets
			, 17060, 17061, 17062, 22269, 28431, 28432, 28436, 29431, 31151, 31152, 31153, 35121 _  ; Sweet Pcons
			, 6370, 19039, 21488, 21489, 22191, 26784, 28433, 35127 _  ; DP Removal Sweets
			, 556, 18345, 21491, 37765, 21833, 28433, 28434  ; Special Drops
		 Return True
;		Case 2511 ; Gold/Plat
;			$aAmount = DllStructGetData($aItem, 'Value')
;			If GetGoldCharacter() + $aAmount > 100000 Then
;				Return False
;			Else
;				Return True
;			EndIf
;		Case 24372 ; Naga Shaman Polymock Piece
;			Return True
;		Case 27036 ; Amphibian Tongue - Nicholas Sometimes
;			Return True
   EndSwitch

   Switch $aType
	  Case $TYPE_KEY, $TYPE_TROPHY_2 , $TYPE_TROPHY_2 , $TYPE_MATERIAL_AND_ZCOINS
		 Return True
	  Case $TYPE_SHIELD ; shields
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
EndFunc

#Endregion Loot

#Region Inventory

Func ClearInventory()
   Local $aItem, $aMod, $Timer

   Out("Cleaning Inventory")
   If GetMapID() <> $MAP_ID_BALTH_TEMPLE Then TravelTo($MAP_ID_BALTH_TEMPLE)
   If GetGoldCharacter() >= 80000 Then DepositGold(30000)
   If GetGoldCharacter() < 2500 Then WithdrawGold(3000-GetGoldCharacter())
   If $Store_Golds = True then StoreGolds()
   GoToNPC(GetNearestNPCToCoords(-4861, -7441)) ;Ai Tei [Merchant]
   Sleep (GetPing() + 800)
   If FindIdentificationKit() = 0 then BuySuperiorIDKit()
   If FindSuperiorSalvageKit(16) == 0 Then BuyItem(4, 1, 2000)
   For $lBag = 1 To $UseBags
	  IdentifyBag($lBag)
   Next
   For $i = 0 To 1	;2 iterations: 1st just sell, 2nd salvage and sell
	  For $lBag = 1 To $UseBags ; allows the use of 4 bags, change to protect bags
		 For $lSlot = 1 To DllStructGetData(GetBag($lBag), 'Slots')
			$aItem = GetItemBySlot($lBag, $lSlot)
			If Not ItemHasUsefulMod($aItem) and Not HasUsefulMod($aItem) and CanSell($aItem) Then
			   SellItem($aItem)
			   $Timer = TimerInit()
			   Do
				  Sleep(2500)
			   Until DllStructGetData(GetItemBySlot($lBag, $lSlot), 'ID') == 0 Or TimerDiff($Timer) > 10000
			Elseif ItemHasUsefulMod($aItem) or HasUsefulMod($aItem) then
				 $aMod = @extended  ; doing runes stuff at the end so that there's no risk of no inventory space left
				 $Timer = TimerInit()
				 Do
					 StartSalvageSuperiorKit($aItem, 16)
					 Sleep(GetPing() + 1000)
					 SalvageMod($aMod)
					 Sleep(GetPing() + 1000)
				 Until TimerDiff($Timer) > 15000
			EndIf
		 Next
	  Next
   Next
   MoveTo(-4700, -7250)	;so you don't get stuck at Merchant
   GoToNPC(GetNearestNPCToCoords(-4822, -7730)) ;Rune Trader
   Sleep (GetPing() + 800)
   For $lBag = 1 To $UseBags
	  For $lSlot = 1 To DllStructGetData(GetBag($lBag), 'Slots')
		 $aItem = GetItemBySlot($lBag, $lSlot)
		 If DllStructGetData($aItem, 'type') == $TYPE_RUNE_AND_MOD Then
			If GetGoldCharacter() >= 50000 Then DepositGold(90000)
			TraderRequestSell($aItem)
			Sleep(GetPing() + 1000)
			TraderSell()
			Sleep(GetPing() + 1000)
			EndIf
		Next
	Next
 EndFunc	;==>CheckInventory

Global Enum $iStaff=3, $iWand, $iOffhand,  $iShield, $iSpear, $iSword, $iAxe, $iBow, $iHammer, $iDaggers, $iScythe
Global $iStaff



Func HasUsefulMod($aItem)
    $aModStruct = GetModStruct($aItem)
	$aType = DllStructGetData($aItem,'Type')
	For $i = 0 to 12
		 For $j = 0 to 10
			If StringInStr($aModStruct, $array_weaponmods[$i][1]) > 0 and $aType = $TYPE_ID[$j]  then
			   Out (StringInStr($aModStruct, $array_weaponmods[$i][0]))
			   Out($array_weaponmods[$i][0])
			   Out ($TYPE_ID[$j])
			   Return True
			Else
			   Return False
			Endif
		 Next
	  Next
   EndFunc


Func ItemHasUsefulMod($aItem)
	If DllStructGetData($aItem, 'Type') <> $TYPE_SALVAGE Then Return False
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
 EndFunc	;==>ItemHasUsefulMod

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
	  Case 896, 908, 15542, 1151, 15554, 15551 _ ; select mods and inscriptions (see list above and adjust as needed) - salvaged manually (bot won't salavage them)
		 , 1175, 1176, 1152, 1153, 920, 0 _  ; picked up from other bot not sure which those items are
		 , 146, 22751 _  ; prevents selling dyes (146) and lockpicks (22751)
		 , 2989, 5899, 2992, 2992, 2991, 5900 _  ; prevents selling ID (2989->5899) and salvage kits (2992->2991->5900)
		 , 1953, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969, 1970, 1971, 1972, 1973, 1974, 1975 _  ; All Froggy's
		 , 24897 ;  Brass Knuckles
		 Return False
	  Endswitch

	;   Switch $Rarity
	;	  	Case $Rarity_Gold
	;		 	Switch $aReq
	;				Case 9
	;			   		Return False
	;			Endswitch
	;   	Endswitch

   Switch $aType
	  Case $TYPE_RUNE_AND_MOD, $TYPE_USABLE, $TYPE_KIT, $TYPE_SCROLL, $TYPE_DYE
		 Return False
	  Case $TYPE_SHIELD
		 If $aReq = 9 And GetItemMaxDmg($aItem) = 16 Then ; Req8 Shields
			Return False
		 ElseIf $aReq = 8 And GetItemMaxDmg($aItem) = 16 Then ; Req8 Shields
			Return False
		 ElseIf $aReq = 7 And GetItemMaxDmg($aItem) = 15 Then ; Req7 Shields
			Return False
		 ElseIf $aReq = 6 And GetItemMaxDmg($aItem) = 14 Then ; Req6 Shields
			Return False
		 ElseIf $aReq = 5 And GetItemMaxDmg($aItem) = 13 Then ; Req5 Shields
			Return False
		 ElseIf $aReq = 4 And GetItemMaxDmg($aItem) = 12 Then ; Req4 Shields
			Return False
		 EndIf
	  EndSwitch

   Return True
EndFunc	;==>CanSell

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

Func CountTotalSlots($NumOfBags = 4)
	Local $FreeSlots, $Slots

	For $Bag = 1 To $NumOfBags
		$Slots += DllStructGetData(GetBag($Bag), 'Slots')
	Next

	Return $Slots
EndFunc   ;==>CountFreeSlots

Func CountFreeSlots($NumOfBags = 4)
	Local $FreeSlots, $Slots
	For $Bag = 1 To $NumOfBags
		$Slots += DllStructGetData(GetBag($Bag), 'Slots')
		$Slots -= DllStructGetData(GetBag($Bag), 'ItemsCount')
	Next
	Return $Slots
 EndFunc   ;==>CountFreeSlots

Func FindSuperiorSalvageKit($iBags = 16)
;   If GetMapLoading() == $INSTANCETYPE_LOADING Then Disconnected()
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

Func GetItemMaxDmg($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Local $lModString = GetModStruct($aItem)
	Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
	If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
	If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
	If $lPos = 0 Then Return 0
	Return Int("0x" & StringMid($lModString, $lPos - 2, 2))
 EndFunc   ;==>GetItemMaxDmg

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
   For $i = 1 To CountTotalSlots()
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

 #Endregion Inventory

#Region Misc

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
;	  $item = GetItemByModelID(35126)                        ;the ID seems to be incorrect as this is activated even when none exists
;	  If (DllStructGetData($item, 'Bag') <> 0) Then
;		 Out("Using Shining Blade Summoning Stone")
;		 UseItem($item)
;		 Return
;	  EndIf
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

Func CheckPartyDead()
	$DeadParty = 0
	For $i = 1 To GetHeroCount()
		If GetIsDead(GetHeroID($i)) = True Then
			$DeadParty += 1
		EndIf
		If $DeadParty >= 6 Then
			$DeadOnTheRun = 1
			Out("Wiped, waiting for rezz")
		EndIf
	Next
 EndFunc   ;==>CheckPartyDead

 Func GetChecked($GUICtrl)
	Return (GUICtrlRead($GUICtrl)==$GUI_Checked)
 EndFunc

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

 Func GetAgentNameArraySorted($lAgentName)	;returns a 2-dimensional array([agentID, [distance]) sorted by distance
	Local $lDistance
	Local $lAgentArray = GetAgentArray($lAgentName)
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

 #EndRegion Misc

 #Region GUI Functions

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

Func ToggleScrolls()
   If $Use_Scrolls = True Then
	  $Use_Scrolls = False
   Else
	  if $Use_Scrolls = False then
		 $Use_Scrolls = True
	  Endif
   EndIf
EndFunc   ;==>ToggleScrolls

Func ToggleStones()
   If $Use_Stones = True Then
	  $Use_Stones = False
   Else
	  if $Use_Stones = False then
		 $Use_Stones = True
	  Endif
   EndIf
EndFunc   ;==>ToggleStones

Func ToggleOpenChests()
   If $Open_Chests = True Then
	  $Open_Chests = False
   Else
	  if $Open_Chests = False then
		 $Open_Chests = True
	  Endif
   EndIf
EndFunc ;==> ToggleOpenChests

Func ToggleStore()
   If $Store_Golds = True Then
	  $Store_Golds = False
   Else
	  if $Store_Golds = False then
		 $Store_Golds = True
	  Endif
   EndIf
EndFunc ;==>ToggleIdent and identifies bags

Func ToggleSell()
   If $Sell_Items = True Then
	  $Sell_Items = False
   Else
	  if $Sell_Items = False then
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
	_TicksToTime(Int(TimerDiff($nCurrentRunTime)), $g_iHour, $g_iMins, $g_iSecs)
	Local $sTime = StringFormat("%02i:%02i:%02i", $g_iHour, $g_iMins, $g_iSecs)
	GuiCtrlSetData($lblCurrentRunData, $sTime)
 EndFunc

Func Coords()
	Local $iCoords = StringFormat("%02i,%02i", DllStructGetData(GetAgentByID(-2), 'X'),DllStructGetData(GetAgentByID(-2), 'Y'))
	GuiCtrlSetData($lblCoordsData, $iCoords)
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

#Endregion GUI Functions
