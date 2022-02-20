#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_pers_upgrades_system;


disable_high_round_walkers()
{
	level.speed_change_round = undefined;
}

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

set_run_speed_override()
{
	self.zombie_move_speed = "sprint";
}

ai_calculate_health_override( round_number ) //checked changed to match cerberus output
{
	if( is_classic() ) // insta kill rounds staring at 115 then every 2 rounds after
	{
		if( (round_number >= 115) && (round_number % 2) )
		{
			level.zombie_health = 150;
			return;
		}
	}
	else // insta kill rounds staring at 75  on survial maps then every 2 rounds after
	{
		if( (round_number >= 75) && (round_number % 2) )
		{
			level.zombie_health = 150;
			return;
		}
	}

	// more linearly health formula - health is about the same at 60
	if( round_number > 50 )
	{	
		round = (round_number - 50);
		multiplier = 1;
		zombie_health = 0;

		for( i = 0; i < round; i++ )
		{
			multiplier++;
			zombie_health += int(5000 + (200 * multiplier) );
		}
		level.zombie_health = int(zombie_health + 51780); // round 51 zombies health

		// level.zombie_health = 150;
		// iprintln( "health: " + level.zombie_health );
	}
	else
	{
		level.zombie_health = level.zombie_vars[ "zombie_health_start" ];
		i = 2;
		while ( i <= round_number )
		{
			if ( i >= 10 )
			{
				old_health = level.zombie_health;
				level.zombie_health = level.zombie_health + int( level.zombie_health * level.zombie_vars[ "zombie_health_increase_multiplier" ] );
				if ( level.zombie_health < old_health )
				{
					level.zombie_health = old_health;
					return;
				}
				i++;
				continue;
			}
			level.zombie_health = int( level.zombie_health + level.zombie_vars[ "zombie_health_increase" ] );
			i++;
		}
	}
}

round_think_override( restart ) //checked changed to match cerberus output
{
	if ( !isDefined( restart ) )
	{
		restart = 0;
	}
	level endon( "end_round_think" );
	if ( !is_true( restart ) )
	{
		if ( isDefined( level.initial_round_wait_func ) )
		{
			[[ level.initial_round_wait_func ]]();
		}
		players = get_players();
		foreach ( player in players )
		{
			if ( is_true( player.hostmigrationcontrolsfrozen ) ) 
			{
				player freezecontrols( 0 );
			}
			player maps/mp/zombies/_zm_stats::set_global_stat( "rounds", level.round_number );
		}
	}
	setroundsplayed( level.round_number );
	for ( ;; )
	{
		maxreward = 50 * level.round_number;
		if ( maxreward > 500 )
		{
			maxreward = 500;
		}
		level.zombie_vars[ "rebuild_barrier_cap_per_round" ] = maxreward;
		level.pro_tips_start_time = getTime();
		level.zombie_last_run_time = getTime();
		if ( isDefined( level.zombie_round_change_custom ) )
		{
			[[ level.zombie_round_change_custom ]]();
		}
		else
		{
			level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
			round_one_up();
		}
		maps/mp/zombies/_zm_powerups::powerup_round_start();
		players = get_players();
		array_thread( players, ::rebuild_barrier_reward_reset );
		if ( !is_true( level.headshots_only ) && !restart )
		{
			level thread award_grenades_for_survivors();
		}
		level.round_start_time = getTime();
		while ( level.zombie_spawn_locations.size <= 0 )
		{
			wait 0.1;
		}
		level thread [[ level.round_spawn_func ]]();
		level notify( "start_of_round" );
		recordzombieroundstart();
		players = getplayers();
		for ( index = 0; index < players.size; index++  )
		{
			zonename = players[ index ] get_current_zone();
			if ( isDefined( zonename ) )
			{
				players[ index ] recordzombiezone( "startingZone", zonename );
			}
		}
		if ( isDefined( level.round_start_custom_func ) )
		{
			[[ level.round_start_custom_func ]]();
		}
		[[ level.round_wait_func ]]();
		level.first_round = 0;
		level notify( "end_of_round" );
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_end" );
		uploadstats();
		if ( isDefined( level.round_end_custom_logic ) )
		{
			[[ level.round_end_custom_logic ]]();
		}
		players = get_players();
		if ( is_true( level.no_end_game_check ) )
		{
			level thread last_stand_revive();
			level thread spectators_respawn();
		}
		else if ( players.size != 1 )
		{
			level thread spectators_respawn();
		}
		players = get_players();
		array_thread( players, ::round_end );
		timer = level.zombie_vars[ "zombie_spawn_delay" ];
		if ( timer > 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = timer * 0.95;
		}
		else if ( timer < 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
		}
		if ( level.gamedifficulty == 0 )
		{
			level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier_easy" ];
		}
		else
		{
			level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier" ];
		}
		level.round_number++;
		// if ( level.round_number >= 255 )
		// {
		// 	level.round_number = 255;
		// }
		setroundsplayed( level.round_number );
		matchutctime = getutc();
		players = get_players();
		foreach ( player in players )
		{
			if ( level.curr_gametype_affects_rank && level.round_number > 3 + level.start_round )
			{
				player maps/mp/zombies/_zm_stats::add_client_stat( "weighted_rounds_played", level.round_number );
			}
			player maps/mp/zombies/_zm_stats::set_global_stat( "rounds", level.round_number );
			player maps/mp/zombies/_zm_stats::update_playing_utc_time( matchutctime );
		}
		check_quickrevive_for_hotjoin(); //was commented out
		level round_over();
		level notify( "between_round_over" );
		restart = 0;
	}
}

zombie_rise_death_override( zombie, spot ) //checked matches cerberus output
{
	zombie.zombie_rise_death_out = 0;
	zombie endon( "rise_anim_finished" );
	while ( isDefined( zombie ) && isDefined( zombie.health ) && zombie.health > 1 )
	{
		zombie waittill( "damage", amount );
	}
	spot notify( "stop_zombie_rise_fx" );
	if ( isDefined( zombie ) )
	{
		// zombie.deathanim = zombie get_rise_death_anim();
		zombie stopanimscripted();
	}
}

get_rise_death_anim() //checked matches cerberus output
{
	if ( self.zombie_rise_death_out )
	{
		return "zm_rise_death_out";
	}
	self.noragdoll = 1;
	self.nodeathragdoll = 1;
	return "zm_rise_death_in";
}