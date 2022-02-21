#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_zonemgr;


buried_zone_changes()
{
    if(is_classic())
    {
        // nerf jug zone
        add_adjacent_zone( "zone_street_lightwest_alley", "zone_underground_jail", "jail_jugg" );
        add_adjacent_zone( "zone_street_lightwest_alley", "zone_underground_jail2", "jail_jugg" );
        add_adjacent_zone( "zone_morgue_upstairs", "zone_street_lightwest_alley", "jail_jugg" ); 
        // level.zones[ "zone_street_lightwest_alley" ].adjacent_zones[ "zone_citadel_warden" ] structdelete();
        // level.zones[ "zone_street_lightwest_alley" ].adjacent_zones[ "zone_citadel_warden" ] = undefined;
    }
}