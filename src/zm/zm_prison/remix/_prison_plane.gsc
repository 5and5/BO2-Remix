#include maps/mp/zombies/_zm_utility;

prison_auto_refuel_plane()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "prison"))
	{
		return;
	}

	for ( ;; )
	{
		flag_wait( "spawn_fuel_tanks" );

		wait 0.05;

		buildcraftable( "refuelable_plane" );
	}
}