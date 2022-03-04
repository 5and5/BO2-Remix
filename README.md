# Call of Duty: Black Ops II Zombies - Remix

## Created by: 5and5

[Discord](https://discord.gg/Z44Vnjd) - [YouTube](https://www.youtube.com/user/Zomb0s4life) - [Twitch](https://twitch.tv/5and5) - [Twitter](https://twitter.com/5and55)

## Download

[Download](https://github.com/5and5/BO2-Remix/releases/download/latest/BO2-Remix.zip)

## Leaderboards

[Leaderboards](https://docs.google.com/spreadsheets/d/14oRX3aQFWWz5VaLz3B_nt_YOe-9zHf3HTQNuCU9Xqcs/)

## How to Install

### Automatic Installer

- Download and install BO2 Plutonium [Plutonium Download](https://plutonium.pw/)
- Download the [Remix Installer](https://github.com/5and5/BO2-Remix/releases/download/Installer/BO2-Remix-Installer.bat)
- Double click on "BO2-Remix-Installer.bat" this will download the latest version of Remix and copy all the files into `%localappdata%\Plutonium\storage\t6\scripts`
- Launch the game and enjoy!

### Manual Installation

- Download and install BO2 Plutonium [Plutonium Download](https://plutonium.pw/)
- Download the [Remix](https://github.com/5and5/BO2-Remix/releases/download/latest/BO2-Remix.zip)
- Open "BO2-Remix.zip" and copy the "zm" folder into `%localappdata%\Plutonium\storage\t6\scripts`
- Launch the game and enjoy!

## Change Notes

### General

- Zombies start running at round 1
- Walkers removed
- Coop pause
- Three weapon slots by default
- Zombies health scales more linearly
- Insta kill rounds start on round 115 on normal maps then happen every odd round after
- Insta kill rounds start on round 75 on survival maps then happen every odd round after
- 12 hour reset

### Visual

- Tweaked graphics
- Tweaked vision set
- Rotating skybox
- Fog disabled
- Night mode option with `night_mode 1` dvar

### Patches

- Bank automatically full
- Perma Perks given
- Fridge has AN94 or War Machine depending on the map
- Set box starting locations
- Round 255 round cap removed
- Remove player quotes `disable_player_quotes 1` dvar
- In game fast ray `rapid_fire 1` dvar
- Characters can be selected with `character` dvar

### HUD

- Timer
- Round timer
- Health bar
- SPH - appears after round 50
- Zombies remaining counter
- Current zone
- Trap timer
- All hud can be turned on with `hud_all 1`
- Hud text color can be changed with `hud_color 1 1 1` "1" can be any value from 0 to 1
- Health bar hud color can be changed with `hud_color_health 1 1 1` "1" can be any value from 0 to 1

### Player

- Starting points set to 555
- Explosive damage scaling increased
- Reduced fall damage
- Increased max points to 5000005

### Power Ups

- Drop rate increased from 3% to 4%
- Fire sales removed
- Max ammos refill clip as well
- Carpenters repair shields
- Insta kill timer stacks
- Double points timer stacks
- Nukes kill zombies faster
- Perk bottles give extra perk slot
- Effect added to the first drop of a new powerup cycle

### Perks

- Players can sprint while drinking perks
- Perk bottles also increase players perk limit by 1
- Mulekick increases ads, weapon switching, grenade tossing and perk drinking
- Deadshot increases head shot damage by x2
- Who's who wont activate when player has quick revive
- Electric cherry wont activate when a player goes down
- Proning in front of perks gives you 100 points

### Mystery Box

- Weapons can be shared by knifing the box
- Box moves instantly now
- Box perma perk guarantees a good weapon first hit
- First box setup guaranteed
- Mark 2 probability increased from 33% to 50%

### Buildables

- All parts are given at the start of the game
- Increased buildable buy distance
- Buildables can be built without looking at them

### Weapons

- Increased wall weapon buy distance
- Buying wall weapon ammo fills clip

### Equipment

- Claymores do 1/2 of zombies max health
- Max claymores changed from 12 per player to 10 total on the map at a time

# Maps

## Survival

- Dogs are enabled by default except on Nuketown
- Dogs rounds always happen every 4 rounds

### Bus Depot

- Pack-A-Punch added
- Claymores added

### Farm

- Pack-A-Punch added
- Claymores added

### Town

- Speed cola moved to tombstone location
- Tombstone removed
- Olympia wall buy replaced with an mp5
- Claymores added

### Nuke Town

- Pack-a-punch and jug will always land in the backyard that the box starts at
- Set box starting location with `nuked_box yellow` or `nuked_box green`
- Perks drop in the same order every game ( revive, jug, pap, speed cola, double tap )
- Disabled zombies spawning in the middle while players are in either backyards
- Limited M27

## Tranzit

### General

- Denizens disabled
- All light post portals are always active
- Pap door is always open
- Removed iron boards

### Zones

- Farm barn zone acts the same as it does on Farm
- Outside of Farm zone acts the same even if you open the door

### Buildables

- Bus parts are prebuilt except cattle catcher
- Dinner hatch is prebuilt
- Turret does not need a turbine
- Electric trap does not need a turbine

### Weapons

- Jetgun recharges faster
- Jetgun recharges while away
- Jetgun returns to bench when over heated

## Die Rise

### General

- Leaper rounds always happen every 4 rounds
- Perma phd flopper added

### Zones

- Limited where players can camp while in the shaft
- Zombies no longer jump across to trample steam zone
- Disabled ground spawner in square room

### Elevators

- Elevator wait time changed from 5-20 to 7-12 seconds
- Standing on elevators make them move quicker
- Key is given on spawn
- Key can be used unlimited amount of times
- Key can lock elevator in set positions

### Weapons

- Semtex wallbuy added by b23r
- Sliquifier kills till round 255
- Sliquifier continues to chain while put away
- Sliquifier goo removed
<!-- * Sliquifier no longer drops extra goo -->

## Mob of the Dead

### General

- Blundergat spawns in wardens office without collecting 5 skulls
- Set key to always spawn next to the cafeteria

### Buildables

- All plane parts are given on spawn in solo only
- Plane automatically refills
- Zombie shield bench added inside wardens office
- Zombie shield inside wardens has a 5 minute cooldown

### Traps

- Fan trap no longer kills players instantly
- Sniper trap does infinite damage
- Acid trap player damage cool down increased from 1 to 1.5 seconds

### Zones

- Opening double tap door does not cause zombies to spawn upstairs

### Weapons

- Blundergat damage no longer falls off
- Blundergat is no longer limited in the box
- Blundergat ammo reduced by 1/3
- Acidgat ammo reduced by 1/3
- Tomahawk is upgraded when picked up
- Tomahawk reduced cooldown from 5 to 4 seconds

## Buried

### General

- Initial spawns changed to be closer to the slide
- Vultureaid will always be the last perk given by the witches
- Removed barricade in front of jug
- Nerfed jug spawn zone

### Buildables

- Spawned turbine workbench by candy shop
- Subwoofer gives powerups
- Subwoofer has increased range
- Turbine starts dying at 17% instead of 50% power

### Weapons

- Pack-a-punch camo replaced with Mob of the Dead animated camo

### Leroy

- Leroy runs 25% longer when meleed with a Bowie Knife
- Leroy runs 50% longer when meleed with Galvaknuckles

## Origins

### General

- Tank has instant cool down
- Pack-a-punch is always on
- First robot always comes over tank station
- Reduced soul boxes zombie requirement from 30 to 15
- Replace the 115 packed weapon reward with a Raygun Mark 2

### Buildables

- All records and buildable parts are given on spawn
- Gramophone is no longer needed

### Teleporters

- Teleporters activate as soon as doors leading to them are opened
- Teleporters in the crazy place can be used without first being used from the other side

### Special Rounds

- Panzers will come every 4 rounds on solo and coop
- Generator zombies can come every 4 rounds
- Generator zombies come will come the same round as you turn on 4 or more generators

### Weapons

- Staffs can be upgraded without doing the easter egg steps
- Upgraded lighting does infinite damage

### Crazy Place

- Moving walls at disabled
- All gems are spawned

### Shovel and Helmet

- Shovels given on spawn
- Golden shovel are awarded after 5 digs
- Golden helmet chance increased from 5% to 20%

### Dig spots

- Removed firesale, zombie blood and bonus points as possible powerups that can be dug
- Dug powerups spawn in a cycle (4 main powerups)
- Hidden perk bottle dig spots are visible without zombie blood
- Hidden perk bottle dig spots respawn every round
- Hidden perk bottles give all 9 perk slots

## Strat Tester

- Enable strat tester with `strat_tester 1`
- Choose desired round with `strat_round X` default is 70
- All perks are given
- All weapons are given

## Custom Dvars

```
strat_tester
coop_pause
night_mode
character
disable_player_quotes
rapid_fire
hud_all
hud_timer
hud_round_timer
hud_health_bar
hud_remaining
hud_zone
hud_color
```

## Custom Binds

```
bind Q "toggle rapid_fire 1 0"
bind F8 "toggle coop_pause 1 0"
```

## Config settings

```
seta hud_round_timer "1"
seta hud_health_bar "1"
seta hud_remaining "1"
seta hud_zone "1"
seta disable_player_quotes "1"
seta night_mode "1"
seta character "1"
```

## Insta Kill Rounds

```
115 117 119 121 123 125 127 129 131 133 135 137 139 141 143 145 147 149 151 153 155 157 159 161 163 165 167 169 171 173 175 177 179 181 183 185 187 189 191 193 195 197 199 201
```

## Insta Kill Rounds on Survival Maps

```
75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119 121 123 125 127 129 131 133 135 137 139 141 143 145 147 149
```

## Dog Rounds

```
5 9 13 17 21 25 29 33 37 41 45 49 53 57 61 65 69 73 77 81 85 89 93 97 101 105 109 113 117 121 125 129 133 137 141 145 149 153 157 161 165 169 173 177 181 185 189 193 197 201
```

## Panzer Rounds

```
8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200
```

## Credits

- JezuzLizard
- JBleezy
- ZECxR3ap3r
- Bandit
- TTS
- Naomi
- Chase
- DoktorSAS
- HuthTV
