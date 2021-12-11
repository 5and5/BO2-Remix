
jetgun_buff()
{
    level endon("end_game");
    self endon("disconnect");
    for(;;)
    {
        if (self hasweapon("jetgun_zm"))
        {
            self.jetgun_heatval -= 1;
            if (self.jetgun_heatval < 0)
            {
                self.jetgun_heatval = 0;
            }
            self setweaponoverheating( self.jetgun_overheating, self.jetgun_heatval );
        }
        wait 0.25;
    }
}