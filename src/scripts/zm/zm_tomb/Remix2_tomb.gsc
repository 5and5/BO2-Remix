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
#include maps/mp/zm_tomb_challenges;
#include maps/mp/zm_tomb_giant_robot;

#include scripts/zm/remix/_debug;
#include scripts/zm/zm_tomb/remix/_tomb_dig;
#include scripts/zm/zm_tomb/remix/_tomb_weapons;
#include scripts/zm/zm_tomb/remix/_tomb_craftables;
#include scripts/zm/zm_tomb/remix/_tomb_chambers;

main()
{
    // replaceFunc( maps/mp/zm_tomb::include_weapons, ::include_weapons_override );
    replaceFunc( maps/mp/zm_tomb_tank::wait_for_tank_cooldown, ::wait_for_tank_cooldown_override );
	replaceFunc( maps/mp/zm_tomb_dig::waittill_dug, ::waittill_dug );
	replaceFunc( maps/mp/zm_tomb_dig::dig_up_powerup, ::dig_up_powerup );
	replaceFunc( maps/mp/zm_tomb_dig::dig_get_rare_powerups, ::dig_get_rare_powerups );
	replaceFunc( maps/mp/zm_tomb_dig::increment_player_perk_purchase_limit, ::increment_player_perk_purchase_limit );
	replaceFunc( maps/mp/zm_tomb_main_quest::chambers_init, ::chambers_init );
	replaceFunc( maps/mp/zombies/_zm_powerup_zombie_blood::make_zombie_blood_entity, ::make_zombie_blood_entity );
	replaceFunc( maps/mp/zm_tomb_craftables::sndplaystaffstingeronce, ::sndplaystaffstingeronce );
	replaceFunc( maps/mp/zombies/_zm_weap_staff_lightning::staff_lightning_ball_damage_over_time, ::staff_lightning_ball_damage_over_time );
	replaceFunc( maps/mp/zm_tomb_challenges::box_footprint_think, ::box_footprint_think );
	replaceFunc( maps/mp/zm_tomb_ee_side::check_for_change, ::check_for_change );
	replaceFunc( maps/mp/zm_tomb_capture_zones::recapture_round_tracker, ::recapture_round_tracker_override );
	replaceFunc( maps/mp/zm_tomb_capture_zones::pack_a_punch_think, ::pack_a_punch_think );
	replaceFunc( maps/mp/zm_tomb_capture_zones::play_pap_anim, ::play_pap_anim );
	replaceFunc( maps/mp/zm_tomb_giant_robot::robot_cycling, ::robot_cycling );
	replaceFunc( maps/mp/zm_tomb_challenges::challenges_init, ::challenges_init_override );

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
            self.initial_spawn_tomb = false;
        }

        if(level.initial_spawn_tomb)
        {
            level.initial_spawn_tomb = false;

			level thread tomb_remove_shovels_from_map();
			level thread tomb_zombie_blood_dig_changes();

			flag_wait( "start_zombie_round_logic" );
   			wait 0.05;
			
			soul_box_changes();
			set_panzer_rounds();
			disable_walls_moving();

			level thread enable_all_teleporters();
			level thread spawn_gems_in_chambers();
        }
    }
}

set_panzer_rounds()
{
	level.mechz_min_round_fq = 4;
	level.mechz_max_round_fq = 5;
	level.mechz_min_round_fq_solo = 4;
	level.mechz_max_round_fq_solo = 5;
}

soul_box_changes()
{
	a_boxes = getentarray( "foot_box", "script_noteworthy" );
	array_thread( a_boxes, ::soul_box_decrease_kill_requirement );
}

soul_box_decrease_kill_requirement()
{
	self endon( "box_finished" );

	while (1)
	{
		self waittill( "soul_absorbed" );
		wait 0.05;
		self.n_souls_absorbed += 15;
		self waittill( "robot_foot_stomp" );
	}
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

play_pap_anim( b_assemble )
{
	// level setclientfield( "packapunch_anim", get_captured_zone_count() );
}

pack_a_punch_think()
{
	flag_wait( "start_zombie_round_logic" );
	wait 5;
	level setclientfield( "packapunch_anim", 6 );
	pack_a_punch_enable();
}

check_for_change()
{
	while ( 1 )
	{
		self waittill( "trigger", e_player );
		if ( e_player getstance() == "prone" )
		{
			e_player maps/mp/zombies/_zm_score::add_to_player_score( 100 );
			play_sound_at_pos( "purchase", e_player.origin );
			return;
		}
		else
		{
			wait 0.1;
		}
	}
}

robot_cycling()
{
	three_robot_round = 0;
	last_robot = -1;
	level thread giant_robot_intro_walk( 1 );
	level waittill( "giant_robot_intro_complete" );
	while ( 1 )
	{
		if ( !(level.round_number % 4) && three_robot_round != level.round_number )
		{
			flag_set( "three_robot_round" );
		}
		if ( flag( "ee_all_staffs_placed" ) && !flag( "ee_mech_zombie_hole_opened" ) )
		{
			flag_set( "three_robot_round" );
		}
		if ( flag( "three_robot_round" ) )
		{
			level.zombie_ai_limit = 22;
			random_number = randomint( 3 );
			if ( random_number == 2 )
			{
				level thread giant_robot_start_walk( 2 );
			}
			else
			{
				level thread giant_robot_start_walk( 2, 0 );
			}
			wait 5;
			if ( random_number == 0 )
			{
				level thread giant_robot_start_walk( 0 );
			}
			else
			{
				level thread giant_robot_start_walk( 0, 0 );
			}
			wait 5;
			if ( random_number == 1 )
			{
				level thread giant_robot_start_walk( 1 );
			}
			else
			{
				level thread giant_robot_start_walk( 1, 0 );
			}
			level waittill( "giant_robot_walk_cycle_complete" );
			level waittill( "giant_robot_walk_cycle_complete" );
			level waittill( "giant_robot_walk_cycle_complete" );
			wait 5;
			level.zombie_ai_limit = 24;
			three_robot_round = level.round_number;
			last_robot = -1;
			flag_clear( "three_robot_round" );
			continue;
		}
		else
		{
			if ( !flag( "activate_zone_nml" ) )
			{
				random_number = randomint( 2 );
			}
			else
			{
				random_number = randomint( 3 );
				while(random_number == last_robot)
				{
					random_number = randomint( 3 );
				}
			}
			last_robot = random_number;
			if( !isDefined( level.first_robot_round ) )
			{
				level.first_robot_round = 1;
				random_number = 1; // tank station robot
			}
			level thread giant_robot_start_walk( random_number );
			level waittill( "giant_robot_walk_cycle_complete" );
			wait 5;
		}
	}
}