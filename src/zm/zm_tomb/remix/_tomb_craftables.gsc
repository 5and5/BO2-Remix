#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_ai_quadrotor;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zm_tomb_vo;
#include maps/mp/zm_tomb_main_quest;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zm_tomb_craftables;

spawn_gems_in_chambers()
{
	for(i = 0; i < 4; i++)
	{
		wait 1;
		level notify( "player_teleported", level.players[0], i + 1 );
	}
}
