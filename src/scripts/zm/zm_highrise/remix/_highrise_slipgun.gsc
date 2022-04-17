#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_weap_slipgun;

slipgun_always_kill()
{
	level.slipgun_damage = maps/mp/zombies/_zm::ai_zombie_health( 255 );
	level.zombie_vars["slipgun_max_kill_round"] = 255;
}

slipgun_disable_reslip()
{
	level.zombie_vars["slipgun_reslip_rate"] = 0;
    level.zombie_vars["slipgun_reslip_max_spots"] = 0;
}

slipgun_kills_while_away()
{
	maps/mp/zombies/_zm_spawner::register_zombie_death_animscript_callback( ::slipgun_zombie_death_response_override );
}

is_slipgun_explosive_damage_custom( damagemod, damageweapon )
{
	if ( is_true(self.slipgun_marked) && damagemod == "MOD_PROJECTILE_SPLASH" )
	{
		return 1;
	}
	return 0;
}

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

slip_bolt( player, upgraded ) //checked matches cerberus output
{
	startpos = player getweaponmuzzlepoint();
	self waittill( "explode", position );
	duration = 15; //24;
	thread add_slippery_spot( position, duration, startpos );
}

slipgun_zombie_death_response_override() //checked matches cerberus output
{
	if ( !self is_slipgun_explosive_damage_custom( self.damagemod, self.damageweapon ) )
	{
		return 0;
	}
	level maps/mp/zombies/_zm_spawner::zombie_death_points( self.origin, self.damagemod, self.damagelocation, self.attacker, self );
	self explode_into_goo( self.attacker, 0 );
	return 1;
}

explode_to_near_zombies_override( player, origin, radius, chain_depth ) //checked partially changed to match cerberus output changed at own discretion
{
	if ( level.zombie_vars[ "slipgun_max_kill_chain_depth" ] > 0 && chain_depth > level.zombie_vars[ "slipgun_max_kill_chain_depth" ] )
	{
		return;
	}
	enemies = get_round_enemy_array();
	enemies = get_array_of_closest( origin, enemies );
	minchainwait = level.zombie_vars[ "slipgun_chain_wait_min" ];
	maxchainwait = level.zombie_vars[ "slipgun_chain_wait_max" ];
	rsquared = radius * radius;
	tag = "J_Head";
	marked_zombies = [];
	if ( isDefined( enemies ) && enemies.size )
	{
		index = 0;
		enemy = enemies[ index ];
		while ( distancesquared( enemy.origin, origin ) < rsquared )
		{
			if ( isalive( enemy ) && !is_true( enemy.guts_explosion ) && !is_true( enemy.nuked ) && !isDefined( enemy.slipgun_sizzle ) )
			{
				trace = bullettrace( origin + vectorScale( ( 0, 0, 1 ), 50 ), enemy.origin + vectorScale( ( 0, 0, 1 ), 50 ), 0, undefined, 1 );
				if ( isDefined( trace[ "fraction" ] ) && trace[ "fraction" ] == 1 )
				{
					enemy.slipgun_sizzle = playfxontag( level._effect[ "slipgun_simmer" ], enemy, tag );
					enemy.slipgun_marked = 1;
					marked_zombies[ marked_zombies.size ] = enemy;
				}
			}
			index++;
			if ( index >= enemies.size )
			{
				break;
			}
			else
			{
				enemy = enemies[ index ];
			}
		}
	}
	if ( isDefined( marked_zombies ) && marked_zombies.size )
	{
		foreach(enemy in marked_zombies)
		{
			if ( isalive( enemy ) && !is_true( enemy.guts_explosion ) && !is_true( enemy.nuked ) )
			{
				wait randomfloatrange( minchainwait, maxchainwait );
				if ( isalive( enemy ) && !is_true( enemy.guts_explosion ) && !is_true( enemy.nuked ) )
				{
					if ( !isDefined( enemy.goo_chain_depth ) )
					{
						enemy.goo_chain_depth = chain_depth;
					}
					if ( enemy.health > 0 )
					{
						if ( player maps/mp/zombies/_zm_powerups::is_insta_kill_active() )
						{
							enemy.health = 1;
						}
						enemy dodamage( level.slipgun_damage, origin, player, player, "none", level.slipgun_damage_mod, 0, "slip_goo_zm" );
					}
					if ( level.slippery_spot_count < level.zombie_vars[ "slipgun_reslip_max_spots" ] )
					{
						if ( isDefined( enemy.slick_count ) && enemy.slick_count == 0 && enemy.health <= 0 )
						{
							if ( level.zombie_vars[ "slipgun_reslip_rate" ] > 0 && randomint( level.zombie_vars[ "slipgun_reslip_rate" ] ) == 0 )
							{
								startpos = origin;
								duration = 15;
								thread add_slippery_spot( enemy.origin, duration, startpos );
							}
						}
					}
				}
			}
		}
	}
}

pool_of_goo( origin, duration ) //checked matches cerberus output
{
	// iPrintLn(duration);
	// goo = spawn( "script_model", origin );
	// effect_life = 15;
	// if ( duration > effect_life )
	// {
	// 	pool_of_goo( origin, duration - effect_life );
	// 	duration = effect_life;
	// }
	if ( isDefined( level._effect[ "slipgun_splatter" ] ) )
	{
		// playfx( level._effect[ "slipgun_splatter" ], origin );
		// playfxontag( level._effect[ "slipgun_splatter" ], goo, "tag_origin" );
	}
	wait duration;
	// goo delete();
}

add_slippery_spot( origin, duration, startpos ) //checked partially changed to match cerberus output
{
	// wait 0.5;
	// level.slippery_spot_count++;
	// hit_norm = vectornormalize( startpos - origin );
	// hit_from = 6 * hit_norm;
	// trace_height = 120;
	// trace = bullettrace( origin + hit_from, origin + hit_from + ( 0, 0, trace_height * -1 ), 0, undefined );
	// if ( isDefined( trace[ "entity" ] ) )
	// {
	// 	parent = trace[ "entity" ];
	// 	if ( is_true( parent.can_move ) )
	// 	{
	// 		return;
	// 	}
	// }
	// fxorigin = origin + hit_from;
	// if ( trace[ "fraction" ] == 1 )
	// {
	// 	return;
	// }
	// moving_parent = undefined;
	// moving_parent_start = ( 0, 0, 1 );
	// if ( isDefined( trace[ "entity" ] ) )
	// {
	// 	parent = trace[ "entity" ];
	// 	if ( is_true( parent.can_move ) )
	// 	{
	// 		return;
	// 	}
	// }
	// origin = trace[ "position" ];
	// thread pool_of_goo( fxorigin, duration );
	// if ( !isDefined( level.slippery_spots ) )
	// {
	// 	level.slippery_spots = [];
	// }
	// level.slippery_spots[ level.slippery_spots.size ] = origin;
	// radius = 60;
	// height = 48;
	// slicked_players = [];
	// slicked_zombies = [];
	// lifetime = duration;
	// radius2 = radius * radius;
	// while ( lifetime > 0 )
	// {
	// 	oldlifetime = lifetime;
	// 	foreach ( player in get_players() )
	// 	{
	// 		num = player getentitynumber();
	// 		morigin = origin;
	// 		if ( isDefined( moving_parent ) )
	// 		{
	// 			morigin = origin + ( moving_parent.origin - moving_parent_start );
	// 		}
	// 		if ( distance2dsquared( player.origin, morigin ) < radius2 && abs( player.origin[ 2 ] - morigin[ 2 ] ) < height )
	// 		{
	// 			should_be_slick = 1;
	// 		}
	// 		else
	// 		{
	// 			should_be_slick = 0;
	// 		}
	// 		is_slick = isDefined( slicked_players[ num ] );
	// 		if ( should_be_slick != is_slick )
	// 		{
	// 			if ( !isDefined( player.slick_count ) )
	// 			{
	// 				player.slick_count = 0;
	// 			}
	// 			if ( should_be_slick )
	// 			{
	// 				player.slick_count++;
	// 				slicked_players[ num ] = player;
	// 			}
	// 			else
	// 			{
	// 				player.slick_count--;
	// 				slicked_players[ num ] = undefined;
	// 			}
	// 			player forceslick( player.slick_count );
	// 		}
	// 		lifetime = slippery_spot_choke( lifetime );
	// 	}
	// 	zombies = get_round_enemy_array();
	// 	if ( isDefined( zombies ) )
	// 	{
	// 		foreach ( zombie in zombies )
	// 		{
	// 			if ( isDefined( zombie ) )
	// 			{
	// 				num = zombie getentitynumber();
	// 				morigin = origin;
	// 				if ( isDefined( moving_parent ) )
	// 				{
	// 					morigin = origin + ( moving_parent.origin - moving_parent_start );
	// 				}
	// 				if ( distance2dsquared( zombie.origin, morigin ) < radius2 && abs( zombie.origin[ 2 ] - morigin[ 2 ] ) < height )
	// 				{
	// 					should_be_slick = 1;
	// 				}
	// 				else
	// 				{
	// 					should_be_slick = 0;
	// 				}
	// 				if ( should_be_slick && !zombie zombie_can_slip() )
	// 				{
	// 					should_be_slick = 0;
	// 				}
	// 				is_slick = isDefined( slicked_zombies[ num ] );
	// 				if ( should_be_slick != is_slick )
	// 				{
	// 					if ( !isDefined( zombie.slick_count ) )
	// 					{
	// 						zombie.slick_count = 0;
	// 					}
	// 					if ( should_be_slick )
	// 					{
	// 						zombie.slick_count++;
	// 						slicked_zombies[ num ] = zombie;
	// 					}
	// 					else if ( zombie.slick_count > 0 )
	// 					{
	// 						zombie.slick_count--;

	// 					}
	// 					zombie zombie_set_slipping( zombie.slick_count > 0 );
	// 				}
	// 				lifetime = slippery_spot_choke( lifetime );
	// 			}
	// 		}
	// 	}
	// 	else if ( oldlifetime == lifetime )
	// 	{
	// 		lifetime -= 0.05;
	// 		wait 0.05;
	// 	}
	// }
	// foreach ( player in slicked_players )
	// {
	// 	player.slick_count--;
	// 	player forceslick( player.slick_count );
	// }
	// foreach ( zombie in slicked_zombies )
	// {
	// 	if ( isDefined( zombie ) )
	// 	{
	// 		if ( zombie.slick_count > 0 )
	// 		{
	// 			zombie.slick_count--;

	// 		}
	// 		zombie zombie_set_slipping( zombie.slick_count > 0 );
	// 	}
	// }
	// arrayremovevalue( level.slippery_spots, origin, 0 );
	// level.slippery_spot_count--;
}