#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

#include scripts/zm/remix/_buildables;

prison_auto_refuel_plane()
{

	for ( ;; )
	{
		flag_wait( "spawn_fuel_tanks" );

		wait 0.05;

		buildcraftable( "refuelable_plane" );
	}
}