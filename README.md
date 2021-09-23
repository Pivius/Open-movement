# Open Movement
Open source movement gamemode.

To switch between movement modes you use the console command:
    
    mm_mode 1-5

    1. Parkour
    2. Grapple
    3. RadioSkate
    4. VQ3
    5. CPMA
    6. Bhop
    7. Momentum

You can spectate other players by typing spectate 'nick' in console.

The server config should look something like this.

    sv_accelerate 0
    sv_friction 0
    sv_airaccelerate 0
    sv_gravity 300
    sv_maxrate 0
    sv_minrate 100000
    sv_maxupdaterate 99
    sv_maxcmdrate 99

To change the tickrate to 100 you add the follow line to launch options:

    -tickrate 100
   

Note that this gamemode works poorly in singleplayer.
