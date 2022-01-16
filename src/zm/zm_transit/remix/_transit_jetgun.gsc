
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