#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zm_tomb;
#include maps/mp/zm_tomb_tank;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zm_tomb_main_quest;
#include maps/mp/zm_tomb_utility;

#include scripts/zm/zm_tomb/remix/_tomb_dig;
#include scripts/zm/zm_tomb/remix/_tomb_weapons;
#include scripts/zm/zm_tomb/remix/_tomb_craftables;

main()
{
    replaceFunc( maps/mp/zm_tomb::include_weapons, ::include_weapons_override );
    replaceFunc( maps/mp/zm_tomb_tank::wait_for_tank_cooldown, ::wait_for_tank_cooldown_override );
	replaceFunc( maps/mp/zm_tomb_dig::waittill_dug, ::waittill_dug );
	replaceFunc( maps/mp/zm_tomb_dig::dig_up_powerup, ::dig_up_powerup );
	replaceFunc( maps/mp/zm_tomb_dig::dig_get_rare_powerups, ::dig_get_rare_powerups );
	// replaceFunc( maps/mp/zm_tomb_craftables::include_craftables, ::include_craftables );
	// replaceFunc( maps/mp/zm_tomb_main_quest::staff_crystal_wait_for_teleport, ::staff_crystal_wait_for_teleport );
	// replaceFunc( maps/mp/zm_tomb::include_weapons, ::include_weapons );
	replaceFunc( maps/mp/zm_tomb_main_quest::chambers_init, ::chambers_init );
	replaceFunc( maps/mp/zombies/_zm_powerup_zombie_blood::make_zombie_blood_entity, ::make_zombie_blood_entity );
	
    level.initial_spawn_tomb = true;
    level thread onplayerconnect();
}

onplayerconnect()
{   
    for(;;)
    {
        level waittill("connected", player);
        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon("disconnect");
    self.initial_spawn_tomb = true;
    
    for(;;)
    {
        self waittill("spawned_player");

		self tomb_give_shovel();

        if(self.initial_spawn_tomb)
		{
            self.initial_spawn_tomb = true;
        }

        if(level.initial_spawn_tomb)
        {
            level.initial_spawn_tomb = false;

			level thread tomb_remove_shovels_from_map();
			level thread tomb_zombie_blood_dig_changes();

			flag_wait( "start_zombie_round_logic" );
   			wait 0.05;
			   
			disable_walls_moving();
			thread enable_all_teleporters();
			thread spawn_gems_in_chambers();
        }
    }
}

enable_all_teleporters()
{
	flag_wait( "initial_blackscreen_passed" );
	flag_set( "activate_zone_chamber" );
	while(1)
	{
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
		if( isDefined(air) && isDefined(fire) && isDefined(light) && isDefined(ice) )
		{
			break;
		}
		wait 1;
	}
}

disable_walls_moving()
{
	flag_wait( "start_zombie_round_logic" );
	wait 0.05;
	flag_set( "stop_random_chamber_walls" );
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
	a_stargate_gramophones = getstructarray( "stargate_gramophone_pos", "targetname" );
	//array_thread( a_stargate_gramophones, :: );
	a_door_main = getentarray( "chamber_entrance", "targetname" );
	array_thread( a_door_main, ::run_gramophone_door, "vinyl_master" );
}

wait_for_tank_cooldown_override()
{
	self thread snd_fuel();
	if ( self.n_cooldown_timer < 2 )
	{
		self.n_cooldown_timer = 2;
	}
	else
	{
		if ( self.n_cooldown_timer > 4 )
		{
			self.n_cooldown_timer = 4;
		}
	}
	wait self.n_cooldown_timer;
	level notify( "stp_cd" );
	self playsound( "zmb_tank_ready" );
	self playloopsound( "zmb_tank_idle" );
}