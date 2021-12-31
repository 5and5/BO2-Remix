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

slipgun_zombie_death_response_override() //checked matches cerberus output
{
	if ( !is_slipgun_explosive_damage_custom( self.damagemod ) )
	{
		return 0;
	}
	level maps/mp/zombies/_zm_spawner::zombie_death_points( self.origin, self.damagemod, self.damagelocation, self.attacker, self );
	self explode_into_goo( self.attacker, 0 );
	return 1;
}

is_slipgun_explosive_damage_custom( damagemod )
{
	if ( damagemod == "MOD_PROJECTILE_SPLASH" )
	{
		return 1;
	}
	return 0;
}