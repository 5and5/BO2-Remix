#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zm_tomb_dig;

tomb_give_shovel()
{
	flag_wait( "start_zombie_round_logic" );
	self.dig_vars[ "has_shovel" ] = 1;
	n_player = self getentitynumber() + 1;
	level setclientfield( "shovel_player" + n_player, 1 );
}

tomb_remove_shovels_from_map()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	flag_wait( "initial_blackscreen_passed" );

	stubs = level._unitriggers.trigger_stubs;
	for(i = 0; i < stubs.size; i++)
	{
		stub = stubs[i];
		if(IsDefined(stub.e_shovel))
		{
			stub.e_shovel delete();
			maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
		}
	}
}

tomb_zombie_blood_dig_changes()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	while (1)
	{
		for (i = 0; i < level.a_zombie_blood_entities.size; i++)
		{
			ent = level.a_zombie_blood_entities[i];
			if (IsDefined(ent.e_unique_player))
			{
				if (!isDefined(ent.e_unique_player.initial_zombie_blood_dig))
				{
					ent.e_unique_player.initial_zombie_blood_dig = 0;
				}

				ent.e_unique_player.initial_zombie_blood_dig++;
				if (ent.e_unique_player.initial_zombie_blood_dig <= 2)
				{
					ent setvisibletoplayer(ent.e_unique_player);
				}
				else
				{
					ent thread set_visible_after_rounds(ent.e_unique_player, 1);
				}

				arrayremovevalue(level.a_zombie_blood_entities, ent);
			}
		}

		wait .5;
	}
}

set_visible_after_rounds(player, num)
{
	for (i = 0; i < num; i++)
	{
		level waittill( "end_of_round" );
	}

	self setvisibletoplayer(player);
}


/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

make_zombie_blood_entity()
{
	level.a_zombie_blood_entities[ level.a_zombie_blood_entities.size ] = self;
	self setinvisibletoall();
	_a196 = getplayers();
	_k196 = getFirstArrayKey( _a196 );
	while ( isDefined( _k196 ) )
	{
		e_player = _a196[ _k196 ];
		if ( isDefined( self.e_unique_player ) )
		{
			if ( self.e_unique_player == e_player )
			{
				self setvisibletoplayer( e_player );
			}
			break;
		}
		_k196 = getNextArrayKey( _a196, _k196 );
	}
}

waittill_dug( s_dig_spot ) //checked changed to match cerberus output
{
	last_dig_powerup = 0;

	while ( 1 )
	{
		self waittill( "trigger", player );
		if ( is_true( player.dig_vars[ "has_shovel" ] ) )
		{
			player playsound( "evt_dig" );
			s_dig_spot.dug = 1;
			level.n_dig_spots_cur--;

			playfx( level._effect[ "digging" ], self.origin );
			player setclientfieldtoplayer( "player_rumble_and_shake", 1 );
			player maps/mp/zombies/_zm_stats::increment_client_stat( "tomb_dig", 0 );
			player maps/mp/zombies/_zm_stats::increment_player_stat( "tomb_dig" );
			s_staff_piece = s_dig_spot maps/mp/zm_tomb_main_quest::dig_spot_get_staff_piece( player );
			if ( isDefined( s_staff_piece ) )
			{
				s_staff_piece maps/mp/zm_tomb_main_quest::show_ice_staff_piece( self.origin );
				player dig_reward_dialog( "dig_staff_part" );
			}
			else 
			{
				n_good_chance = 50;
				if ( player.dig_vars[ "n_spots_dug" ] == 0 || player.dig_vars[ "n_losing_streak" ] == 3 )
				{
					player.dig_vars[ "n_losing_streak" ] = 0;
					n_good_chance = 100;
				}
				if ( player.dig_vars[ "has_upgraded_shovel" ] )
				{
					if ( !player.dig_vars[ "has_helmet" ] )
					{
						n_helmet_roll = randomint( 100 );
						if ( n_helmet_roll >= 80 )
						{
							player.dig_vars[ "has_helmet" ] = 1;
							n_player = player getentitynumber() + 1;
							level setclientfield( "helmet_player" + n_player, 1 );
							player playsoundtoplayer( "zmb_squest_golden_anything", player );
							player maps/mp/zombies/_zm_stats::increment_client_stat( "tomb_golden_hard_hat", 0 );
							player maps/mp/zombies/_zm_stats::increment_player_stat( "tomb_golden_hard_hat" );
							return;
						}
					}
					n_good_chance = 70;
				}
				n_prize_roll = randomint( 100 );
				if ( n_prize_roll > n_good_chance )
				{
					if ( cointoss() )
					{
						player dig_reward_dialog( "dig_grenade" );
						self thread dig_up_grenade( player );
					}
					else
					{
						player dig_reward_dialog( "dig_zombie" );
						self thread dig_up_zombie( player, s_dig_spot );
					}
					player.dig_vars[ "n_losing_streak" ]++;
				}
				else if ( cointoss() && !last_dig_powerup )
				{
					self thread dig_up_powerup( player );
					last_dig_powerup = 1;
				}
				else
				{
					player dig_reward_dialog( "dig_gun" );
					self thread dig_up_weapon( player );
					last_dig_powerup = 0;
				}
			}
			if ( !player.dig_vars[ "has_upgraded_shovel" ] )
			{
				player.dig_vars[ "n_spots_dug" ]++;
				if ( player.dig_vars[ "n_spots_dug" ] >= 5 )
				{
					player.dig_vars[ "has_upgraded_shovel" ] = 1;
					player thread ee_zombie_blood_dig();
					n_player = player getentitynumber() + 1;
					level setclientfield( "shovel_player" + n_player, 2 );
					player playsoundtoplayer( "zmb_squest_golden_anything", player );
					player maps/mp/zombies/_zm_stats::increment_client_stat( "tomb_golden_shovel", 0 );
					player maps/mp/zombies/_zm_stats::increment_player_stat( "tomb_golden_shovel" );
				}
			}
			return;
		}
	}
}

dig_up_powerup( player ) //checked changed to match cerberus output
{
	powerup = spawn( "script_model", self.origin );
	powerup endon( "powerup_grabbed" );
	powerup endon( "powerup_timedout" );
	a_rare_powerups = dig_get_rare_powerups( player );
	powerup_item = undefined;

	powerup_item = a_rare_powerups[ randomint( a_rare_powerups.size ) ];
	level.dig_n_powerups_spawned++;
	player dig_reward_dialog( "dig_powerup" );
	dig_set_powerup_spawned( powerup_item );

	powerup maps/mp/zombies/_zm_powerups::powerup_setup( powerup_item );
	powerup movez( 40, 0.6 );
	powerup waittill( "movedone" );
	powerup thread maps/mp/zombies/_zm_powerups::powerup_timeout();
	powerup thread maps/mp/zombies/_zm_powerups::powerup_wobble();
	powerup thread maps/mp/zombies/_zm_powerups::powerup_grab();
}

dig_get_rare_powerups( player ) //checked changed to match cerberus output
{
	a_rare_powerups = [];
	a_possible_powerups = array( "nuke", "double_points", "insta_kill" );
	if ( player.dig_vars[ "has_upgraded_shovel" ] )
	{
		a_possible_powerups = combinearrays( a_possible_powerups, array( "full_ammo" ) );
	}
	foreach ( powerup in a_possible_powerups )
	{
		if ( !dig_has_powerup_spawned( powerup ) )
		{
			a_rare_powerups[ a_rare_powerups.size ] = powerup;
		}
	}
	return a_rare_powerups;
}

