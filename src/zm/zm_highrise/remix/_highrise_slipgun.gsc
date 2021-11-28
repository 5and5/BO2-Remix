#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

slipgun_always_kill()
{
	level.slipgun_damage = maps/mp/zombies/_zm::ai_zombie_health( 666 );
	level.zombie_vars["slipgun_max_kill_round"] = 666; 
}

slipgun_disable_reslip()
{
	level.zombie_vars["slipgun_reslip_rate"] = 0;
    level.zombie_vars["slipgun_reslip_max_spots"] = 0; //
}