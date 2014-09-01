--MOAI
serializer = ... or MOAIDeserializer.new ()

local function init ( objects )

	--Initializing Tables
	local table

	table = objects [ 0x0FF4E858 ]
	table [ "fantasy" ] = objects [ 0x11153A48 ]
	table [ "gothic" ] = objects [ 0x0FF85D78 ]
	table [ "scifi" ] = objects [ 0x1103D6F0 ]
	table [ "romance" ] = objects [ 0x1115F448 ]
	table [ "crime" ] = objects [ 0x0FFD1B70 ]
	table [ "action" ] = objects [ 0x1100B0B8 ]

	table = objects [ 0x0FF4E928 ]

	table = objects [ 0x0FF7EF10 ]
	table [ "statistics" ] = objects [ 0x0FF80800 ]
	table [ "level" ] = 1
	table [ "genre" ] = "fantasy"
	table [ "id" ] = 1
	table [ "status" ] = objects [ 0x11006D90 ]
	table [ "xp" ] = 0
	table [ "name" ] = "sword"
	table [ "flags" ] = "character"

	table = objects [ 0x0FF7EF90 ]
	table [ "wordcount" ] = objects [ 0x0FFE0210 ]

	table = objects [ 0x0FF80800 ]
	table [ "protagonist" ] = objects [ 0x0FF7EF90 ]
	table [ "character" ] = objects [ 0x0FFE8990 ]

	table = objects [ 0x0FF83E50 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 100
	table [ "base_rank" ] = 0
	table [ "tier" ] = 1
	table [ "scale" ] = "wordcount"
	table [ "progression_rank" ] = 0

	table = objects [ 0x0FF85D78 ]

	table = objects [ 0x0FF87670 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 3
	table [ "tier" ] = 1
	table [ "scale" ] = "defense"
	table [ "progression_rank" ] = 3

	table = objects [ 0x0FF8C6F8 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 2
	table [ "tier" ] = 1
	table [ "scale" ] = "inspiration"
	table [ "progression_rank" ] = 2

	table = objects [ 0x0FF926F8 ]
	table [ "character" ] = objects [ 0x0FF99E98 ]
	table [ "antagonist" ] = objects [ 0x0FF932B0 ]

	table = objects [ 0x0FF932B0 ]
	table [ "inspiration" ] = objects [ 0x0FFAA818 ]
	table [ "defense" ] = objects [ 0x0FFC2880 ]

	table = objects [ 0x0FF99E98 ]
	table [ "inspiration" ] = objects [ 0x0FF8C6F8 ]
	table [ "wordcount" ] = objects [ 0x0FF83E50 ]
	table [ "defense" ] = objects [ 0x0FF87670 ]

	table = objects [ 0x0FFA83A0 ]
	table [ "statistics" ] = objects [ 0x0FF926F8 ]
	table [ "level" ] = 1
	table [ "genre" ] = "fantasy"
	table [ "id" ] = 2
	table [ "status" ] = objects [ 0x0FFE2968 ]
	table [ "xp" ] = 0
	table [ "name" ] = "orc"
	table [ "flags" ] = "character"

	table = objects [ 0x0FFAA618 ]
	table [ "fantasy" ] = 165
	table [ "gothic" ] = 0
	table [ "total" ] = 165
	table [ "scifi" ] = 0
	table [ "romance" ] = 0
	table [ "crime" ] = 0
	table [ "action" ] = 0

	table = objects [ 0x0FFAA818 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 100
	table [ "base_rank" ] = 0
	table [ "tier" ] = 1
	table [ "scale" ] = "inspiration"
	table [ "progression_rank" ] = 0

	table = objects [ 0x0FFBDC08 ]

	table = objects [ 0x0FFBE088 ]

	table = objects [ 0x0FFC2880 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 2
	table [ "tier" ] = 1
	table [ "scale" ] = "defense"
	table [ "progression_rank" ] = 2

	table = objects [ 0x0FFC2960 ]

	table = objects [ 0x0FFC4CF0 ]
	table [ "level" ] = 1
	table [ "xp" ] = 0

	table = objects [ 0x0FFC4DD8 ]
	table [ "fantasy" ] = objects [ 0x0FFC4E30 ]
	table [ "gothic" ] = objects [ 0x0FFC2960 ]
	table [ "scifi" ] = objects [ 0x0FFBDC08 ]
	table [ "romance" ] = objects [ 0x0FF4E928 ]
	table [ "crime" ] = objects [ 0x0FFBE088 ]
	table [ "action" ] = objects [ 0x111649C8 ]

	table = objects [ 0x0FFC4E30 ]
	table [ 1 ]	= 44
	table [ 2 ]	= 214

	table = objects [ 0x0FFC5F38 ]

	table = objects [ 0x0FFD0DC0 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 3
	table [ "tier" ] = 1
	table [ "scale" ] = "inspiration"
	table [ "progression_rank" ] = 3

	table = objects [ 0x0FFD1940 ]

	table = objects [ 0x0FFD1B70 ]

	table = objects [ 0x0FFD2AA8 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 2
	table [ "tier" ] = 1
	table [ "scale" ] = "wordcount"
	table [ "progression_rank" ] = 2

	table = objects [ 0x0FFD2B60 ]
	table [ "fantasy" ] = 258
	table [ "gothic" ] = 0
	table [ "total" ] = 258
	table [ "scifi" ] = 0
	table [ "romance" ] = 0
	table [ "crime" ] = 0
	table [ "action" ] = 0

	table = objects [ 0x0FFD5610 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 1
	table [ "tier" ] = 1
	table [ "scale" ] = "defense"
	table [ "progression_rank" ] = 1

	table = objects [ 0x0FFD8D18 ]
	table [ "inspiration" ] = objects [ 0x1102E3A8 ]
	table [ "wordcount" ] = objects [ 0x0FF4E858 ]
	table [ "defense" ] = objects [ 0x0FFC4DD8 ]

	table = objects [ 0x0FFD9150 ]
	table [ "inspiration" ] = objects [ 0x11154060 ]
	table [ "wordcount" ] = objects [ 0x0FFAA618 ]
	table [ "defense" ] = objects [ 0x0FFD2B60 ]

	table = objects [ 0x0FFDD7D0 ]
	table [ "wordcount" ] = 43
	table [ "inspiration" ] = 320
	table [ "defense" ] = 44

	table = objects [ 0x0FFE0210 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 1
	table [ "tier" ] = 1
	table [ "scale" ] = "wordcount"
	table [ "progression_rank" ] = 1

	table = objects [ 0x0FFE1430 ]
	table [ "inspiration" ] = objects [ 0x11148D28 ]
	table [ "wordcount" ] = objects [ 0x1114F2F8 ]
	table [ "defense" ] = objects [ 0x11154378 ]

	table = objects [ 0x0FFE2968 ]
	table [ "wordcount" ] = 100
	table [ "inspiration" ] = 215
	table [ "defense" ] = 128

	table = objects [ 0x0FFE8990 ]
	table [ "inspiration" ] = objects [ 0x0FFECF80 ]
	table [ "wordcount" ] = objects [ 0x11000DF8 ]
	table [ "defense" ] = objects [ 0x11001738 ]

	table = objects [ 0x0FFECF80 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 3
	table [ "tier" ] = 1
	table [ "scale" ] = "inspiration"
	table [ "progression_rank" ] = 3

	table = objects [ 0x11000DF8 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 2
	table [ "tier" ] = 1
	table [ "scale" ] = "wordcount"
	table [ "progression_rank" ] = 2

	table = objects [ 0x11001738 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 1
	table [ "tier" ] = 1
	table [ "scale" ] = "defense"
	table [ "progression_rank" ] = 1

	table = objects [ 0x11006D90 ]
	table [ "wordcount" ] = 43
	table [ "inspiration" ] = 320
	table [ "defense" ] = 44

	table = objects [ 0x110094A8 ]
	table [ "statistics" ] = objects [ 0x1100A428 ]
	table [ "level" ] = 1
	table [ "genre" ] = "fantasy"
	table [ "id" ] = 1
	table [ "status" ] = objects [ 0x111534D8 ]
	table [ "xp" ] = 0
	table [ "name" ] = "sword"
	table [ "flags" ] = "character"

	table = objects [ 0x11009528 ]
	table [ 1 ]	= objects [ 0x11168520 ]
	table [ 2 ]	= objects [ 0x11038638 ]
	table [ 3 ]	= objects [ 0x11017B48 ]
	table [ 4 ]	= objects [ 0x0FFA83A0 ]
	table [ 5 ]	= objects [ 0x0FF7EF10 ]
	table [ 6 ]	= objects [ 0x110094A8 ]

	table = objects [ 0x1100A428 ]
	table [ "protagonist" ] = objects [ 0x1100AF00 ]
	table [ "character" ] = objects [ 0x1100B040 ]

	table = objects [ 0x1100AF00 ]
	table [ "wordcount" ] = objects [ 0x1100C490 ]

	table = objects [ 0x1100B040 ]
	table [ "inspiration" ] = objects [ 0x1100EE58 ]
	table [ "wordcount" ] = objects [ 0x1100FED0 ]
	table [ "defense" ] = objects [ 0x110114C8 ]

	table = objects [ 0x1100B0B8 ]

	table = objects [ 0x1100C490 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 1
	table [ "tier" ] = 1
	table [ "scale" ] = "wordcount"
	table [ "progression_rank" ] = 1

	table = objects [ 0x1100EE58 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 3
	table [ "tier" ] = 1
	table [ "scale" ] = "inspiration"
	table [ "progression_rank" ] = 3

	table = objects [ 0x1100FED0 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 2
	table [ "tier" ] = 1
	table [ "scale" ] = "wordcount"
	table [ "progression_rank" ] = 2

	table = objects [ 0x110114C8 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 1
	table [ "tier" ] = 1
	table [ "scale" ] = "defense"
	table [ "progression_rank" ] = 1

	table = objects [ 0x11017B48 ]
	table [ "statistics" ] = objects [ 0x1101B100 ]
	table [ "level" ] = 1
	table [ "genre" ] = "fantasy"
	table [ "id" ] = 1
	table [ "status" ] = objects [ 0x0FFDD7D0 ]
	table [ "xp" ] = 0
	table [ "name" ] = "sword"
	table [ "flags" ] = "character"

	table = objects [ 0x1101B100 ]
	table [ "protagonist" ] = objects [ 0x1101B178 ]
	table [ "character" ] = objects [ 0x1101C330 ]

	table = objects [ 0x1101B178 ]
	table [ "wordcount" ] = objects [ 0x1101CBE8 ]

	table = objects [ 0x1101C330 ]
	table [ "inspiration" ] = objects [ 0x0FFD0DC0 ]
	table [ "wordcount" ] = objects [ 0x0FFD2AA8 ]
	table [ "defense" ] = objects [ 0x0FFD5610 ]

	table = objects [ 0x1101CBE8 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 1
	table [ "tier" ] = 1
	table [ "scale" ] = "wordcount"
	table [ "progression_rank" ] = 1

	table = objects [ 0x1101DB78 ]
	table [ "wordcount" ] = objects [ 0x11159BA8 ]

	table = objects [ 0x1102E3A8 ]
	table [ "fantasy" ] = objects [ 0x110387D8 ]
	table [ "gothic" ] = objects [ 0x0FFC5F38 ]
	table [ "scifi" ] = objects [ 0x1103D8E8 ]
	table [ "romance" ] = objects [ 0x0FFD1940 ]
	table [ "crime" ] = objects [ 0x11030608 ]
	table [ "action" ] = objects [ 0x11038768 ]

	table = objects [ 0x1102F300 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 100
	table [ "base_rank" ] = 0
	table [ "tier" ] = 1
	table [ "scale" ] = "wordcount"
	table [ "progression_rank" ] = 0

	table = objects [ 0x1102F998 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 3
	table [ "tier" ] = 1
	table [ "scale" ] = "defense"
	table [ "progression_rank" ] = 3

	table = objects [ 0x11030608 ]

	table = objects [ 0x11031778 ]
	table [ 1 ]	= objects [ 0x1115D0C8 ]

	table = objects [ 0x110318C8 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 100
	table [ "base_rank" ] = 0
	table [ "tier" ] = 1
	table [ "scale" ] = "inspiration"
	table [ "progression_rank" ] = 0

	table = objects [ 0x11031D50 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 2
	table [ "tier" ] = 1
	table [ "scale" ] = "defense"
	table [ "progression_rank" ] = 2

	table = objects [ 0x110328A0 ]
	table [ "wordcount" ] = 100
	table [ "inspiration" ] = 315
	table [ "defense" ] = 214

	table = objects [ 0x110380E0 ]

	table = objects [ 0x11038638 ]
	table [ "statistics" ] = objects [ 0x1103ADC8 ]
	table [ "level" ] = 1
	table [ "genre" ] = "fantasy"
	table [ "id" ] = 2
	table [ "status" ] = objects [ 0x110328A0 ]
	table [ "xp" ] = 0
	table [ "name" ] = "orc"
	table [ "flags" ] = "antagonist character"

	table = objects [ 0x11038768 ]

	table = objects [ 0x110387D8 ]
	table [ 1 ]	= 320
	table [ 2 ]	= 315

	table = objects [ 0x1103ADC8 ]
	table [ "character" ] = objects [ 0x1103C100 ]
	table [ "antagonist" ] = objects [ 0x1103AE18 ]

	table = objects [ 0x1103AE18 ]
	table [ "inspiration" ] = objects [ 0x110318C8 ]
	table [ "defense" ] = objects [ 0x11031D50 ]

	table = objects [ 0x1103C100 ]
	table [ "inspiration" ] = objects [ 0x1103C528 ]
	table [ "wordcount" ] = objects [ 0x1102F300 ]
	table [ "defense" ] = objects [ 0x1102F998 ]

	table = objects [ 0x1103C528 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 2
	table [ "tier" ] = 1
	table [ "scale" ] = "inspiration"
	table [ "progression_rank" ] = 2

	table = objects [ 0x1103D6F0 ]

	table = objects [ 0x1103D8E8 ]

	table = objects [ 0x11148D28 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 3
	table [ "tier" ] = 1
	table [ "scale" ] = "inspiration"
	table [ "progression_rank" ] = 3

	table = objects [ 0x1114F2F8 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 2
	table [ "tier" ] = 1
	table [ "scale" ] = "wordcount"
	table [ "progression_rank" ] = 2

	table = objects [ 0x111534D8 ]
	table [ "wordcount" ] = 43
	table [ "inspiration" ] = 320
	table [ "defense" ] = 44

	table = objects [ 0x11153A48 ]
	table [ 1 ]	= 65
	table [ 2 ]	= 100

	table = objects [ 0x11154060 ]
	table [ "fantasy" ] = 635
	table [ "gothic" ] = 0
	table [ "total" ] = 635
	table [ "scifi" ] = 0
	table [ "romance" ] = 0
	table [ "crime" ] = 0
	table [ "action" ] = 0

	table = objects [ 0x11154378 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 1
	table [ "tier" ] = 1
	table [ "scale" ] = "defense"
	table [ "progression_rank" ] = 1

	table = objects [ 0x111593E8 ]
	table [ "element" ] = objects [ 0x11168520 ]
	table [ "flags" ] = "protagonist character"

	table = objects [ 0x11159BA8 ]
	table [ "level" ] = 1
	table [ "fixed_value" ] = 0
	table [ "base_rank" ] = 1
	table [ "tier" ] = 1
	table [ "scale" ] = "wordcount"
	table [ "progression_rank" ] = 1

	table = objects [ 0x11159CD8 ]
	table [ "element" ] = objects [ 0x11038638 ]
	table [ "flags" ] = "antagonist character"

	table = objects [ 0x1115D0C8 ]
	table [ "inspiration" ] = 635
	table [ "slots" ] = objects [ 0x1115E3E0 ]
	table [ "type" ] = "novel"
	table [ "details" ] = objects [ 0x0FFD8D18 ]
	table [ "max_inspiration" ] = 635
	table [ "stats" ] = objects [ 0x0FFD9150 ]

	table = objects [ 0x1115E3E0 ]
	table [ 1 ]	= objects [ 0x111593E8 ]
	table [ 2 ]	= objects [ 0x11159CD8 ]

	table = objects [ 0x1115F448 ]

	table = objects [ 0x111649C8 ]

	table = objects [ 0x11166850 ]
	table [ "protagonist" ] = objects [ 0x1101DB78 ]
	table [ "character" ] = objects [ 0x0FFE1430 ]

	table = objects [ 0x11167068 ]
	table [ "wordcount" ] = 65
	table [ "inspiration" ] = 320
	table [ "defense" ] = 44

	table = objects [ 0x11168520 ]
	table [ "statistics" ] = objects [ 0x11166850 ]
	table [ "level" ] = 1
	table [ "genre" ] = "fantasy"
	table [ "id" ] = 1
	table [ "status" ] = objects [ 0x11167068 ]
	table [ "xp" ] = 0
	table [ "name" ] = "sword"
	table [ "flags" ] = "protagonist character"

	table = objects [ 0x1116EAD8 ]
	table [ "tropes" ] = objects [ 0x110380E0 ]
	table [ "formations" ] = objects [ 0x11031778 ]
	table [ "formation" ] = objects [ 0x1115D0C8 ]
	table [ "elements" ] = objects [ 0x11009528 ]
	table [ "author" ] = objects [ 0x0FFC4CF0 ]

end

--Declaring Objects
local objects = {

	--Declaring Tables
	[ 0x0FF4E858 ] = {},
	[ 0x0FF4E928 ] = {},
	[ 0x0FF7EF10 ] = {},
	[ 0x0FF7EF90 ] = {},
	[ 0x0FF80800 ] = {},
	[ 0x0FF83E50 ] = {},
	[ 0x0FF85D78 ] = {},
	[ 0x0FF87670 ] = {},
	[ 0x0FF8C6F8 ] = {},
	[ 0x0FF926F8 ] = {},
	[ 0x0FF932B0 ] = {},
	[ 0x0FF99E98 ] = {},
	[ 0x0FFA83A0 ] = {},
	[ 0x0FFAA618 ] = {},
	[ 0x0FFAA818 ] = {},
	[ 0x0FFBDC08 ] = {},
	[ 0x0FFBE088 ] = {},
	[ 0x0FFC2880 ] = {},
	[ 0x0FFC2960 ] = {},
	[ 0x0FFC4CF0 ] = {},
	[ 0x0FFC4DD8 ] = {},
	[ 0x0FFC4E30 ] = {},
	[ 0x0FFC5F38 ] = {},
	[ 0x0FFD0DC0 ] = {},
	[ 0x0FFD1940 ] = {},
	[ 0x0FFD1B70 ] = {},
	[ 0x0FFD2AA8 ] = {},
	[ 0x0FFD2B60 ] = {},
	[ 0x0FFD5610 ] = {},
	[ 0x0FFD8D18 ] = {},
	[ 0x0FFD9150 ] = {},
	[ 0x0FFDD7D0 ] = {},
	[ 0x0FFE0210 ] = {},
	[ 0x0FFE1430 ] = {},
	[ 0x0FFE2968 ] = {},
	[ 0x0FFE8990 ] = {},
	[ 0x0FFECF80 ] = {},
	[ 0x11000DF8 ] = {},
	[ 0x11001738 ] = {},
	[ 0x11006D90 ] = {},
	[ 0x110094A8 ] = {},
	[ 0x11009528 ] = {},
	[ 0x1100A428 ] = {},
	[ 0x1100AF00 ] = {},
	[ 0x1100B040 ] = {},
	[ 0x1100B0B8 ] = {},
	[ 0x1100C490 ] = {},
	[ 0x1100EE58 ] = {},
	[ 0x1100FED0 ] = {},
	[ 0x110114C8 ] = {},
	[ 0x11017B48 ] = {},
	[ 0x1101B100 ] = {},
	[ 0x1101B178 ] = {},
	[ 0x1101C330 ] = {},
	[ 0x1101CBE8 ] = {},
	[ 0x1101DB78 ] = {},
	[ 0x1102E3A8 ] = {},
	[ 0x1102F300 ] = {},
	[ 0x1102F998 ] = {},
	[ 0x11030608 ] = {},
	[ 0x11031778 ] = {},
	[ 0x110318C8 ] = {},
	[ 0x11031D50 ] = {},
	[ 0x110328A0 ] = {},
	[ 0x110380E0 ] = {},
	[ 0x11038638 ] = {},
	[ 0x11038768 ] = {},
	[ 0x110387D8 ] = {},
	[ 0x1103ADC8 ] = {},
	[ 0x1103AE18 ] = {},
	[ 0x1103C100 ] = {},
	[ 0x1103C528 ] = {},
	[ 0x1103D6F0 ] = {},
	[ 0x1103D8E8 ] = {},
	[ 0x11148D28 ] = {},
	[ 0x1114F2F8 ] = {},
	[ 0x111534D8 ] = {},
	[ 0x11153A48 ] = {},
	[ 0x11154060 ] = {},
	[ 0x11154378 ] = {},
	[ 0x111593E8 ] = {},
	[ 0x11159BA8 ] = {},
	[ 0x11159CD8 ] = {},
	[ 0x1115D0C8 ] = {},
	[ 0x1115E3E0 ] = {},
	[ 0x1115F448 ] = {},
	[ 0x111649C8 ] = {},
	[ 0x11166850 ] = {},
	[ 0x11167068 ] = {},
	[ 0x11168520 ] = {},
	[ 0x1116EAD8 ] = {},

}

init ( objects )

--Returning Tables
return objects [ 0x1116EAD8 ]
