#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_ai_quadrotor;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zm_tomb_vo;
#include maps/mp/zm_tomb_main_quest;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zm_tomb_craftables;
#include maps/mp/zm_tomb_main_quest;

spawn_gems_in_chambers()
{
	for(i = 0; i < 4; i++)
	{
		wait 1;
		level notify( "player_teleported", level.players[0], i + 1 );
	}
}

open_gramophone_door()
{
	flag_init( self.targetname + "_opened" );
	trig_position = getstruct( self.targetname + "_position", "targetname" );
	trig_position.has_vinyl = 0;
	trig_position.gramophone_model = undefined;
	t_door = tomb_spawn_trigger_radius( trig_position.origin, 60, 1 );
	t_door set_unitrigger_hint_string( &"ZOMBIE_BUILD_PIECE_MORE" );
	trig_position.gramophone_model = spawn( "script_model", trig_position.origin );
	trig_position.gramophone_model.angles = trig_position.angles;
	trig_position.gramophone_model setmodel( "p6_zm_tm_gramophone" );
	flag_set( "gramophone_placed" );
	//level setclientfield( "piece_record_zm_player", 0 );
	t_door trigger_off();
	str_song = trig_position get_gramophone_song();
	playsoundatposition( str_song, self.origin );
	self playsound( "zmb_crypt_stairs" );
	wait 6;
	chamber_blocker();
	flag_set( self.targetname + "_opened" );
	if ( isDefined( trig_position.script_flag ) )
	{
		flag_set( trig_position.script_flag );
	}
	level setclientfield( "crypt_open_exploder", 1 );
	self movez( -260, 10, 1, 1 );
	self waittill( "movedone" );
	self connectpaths();
	self delete();
	t_door tomb_unitrigger_delete();
	trig_position.trigger = undefined;
}