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
    self endon("disconnect");

    for(;;)
    {
        if (isDefined(self maps/mp/zombies/_zm_buildables::player_get_buildable_piece()) && self maps/mp/zombies/_zm_buildables::player_get_buildable_piece() == "keys_zm")
        {
            wait 20;
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
	can_use = self pooledbuildabletrigger_update_prompt( player );
	// buildablestub_update_prompt
	if ( can_use )
	{
		thread watch_elevator_prompt( player, self );
	}
	return can_use;
}

onuseplantobject_elevatorkey( player )
{
	elevatorname = self.script_noteworthy;
	if ( isDefined( elevatorname ) && isDefined( self.script_parameters ) )
	{
		floor = int( self.script_parameters );
		elevator = level.elevators[ elevatorname ];
		// iPrintLn("floor: " + floor);
		// iPrintLn("current: " + elevator.body.current_level);
		if( isDefined( elevator ) ) 
		{
			if ( !isDefined(elevator.body.elevator_stop) )
			{
				elevator.body.elevator_stop = 0;
			}

			if ( self.buildables_available_index == 0 )
			{
				elevator.body.elevator_stop = 0;
				elevator.body.force_starting_floor = floor;
				elevator.body notify( "forcego" );
			}
			else if ( self.buildables_available_index == 1 )
			{
				if ( floor == 0 || floor == 1 || floor == 2 )
				{
					floor = floor + 1;
				}
				else if ( floor == 5 || floor == 4 || floor == 3)
				{
					floor = floor - 1;
				}
				elevator.body.elevator_stop = 0;
				elevator.body.force_starting_floor = floor;
				elevator.body notify( "forcego" );
			}
			else if ( self.buildables_available_index == 2 )
			{
				elevator.body.elevator_stop = 0;
			}
			else if ( self.buildables_available_index == 3 )
			{
				elevator.body.elevator_stop = 0;
				elevator.body.force_starting_floor = 3;
				elevator.body notify( "forcego" );
				elevator.body.elevator_stop = 1;
			}
		}
	}
}

pooledbuildabletrigger_update_prompt( player )
{
	can_use = self.stub pooledbuildablestub_update_prompt( player, self );
	self sethintstring( self.stub.hint_string );
	if ( isDefined( self.stub.cursor_hint ) )
	{
		if ( self.stub.cursor_hint == "HINT_WEAPON" && isDefined( self.stub.cursor_hint_weapon ) )
		{
			self setcursorhint( self.stub.cursor_hint, self.stub.cursor_hint_weapon );
		}
		else
		{
			self setcursorhint( self.stub.cursor_hint );
		}
	}
	return can_use;
}

pooledbuildablestub_update_prompt( player, trigger ) //checked changed to match cerberus output
{
	if ( !self anystub_update_prompt( player ) )
	{
		return 0;
	}
	can_use = 1;
	if ( isDefined( self.buildablestub_reject_func ) )
	{
		rval = self [[ self.buildablestub_reject_func ]]( player );
		if ( rval )
		{
			return 0;
		}
	}
	if ( isDefined( self.custom_buildablestub_update_prompt ) && !self [[ self.custom_buildablestub_update_prompt ]]( player ) )
	{
		return 0;
	}
	self.cursor_hint = "HINT_NOICON";
	self.cursor_hint_weapon = undefined;
	if ( isDefined( self.built ) && !self.built )
	{
		self thread choose_buildable(player);
		slot = self.buildablestruct.buildable_slot;
		if ( !isDefined( player player_get_buildable_piece( slot ) ) )
		{
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint_more ) )
			{
				self.hint_string = level.zombie_buildables[ self.equipname ].hint_more;
			}
			else
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";
			}
			return 0;
		}
		else if ( !self.buildablezone buildable_has_piece( player player_get_buildable_piece( slot ) ) )
		{
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint_wrong ) )
			{
				self.hint_string = level.zombie_buildables[ self.equipname ].hint_wrong;
			}
			else
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
			}
			return 0;
		}
		else
		{
			/*
		/#
			assert( isDefined( level.zombie_buildables[ self.equipname ].hint ), "Missing buildable hint" );
		#/
			*/
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint ) )
			{
				self.hint_string = "Hold ^3&&1^7 to call the perk";//level.zombie_buildables[ self.equipname ].hint;
			}
			else
			{
				self.hint_string = "Missing buildable hint";
			}
		}
	}
	else if ( self.persistent == 1 )
	{
		if ( maps/mp/zombies/_zm_equipment::is_limited_equipment( self.weaponname ) && maps/mp/zombies/_zm_equipment::limited_equipment_in_use( self.weaponname ) )
		{
			self.hint_string = &"ZOMBIE_BUILD_PIECE_ONLY_ONE";
			return 0;
		}
		if ( player has_player_equipment( self.weaponname ) )
		{
			self.hint_string = &"ZOMBIE_BUILD_PIECE_HAVE_ONE";
			return 0;
		}
		/*
		if ( getDvarInt( #"1F0A2129" ) )
		{
			self.cursor_hint = "HINT_WEAPON";
			self.cursor_hint_weapon = self.weaponname;
		}
		*/
		self.hint_string = self.trigger_hintstring;
	}
	else if ( self.persistent == 2 )
	{
		if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.weaponname, undefined ) )
		{
			self.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
			return 0;
		}
		else if ( is_true( self.bought ) )
		{
			self.hint_string = &"ZOMBIE_GO_TO_THE_BOX";
			return 0;
		}
		self.hint_string = self.trigger_hintstring;
	}
	else
	{
		self.hint_string = "";
		return 0;
	}
	return 1;
}

choose_buildable( player )
{
	n_playernum = player getentitynumber();
	b_got_input = 1;
	hinttexthudelem = newclienthudelem( player );
	hinttexthudelem.alignx = "center";
	hinttexthudelem.aligny = "middle";
	hinttexthudelem.horzalign = "center";
	hinttexthudelem.vertalign = "bottom";
	hinttexthudelem.y = -100;
	hinttexthudelem.foreground = 1;
	hinttexthudelem.font = "default";
	hinttexthudelem.fontscale = 1;
	hinttexthudelem.alpha = 1;
	hinttexthudelem.color = ( 1, 1, 1 );
	hinttexthudelem settext( "Press [{+actionslot 1}] or [{+actionslot 2}] to change item" );

	if (!isDefined(level.buildables_index_max))
	{
		level.buildables_index_max = 3;
	}
	if (!isDefined(self.buildables_available_index))
	{
		self.buildables_available_index = 0;
	}

	while ( isDefined( self.playertrigger[ n_playernum ] ) )
	{
		// iPrintLn(player isTouching(self.playertrigger[n_playernum]));
		if (!player isTouching(self.playertrigger[n_playernum]))
		{
			hinttexthudelem.alpha = 0;
			wait 0.05;
			continue;
		}

		hinttexthudelem.alpha = 1;

		if ( player actionslotonebuttonpressed() )
		{
			self.buildables_available_index++;
			b_got_input = 1;
		}
		else
		{
			if ( player actionslottwobuttonpressed() )
			{
				self.buildables_available_index--;
				b_got_input = 1;
			}
		}

		if ( self.buildables_available_index > level.buildables_index_max )
		{
			self.buildables_available_index = 0;
		}
		else
		{
			if ( self.buildables_available_index < 0 )
			{
				self.buildables_available_index = level.buildables_index_max;
			}
		}

		if ( b_got_input )
		{
			piece = undefined;
			// foreach (stub in level.buildable_stubs)
			// {
			// 	if (stub.buildablezone.buildable_name == level.buildables_available[self.buildables_available_index])
			// 	{
			// 		piece = stub.buildablezone.pieces[0];
			// 		break;
			// 	}
			// }
			// slot = self.buildablestruct.buildable_slot;
			// player maps/mp/zombies/_zm_buildables::player_set_buildable_piece(piece, slot);

			// self.locked = !self.locked;
			if ( self.buildables_available_index == 0 )
			{
				self.hint_string = "Hold ^3&&1^7 to call the perk";
			}
			else if ( self.buildables_available_index == 1 )
			{
				self.hint_string = "Hold ^3&&1^7 to call the elevator";
			}
			else if ( self.buildables_available_index == 2 )
			{
				self.hint_string = "Hold ^3&&1^7 to unlock the elevator";
			}
			else if ( self.buildables_available_index == 3 )
			{
				self.hint_string = "Hold ^3&&1^7 to lock the elevator";
			}
			
			self.playertrigger[n_playernum] sethintstring(self.hint_string);
			b_got_input = 0;
		}

		if ( player is_player_looking_at( self.playertrigger[n_playernum].origin, 0.76 ) )
		{
			hinttexthudelem.alpha = 1;
		}
		else
		{
			hinttexthudelem.alpha = 0;
		}

		wait 0.05;
	}

	hinttexthudelem destroy();
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
				wait 2;
				elevator.body.departing_early = 0;
			}
		}
		wait 1;
	}
}

elevator_initial_wait( elevator, minwait, maxwait, delaybeforeleaving )
{
	elevator.body endon( "forcego" );
	minwait = minwait + 2;
	maxwait = maxwait - 8;
	elevator.body waittill_any_or_timeout( randomintrange( minwait, maxwait ), "depart_early" );
	if ( !is_true( elevator.body.lock_doors ) )
	{
		elevator.body setanim( level.perk_elevators_anims[ elevator.body.perk_type ][ 0 ] );
	}
	if ( !is_true( elevator.body.departing_early ) )
	{
		wait delaybeforeleaving;
	}
	if ( elevator.body.perk_type == "specialty_weapupgrade" )
	{
		while ( flag( "pack_machine_in_use" ) )
		{
			wait 0.5;
		}
		wait randomintrange( 2, 3 );
	}
	while ( isDefined( level.elevators_stop ) || level.elevators_stop && isDefined( elevator.body.elevator_stop ) && elevator.body.elevator_stop )
	{
		wait 0.05;
	}
}

elevator_think( elevator )
{
	current_floor = elevator.body.current_location;
	delaybeforeleaving = 5;
	skipinitialwait = 0;
	speed = 100;
	minwait = 5;
	maxwait = 20;
	flag_wait("perks_ready");
	if(isdefined(elevator.body.force_starting_floor))
	{
		elevator.body.current_level = "" + elevator.body.force_starting_floor;
		elevator.body.origin = elevator.floors[elevator.body.current_level].origin;
		if(isdefined(elevator.body.force_starting_origin_offset))
		{
			elevator.body.origin = elevator.body.origin + (0, 0, elevator.body.force_starting_origin_offset);
		}
	}
	elevator.body.can_move = 1;
	elevator elevator_set_moving(0);
	elevator elevator_enable_paths(elevator.body.current_level);
	if(elevator.body.perk_type == "vending_revive")
	{
		minwait = level.packapunch_timeout;
		maxwait = minwait + 10;
		elevator thread quick_revive_solo_watch();
	}
	if(elevator.body.perk_type == "vending_revive" && flag("solo_game"))
	{
	}
	else
	{
		flag_wait("power_on");
	}
	elevator.body perkelevatordoor(1);
	next = undefined;
	while(1)
	{
		start_location = 0;
		if(isdefined(elevator.body.force_starting_floor))
		{
			skipinitialwait = 1;
		}
		elevator.body.departing = 1;
		if(!is_true(elevator.body.lock_doors))
		{
			elevator.body setanim(level.perk_elevators_anims[elevator.body.perk_type][1]);
		}
		predict_floor(elevator, next, speed);
		if(!is_true(skipinitialwait))
		{
			elevator_initial_wait(elevator, minwait, maxwait, delaybeforeleaving);
			if(!is_true(elevator.body.lock_doors))
			{
				elevator.body setanim(level.perk_elevators_anims[elevator.body.perk_type][1]);
			}
		}
		next = elevator_next_floor(elevator, next, 0);
		if(isdefined(elevator.floors["" + next + 1]))
		{
			elevator.body.next_level = "" + next + 1;
		}
		else
		{
			start_location = 1;
			elevator.body.next_level = "0";
		}
		floor_stop = elevator.floors[elevator.body.next_level];
		floor_goal = undefined;
		cur_level_start_pos = elevator.floors[elevator.body.next_level].starting_position;
		start_level_start_pos = elevator.floors[elevator.body.starting_floor].starting_position;
		if(elevator.body.next_level == elevator.body.starting_floor || isdefined(cur_level_start_pos) && isdefined(start_level_start_pos) && cur_level_start_pos == start_level_start_po)
		{
			floor_goal = cur_level_start_pos;
		}
		else
		{
			floor_goal = floor_stop.origin;
		}
		dist = distance(elevator.body.origin, floor_goal);
		time = dist / speed;
		if(dist > 0)
		{
			if(elevator.body.origin[2] > floor_goal[2])
			{
				clientnotify(elevator.name + "_d");
			}
			else
			{
				clientnotify(elevator.name + "_u");
			}
		}
		if(is_true(start_location))
		{
			elevator.body thread squashed_death_alarm();
			if(!skipinitialwait)
			{
				wait(3);
			}
		}
		skipinitialwait = 0;
		elevator.body.current_level = elevator.body.next_level;
		elevator notify("floor_changed");
		elevator elevator_disable_paths(elevator.body.current_level);
		elevator.body.departing = 0;
		elevator elevator_set_moving(1);
		if(dist > 0)
		{
			elevator.body moveto(floor_goal, time, time * 0.25, time * 0.25);
			if(isdefined(elevator.body.trig))
			{
				elevator.body thread elev_clean_up_corpses();
			}
			elevator.body thread elevator_move_sound();
			elevator.body waittill_any("movedone", "forcego");
		}
		elevator elevator_set_moving(0);
		elevator elevator_enable_paths(elevator.body.current_level);
		if(elevator.body.perk_type == "vending_revive" && !flag("solo_game") && !flag("power_on"))
		{
			flag_wait("power_on");
		}
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
	wait 0.05;
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
		if ( 0 )
		{
			// playfx( level._effect[ "zomb_gib" ], self.origin );
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
				if( isDefined( self ) )
				{
					
					// level.elevator_kills++;
					// iPrintLn("Elevator kills: " + level.elevator_kills);
					// self stopanimscripted();
					// self.deathanim = "zm_death";
					// self delete();
                	// self dodamage( self.health + 100, self.origin );
				}
			}
			return;
		}
		else
		{
			wait 0.05;
		}
	}
}

faller_location_logic_override()
{
	print("override");
	wait 1;
	// faller_spawn_points = getstructarray( "faller_location", "script_noteworthy" );
	// leaper_spawn_points = getstructarray( "leaper_location", "script_noteworthy" );
	// spawn_points = arraycombine( faller_spawn_points, leaper_spawn_points, 1, 0 );
	spawn_points = getstructarray( "faller_location", "script_noteworthy" );
	dist_check = 35840;//16384;
	elevator_names = getarraykeys( level.elevators );
	elevators = [];
	for(i = 0; i < elevator_names.size; i++)
	{
		elevators[i] = getent("elevator_" + elevator_names[i] + "_body", "targetname");
	}
	elevator_volumes = [];
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_1b", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_1c", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_1d", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3a", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3b", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3c", "targetname" );
	elevator_volumes[ elevator_volumes.size ] = getent( "elevator_3d", "targetname" );
	level.elevator_volumes = elevator_volumes;

	while ( 1 )
	{
		foreach(point in spawn_points)
		{
			should_block = 0;
			foreach(elevator in elevators)
			{
				if(distancesquared(elevator.origin + (0, 0 ,50), point.origin) <= dist_check)
				{
					should_block = 1;
				}
			}
			if(should_block)
			{
				point.is_enabled = 0;
				point.is_blocked = 1;
				continue;
			}
			if(isdefined(point.is_blocked) && point.is_blocked)
			{
				point.is_blocked = 0;
			}
			if(!isdefined(point.zone_name))
			{
				continue;
			}
			zone = level.zones[point.zone_name];
			if(zone.is_enabled && zone.is_active && zone.is_spawning_allowed)
			{
				point.is_enabled = 1;
			}
		}

		players = get_players();
		foreach(volume in elevator_volumes)
		{
			should_disable = 0;
			foreach(player in players)
			{
				if(is_player_valid(player))
				{
					if(player istouching(volume))
					{
						should_disable = 1;
					}
				}
			}
			if(should_disable)
			{
				disable_elevator_spawners(volume, spawn_points);
			}
		}
		wait 0.5;
	}
}

remove_ground_spawns()
{ 
	foreach ( zone in level.zones )
	{
		for ( i = 0; i < zone.spawn_locations.size; i++ )
		{
			if ( zone.spawn_locations[ i ].origin == (1664, 1408, 3050.32) )
			{
				zone.spawn_locations[ i ].is_enabled = false;
			}
		}
    }
}