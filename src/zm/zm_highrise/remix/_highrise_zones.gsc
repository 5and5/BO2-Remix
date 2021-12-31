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

patch_shaft()
{
	origin = ( 3709.89, 1967.07, 2176.7 );
	length = 210;
	width = 120;
	height = 45;
	trig1 = spawn( "trigger_box", origin, 0, length, width, height );
	trig1.angles = ( 0, 0, 0 );
	trig1.targetname = "push_from_prone";
	trig1.push_player_towards_point = ( 3709.89, 2100, 2176.7 );
	while ( 1 )
	{
		trig1 waittill( "trigger", who );
		if ( who getstance() == "prone" && isplayer( who ) )
		{
			who setstance( "crouch" );
		}
		trig1 thread slide_push_think( who );
		wait 0.1;
	}
}

slide_push_think( who )
{
	while ( who istouching( self ) )
	{
		who setvelocity( self get_push_vector() );
		wait 2;
	}
}

get_push_vector()
{
	return vectornormalize( self.push_player_towards_point - self.origin ) * 700;
}