#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

prison_zone_changes()
{
    if(is_classic())
    {
        if(level.scr_zm_map_start_location == "prison")
        {
			// double zone
            level.zones[ "zone_cellblock_west_warden" ].adjacent_zones[ "zone_citadel_warden" ] structdelete();
            level.zones[ "zone_cellblock_west_warden" ].adjacent_zones[ "zone_citadel_warden" ] = undefined;

			level.zones[ "zone_citadel_warden" ].adjacent_zones[ "zone_cellblock_west_warden" ] structdelete();
            level.zones[ "zone_citadel_warden" ].adjacent_zones[ "zone_cellblock_west_warden" ] = undefined;

			level.zones[ "zone_cellblock_west_warden" ].adjacent_zones[ "zone_cellblock_west_barber" ] structdelete();
            level.zones[ "zone_cellblock_west_warden" ].adjacent_zones[ "zone_cellblock_west_barber" ] = undefined;
        }
    }
}