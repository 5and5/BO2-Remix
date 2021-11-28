#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

spawn_shield_bench( origin, angles ) //jz is the best
{
	level endon("end_game");

	bench = spawn("script_model", origin);
	bench SetModel("p6_zm_work_bench");
	bench.angles = angles;
	col = spawn("script_model", origin + (-25,0,0));
	col SetModel("collision_clip_64x64x64");
	col.angles = angles;
	shieldModel = spawn("script_model", origin + ( 0, 0, 70 ) );
	shieldModel SetModel("t6_wpn_zmb_shield_dlc2_dmg0_world");
	shieldModel.angles = ( angles + vectorScale( ( 0, 0, 0 ), 90 ) );
	trigger = spawn("trigger_radius", origin + (0,0,32), 20, 35, 70);
	trigger.targetname = "shield_trigger";
	trigger.angles = angles;
	trigger SetCursorHint("HINT_NOICON");
	trigger SetHintString("Hold ^3&&1^7 for Zombie Shield");
	wait 5;
	level thread update_hint_string( trigger );
	for(;;)
	{
		trigger waittill( "trigger", player );
		if( player UseButtonPressed() )
		{
			if( !player.shield_cooldown_time && !player hasWeapon( "alcatraz_shield_zm" ) )
			{
				player maps/mp/zombies/_zm_equipment::equipment_buy( "alcatraz_shield_zm" );
				player.shield_cooldown_time = 300;
				player thread shield_cooldown();
			}
		}
		wait 0.1;
	}
}

shield_cooldown()
{
	level endon("end_game");

	while(1)
	{
		wait 1;
		self.shield_cooldown_time--;
		if(self.shield_cooldown_time == 0)
		{
			break;
		}
	}
}

update_hint_string( trig )
{
	level endon("end_game");

	foreach(player in level.players)
	{
		player.shield_cooldown_time = 0;
	}
	state = 0;
	prevState = 0;
	while(1)
	{
		foreach(player in level.players)
		{
			
			if ( player.shield_cooldown_time > 0 )
			{
				trig SetHintString("Zombie Shield Cool Down: " + to_mins(player.shield_cooldown_time));
			}
			else if ( !player hasweapon( "alcatraz_shield_zm" ) )
			{
				trig SetHintString("Hold ^3&&1^7 for Zombie Shield");
			}
			else
			{
				trig SetHintString("Took Zombie Shield");
			}
		}
		wait 0.1;
	}
}
		
to_mins( seconds )
{
	hours = 0;
	minutes = 0;

	if( seconds > 59 )
	{
		minutes = int( seconds / 60 );

		seconds = int( seconds * 1000 ) % ( 60 * 1000 );
		seconds = seconds * 0.001;

		if( minutes > 59 )
		{
			hours = int( minutes / 60 );
			minutes = int( minutes * 1000 ) % ( 60 * 1000 );
			minutes = minutes * 0.001;
		}
	}

	if( hours < 10 )
	{
		hours = "0" + hours;
	}

	if( minutes < 10 )
	{
		minutes = "0" + minutes;
	}

	seconds = Int( seconds );
	if( seconds < 10 )
	{
		seconds = "0" + seconds;
	}

	combined = minutes  + ":" + seconds;

	return combined;
}
