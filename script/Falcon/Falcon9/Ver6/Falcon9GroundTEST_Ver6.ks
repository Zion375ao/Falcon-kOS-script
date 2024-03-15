//Falcon9 Ground Test Ver2
//Script Ver1

startup().

set ship:name to MissionName + " : TEST".

//Select TEST Mode
local testGUI to gui(200).
local title to testGUI:addlabel("Falcon9 TEST Mode").
set testGUI:x to 100.
set testGUI:y to 100.

lock throttle to thrott().
lock steering to steer().

until runmode = 0 {
    //Countdown
    if runmode = 1 {
        //Ignition
        if CountdownT = IgnitionT {
            enginemode("full").
        }
        
        if CountdownT = 0 {
            set ShutdownTime to sessionTime + SFTime.
            set runmode to 2.
        }
        else {
            set CountdownT to CountdownT - 1.

            wait 1.
        }
    }
    //Shutdown
    else if runmode = 2 {
        if sessionTime > ShutdownTime {
            enginemode("AllShutdown").

            unlock all.

            set runmode to 0.
        }
    }
}

function thrott {
    return SFThrottle / 100.
}

function steer {
    return ship:up.
}

function startup {
    set runmode to 1.

    if IgnitionT > CountdownT {
        set CountdownT to IgnitionT.
    }
}