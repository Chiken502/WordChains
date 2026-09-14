# CheddaBoards — Online Leaderboards (Godot SDK)

Version 2.2.6 · Godot 4.6+ · MIT

Online leaderboards, achievements, and cross-platform sign-in for
Godot 4.6+ — with nothing for you to host.

## Install

1. Copy `addons/cheddaboards/` into your project (if you're reading
   this from inside your project, that's already done).
2. Enable the plugin: **Project → Project Settings → Plugins →
   CheddaBoards**. This registers the `CheddaBoards` autoload for you.

## Set up

Grab your API key from https://cheddaboards.com (free tier available),
then run the Setup Wizard: open `addons/cheddaboards/SetupWizard.gd`
and use **File → Run** (Ctrl/Cmd+Shift+X). It writes the credentials
into your main scene's script and verifies the autoload.

Prefer to do it by hand? In your startup script's `_ready()`:

	CheddaBoards.set_api_key("cb_your-game_xxxxxxxxxx")
	CheddaBoards.set_game_id("your-game")

## Use

	await CheddaBoards.wait_until_ready()
	CheddaBoards.login_anonymous()        # no sign-up needed
	CheddaBoards.submit_score(score)      # e.g. on game over
	CheddaBoards.get_leaderboard()        # emits leaderboard_loaded

Players are identified by a persistent device ID — no account
required, and anonymous players can upgrade to a full account later
without losing their scores. Sign-in sessions persist across
restarts, so players who link a Google or Apple account stay
signed in. Nicknames are 3–16 characters: letters, numbers, and
underscores.

Leaderboard reads now go straight to the backend where possible,
with the API used as automatic fallback — no configuration needed,
boards just load faster.

## More

- Full documentation, guides and API reference:
  https://docs.cheddaboards.com
- The complete game template:
  https://github.com/cheddatech/cheddaboards-godot
- Worked example — Dodge the Creeps with leaderboards:
  https://github.com/cheddatech/cheddaboards-dodge-the-creeps

License: MIT (see LICENSE)
