extends Node

## Stores an array of level arrays. inside each level array is a starting word, target word, solution letters, and solution word path (words are comma seperated)
var levels: Array[Array] = [
	# starting_word, target_word, solution(conjoined), sulution comma seperated
	["POT", "GEM", "GEM", "POT,GOT,GET,GEM"],
	["CARD", "GAME", "EMG", "CARD,CARE,CAME,GAME"],
	["RING", "LIFE", "DELF", "RING,DING,DINE,LINE,LIFE"],
	["CARE", "BEAR", "BKEAR", "CARE,BARE,BARK,BERK,BEAK,BEAR"],
	["CARD", "KING", "BNIKG", "CARD,BARD,BAND,BIND,KIND,KING"],
	["GLASS", "SHARD", "CPHRDS", "GLASS,CLASS,CLAPS,CHAPS,CHARD,SHARD"],
	["SLIDE", "COAST", "GABSTOC", "SLIDE,GLIDE,GLADE,BLADE,BLASE,BLAST,BOAST,COAST"],
	[
		"WATER",
		"SPILL",
		"HDRISHIPLL",
		"WATER,HATER,HATED,HARED,HIRED,SIRED,SHRED,SHIED,SPIED,SPIEL,SPILL",
	], # Need to find better stuff for this
	[
		"BROKE",
		"CHEAP",
		"ACTKCIHEEPA",
		"BROKE,BRAKE,BRACE,TRACE,TRACK,CRACK,CRICK,CHICK,CHECK,CHEEK,CHEEP,CHEAP",
	],
	[
		"MAGIC",
		"SPELL",
		"NAGYLWLDIRLTWSPE",
		"MAGIC,MANIA,MANGA,MANGY,MANLY,WANLY,WALLY,DAILY,DIRTLY,DRILL,TRILL,TWILL,SWILL,SPILL,SPELL",
	],
]
