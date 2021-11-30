#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

die_rise_zone_changes()
{
    if(is_classic())
    {
            // AN94 to Debris
            level.zones[ "zone_orange_level3a" ].adjacent_zones[ "zone_orange_level3b" ].is_connected = 0;

            // Trample Steam to Skyscraper
            // level.zones[ "zone_blue_level1c" ].adjacent_zones[ "zone_green_level3b" ].is_connected = 0;
            level.zones[ "zone_green_level3b" ].adjacent_zones[ "zone_blue_level1c" ] structdelete();
            level.zones[ "zone_green_level3b" ].adjacent_zones[ "zone_blue_level1c" ] = undefined;
    }
}