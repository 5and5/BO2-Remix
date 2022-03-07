#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;

set_visionset()
{
	self useservervisionset(1);
	self setvisionsetforplayer(GetDvar( "mapname" ), 1.0 );
	// visionSetNaked( GetDvar( "mapname" ), 1.0 );
	// self setvisionsetforplayer("", 0 );
}

graphic_tweaks()
{
	if( level.script != "zm_tomb")
		self setclientdvar("r_fog", 0);
	self setclientdvar("r_dof_enable", 0);
	self setclientdvar("r_lodBiasRigid", -1000); // casues error when nocliping
	self setclientdvar("r_lodBiasSkinned", -1000);
	self setClientDvar("r_lodScaleRigid", 1);
	self setClientDvar("r_lodScaleSkinned", 1);
	self setclientdvar("sm_sunquality", 2);
	self setclientdvar("r_enablePlayerShadow", 1);
	self setclientdvar( "vc_fbm", "0 0 0 0" );
	self setclientdvar( "vc_fsm", "1 1 1 1" );
	self setclientdvar( "vc_fgm", "1 1 1 1" );
	// self setclientdvar( "r_skyColorTemp", 25000 );
}

night_mode()
{
	if ( !isDefined( self.night_mode ) )
	{
		self.night_mode = true;
	}
	else
	{
		return;
	}

	flag_wait( "start_zombie_round_logic" );
	wait 0.05;	

	self thread night_mode_watcher();
}

night_mode_watcher()
{	
	if( getDvar( "night_mode") == "" )
		setDvar( "night_mode", 0 );

	wait 1;

	while(1)
	{
		while( getDvarInt( "night_mode" ) == 0 )
		{
			wait 0.1;
		}
		self thread enable_night_mode();
		self thread visual_fix();

		while( getDvarInt( "night_mode" ) == 1 )
		{
			wait 0.1;
		}
		self thread disable_night_mode();
	}
}

enable_night_mode()
{
	if( !isDefined( level.default_r_exposureValue ) )
		level.default_r_exposureValue = getDvar( "r_exposureValue" );
	if( !isDefined( level.default_r_lightTweakSunLight ) )
		level.default_r_lightTweakSunLight = getDvar( "r_lightTweakSunLight" );
	if( !isDefined( level.default_r_sky_intensity_factor0 ) )
		level.default_r_sky_intensity_factor0 = getDvar( "r_sky_intensity_factor0" );
	// if( !isDefined( level.default_r_sky_intensity_factor0 ) )
	// 	level.default_r_lightTweakSunColor = getDvar( "r_lightTweakSunColor" );

	//self setclientdvar( "r_fog", 0 );
	self setclientdvar( "r_filmUseTweaks", 1 );
	self setclientdvar( "r_bloomTweaks", 1 );
	self setclientdvar( "r_exposureTweak", 1 );
	self setclientdvar( "vc_rgbh", "0.07 0 0.25 0" );
	self setclientdvar( "vc_yl", "0 0 0.25 0" );
	self setclientdvar( "vc_yh", "0.015 0 0.07 0" );
	self setclientdvar( "vc_rgbl", "0.015 0 0.07 0" );
	self setclientdvar( "vc_rgbh", "0.015 0 0.07 0" );
	self setclientdvar( "r_exposureValue", 3.9 );
	self setclientdvar( "r_lightTweakSunLight", 16 );
	self setclientdvar( "r_sky_intensity_factor0", 3 );
	//self setclientdvar( "r_lightTweakSunColor", ( 0.015, 0, 0.07 ) );
	if( level.script == "zm_buried" )
	{
		self setclientdvar( "r_exposureValue", 3.5 );
	}
	else if( level.script == "zm_tomb" )
	{
		self setclientdvar( "r_exposureValue", 4 );
	}
	else if( level.script == "zm_nuked" )
	{
		self setclientdvar( "r_exposureValue", 5.6 );
	}
	else if( level.script == "zm_highrise" )
	{
		self setclientdvar( "r_exposureValue", 3 );
	}
}

disable_night_mode()
{
	self notify( "disable_nightmode" );
	//self setclientdvar( "r_fog", 1 );
	self setclientdvar( "r_filmUseTweaks", 0 );
	self setclientdvar( "r_bloomTweaks", 0 );
	self setclientdvar( "r_exposureTweak", 0 );
	self setclientdvar( "vc_rgbh", "0 0 0 0" );
	self setclientdvar( "vc_yl", "0 0 0 0" );
	self setclientdvar( "vc_yh", "0 0 0 0" );
	self setclientdvar( "vc_rgbl", "0 0 0 0" );
	self setclientdvar( "r_exposureValue", int( level.default_r_exposureValue ) );
	self setclientdvar( "r_lightTweakSunLight", int( level.default_r_lightTweakSunLight ) );
	self setclientdvar( "r_sky_intensity_factor0", int( level.default_r_sky_intensity_factor0 ) );
	//self setclientdvar( "r_lightTweakSunColor", level.default_r_lightTweakSunColor );
}

visual_fix()
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	self endon( "disable_nightmode" );
	if( level.script == "zm_buried" )
	{
		while( getDvar( "r_sky_intensity_factor0" ) != 0 )
		{	
			self setclientdvar( "r_lightTweakSunLight", 1 );
			self setclientdvar( "r_sky_intensity_factor0", 0 );
			wait 0.05;
		}
	}
	else if( level.script == "zm_prison" || level.script == "zm_tomb" )
	{
		while( getDvar( "r_lightTweakSunLight" ) != 0 )
		{
			for( i = getDvar( "r_lightTweakSunLight" ); i >= 0; i = ( i - 0.05 ) )
			{
				self setclientdvar( "r_lightTweakSunLight", i );
				wait 0.05;
			}
			wait 0.05;
		}
	}
	else return;
}

rotate_skydome()
{
	if ( level.script == "zm_tomb" )
	{
		return;
	}
	
	x = 360;
	
	self endon("disconnect");
	for(;;)
	{
		x -= 0.025;
		if ( x < 0 )
		{
			x += 360;
		}
		self setclientdvar( "r_skyRotation", x );
		wait 0.1;
	}
}

change_skydome()
{
	x = 6500;
	
	self endon("disconnect");
	for(;;)
	{
		x += 1.626;
		if ( x > 25000 )
		{
			x -= 23350;
		}
		self setclientdvar( "r_skyColorTemp", x );
		wait 0.1;
	}
}

eye_color_watcher()
{	
	if( getDvar( "eye_color") == "" )
		setDvar( "eye_color", 0 );

	wait 1;

	while(1)
	{
		while( getDvarInt( "eye_color" ) == 0 )
		{
			wait 0.1;
		}
		level setclientfield( "zombie_eye_change", 1 );
    	sndswitchannouncervox( "richtofen" );

		while( getDvarInt( "eye_color" ) == 1 )
		{
			wait 0.1;
		}
		level setclientfield( "zombie_eye_change", 0 );
		sndswitchannouncervox( "sam" );
	}
}