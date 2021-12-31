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
								duration = 24;
								thread add_slippery_spot( enemy.origin, duration, startpos );
							}
						}
					}
				}
			}
		}
	}
}