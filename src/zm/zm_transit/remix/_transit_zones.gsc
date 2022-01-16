#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

transit_zone_changes()
{
    // Outside Farm to Farm
    level.zones[ "zone_far" ].adjacent_zones[ "zone_far_ext" ] structdelete();
    level.zones[ "zone_far" ].adjacent_zones[ "zone_far_ext" ] = undefined;

    // Barn to Farm
    level.zones[ "zone_brn" ].adjacent_zones[ "zone_far_ext" ] structdelete();
    level.zones[ "zone_brn" ].adjacent_zones[ "zone_far_ext" ] = undefined;
}