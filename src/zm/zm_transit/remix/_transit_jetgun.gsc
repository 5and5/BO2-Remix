#include maps\mp\zombies\_zm_weap_jetgun;
#include maps\mp\zombies\_zm_buildables;

jetgun_pickup_cooldown()
{
	while( !isDefined(level.jetgun_buildable) )
	{
		wait 0.1;
	}
	level.zombie_include_buildables[ "jetgun_zm" ].triggerthink
	// level.jetgun_buildable.trigger_hintstring = ;
}

jetgunbuildable_custom()
{

}

jetgun_fast_cooldown()
{
    level endon("end_game");
    self endon("disconnect");

    while ( 1 )
    {
        if (self hasweapon("jetgun_zm"))
        {
            self.jetgun_heatval -= 1;
            if (self.jetgun_heatval < 0)
            {
                self.jetgun_heatval = 0;
            }
            self setweaponoverheating( self.jetgun_overheating, self.jetgun_heatval );
        }
        wait 0.25;
    }
}

jetgun_fast_spinlerp()
{
	self endon( "disconnect" );

	previous_spinlerp = 0;
	while ( 1 )
	{
		if ( self getcurrentweapon() == "jetgun_zm" )
		{
			if (self AttackButtonPressed())
			{
				previous_spinlerp -= 0.0166667;
				if (previous_spinlerp < -1)
				{
					previous_spinlerp = -1;
				}
			}
			else
			{
				previous_spinlerp += 0.01;
				if (previous_spinlerp > 0)
				{
					previous_spinlerp = 0;
				}
				self setcurrentweaponspinlerp(0);
			}
		}
		else
		{
			previous_spinlerp = 0;
		}

		wait 0.05;
	}
}

jetgun_remove_forced_weapon_switch()
{
	foreach (buildable in level.zombie_include_buildables)
	{
		if(IsDefined(buildable.name) && buildable.name == "jetgun_zm")
		{
			buildable.onbuyweapon = undefined;
			return;
		}
	}
}

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

handle_overheated_jetgun()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "jetgun_overheated" );
		if ( self getcurrentweapon() == "jetgun_zm" )
		{
            self thread maps/mp/zombies/_zm_equipment::equipment_release( "jetgun_zm" );
            weapon_org = self gettagorigin( "tag_weapon" );
		    self dodamage( 50, weapon_org );
		    self playsound( "wpn_jetgun_explo" );
            self.jetgun_overheating = 100;
            self.jetgun_heatval = 0;
		}
	}
}

jetgun_check_enemies_in_range( zombie, view_pos, drag_range_squared, gib_range_squared, grind_range_squared, cylinder_radius_squared, forward_view_angles, end_pos, invert )
{
	if ( !isDefined( zombie ) )
	{
		return;
	}
	if ( zombie enemy_killed_by_jetgun() )
	{
		return;
	}
	if ( isDefined( zombie.is_avogadro ) && zombie.is_avogadro )
	{
		return;
	}
	if ( isDefined( zombie.isdog ) && zombie.isdog )
	{
		return;
	}
	if ( isDefined( zombie.isscreecher ) && zombie.isscreecher )
	{
		return;
	}
	if ( isDefined( self.animname ) && self.animname == "quad_zombie" )
	{
		return;
	}
	test_origin = zombie getcentroid();
	test_range_squared = distancesquared( view_pos, test_origin );
	if ( test_range_squared > drag_range_squared )
	{
		zombie jetgun_debug_print( "range", ( 1, 0, 1 ) );
		return;
	}
	normal = vectornormalize( test_origin - view_pos );
	dot = vectordot( forward_view_angles, normal );
	if ( abs( dot ) < 0.7 )
	{
		zombie jetgun_debug_print( "dot", ( 1, 0, 1 ) );
		return;
	}
	radial_origin = pointonsegmentnearesttopoint( view_pos, end_pos, test_origin );
	if ( distancesquared( test_origin, radial_origin ) > cylinder_radius_squared )
	{
		zombie jetgun_debug_print( "cylinder", ( 1, 0, 1 ) );
		return;
	}
	if ( zombie damageconetrace( view_pos, self ) == 0 )
	{
		zombie jetgun_debug_print( "cone", ( 1, 0, 1 ) );
		return;
	}
	if ( test_range_squared < grind_range_squared )
	{
		level.jetgun_fling_enemies[ level.jetgun_fling_enemies.size ] = zombie;
		level.jetgun_grind_enemies[ level.jetgun_grind_enemies.size ] = dot < 0;
	}
	else
	{
        if ( !isDefined( zombie.ai_state ) || zombie.ai_state != "find_flesh" && zombie.ai_state != "zombieMoveOnBus" )
        {
            return;
        }
        if ( isDefined( zombie.in_the_ground ) && zombie.in_the_ground )
        {
            return;
        }

		if ( test_range_squared < drag_range_squared && dot > 0 )
		{
			level.jetgun_drag_enemies[ level.jetgun_drag_enemies.size ] = zombie;
		}
	}
}

is_jetgun_firing()
{
    if(!self attackButtonPressed())
    {
        return 0;
    }

	return abs( self get_jetgun_engine_direction() ) > 0.2;
}