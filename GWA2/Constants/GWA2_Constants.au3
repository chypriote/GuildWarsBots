#include-once
#include <Array.au3>

#Region Global Items
Global Const $GOLD_COINS = 2511

Global Const $RARITY_GREEN = 2627
Global Const $RARITY_GOLD = 2624
Global Const $RARITY_PURPLE = 2626
Global Const $RARITY_BLUE = 2623
Global Const $RARITY_WHITE = 2621

Global Const $ITEM_FEATHERED_CREST = 835

#Region Weapon mods
Global Const $WMOD_AXE_HAFT = 893
Global Const $WMOD_BOW_STRING = 894
Global Const $WMOD_HAMMER_HAFT = 895
Global Const $WMOD_STAFF_HEAD = 896
Global Const $WMOD_SWORD_HILT = 897
Global Const $WMOD_AXE_GRIP = 905
Global Const $WMOD_BOW_GRIP = 906
Global Const $WMOD_HAMMER_GRIP = 907
Global Const $WMOD_STAFF_WRAPPING = 908
Global Const $WMOD_SWORD_POMMEL = 909
Global Const $WMOD_DAGGER_TANG = 6323
Global Const $WMOD_DAGGER_HANDLE = 6331
Global Const $WMOD_SCYTHE_SNATHE = 15543
Global Const $WMOD_SPEARHEAD = 15544
Global Const $WMOD_FOCUS_CORE = 15551
Global Const $WMOD_WAND = 15552
Global Const $WMOD_SCYTHE_GRIP = 15553
Global Const $WMOD_SHIELD_HANDLE = 15554
Global Const $WMOD_SPEAR_GRIP = 15555
Global Const $WMOD_INSCRIPTIONS_GENERAL = 17059
Global Const $WMOD_INSCRIPTIONS_MARTIAL = 15540
Global Const $WMOD_INSCRIPTIONS_SPELLCASTING = 19122
Global Const $WMOD_INSCRIPTIONS_FOCUS_SHIELD = 15541
Global Const $WMOD_INSCRIPTIONS_FOCUS_ITEM = 19123
Global Const $WMOD_INSCRIPTIONS_ALL = 15542
Global Const $WEAPON_MOD_ARRAY = [893, 894, 895, 896, 897, 905, 906, 907, 908, 909, 6323, 6331, 15543, 15544, 15551, 15552, 15553, 15554, 15555, 17059, 15540, 19122, 15541, 19123, 15542]
#EndRegion Weapon mods

#Region General Items
Global Const $ITEM_BELT_POUCH = 34
Global Const $ITEM_BAG = 35
Global Const $ITEM_CHARR_BAG = 35 ;ModelID = 16453
Global Const $ITEM_HOLDING_RUNE = 2988
Global Const $ITEM_IDENT_KIT = 2989
Global Const $ITEM_SUP_IDENT_KIT = 5899
Global Const $ITEM_SALVAGE_KIT = 2992
Global Const $ITEM_EXP_SALVAGE_KIT = 2991
Global Const $ITEM_SUP_SALVAGE_KIT = 5900
Global Const $ITEM_CHARR_SALVAGE_KIT = 170 ;ModelID = 18721
Global Const $ITEM_LOCKPICK = 22751
Global Const $ITEM_SMALL_PACK = 31221
Global Const $ITEM_LIGHT_PACK = 31222
Global Const $ITEM_LARGE_PACK = 31223
Global Const $ITEM_HEAVY_PACK = 31224
Global Const $GENERAL_ITEMS_ARRAY = [ _
    $ITEM_IDENT_KIT, _
	$ITEM_EXP_SALVAGE_KIT, _
	$ITEM_SALVAGE_KIT, _
	$ITEM_SUP_IDENT_KIT, _
	$ITEM_SUP_SALVAGE_KIT, _
	$ITEM_CHARR_SALVAGE_KIT, _
	$ITEM_LOCKPICK, _
	$ITEM_BELT_POUCH, _
	$ITEM_BAG, _
	$ITEM_CHARR_BAG, _
	$ITEM_SMALL_PACK, _
	$ITEM_LIGHT_PACK, _
	$ITEM_LARGE_PACK, _
	$ITEM_HEAVY_PACK _
]
#EndRegion General Items

#Region Dyes
Global Const $ITEM_DYES = 146
Global Const $ITEM_BLUE_DYE = 2
Global Const $ITEM_GREEN_DYE = 3
Global Const $ITEM_PURPLE_DYE = 4
Global Const $ITEM_RED_DYE = 5
Global Const $ITEM_YELLOW_DYE = 6
Global Const $ITEM_BROWN_DYE = 7
Global Const $ITEM_ORANGE_DYE = 8
Global Const $ITEM_SILVER_DYE = 9
Global Const $ITEM_BLACK_DYE = 10
Global Const $ITEM_GRAY_DYE = 11
Global Const $ITEM_WHITE_DYE = 12
Global Const $ITEM_PINK_DYE = 13
#EndRegion Dyes

#Region Tonics
	Global Const $TONIC_SINISTER_AUTOMATONIC = 4730
	Global Const $TONIC_TRANSMOGRIFIER = 15837
	Global Const $TONIC_YULETIDE = 21490
	Global Const $TONIC_BEETLE_JUICE = 22192
	Global Const $TONIC_ABYSSAL = 30624
	Global Const $TONIC_CEREBRAL = 30626
	Global Const $TONIC_MACABRE =30628
	Global Const $TONIC_TRAPDOOR = 30630
	Global Const $TONIC_SEARING = 30632
	Global Const $TONIC_AUTMATONIC = 30634
	Global Const $TONIC_SKELETONIC = 30636
	Global Const $TONIC_BOREAL = 30638
	Global Const $TONIC_GELATINOUS = 30640
	Global Const $TONIC_PHANTASMAL = 30642
	Global Const $TONIC_ABOMINABLE = 30646
	Global Const $TONIC_FROSTY = 30648
	Global Const $TONIC_MISCHIEVIOUS = 31020
	Global Const $TONIC_MYSTERIOUS = 31141
	Global Const $TONIC_COTTONTAIL = 31142
	Global Const $TONIC_ZAISHEN = 31144
	Global Const $TONIC_UNSEEN = 31172
	Global Const $TONIC_SPOOKY = 37771
	Global Const $TONIC_MINUTELY_MAD_KING = 37772
Global Const $TONIC_PARTY_ARRAY = [4730, 15837, 21490, 22192, 30624, 30626, 30628, 30630, 30632, 30634, 30636, 30638, 30640, 30642, 30646, 30648, 31020, 31141, 31142, 31144, 31172, 37771, 37772]
#EndRegion Tonics

#Region Special Drops
    Global Const $CANDY_CANE_SHARD = 556
    Global Const $FLAME_OF_BALTHAZAR = 2514
    Global Const $GOLDEN_FLAME_OF_BALTHAZAR = 22188
    Global Const $CELESTIAL_SIGIL = 2571
    Global Const $VICTORY_TOKEN = 18345
    Global Const $WINTERSDAY_GIFT = 21491
    Global Const $WAYFARER_MARK = 37765
    Global Const $LUNAR_TOKEN = 21833
    Global Const $LUNAR_TOKENS = 28433
    Global Const $TRICK_OR_TREAT_BAG = 28434
Global Const $SPECIAL_DROPS_ARRAY = [556, 2514, 22188, 2571, 18345, 21491, 37765, 21833, 28433, 28434]
#EndRegion Special Drops

;~ Map pieces
Global Const $MAP_PIECE_ARRAY = [24629, 24630, 24631, 24632]

#Region Materials
;~ Materials
    Global Const $MAT_BONES = 921
    Global Const $MAT_CLOTH = 925
    Global Const $MAT_DUST = 929
    Global Const $MAT_FEATHER = 933
    Global Const $MAT_PLANT_FIBERS = 934
    Global Const $MAT_TANNED = 940
    Global Const $MAT_PLANKS = 946
    Global Const $MAT_IRON = 948
    Global Const $MAT_SCALES = 953
    Global Const $MAT_CHITINE = 954
    Global Const $MAT_GRANITE = 955
Global Const $COMMON_MATERIALS_ARRAY = [921, 925, 929, 933, 934, 940, 946, 948, 953, 954, 955]

;~ Rare Materials
    Global Const $MAT_CHARCOAL = 922
    Global Const $MAT_MONST_CLAW = 923
    Global Const $MAT_LINEN = 926
    Global Const $MAT_DASMAK = 927
    Global Const $MAT_SILK = 928
    Global Const $MAT_ECTOPLASM = 930
    Global Const $MAT_MONST_EYE = 931
    Global Const $MAT_MONST_FANG = 932
    Global Const $MAT_DIAMOND = 935
    Global Const $MAT_ONYX_GEMSTONE = 936
    Global Const $MAT_RUBY = 937
    Global Const $MAT_SAPPHIRE = 938
    Global Const $MAT_GLASS_VIAL = 939
    Global Const $MAT_FUR_SQUARE = 941
    Global Const $MAT_LEATHER_SQUARE = 942
    Global Const $MAT_ELONIAN_LEATHER = 943
    Global Const $MAT_INK_VIAL = 944
    Global Const $MAT_OBSIDIAN_SHARD = 945
    Global Const $MAT_STEEL_INGOT = 949
    Global Const $MAT_DELDRIMOR_INGOT = 950
    Global Const $MAT_PARCHMENT = 951
    Global Const $MAT_VELLUM = 952
    Global Const $MAT_SPIRITWOOD = 956
    Global Const $MAT_AMBER_CHUNK = 6532
    Global Const $MAT_JADEITE_SHARD = 6533
Global Const $RARE_MATERIALS_ARRAY = [922, 923, 926, 927, 928, 930, 931, 932, 935, 936, 937, 938, 939, 941, 942, 943, 944, 945, 949, 950, 951, 952, 956, 6532, 6533]

Global $ALL_MATERIALS_ARRAY = []
_ArrayConcatenate($ALL_MATERIALS_ARRAY, $COMMON_MATERIALS_ARRAY)
_ArrayConcatenate($ALL_MATERIALS_ARRAY, $RARE_MATERIALS_ARRAY)
#EndRegion Materials

#Region Title items
;~ Alcohol
    Global Const $ALCOHOL_HUNTERS_ALE = 910
	Global Const $ALCOHOL_FLASK_OF_FIREWATER = 2513
	Global Const $ALCOHOL_DWARVEN_ALE = 5585
	Global Const $ALCOHOL_WITCHS_BREW = 6049
	Global Const $ALCOHOL_SPIKED_EGGNOG = 6366
	Global Const $ALCOHOL_VIAL_OF_ABSINTHE = 6367
	Global Const $ALCOHOL_EGGNOG = 6375
	Global Const $ALCOHOL_BOTTLE_OF_RICE_WINE = 15477
	Global Const $ALCOHOL_ZEHTUKAS_JUG = 19171
	Global Const $ALCOHOL_BOTTLE_OF_JUNIBERRY_GIN = 19172
	Global Const $ALCOHOL_BOTTLE_OF_VABBIAN_WINE = 19173
	Global Const $ALCOHOL_SHAMROCK_ALE = 22190
	Global Const $ALCOHOL_AGED_DWARVEN_ALE = 24593
	Global Const $ALCOHOL_HARD_APPLE_CIDER = 28435
	Global Const $ALCOHOL_BOTTLE_OF_GROG = 30855
	Global Const $ALCOHOL_AGED_HUNTERS_ALE = 31145
	Global Const $ALCOHOL_KEG_OF_AGED_HUNTERS_ALE = 31146
	Global Const $ALCOHOL_KRYTAN_BRANDY = 35124
	Global Const $ALCOHOL_BATTLE_ISLE_ICED_TEA = 36682
Global Const $ALL_ALCOHOL_ARRAY = [910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 19172, 19173, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682]

	;~ Town Sweets
	Global Const $SWEET_CREME_BRULEE = 15528
	Global Const $SWEET_RED_BEAN_CAKE = 15479
	Global Const $SWEET_MANDRAGOR_ROOT_CAKE = 19170
	Global Const $SWEET_FRUITCAKE = 21492
	Global Const $SWEET_SUGARY_BLUE_DRINK = 21812
	Global Const $SWEET_CHOCOLATE_BUNNY = 22644
	Global Const $SWEET_MINITREATS_OF_PURITY = 30208
	Global Const $SWEET_JAR_OF_HONEY = 31150
	Global Const $SWEET_KRYTAN_LOKUM = 35125
	Global Const $SWEET_DELICIOUS_CAKE = 36681
Global Const $ALL_TOWN_SWEETS_ARRAY = [15528, 15479, 19170, 21492, 21812, 22644, 26784, 30208, 31150, 35125, 36681]

	;~ PVE Sweets
	Global Const $SWEET_DRAKE_KABOB = 17060
	Global Const $SWEET_BOWL_OF_SKALEFIN_SOUP = 17061
	Global Const $SWEET_PAHNAI_SALAD = 17062
	Global Const $SWEET_BIRTHDAY_CUPCAKE = 22269
	Global Const $SWEET_GOLDEN_EGG = 22752
	Global Const $SWEET_CANDY_APPLE = 28431
	Global Const $SWEET_CANDY_CORN = 28432
	Global Const $SWEET_SLICE_OF_PUMPKIN_PIE = 28436
	Global Const $SWEET_LUNAR_FORTUNE_2007 = 29424 ; Pig
	Global Const $SWEET_LUNAR_FORTUNE_2008 = 29425 ; Rat
	Global Const $SWEET_LUNAR_FORTUNE_2009 = 29426 ; Ox
	Global Const $SWEET_LUNAR_FORTUNE_2010 = 29427 ; Tiger
	Global Const $SWEET_LUNAR_FORTUNE_2011 = 29428 ; Rabbit
	Global Const $SWEET_LUNAR_FORTUNE_2012 = 29429 ; Dragon
	Global Const $SWEET_LUNAR_FORTUNE_2013 = 29430 ; Snake
	Global Const $SWEET_LUNAR_FORTUNE_2014 = 29431 ; Horse
	Global Const $SWEET_LUNAR_FORTUNE_2015 = 29432 ; Sheep
	Global Const $SWEET_LUNAR_FORTUNE_2016 = 29433 ; Monkey
	Global Const $SWEET_LUNAR_FORTUNE_2017 = 29434 ; Rooster
	Global Const $SWEET_LUNAR_FORTUNE_2018 = 29435 ; Dog
	Global Const $SWEET_BLUE_ROCK_CANDY = 31151
	Global Const $SWEET_GREEN_ROCK_CANDY = 31152
	Global Const $SWEET_RED_ROCK_CANDY = 31153
Global Const $ALL_PVE_SWEETS_ARRAY = [17060, 17061, 17062, 22269, 22752, 28431, 28432, 28436, 31151, 31152, 31153]

;~ Party
	Global Const $PARTY_GHOST_IN_THE_BOX = 6368
	Global Const $PARTY_SQUASH_SERUM = 6369
	Global Const $PARTY_SNOWMAN_SUMMONER = 6376
	Global Const $PARTY_BOTTLE_ROCKET = 21809
	Global Const $PARTY_CHAMPAGNE_POPPER = 21810
	Global Const $PARTY_SPARKLER = 21813
	Global Const $PARTY_CRATE_OF_FIREWORKS = 29436 ; Not spammable
	Global Const $PARTY_DISCO_BALL = 29543 ; Not Spammable
	Global Const $PARTY_PARTY_BEACON = 36683
Global Const $ALL_PARTY_ARRAY = [6368, 6369, 6376, 21809, 21810, 21813, 29436, 29543, 36683]

Global $ALL_TITLE_ITEMS = []
_ArrayConcatenate($ALL_TITLE_ITEMS, $ALL_ALCOHOL_ARRAY)
_ArrayConcatenate($ALL_TITLE_ITEMS, $ALL_PVE_SWEETS_ARRAY)
_ArrayConcatenate($ALL_TITLE_ITEMS, $ALL_TOWN_SWEETS_ARRAY)
_ArrayConcatenate($ALL_TITLE_ITEMS, $ALL_PARTY_ARRAY)
#EndRegion Title items

#Region DP Removal
	Global Const $DPREMOVAL_PEPPERMINT_CC = 6370
	Global Const $DPREMOVAL_REFINED_JELLY = 19039
	Global Const $DPREMOVAL_ELIXIR_OF_VALOR = 21227
	Global Const $DPREMOVAL_WINTERGREEN_CC = 21488
	Global Const $DPREMOVAL_RAINBOW_CC = 21489
	Global Const $DPREMOVAL_FOUR_LEAF_CLOVER = 22191
	Global Const $DPREMOVAL_HONEYCOMB = 26784
	Global Const $DPREMOVAL_PUMPKIN_COOKIE = 28433
	Global Const $DPREMOVAL_OATH_OF_PURITY = 30206
	Global Const $DPREMOVAL_SEAL_OF_THE_DRAGON_EMPIRE = 30211
	Global Const $DPREMOVAL_SHINING_BLADE_RATION = 35127
Global Const $ALL_DPREMOVAL_ARRAY = [6370, 19039, 21488, 21489, 22191, 26784, 28433, 35127]
#EndRegion DP Removal

#Region Special Drops
    Global Const $TROPHY_GLACIAL_STONES = 27047
    Global Const $TROPHY_SUPERIOR_CHARR_CARVING = 27052
    Global Const $TROPHY_DESTROYER_CORE = 27033
    Global Const $TROPHY_DIESSA_CHALICE = 24353
    Global Const $TROPHY_RIN_RELIC = 24354
Global $ALL_TROPHIES_ARRAY = [27047, 27052, 27033, 24353, 24354]
#EndRegion Special Drops

#Region Tomes
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
Global Const $ELITE_TOME_ARRAY = [21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795]
Global Const $REGULAR_TOME_ARRAY = [21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805]
Global $ALL_TOMES_ARRAY = []
_ArrayConcatenate($ALL_TOMES_ARRAY, $ELITE_TOME_ARRAY)
_ArrayConcatenate($ALL_TOMES_ARRAY, $REGULAR_TOME_ARRAY)
#EndRegion Tomes

#Region Scrolls
	Global Const $ITEM_PASSAGE_SCROLL_URGOZ = 3256
	Global Const $ITEM_PASSAGE_SCROLL_UW = 3746
	Global Const $ITEM_HEROS_INSIGHT_SCROLL = 5594
	Global Const $ITEM_BERSERKERS_INSIGHT_SCROLL = 5595
	Global Const $ITEM_SLAYERS_INSIGHT_SCROLL = 5611
	Global Const $ITEM_ADVENTURERS_INSIGHT_SCROLL = 5853
	Global Const $ITEM_RAMPAGERS_INSIGHT_SCROLL = 5975
	Global Const $ITEM_HUNTERS_INSIGHT_SCROLL = 5976
	Global Const $ITEM_SCROLL_OF_THE_LIGHTBRINGER = 21233
	Global Const $ITEM_PASSAGE_SCROLL_DEEP = 22279
	Global Const $ITEM_PASSAGE_SCROLL_FOW = 22280
Global Const $BLUE_SCROLLS_ARRAY = [5853, 5975, 5976]
Global Const $GOLD_SCROLLS_ARRAY = [3256, 3746, 5594, 5595, 5611, 21233, 22279, 22280]
Global $ALL_SCROLLS_ARRAY = []
_ArrayConcatenate($ALL_SCROLLS_ARRAY, $BLUE_SCROLLS_ARRAY)
_ArrayConcatenate($ALL_SCROLLS_ARRAY, $GOLD_SCROLLS_ARRAY)
#EndRegion Scrolls

#EndRegion Global Items

#Region Item Types
	Global Const $ITEM_TYPE_SALVAGE = 0
	Global Const $ITEM_TYPE_LEADHAND = 1
	Global Const $ITEM_TYPE_AXE = 2
	Global Const $ITEM_TYPE_BAG = 3
	Global Const $ITEM_TYPE_FEET = 4
	Global Const $ITEM_TYPE_BOW = 5
	Global Const $ITEM_TYPE_BUNDLE = 6
	Global Const $ITEM_TYPE_CHEST = 7
	Global Const $ITEM_TYPE_RUNE = 8
	Global Const $ITEM_TYPE_CONSUMABLE = 9
	Global Const $ITEM_TYPE_DYE = 10
	Global Const $ITEM_TYPE_MATERIAL = 11
	Global Const $ITEM_TYPE_FOCUS = 12
	Global Const $ITEM_TYPE_ARMS = 13
	Global Const $ITEM_TYPE_SIGIL = 14
	Global Const $ITEM_TYPE_HAMMER = 15
	Global Const $ITEM_TYPE_HEAD = 16
	Global Const $ITEM_TYPE_SALVAGEITEM = 17
	Global Const $ITEM_TYPE_KEY = 18
	Global Const $ITEM_TYPE_LEGS = 19
	Global Const $ITEM_TYPE_COINS = 20
	Global Const $ITEM_TYPE_QUESTITEM = 21
	Global Const $ITEM_TYPE_WAND = 22
	Global Const $ITEM_TYPE_SHIELD = 24
	Global Const $ITEM_TYPE_STAFF = 26
	Global Const $ITEM_TYPE_SWORD = 27
	Global Const $ITEM_TYPE_KIT = 29
	Global Const $ITEM_TYPE_TROPHY = 30
	Global Const $ITEM_TYPE_SCROLL = 31
	Global Const $ITEM_TYPE_DAGGERS = 32
	Global Const $ITEM_TYPE_PRESENT = 33
	Global Const $ITEM_TYPE_MINIPET = 34
	Global Const $ITEM_TYPE_SCYTHE = 35
	Global Const $ITEM_TYPE_SPEAR = 36
	Global Const $ITEM_TYPE_HANDBOOK = 43 ; Encrypted Charr Battle Plan/Decoder, Golem User Manual, Books
	Global Const $ITEM_TYPE_COSTUMEBODY = 44
	Global Const $ITEM_TYPE_COSTUMEHEAD = 45
	Global Const $ITEM_TYPE_NOT_EQUIPPED = 46
Global Const $UNSTACKABLES = [ _
	$ITEM_TYPE_LEADHAND, _
	$ITEM_TYPE_AXE, _
	$ITEM_TYPE_BAG, _
	$ITEM_TYPE_FEET, _
	$ITEM_TYPE_BOW, _
	$ITEM_TYPE_RUNE, _
	$ITEM_TYPE_FOCUS, _
	$ITEM_TYPE_ARMS, _
	$ITEM_TYPE_SIGIL, _
	$ITEM_TYPE_HAMMER, _
	$ITEM_TYPE_HEAD, _
	$ITEM_TYPE_SALVAGEITEM, _
	$ITEM_TYPE_LEGS, _
	$ITEM_TYPE_WAND, _
	$ITEM_TYPE_SHIELD, _
	$ITEM_TYPE_STAFF, _
	$ITEM_TYPE_SWORD, _
	$ITEM_TYPE_KIT, _
	$ITEM_TYPE_DAGGERS, _
	$ITEM_TYPE_MINIPET, _
	$ITEM_TYPE_SCYTHE, _
	$ITEM_TYPE_SPEAR, _
	$ITEM_TYPE_HANDBOOK _
]
#EndRegion Item Types

#Region Professions
	Global Const $PROF_NONE = 0
	Global Const $PROF_WARRIOR = 1
	Global Const $PROF_RANGER = 2
	Global Const $PROF_MONK = 3
	Global Const $PROF_NECROMANCER = 4
	Global Const $PROF_MESMER = 5
	Global Const $PROF_ELEMENTALIST = 6
	Global Const $PROF_ASSASSIN = 7
	Global Const $PROF_RITUALIST = 8
	Global Const $PROF_PARAGON = 9
	Global Const $PROF_DERVISH = 10
Global Const $CASTER_PROFS = [3, 4, 5, 6, 8]
Global Const $FIGHTER_PROFS = [1, 2, 7, 9, 10]
#EndRegion Professions

#Region Effects
Global Const $EFFECT_ID_BLEEDING	= 478
Global Const $EFFECT_ID_BLIND		= 479
Global Const $EFFECT_ID_BURNING		= 480
Global Const $EFFECT_ID_CRIPPLED	= 481
Global Const $EFFECT_ID_DEEP_WOUND	= 482
Global Const $EFFECT_ID_DISEASE		= 483
Global Const $EFFECT_ID_POISON		= 484
Global Const $EFFECT_ID_DAZED		= 485
Global Const $EFFECT_ID_WEAKNESS	= 486
#EndRegion Effects

#Region SkillTypes
Global $SKILL_TYPE_STANCE = 3
Global $SKILL_TYPE_HEX = 4
Global $SKILL_TYPE_SPELL = 5
Global $SKILL_TYPE_ENCHANTMENT = 6
Global $SKILL_TYPE_SIGNET = 7
Global $SKILL_TYPE_CONDITION = 8
Global $SKILL_TYPE_WELL = 9
Global $SKILL_TYPE_SKILL = 10
Global $SKILL_TYPE_WARD = 11
Global $SKILL_TYPE_GLYPH = 12
Global $SKILL_TYPE_ATTACK = 14
Global $SKILL_TYPE_SHOUT = 15
Global $SKILL_TYPE_PREPARATION = 19
Global $SKILL_TYPE_TRAP = 21
Global $SKILL_TYPE_RITUAL = 22
Global $SKILL_TYPE_ITEMSPELL = 24
Global $SKILL_TYPE_WEAPONSPELL = 25
Global $SKILL_TYPE_CHANT = 27
Global $SKILL_TYPE_ECHOREFRAIN = 28
Global $SKILL_TYPE_DISGUISE = 29
#EndRegion SkillTypes

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
Global $array_runes[184][4] = [ _
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
