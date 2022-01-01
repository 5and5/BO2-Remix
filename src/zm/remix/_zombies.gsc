
disable_high_round_walkers()
{
	level.speed_change_round = undefined;
}

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

zombie_rise_death_override( zombie, spot ) //checked matches cerberus output
{
	zombie.zombie_rise_death_out = 0;
	zombie endon( "rise_anim_finished" );
	while ( isDefined( zombie ) && isDefined( zombie.health ) && zombie.health > 1 )
	{
		zombie waittill( "damage", amount );
	}
	spot notify( "stop_zombie_rise_fx" );
	if ( isDefined( zombie ) )
	{
		// zombie.deathanim = zombie get_rise_death_anim();
		zombie stopanimscripted();
	}
}

get_rise_death_anim() //checked matches cerberus output
{
	if ( self.zombie_rise_death_out )
	{
		return "zm_rise_death_out";
	}
	self.noragdoll = 1;
	self.nodeathragdoll = 1;
	return "zm_rise_death_in";
}