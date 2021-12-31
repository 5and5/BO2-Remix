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

#include scripts/zm/remix/_debug;
#include scripts/zm/zm_tomb/remix/_tomb_dig;
#include scripts/zm/zm_tomb/remix/_tomb_weapons;
#include scripts/zm/zm_tomb/remix/_tomb_craftables;
#include scripts/zm/zm_tomb/remix/_tomb_chambers;

main()
{
    replaceFunc( maps/mp/zm_tomb::include_weapons, ::include_weapons_override );
    replaceFunc( maps/mp/zm_tomb_tank::wait_for_tank_cooldown, ::wait_for_tank_cooldown_override );
	replaceFunc( maps/mp/zm_tomb_dig::waittill_dug, ::waittill_dug );
	replaceFunc( maps/mp/zm_tomb_dig::dig_up_powerup, ::dig_up_powerup );
	replaceFunc( maps/mp/zm_tomb_dig::dig_get_rare_powerups, ::dig_get_rare_powerups );
	replaceFunc( maps/mp/zm_tomb_main_quest::chambers_init, ::chambers_init );
	replaceFunc( maps/mp/zombies/_zm_powerup_zombie_blood::make_zombie_blood_entity, ::make_zombie_blood_entity );
	replaceFunc( maps/mp/zm_tomb_capture_zones::recapture_round_tracker, ::recapture_round_tracker_override );
	
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
			
			set_panzer_rounds();
			disable_walls_moving();

			thread enable_all_teleporters();
			thread spawn_gems_in_chambers();
        }
    }
}

set_panzer_rounds()
{
	level.mechz_min_round_fq = 4;
	level.mechz_max_round_fq = 4;
	level.mechz_min_round_fq_solo = 4;
	level.mechz_max_round_fq_solo = 4;
}

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

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

recapture_round_tracker_override()
{
	n_next_recapture_round = 10;
	while ( 1 )
	{
		if ( level.round_number >= n_next_recapture_round && !flag( "zone_capture_in_progress" ) && get_captured_zone_count() >= get_player_controlled_zone_count_for_recapture() )
		{
			n_next_recapture_round = (level.round_number + 4);
			level thread recapture_round_start();
		}
		wait 1;
	}
}