#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_ai_faller;
#include maps\mp\zm_highrise_elevators;
#include maps\mp\zm_highrise_buildables;
#include maps\mp\zombies\_zm_buildables;


give_elevator_key()
{
    level endon("end_game");
    self endon("disconnect");

    for(;;)
    {
        if (isDefined(self maps/mp/zombies/_zm_buildables::player_get_buildable_piece()) && self maps/mp/zombies/_zm_buildables::player_get_buildable_piece() == "keys_zm")
        {
            wait 1;
        }
        else
        {
            candidate_list = [];
            foreach (zone in level.zones)
            {
                if (isDefined(zone.unitrigger_stubs))
                {
                    candidate_list = arraycombine(candidate_list, zone.unitrigger_stubs, 1, 0);
                }
            }
            foreach (stub in candidate_list)
            {
                if (isDefined(stub.piece) && stub.piece.buildablename == "keys_zm")
                {
                    self thread maps/mp/zombies/_zm_buildables::player_take_piece(stub.piece);
                    break;
                }
            }
        }
        wait 1;
    }
}

elevator_key_on_use_override()
{
	level.zombie_include_buildables[ "ekeys_zm" ].onuseplantobject = ::onuseplantobject_elevatorkey;
	level.zombie_include_buildables[ "ekeys_zm" ].triggerthink = ::ekeysbuildable;
}

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

onuseplantobject_elevatorkey( player )
{
	elevatorname = self.script_noteworthy;
	if ( isDefined( elevatorname ) && isDefined( self.script_parameters ) )
	{
		floor = int( self.script_parameters );
		elevator = level.elevators[ elevatorname ];

		if ( !isDefined(elevator.body.elevator_stop) )
		{
			elevator.body.elevator_stop = 0;
		}
		if ( int(elevator.body.current_level) == int(floor + 1) )
		{
			elevator.body.elevator_stop = !elevator.body.elevator_stop;
		}
		else if ( isDefined( elevator ) )
		{
			elevator.body.elevator_stop = 0;
			elevator.body.force_starting_floor = floor;
			elevator.body notify( "forcego" );
		}
	}
}

ekeysbuildable()
{
	elevator_keys = maps/mp/zombies/_zm_buildables::buildable_trigger_think_array( "elevator_key_console_trigger", "ekeys_zm", "keys_zm", "", 1, 3 );
	_a143 = elevator_keys;
	_k143 = getFirstArrayKey( _a143 );
	while ( isDefined( _k143 ) )
	{
		stub = _a143[ _k143 ];
		stub.prompt_and_visibility_func = ::elevator_key_prompt;
		stub.buildablezone.stat_name = "keys_zm";
		_k143 = getNextArrayKey( _a143, _k143 );
	}
}

elevator_key_prompt( player )
{
	if ( !isDefined( self.stub.elevator ) )
	{
		elevatorname = self.stub.script_noteworthy;
		if ( isDefined( elevatorname ) && isDefined( self.stub.script_parameters ) )
		{
			elevator = level.elevators[ elevatorname ];
			floor = int( self.stub.script_parameters );
			flevel = elevator maps/mp/zm_highrise_elevators::elevator_level_for_floor( floor );
			self.stub.elevator = elevator;
			self.stub.floor = flevel;
		}
	}
	// if ( isDefined( self.stub.elevator ) )
	// {
	// 	if ( self.stub.elevator maps/mp/zm_highrise_elevators::elevator_is_on_floor( self.stub.floor ) )
	// 	{
	// 		self.stub.hint_string = "";
	// 		self sethintstring( self.stub.hint_string );
	// 		return 0;
	// 	}
	// }
	if ( !flag( "power_on" ) )
	{
		self.stub.hint_string = "";
		self sethintstring( self.stub.hint_string );
		return 0;
	}
	can_use = self buildabletrigger_update_prompt( player );
	if ( can_use )
	{
		thread watch_elevator_prompt( player, self );
	}
	return can_use;
}

elevator_depart_early( elevator )
{
	touchent = elevator.body;
	if ( isDefined( elevator.body.trig ) )
	{
		touchent = elevator.body.trig;
	}
	while ( 1 )
	{
		while ( is_true( elevator.body.is_moving ) )
		{
			wait 0.5;
		}
		someone_touching_elevator = 0;
		players = get_players();
		_a1321 = players;
		_k1321 = getFirstArrayKey( _a1321 );
		while ( isDefined( _k1321 ) )
		{
			player = _a1321[ _k1321 ];
			if ( player istouching( touchent ) )
			{
				someone_touching_elevator = 1;
			}
			_k1321 = getNextArrayKey( _a1321, _k1321 );
		}
		if ( is_true( someone_touching_elevator ) )
		{
			someone_still_touching_elevator = 0;
			wait 2;
			players = get_players();
			_a1336 = players;
			_k1336 = getFirstArrayKey( _a1336 );
			while ( isDefined( _k1336 ) )
			{
				player = _a1336[ _k1336 ];
				if ( player istouching( touchent ) )
				{
					someone_still_touching_elevator = 1;
				}
				_k1336 = getNextArrayKey( _a1336, _k1336 );
			}
			if ( is_true( someone_still_touching_elevator ) )
			{
				elevator.body.departing_early = 1;
				elevator.body.elevator_stop = 0;
				elevator.body notify( "depart_early" );
				wait 3;
				elevator.body.departing_early = 0;
			}
		}
		wait 1;
	}
}

elev_remove_corpses_override()
{
	// playfx( level._effect[ "zomb_gib" ], self.origin );
	self delete();
}

do_zombie_emerge_override( spot ) //checked changed to match cerberus output
{
	self endon( "death" );
	self thread setup_deathfunc( ::faller_death_ragdoll );
	self.no_powerups = 1;
	self.in_the_ceiling = 1;
	anim_org = spot.origin;
	anim_ang = spot.angles;
	self thread zombie_emerge_fx( spot );
	self thread zombie_faller_death_wait( "risen" );
	self thread watch_for_elevator_during_faller_spawn_custom();
	self zombie_faller_emerge( spot );
	self.create_eyes = 1;
	wait 0.1;
	self notify( "risen", spot.script_string );
	self zombie_faller_enable_location();
}

watch_for_elevator_during_faller_spawn_custom()
{
	self endon( "death" );
	self endon( "risen" );
	self endon( "spawn_anim" );

	if( !isDefined(level.elevator_kills) )
	{
		level.elevator_kills = 0;
	}
	while ( 1 )
	{
		should_gib = 0;
		_a1531 = level.elevators;
		_k1531 = getFirstArrayKey( _a1531 );
		while ( isDefined( _k1531 ) )
		{
			elevator = _a1531[ _k1531 ];
			if ( self istouching( elevator.body ) )
			{
				should_gib = 1;
			}
			_k1531 = getNextArrayKey( _a1531, _k1531 );
		}
		if ( should_gib )
		{
			playfx( level._effect[ "zomb_gib" ], self.origin );
			if ( isDefined( self.has_been_damaged_by_player ) && !self.has_been_damaged_by_player && isDefined( self.is_leaper ) && !self.is_leaper )
			{
				level.zombie_total++;
			}
			if ( isDefined( self.is_leaper ) && self.is_leaper )
			{
				self maps/mp/zombies/_zm_ai_leaper::leaper_cleanup();
				self dodamage( self.health + 100, self.origin );
			}
			else
			{
				// level.elevator_kills++;
				// iPrintLn("Elevator kills: " + level.elevator_kills);
				// self.deathanim = "zm_death";
                self dodamage( self.health + 100, self.origin );
				// self delete();
			}
			return;
		}
		else
		{
			wait 0.1;
		}
	}
}