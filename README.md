# Call of Duty: Black Ops II Zombies - Remix

## Download

[Download](https://github.com/5and5/BO2-Remix/releases/download/latest/BO2-Remix.zip)

## Leaderboards
[Leaderboards](https://docs.google.com/spreadsheets/d/14oRX3aQFWWz5VaLz3B_nt_YOe-9zHf3HTQNuCU9Xqcs/)

## Created by: 5and5

[Discord](https://discord.gg/Z44Vnjd)

[YouTube](https://www.youtube.com/user/Zomb0s4life)

[Twitch](https://twitch.tv/5and5)

[Twitter](https://twitter.com/5and55)

## How to Install
* Download and install BO2 Plutonium [Plutonium Download](https://plutonium.pw/)
* Download the latest version of [Remix](https://github.com/5and5/BO2-Remix/releases/download/latest/BO2-Remix.zip)
* Open "BO2-Remix.zip" and copy the "zm" folder into ```%localappdata%\Plutonium\storage\t6\scripts```
* Launch the game and enjoy!

## Change Notes

### General
* Zombies start running at round 1
* Walkers removed
* Starting points set to 555
* Coop pause
* Three weapon slots by default
* Zombies health scales more linearly
* Insta kill rounds start on round 115 on normal maps then happen every odd round after
* Insta kill rounds start on round 75 on survival maps then happen every odd round after
* 12 hour reset

### Visual
* Tweaked graphics
* Tweaked vision set
* Fog disabled
* Night mode option with ```night_mode 1``` dvar

### Patches
* Bank automatically full
* Perma Perks given
* Fridge has AN94 or War Machine depending on the map
* Set box starting locations
* Round 255 round cap removed
* Remove player quotes ```disable_player_quotes``` dvar
* In game fast ray ```rapid_fire``` dvar
* Characters can be selected with ```character``` dvar

### HUD
* Timer
* Round timer
* Health bar
* SPH - appears after round 50
* Zombies remaining counter
* Current zone

### Power Ups
* Drop rate increased from 2% to 3%
* Fire sales removed
* Max ammos refill clip as well
* Carpenters repair shields
* Insta kill timer stacks
* Double points timer stacks
* Nukes kill zombies faster
* Perk bottles give extra perk slot

### Perks
* Players can sprint while drinking perks
* Perk bottles also increase players perk limit by 1
* Mulekick increases ads, weapon switching, grenade tossing and perk drinking
* Deadshot increases head shot damage by x2
* Who's who wont activate when player has quick revive
* Electric cherry wont activate when a player goes down
* Proning in front of perks gives you 100 points

### Mystery Box
* Weapons can be shared by knifing the box
* Box moves instantly now
* Box perma perk guarantees a good weapon first hit
* First box setup guaranteed
* Mark 2 probability increased from 33% to 50%

### Buildables
* Buildables can be built with get parts
* All parts are given at the start of the game
* Increased buildable buy distance
* Buildables can be built without looking at them

### Weapons
* Increased wall weapon buy distance

### Equipment
* Claymores do 1/2 of zombies max health
* Max claymores changed from 12 per player to 10 total on the map at a time

# Maps

### Bus Depot
* Pack-A-Punch added
* Claymores added

### Farm
* Pack-A-Punch added
* Claymores added

### Town
* Speed cola moved
* Olympia replaced with an mp5

### Nuke Town

## Tranzit

### General
* Denizens disabled
* All light post portals are always active
* Pap door is always open

### Zones
* Farm barn zone acts the same as it does on Farm
* Outside of farm acts the same with the door to Farm open

### Buildables
* Bus parts are prebuilt except cattle catcher
* Dinner hatch is prebuilt

### Weapons
* Jetgun recharges faster
* Jetgun recharges while away
* Jetgun returns to bench when over heated

## Die Rise

### General 
* Leaper rounds always happen every 4 rounds
* Perma phd flopper added

### Zones
* Limited where players can camp while in the shaft
* Zombies no longer jump across to trample steam zone

### Elevators
* Elevator wait time changed from 5-20 to 7-12 seconds
* Standing on elevators make them move quicker
* Key is given on spawn
* Key can be used unlimited amount of times
* Key can lock elevator in current position

### Weapons
* Added semtex wallbuy by b23r
* Sliquifier kills till round 255
* Sliquifier continues to chain while put away
<!-- * Sliquifier no longer drops extra goo -->
* Sliquifier goo removed

## Mob of the Dead

### General 
* All plane parts are auto picked up
* Plane automatically refills
* Blunder gat spawns in wardens office without collecting the 5 skulls
* Set key to always spawn next to the cafeteria

### Traps
* Fan trap no longer kills players instantly
* Sniper trap does infinite damage
* Acid trap player damage cool down increased from 1 to 1.5 seconds

### Zones
* Opening double tap door does not cause zombies to spawn upstairs

### Weapons
* Blundergats damage no longer falls off
* Blundergat is no longer limited in the box
* Blundergat ammo reduced by 1/3
* Acidgat ammo reduced by 1/3
* Tomahawk is upgraded when picked up
* Added zombie shield bench inside wardens office

## Buried
* Pack-a-punch camo replaced with Mob of the Dead animated camo

## Origins

### General
* All records and buildable parts given on spawn
* Gramophone is no longer needed
* Tank has instant cool down
* Pack-a-punch is always on
* Reduced soul boxes zombies required from 30 to 15

### Special Rounds
* Panzers will come every 4 rounds on solo and coop
* Generator zombies can come every 4 rounds
* Generator zombies come will come the same round as you turn on 4 or more generators

### Weapons
* Staffs can be upgraded without doing the easter egg steps
* Upgraded lighting does infinite damage

### Crazy Place
* Moving walls at disabled 
* All gems spawn at spawned in

### Teleporters
* Teleporters activate as soon as door leading to them is opened
* Teleporters in the crazy place can be used without being first used from the other side

### Shovel and Helmet
* Shovels given on spawn
* Golden shovel awarded after 5 digs
* Golden helmet chance increased from 5% to 20%

### Dig spots
* Removed firesale, zombie blood and bonus points as possible powerups that can be dug
* Dug powerups spawn in a cycle (4 main powerups)
* Hidden perk bottle dig spots are visible without zombie blood
* Hidden perk bottle dig spots respawn every round
* Hidden perk bottles give all 9 perk slots 

## Custom Dvars
```
coop_pause
night_mode
character
hud_timer
hud_round_timer
hud_health_bar
hud_remaining
hud_zone
disable_player_quotes
```

## Custom Binds
```
bind Q "toggle rapid_fire 1 0"
bind F8 "toggle coop_pause 1 0"
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

* JezuzLizard
* JBleezy
* ZECxR3ap3r
* Bandit
* Naomi_
* Chase
* DoktorSAS
* HuthTV