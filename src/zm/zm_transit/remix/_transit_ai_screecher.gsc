#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/_utility;
#include maps/mp/zm_transit_ai_screecher;
#include maps/mp/zombies/_zm_ai_screecher;

disable_screechers()
{
	level.is_player_in_screecher_zone = ::is_player_in_screencher_zone;
}

is_player_in_screencher_zone()
{
	return 0;
}

spawn_lightpost_portals()
{
	level.screecher_cleanup = undefined;

	portals = getstructarray( "screecher_escape", "targetname" );
	foreach ( portal in portals )
	{
		portal thread create_portals();
	}
}

create_portals()
{
	ground_pos = groundpos( self.origin );
	if ( !isDefined( self.hole ) )
	{
		self.hole = spawn( "script_model", ground_pos);
		self.hole.start_origin = self.hole.origin;
		self.hole setmodel( "p6_zm_screecher_hole" );
		self.hole playsound( "zmb_screecher_portal_spawn" );
	}
	if ( !isDefined( self.hole_fx ) )
	{
		self.hole_fx = spawn( "script_model", ground_pos );
		self.hole_fx setmodel( "tag_origin" );
	}
	wait 0.1;
	playfxontag( level._effect[ "screecher_hole" ], self.hole_fx, "tag_origin" );
	self thread portal_think();
}

portal_think()
{
	wait 1;
	playfxontag( level._effect[ "screecher_vortex" ], self.hole, "tag_origin" );
	self.hole_fx delete();
	self.hole playloopsound( "zmb_screecher_portal_loop", 2 );
	level.portals[ level.portals.size ] = self;
}

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

player_wait_land()
{
	self endon( "disconnect" );
	while ( !self isonground() )
	{
		wait 0.1;
	}
	if ( level.portals.size > 0 )
	{
		use_portal = undefined;
		_a159 = level.portals;
		_k159 = getFirstArrayKey( _a159 );
		while ( isDefined( _k159 ) )
		{
			portal = _a159[ _k159 ];
			dist_sq = distance2dsquared( self.origin, portal.origin );
			if ( dist_sq < 4096 )
			{
				use_portal = 1;
				break;
			}
			else
			{
				_k159 = getNextArrayKey( _a159, _k159 );
			}
		}
		if ( isDefined( use_portal ) )
		{
			portal portal_use( self );
			wait 0.5;
		}
	}
}

portal_use( player )
{
	player playsoundtoplayer( "zmb_screecher_portal_warp_2d", player );
	self thread teleport_player( player );
	playsoundatposition( "zmb_screecher_portal_end", self.hole.origin );
}
