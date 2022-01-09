// #include maps/mp/gametypes_zm/_hud_util;
// #include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;

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
    self setclientdvar("player_backSpeedScale", 1);
    self setclientdvar("player_strafeSpeedScale", 1);
    self setclientdvar("player_sprintStrafeSpeedScale", 1);
}

set_character_option()
{
	if( getDvar("character") == "" )
		setDvar("character", 0 );

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