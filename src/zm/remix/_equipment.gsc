electric_trap_always_kill()
{
	level.etrap_damage = maps/mp/zombies/_zm::ai_zombie_health( 255 );
}

set_claymores_max( max )
{
	level.claymores_max_per_player = max;
}

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

claymore_safe_to_plant()
{
	foreach( player in level.players )
	{
		total_claymores += player.owner.claymores.size;
	}
	if ( total_claymores >= level.claymores_max_per_player )
	{
		return 0;
	}
	if ( isDefined( level.claymore_safe_to_plant ) )
	{
		return self [[ level.claymore_safe_to_plant ]]();
	}
	return 1;
}