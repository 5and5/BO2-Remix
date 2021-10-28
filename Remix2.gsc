init()
{ 
  replaceFunc( maps/mp/zombies/_zm_utility::set_run_speed, ::set_run_speed_override );
  level thread onConnect();
}
onConnect()
{
  for (;;)
  {
    level waittill("connected", player);
    player thread connected();
  }
}
connected()
{
  self endon("disconnect");
  for(;;)
  {
    self waittill("spawned_player");
    self setClientDvar( "cg_fov", 90 );
    self setClientDvar( "cg_fovScale", 1.1 );
    self setClientDvar( "com_maxfps", 101 );

  }
}
set_run_speed_override()
{
	self.zombie_move_speed = "sprint";
}
