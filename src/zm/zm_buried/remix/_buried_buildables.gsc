#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_equip_subwoofer;


spawn_turbine_bench( origin, angles )
{
	level endon("end_game");
	level endon("disconnect");

	precachemodel( "collision_clip_64x64x64" );
	bench = spawn("script_model", origin);
	bench SetModel("p6_zm_work_bench");
	bench.angles = angles;
	col = spawn("script_model", origin + (15, 0, 0));
	col SetModel("collision_clip_64x64x64");
	col.angles = angles;
	shieldModel = spawn("script_model", origin + ( 0, 0, 44 ) );
	shieldModel SetModel("p6_zm_buildable_turbine_mannequin");
	shieldModel.angles = ( angles + vectorScale( ( 0, 0, 0 ), 90 ) );
	trigger = spawn("trigger_radius", origin + (0,0,32), 20, 35, 70);
	trigger.targetname = "shield_trigger";
	trigger.angles = angles;
	trigger SetCursorHint("HINT_NOICON");
	trigger SetHintString("Hold ^3&&1^7 for Turbine");
	wait 5;
	level thread update_hint_string( trigger );
	while( 1 )
	{
		trigger waittill( "trigger", player );
		if( player UseButtonPressed() )
		{
			if( !player hasWeapon( "equip_turbine_zm" ) )
			{
				player maps/mp/zombies/_zm_equipment::equipment_buy( "equip_turbine_zm" );
			}
		}
		wait 0.1;
	}
}

update_hint_string( trig )
{
	level endon("end_game");
	level endon("disconnect");

	while( 1 )
	{
		foreach(player in level.players)
		{	
			//if ( isDefined( player.buildableturbine.owner ) && player.buildableturbine.owner.name == player.name || player hasweapon( "equip_turbine_zm" ) )
			if( player hasWeapon( "equip_turbine_zm" ) )
			{
				trig SetHintString("Took Turbine");
			}
			else
			{
				trig SetHintString("Hold ^3&&1^7 for Turbine");
			}
		}
		wait 0.1;
	}
}

/*
* *****************************************************
*	
* ********************* Overrides *********************
*
* *****************************************************
*/

burst_zombie_override( weapon, player )
{
if ( !isDefined( self ) || !isalive( self ) )
	{
		return;
	}
	if ( isDefined( self.subwoofer_fling_func ) )
	{
		self thread [[ self.subwoofer_fling_func ]]( weapon, fling_vec );
		player notify( "zombie_subwoofer_kill" );
		return;
	}
	self dodamage( self.health + 666, weapon.origin );
	player notify( "zombie_subwoofer_kill" );
	if ( self.health <= 0 )
	{
		if ( isDefined( onlydamage ) && !onlydamage )
		{
			self startragdoll();
			self setclientfield( "subwoofer_flings_zombie", 1 );
		}
		self.subwoofer_death = 1;
	}
}

knockdown_zombie_override( weapon, gib, onlydamage )
{
	if ( !isDefined( self ) || !isalive( self ) )
	{
		return;
	}
	if ( isDefined( self.subwoofer_fling_func ) )
	{
		self thread [[ self.subwoofer_fling_func ]]( weapon, fling_vec );
		player notify( "zombie_subwoofer_kill" );
		return;
	}
	self dodamage( self.health + 666, weapon.origin );
	player notify( "zombie_subwoofer_kill" );
	if ( self.health <= 0 )
	{
		if ( isDefined( onlydamage ) && !onlydamage )
		{
			self startragdoll();
			self setclientfield( "subwoofer_flings_zombie", 1 );
		}
		self.subwoofer_death = 1;
	}
}

turbinepowerdiminish( origin, powerradius ) //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_turbine_zm_taken" );
	self.buildableturbine endon( "death" );
	while ( !is_true( self.buildableturbine.dying ) )
	{
		if ( isDefined( self.turbine_power_level ) && isDefined( self.buildableturbine ) )
		{
			switch( self.turbine_power_level )
			{
				case 4:
					break;
				case 3:
					break;
				case 2:
					self.turbine_power_on = 1;
					wait randomintrange( 12, 20 );
					self turbinepoweroff( origin, powerradius );
					self.turbine_power_on = 0;
					wait randomintrange( 3, 8 );
					self turbinepoweron( origin, powerradius );
					break;
				case 1:
					self.turbine_power_on = 1;
					wait randomintrange( 3, 7 );
					self turbinepoweroff( origin, powerradius );
					self.turbine_power_on = 0;
					wait randomintrange( 6, 12 );
					self turbinepoweron( origin, powerradius );
					break;
			}
			wait 0.05;
		}
	}
}