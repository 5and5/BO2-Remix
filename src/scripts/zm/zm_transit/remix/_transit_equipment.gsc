#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

#include scripts/zm/remix/_utility;

turret_buff()
{
	level.equipment_turret_needs_power = 0;
}

electric_trap_buff()
{
    level.equipment_etrap_needs_power = 0;
    level.etrap_damage = maps/mp/zombies/_zm::ai_zombie_health( 255 );
}

transit_no_power()
{
    create_dvar( "no_power", 0 );
    if( !getDvarInt( "no_power" ) )
        return;

    iPrintLn("No Power");
    if ( level.scr_zm_map_start_location == "transit" && is_classic() )
    {
        level.zombie_include_buildables[ "jetgun_zm" ].triggerthink = ::nullptr;
    }
    level.zombie_include_buildables[ "turbine" ].triggerthink = ::nullptr;
}

nullptr()
{

}