register_zombie_health_mods() {
    replaceFunc(maps/mp/zombies/_zm::ai_calculate_health, ::ai_calculate_health_override);
    // replaceFunc(maps/mp/zombies/_zm::ai_zombie_health, ai_zombie_health_override);

}

ai_calculate_health_override(round) {
    level.zombie_health = level.zombie_vars[ "zombie_health_start" ];
    i = 2;

    iprintln("ai_calc override");

    if(round >= 99 && (round % 2) == 1 ) {
        iprintln("Instakill round!"); 
        level.zombie_health = 150;  //artificial instakill round!
        return; 
    }

    while ( i <= round )
    {
        if ( i >= 10 )
        {
            old_health = level.zombie_health;
            level.zombie_health += int( level.zombie_health * level.zombie_vars[ "zombie_health_increase_multiplier" ] );
            if ( level.zombie_health < old_health )
            {
                level.zombie_health = old_health;
                return;
            }
            i++;
            continue;
        }
        else
        {
            level.zombie_health = int( level.zombie_health + level.zombie_vars[ "zombie_health_increase" ] );
        }
        i++;
    }
}

// Used by buildables/Sliq to calcualte how good they are to a certain round
// Adding instas check here may create unintended behavior, so omitting for now.
ai_zombie_health_override(round) {
    zombie_health = level.zombie_vars[ "zombie_health_start" ];
	i = 2;
    iprintln("ai_zombie override");
	while ( i <= round )
	{
		if ( i >= 10 )
		{
			old_health = zombie_health;
			zombie_health += int( zombie_health * level.zombie_vars[ "zombie_health_increase_multiplier" ] );
			if ( zombie_health < old_health )
			{
				return old_health; 
			}
		}
		else
		{
			zombie_health = int( zombie_health + level.zombie_vars[ "zombie_health_increase" ] );
		}
		i++;
	}
	return zombie_health;
}

