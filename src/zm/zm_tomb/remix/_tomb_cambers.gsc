#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zm_tomb;
#include maps/mp/zm_tomb_tank;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zm_tomb_main_quest;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zm_tomb_capture_zones;

#include scripts/zm/zm_tomb/remix/_tomb_craftables;

disable_walls_moving()
{
	flag_wait( "start_zombie_round_logic" );
	wait 0.05;
	flag_set( "stop_random_chamber_walls" );
}

enable_all_teleporters()
{
	flag_wait( "initial_blackscreen_passed" );
	flag_set( "activate_zone_chamber" );
	while(1)
	{
		if ( level.zones[ "zone_nml_18" ].is_enabled && !isDefined(gramo))
		{
			a_door_main = getentarray( "chamber_entrance", "targetname" );
			array_thread( a_door_main, ::open_gramophone_door );
			gramo = 1;
		}
		if( level.zones[ "zone_air_stairs" ].is_enabled && !isDefined(air))
		{
			maps/mp/zm_tomb_teleporter::stargate_teleport_enable( 2 );
			air = 1;
		}
		if( level.zones[ "zone_fire_stairs" ].is_enabled && !isDefined(fire))
		{
			maps/mp/zm_tomb_teleporter::stargate_teleport_enable( 1 );
			fire = 1;
		}
		if( level.zones[ "zone_nml_farm" ].is_enabled && !isDefined(light))
		{
			maps/mp/zm_tomb_teleporter::stargate_teleport_enable( 3 );
			light = 1;
		}
		if( level.zones[ "zone_ice_stairs" ].is_enabled && !isDefined(ice))
		{
			maps/mp/zm_tomb_teleporter::stargate_teleport_enable( 4 );
			ice = 1;
		}
		if( isDefined(air) && isDefined(fire) && isDefined(light) && isDefined(ice) && isDefined(gramo) )
		{
			break;
		}
		wait 1;
	}
}

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

chambers_init() //checked matches cerberus output
{
	flag_init( "gramophone_placed" );
	array_thread( getentarray( "trigger_death_floor", "targetname" ), ::monitor_chamber_death_trigs );
	// a_stargate_gramophones = getstructarray( "stargate_gramophone_pos", "targetname" );
	// array_thread( a_stargate_gramophones, :: );
	// a_door_main = getentarray( "chamber_entrance", "targetname" );
	// array_thread( a_door_main, ::run_gramophone_door, "vinyl_master" );
}