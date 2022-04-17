#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_craftables;

#include scripts/zm/remix/_buildables;

prison_plane_set_need_all_pieces()
{
	level.zombie_craftablestubs["plane"].need_all_pieces = 1;
	level.zombie_craftablestubs["refuelable_plane"].need_all_pieces = 1;
}

prison_plane_set_pieces_shared()
{
	foreach(stub in level.zombie_include_craftables)
	{
		if(stub.name == "plane" || stub.name == "refuelable_plane")
		{
			foreach(piece in stub.a_piecestubs)
			{
				piece.is_shared = 1;
				piece.client_field_state = undefined;
			}
		}
	}
}

prison_auto_refuel_plane()
{
	for ( ;; )
	{
		flag_wait( "spawn_fuel_tanks" );

		wait 0.05;

		buildcraftable( "refuelable_plane" );
	}
}