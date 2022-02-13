#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;

#include scripts/zm/remix/_utility;


set_players_score( score )
{
	flag_wait( "start_zombie_round_logic" );
	if( self.score == 500)
		self.score = score;
	else
		self.score += 5;
}

set_movement_dvars()
{
    self setClientDvar( "dtp_post_move_pause", 0 );
	self setClientDvar( "dtp_exhaustion_window", 100 );
	self setClientDvar( "dtp_startup_delay", 100 );

    self setclientdvar("player_strafeSpeedScale", 1);
    self setclientdvar("player_sprintStrafeSpeedScale", 1);

	// setDvar("sv_enablebounces", 1);
}

set_client_dvars()
{
	self setClientDvar( "cg_friendlyNameFadeIn", 0 );
	self setClientDvar( "cg_friendlyNameFadeOut", 250 );
	self setClientDvar( "cg_enemyNameFadeIn", 0 );
	self setClientDvar( "cg_enemyNameFadeOut", 250 );

	self setClientDvar( "player_meleeRange", 64 );
	self setClientDvar( "aim_automelee_enabled", 0 );

	self setClientDvar( "g_friendlyfireDist", 0 );
}

set_character_option()
{
	create_dvar( "character", 0 );

	if ( level.force_team_characters != 1 && getDvar("mapname") != "zm_tomb" && getDvar("mapname") != "zm_prison" ) 
	{	
		switch( getDvarInt("character") )
		{
			case 1:
				self setviewmodel( "c_zom_farmgirl_viewhands" );
				self.characterindex = 2;
				break;
			case 2:
				self setviewmodel( "c_zom_oldman_viewhands" );
				self.characterindex = 0;
				break;
			case 3:
				self setviewmodel( "c_zom_reporter_viewhands" );
				self.characterindex = 1;
				break;
			case 4:
				self setviewmodel( "c_zom_engineer_viewhands" );
				self.characterindex = 3;
				break;
		}
	}
}

inspect_weapon()
{
	if(level.script == "zm_tomb")
	{
		return;
	}
	level endon( "end_game" );
	self endon( "disconnect" );

	for(;;)
	{
		if( self actionslotthreebuttonpressed() )
		{
			self initialweaponraise( self getcurrentweapon() );
		}
		wait 0.05;
	}
}

rapid_fire()
{
	create_dvar( "rapid_fire", 0 );
    
    self endon("disconnect");
    for(;;)
    {
        if( !getDvarInt( "rapid_fire" ) )
        {
            wait 0.05;
        }
        if( getDvarInt( "rapid_fire" ) )
        {
            self waittill("weapon_fired", weap);
            primaries = self GetWeaponsListPrimaries();
            if(primaries.size > 1)
            {
                foreach(weapon in primaries)
                {
                    if(weapon != weap)
                    {
                        self SwitchToWeapon(weapon);
                        wait 0.05;
                        self SwitchToWeapon(weap);
                        self SetSpawnWeapon(weap);
                        break;
                    }
                }
            }
        }
    }
}

disable_player_quotes()
{
	create_dvar( "disable_player_quotes", 0 );
    
    self endon("disconnect");
    for(;;)
    {
		if( getDvarInt( "disable_player_quotes" ) )
		{
			self.isspeaking = 1;
		}
		wait 0.5;
	}
}