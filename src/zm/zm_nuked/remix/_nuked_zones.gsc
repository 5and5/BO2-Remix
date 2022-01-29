#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zm_nuked;

remove_ground_spawns()
{ 
	foreach ( zone in level.zones )
	{
		for ( i = 0; i < zone.spawn_locations.size; i++ )
		{
            // ground spawns in spawn - only active when in backyards
			if ( zone.spawn_locations[ i ].origin == (-781.24, -77.56, -56) || 
                 zone.spawn_locations[ i ].origin == (-429.3, 821.21, -64) ||
                 zone.spawn_locations[ i ].origin == (686.78, -174.01, -56.86) ||
                 zone.spawn_locations[ i ].origin == (47.39, 965.91, -64.94) )
			{
				zone.spawn_locations[ i ].is_enabled = false;
			}
		}

    }
}

nuked_zone_changes()
{
    iprintln("zone changes");
    print("zone changes");
    // Yellow House Backyard
    level.zones[ "openhouse2_f1_zone" ].adjacent_zones[ "openhouse2_backyard_zone" ] structdelete();
    level.zones[ "openhouse2_f1_zone" ].adjacent_zones[ "openhouse2_backyard_zone" ] = undefined;

    level.zones[ "openhouse2_f2_zone" ].adjacent_zones[ "openhouse2_backyard_zone" ] structdelete();
    level.zones[ "openhouse2_f2_zone" ].adjacent_zones[ "openhouse2_backyard_zone" ] = undefined;
    
    level.zones[ "openhouse2_f1_zone" ].adjacent_zones[ "openhouse2_backyard_zone" ] structdelete();
    level.zones[ "openhouse2_f1_zone" ].adjacent_zones[ "openhouse2_backyard_zone" ] = undefined;

    // level.zones[ "culdesac_yellow_zone" ].adjacent_zones[ "culdesac_green_zone" ] structdelete();
    // level.zones[ "culdesac_yellow_zone" ].adjacent_zones[ "culdesac_green_zone" ] = undefined;

    // level.zones[ "culdesac_green_zone" ].adjacent_zones[ "culdesac_yellow_zone" ] structdelete();
    // level.zones[ "culdesac_green_zone" ].adjacent_zones[ "culdesac_yellow_zone" ] = undefined;
}

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

