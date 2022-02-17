#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

turret_buff()
{
	level.equipment_turret_needs_power = 0;
}

electric_trap_buff()
{
    level.equipment_etrap_needs_power = 0;
    level.etrap_damage = maps/mp/zombies/_zm::ai_zombie_health( 255 );
}