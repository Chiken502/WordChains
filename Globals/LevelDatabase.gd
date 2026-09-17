extends Node

signal daily_loaded()
signal request_received(response_code: int)
signal daily_failed(response_code: int)

## Stores an array of level arrays. inside each level array is a starting word, target word, solution letters, and solution word path (words are comma seperated)
var levels: Array[Array] = [
	# starting_word, target_word, solution(conjoined), sulution comma seperated
	["POT", "GEM", "GEM", "POT,GOT,GET,GEM"],
	["CAT", "BED", "BDE", "CAT,BAT,BAD,BED"],
	["CARD", "GAME", "EMG", "CARD,CARE,CAME,GAME"],
	["LOVE", "HATE", "HAT", "LOVE,HOVE,HAVE,HATE"],
	["RING", "LIFE", "DELF", "RING,DING,DINE,LINE,LIFE"],
	["CARE", "BEAR", "BKEAR", "CARE,BARE,BARK,BERK,BEAK,BEAR"],
	["CARD", "KING", "BNIKG", "CARD,BARD,BAND,BIND,KIND,KING"],
	["FAST", "SLOW", "COOLSW", "FAST,CAST,COST,COOT,CLOT,SLOT,SLOW"],
	["GLASS", "SHARD", "CPHRDS", "GLASS,CLASS,CLAPS,CHAPS,CHARD,SHARD"],
	["SLIDE", "COAST", "GABSTOC", "SLIDE,GLIDE,GLADE,BLADE,BLASE,BLAST,BOAST,COAST"],
	["EARLY", "LATER", "SNBERSLT", "EARLY,EARLS,EARNS,BARNS,BARES,BARER,BASER,LASER,LATER"],
	["SMART", "BRAIN", "TKCLBNDRIN", "SMART,START,STARK,STACK,SLACK,BLACK,BLANK,BLAND,BRAID,BRAIN"],
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

var day_of_year: int = -1
var utc_datetime: String


func fetch_date():
	print("Loading daily level")
	var http = HTTPRequest.new()
	http.timeout = 30
	add_child(http)
	http.request_completed.connect(self._http_request_completed)

	var file = FileAccess.open("res://api_key.json", FileAccess.READ)
	var raw_data = file.get_as_text()
	file.close()
	var data = JSON.parse_string(raw_data)
	var api_key = data.rapid_api_key

	var headers: PackedStringArray = [
		"x-rapidapi-key: " + api_key,
		"x-rapidapi-host: world-time-api3.p.rapidapi.com",
		"Content-Type: application/json",
	]

	var error = http.request(
		"https://world-time-api3.p.rapidapi.com/timezone/Etc/UTC",
		headers,
		HTTPClient.METHOD_GET,
	)

	if error != OK:
		push_error("An error occurred while initiating the Time HTTP request.")
	else:
		print("Requested Time")


func load_daily_level():
	if day_of_year != -1:
		print("Loading puzzle file")
		var puzzle_file = FileAccess.open(
			"res://Globals/Puzzles/daily_puzzles.json",
			FileAccess.READ,
		)
		var data = JSON.parse_string(puzzle_file.get_as_text())

		print(data["puzzles"][day_of_year - 1])
		print(get_short_solution(data["puzzles"][day_of_year - 1]["solution"]))

		var puzzle = data["puzzles"][day_of_year - 1]

		GameManager.starting_word = puzzle["start"]
		GameManager.current_word = puzzle["start"]
		GameManager.target_word = puzzle["target"]
		GameManager.solution = get_short_solution(puzzle["solution"])
		GameManager.solution_long = puzzle["solution"]

		daily_loaded.emit()


func get_short_solution(solution_long: Array) -> String:
	var result = ""

	for i in range(len(solution_long)):
		if i + 1 < solution_long.size():
			var word = solution_long[i]
			var next_word = solution_long[i + 1]

			var letter_idx = -1
			for j in range(len(next_word)):
				if word[j] == next_word[j]:
					pass
				else:
					letter_idx = j
					break

			if letter_idx != -1:
				result += next_word[letter_idx]

	return result


func _http_request_completed(
	_result: int,
	response_code: int,
	_response_headers: PackedStringArray,
	body: PackedByteArray,
):
	if response_code == 200:
		# Convert the raw byte array directly into a readable string
		var raw_text: String = body.get_string_from_utf8()

		if raw_text.contains("day_of_year"):
			print("The request was successful!")
			var response = parse_response(raw_text)
			day_of_year = int(response["\"day_of_year\""])
			GameManager.day_of_year = day_of_year
			utc_datetime = String(response["\"utc_datetime\""])
			print(day_of_year)
			request_received.emit(200)
	else:
		print("API Request failed with response code: ", response_code)
		daily_failed.emit(response_code)


func parse_response(raw_text: String) -> Dictionary:
	var result_dict: Dictionary = { }

	raw_text = raw_text.remove_chars("{}")
	var lines: PackedStringArray = raw_text.split(",")
	for line in lines:
		line.strip_edges()
		if line.is_empty():
			continue

		var parts: PackedStringArray = line.split(":", true, 1)

		if parts.size() == 2:
			var key = parts[0].strip_edges()
			var value = parts[1].strip_edges()

			result_dict[key] = value

	return result_dict
