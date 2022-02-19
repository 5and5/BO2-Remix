#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_powerups;

max_ammo_refill_clip()
{
	level endon( "end_game" );
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "zmb_max_ammo" );
		weaps = self getweaponslist( 1 );
		foreach( weap in weaps )
		{
			self setweaponammoclip( weap, weaponclipsize( weap ) );
		}
	}
}

last_powerup_fx()
{
	level._effect["powerup_last"]					= LoadFX( "maps/zombie/fx_zombie_tesla_shock" );
	// level._effect[ "tesla_shock" ] = loadfx( "maps/zombie/fx_zombie_tesla_shock" );
	//level._effect[ "elec_md" ] = loadfx( "electrical/fx_elec_player_md" );
}

disable_carpenter()
{
	arrayremoveindex(level.zombie_include_powerups, "carpenter");
	arrayremoveindex(level.zombie_powerups, "carpenter");
	arrayremovevalue(level.zombie_powerup_array, "carpenter");
}

carpenter_repair_shield()
{
    level endon("end_game");
    self endon("disconnect");
    for(;;)
    {
        level waittill( "carpenter_finished" );
        self.shielddamagetaken = 0; 
    }
}

disable_fire_sales()
{
	level.zombie_powerups[ "fire_sale" ].func_should_drop_with_regular_powerups = ::func_should_drop_fire_sale_override;
}

func_should_drop_fire_sale_override() //checked partially changed to match cerberus output
{
	return 0; // fire sales never drop
}

// is_valid_powerup(powerup_name)
// {
// 	if( powerup_name == "carpenter" && get_num_window_destroyed() < 5 )
// 	{
// 		return false;
// 	}
// 	if( powerup_name == "fire_sale" )
// 	{
// 		return false;
// 	}
// 	return true;
// }

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

free_perk_powerup( item ) //checked changed to match cerberus output
{
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if ( !players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() && players[ i ].sessionstate != "spectator" )
		{
			player = players[ i ];
			if ( isDefined( item.ghost_powerup ) )
			{
				player maps/mp/zombies/_zm_stats::increment_client_stat( "buried_ghost_perk_acquired", 0 );
				player maps/mp/zombies/_zm_stats::increment_player_stat( "buried_ghost_perk_acquired" );
				player notify( "player_received_ghost_round_free_perk" );
			}
			free_perk = player maps/mp/zombies/_zm_perks::give_random_perk();
		}
	}
	// increase perk limit
	if ( level.perk_purchase_limit < 8 )
	{
		level.perk_purchase_limit++;
	}
}

nuke_powerup( drop_item, player_team ) //checked changed to match cerberus output
{
	location = drop_item.origin;
	playfx( drop_item.fx, location );
	level thread nuke_flash( player_team );
	wait 0.1;
	zombies = getaiarray( level.zombie_team );
	zombies = arraysort( zombies, location );
	zombies_nuked = [];
	i = 0;
	while ( i < zombies.size )
	{
		if ( is_true( zombies[ i ].ignore_nuke ) )
		{
			i++;
			continue;
		}
		if ( is_true( zombies[ i ].marked_for_death ) )
		{
			i++;
			continue;
		}
		if ( isdefined( zombies[ i ].nuke_damage_func ) )
		{
			zombies[ i ] thread [[ zombies[ i ].nuke_damage_func ]]();
			i++;
			continue;
		}
		if ( is_magic_bullet_shield_enabled( zombies[ i ] ) ) 
		{
			i++;
			continue;
		}
		zombies[ i ].marked_for_death = 1;
		//imported from bo3 _zm_powerup_nuke.gsc
		if ( !zombies[ i ].nuked && !is_magic_bullet_shield_enabled( zombies[ i ] ) )
		{
			zombies[ i ].nuked = 1;
			zombies_nuked[ zombies_nuked.size ] = zombies[ i ];
		}
		i++;
	}
	i = 0;
	while ( i < zombies_nuked.size )
	{
		wait randomfloatrange( 0.05, 0.5 );
		if ( !isdefined( zombies_nuked[ i ] ) )
		{
			i++;
			continue;
		}
		if ( is_magic_bullet_shield_enabled( zombies_nuked[ i ] ) )
		{
			i++;
			continue;
		}
		if ( i < 5 && !zombies_nuked[ i ].isdog )
		{
			zombies_nuked[ i ] thread maps/mp/animscripts/zm_death::flame_death_fx();
		}
		if ( !zombies_nuked[ i ].isdog )
		{
			if ( !is_true( zombies_nuked[ i ].no_gib ) )
			{
				zombies_nuked[ i ] maps/mp/zombies/_zm_spawner::zombie_head_gib();
			}
			zombies_nuked[ i ] playsound("evt_nuked");
		}
		zombies_nuked[ i ] dodamage(zombies_nuked[i].health + 666, zombies_nuked[ i ].origin );
		i++;
	}
	players = get_players( player_team );
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] maps/mp/zombies/_zm_score::player_add_points( "nuke_powerup", 400 );
	}
}

powerup_drop_override( drop_point ) //checked partially changed to match cerberus output
{
	if ( level.powerup_drop_count >= level.zombie_vars[ "zombie_powerup_drop_max_per_round" ] )
	{
		return;
	}
	if ( !isDefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size == 0 )
	{
		return;
	}
	rand_drop = randomint( 100 );
	if ( rand_drop > 99 ) // 2 -> 3
	{
		if ( !level.zombie_vars[ "zombie_drop_item" ] )
		{
			return;
		}
		debug = "score";
	}
	else
	{
		debug = "random";
	}
	playable_area = getentarray( "player_volume", "script_noteworthy" );
	level.powerup_drop_count++;
	powerup = maps/mp/zombies/_zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_point + vectorScale( ( 0, 0, 1 ), 40 ) );
	valid_drop = 0;
	for ( i = 0; i < playable_area.size; i++ )
	{
		if ( powerup istouching( playable_area[ i ] ) )
		{
			valid_drop = 1;
			break;
		}
	}
	if ( valid_drop && level.rare_powerups_active )
	{
		pos = ( drop_point[ 0 ], drop_point[ 1 ], drop_point[ 2 ] + 42 );
		if ( check_for_rare_drop_override( pos ) )
		{
			level.zombie_vars[ "zombie_drop_item" ] = 0;
			valid_drop = 0;
		}
	}
	if ( !valid_drop )
	{
		level.powerup_drop_count--;

		powerup delete();
		return;
	}

	// play fx on last drop of cycle
	// if( level.zombie_powerup_index == 0 )
	if( is_true(level.last_powerup) )
	{
		// playfx(level._effect[ "upgrade_aquired" ], powerup.origin);
		playfx( level._effect[ "fx_zombie_powerup_caution_wave" ], powerup.origin );
		level.last_powerup = false;
	}
	
	powerup powerup_setup();
	//print_powerup_drop( powerup.powerup_name, debug );
	powerup thread powerup_timeout();
	powerup thread powerup_wobble();
	powerup thread powerup_grab();
	powerup thread powerup_move();
	powerup thread powerup_emp();
	level.zombie_vars[ "zombie_drop_item" ] = 0;
	level notify( "powerup_dropped" );
}

get_next_powerup_override() //checked matches cerberus output
{
	powerup = level.zombie_powerup_array[ level.zombie_powerup_index ];
	level.zombie_powerup_index++;
	if ( level.zombie_powerup_index >= level.zombie_powerup_array.size )
	{
		level.last_powerup = true;
		level.zombie_powerup_index = 0;
		randomize_powerups();
	}
	return powerup;
}


insta_kill_powerup_override( drop_item, player ) //checked matches cerberus output
{
	level notify( "powerup instakill_" + player.team );
	level endon( "powerup instakill_" + player.team );
	if ( isDefined( level.insta_kill_powerup_override ) )
	{
		level thread [[ level.insta_kill_powerup_override ]]( drop_item, player );
		return;
	}
	if ( is_classic() )
	{
		player thread maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_insta_kill_upgrade_check();
	}
	team = player.team;
	level thread insta_kill_on_hud( drop_item, team );
	level.zombie_vars[ team ][ "zombie_insta_kill" ] = 1;
	wait level.zombie_vars[ team ][ "zombie_powerup_insta_kill_time" ];
	//wait 30;
	level.zombie_vars[ team ][ "zombie_insta_kill" ] = 0;
	players = get_players( team );
	i = 0;
	while ( i < players.size )
	{
		if ( isDefined( players[ i ] ) )
		{
			players[ i ] notify( "insta_kill_over" );
		}
		i++;
	}
}

insta_kill_on_hud_override( drop_item, player_team ) //checked matches cerberus output
{
	if ( level.zombie_vars[ player_team ][ "zombie_powerup_insta_kill_on" ] )
	{
		level.zombie_vars[ player_team ][ "zombie_powerup_insta_kill_time" ] += 30;
		return;
	} 
	else
	{
		level.zombie_vars[ player_team ][ "zombie_powerup_insta_kill_time" ] = 30;
	}
	level.zombie_vars[ player_team ][ "zombie_powerup_insta_kill_on" ] = 1;
	level thread time_remaning_on_insta_kill_powerup( player_team );
}

double_points_powerup_override( drop_item, player ) //checked partially matches cerberus output did not change
{
	level notify( "powerup points scaled_" + player.team );
	level endon( "powerup points scaled_" + player.team );
	team = player.team;
	level thread point_doubler_on_hud( drop_item, team );
	if ( is_true( level.pers_upgrade_double_points ) )
	{
		player thread maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_double_points_pickup_start();
	}
	if ( isDefined( level.current_game_module ) && level.current_game_module == 2 )
	{
		if ( isDefined( player._race_team ) )
		{
			if ( player._race_team == 1 )
			{
				level._race_team_double_points = 1;
			}
			else
			{
				level._race_team_double_points = 2;
			}
		}
	}
	level.zombie_vars[ team ][ "zombie_point_scalar" ] = 2;
	players = get_players();
	for ( player_index = 0; player_index < players.size; player_index++ )
	{
		if ( team == players[ player_index ].team )
		{
			players[ player_index ] setclientfield( "score_cf_double_points_active", 1 );
		}
	}
	//wait 30;
	wait level.zombie_vars[ team ][ "zombie_powerup_point_doubler_time" ];
	level.zombie_vars[ team ][ "zombie_point_scalar" ] = 1;
	level._race_team_double_points = undefined;
	players = get_players();
	for ( player_index = 0; player_index < players.size; player_index++ )
	{
		if ( team == players[ player_index ].team )
		{
			players[ player_index ] setclientfield( "score_cf_double_points_active", 0 );
		}
	}
}

point_doubler_on_hud_override( drop_item, player_team ) //checked matches cerberus output
{
	self endon( "disconnect" );
	if ( level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_on" ] )
	{
		level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_time" ] += 30;
		return;
	}
	else
	{
		level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_time" ] = 30;
	}
	level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_on" ] = 1;
	level thread time_remaining_on_point_doubler_powerup( player_team );
}