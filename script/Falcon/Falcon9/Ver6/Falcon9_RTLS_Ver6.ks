//Falcon9 Ground Pad Ver6

if ship:status = "prelaunch" {
    wait until not core:messages:empty.

    startup().
}
else {
    restart().
}

set ship:name to "Falcon9 Booster".

lock throttle to thrott().
lock steering to steer().
set steeringManager:rollts to 30.
//set steeringManager:pitchts to 5.
//set steeringManager:yawts to 5.
set steeringManager:maxstoppingtime to 1.
set steeringManager:pitchpid:kd to steeringManager:pitchpid:kd + 5.
set steeringManager:yawpid:kd to steeringManager:yawpid:kd + 5.

clearScreen.

rcs on.

EngineMode("Three").

until runmode = 0 {
    //Waiting for leaving Secound Stage
    if runmode = 1 {
        wait 1.

        set runmode to 2.
    }

    //BoostBack turn
    else if runmode = 2 {
        if PitchAngle() > bbAngle * 0.9 {
            //set ship:control:pitch to 0.

            rcs off.

            set runmode to 3.
        }
    }

    //BoostBack Burn
    else if runmode = 3 {
        if LatLngError(CorrPoint(LZPo, -0.3))[3] < 0 {
            brakes on.

            rcs on.
            
            set runmode to 4.
        }
    }

    //Waiting for Entry
    else if runmode = 4 {
        if ship:verticalSpeed < 0 and ship:altitude < 45000 and LandTh(ship:maxthrust, 25000, -310) > 1 {
            set runmode to 5.
        }
    }

    //Entry Burn
    else if runmode = 5 {
        if ship:altitude < 31000 and not ToggleTex {
            ToggleSoot("Falcon9Tank").

            set ToggleTex to true.
        }
        if ship:verticalSpeed > -310 {
            EngineMode("Center").
            set  runmode to 6.
        }
    }

    //Griding
    else if runmode = 6 {
        if rcs and ship:altitude < 15000 {
            rcs off.
        }

        if LandTh(ship:maxthrust, 0, 0) > 1 {
            set steeringManager:pitchts to 10.
            set steeringManager:yawts to 10.

            set runmode to 7.
        }
    }

    //Landing Burn
    else if runmode = 7 {
        //LandingLeg Deploy
        if not legs and addons:tr:timetillimpact < 3 {
            legs on.
        }

        //Landed
        if ship:status = "landed" or ship:status = "splashed" or ship:verticalspeed > -0.5 {

            set ship:control:pilotmainthrottle to 0.
            unlock all.

            set runmode to 0.
        }
    }

    wait 0.
}

function thrott {
    if runmode = 3 {
        return 1.
    }
    else if runmode = 5 {
        return LandTh(ship:maxthrust, 25000, -310).
    }
    else if runmode = 7 {
        return LandTh(ship:maxthrust, LZAlt, 0).
    }

    return 0.
}

function steer {
    if runmode = 1 {
        return mecosteer.
    }
    else if runmode = 2 {
        if pitchangle() < bbAngle * 0.6 {
            //set ship:control:pitch to 1.
            set steeringManager:maxstoppingtime to 10.
        }
        else {
            //set ship:control:pitch to -1.
            set steeringManager:maxstoppingtime to 1.
        }

        return heading(-LZPo:heading, PitchAngle() + 30, 0).
    }
    else if runmode = 3 {
        return heading(-LZPo:heading, bbAngle, 0) - BoostbackPid(CorrPoint(LZPo, -0.3)).
        //return Boostback().
    }
    else if runmode = 4 or runmode = 5 {
        if ship:verticalSpeed < 0 and ship:altitude < 45000 {
            return LandPid(-1.5, 0.5, ship:velocity:surface, LatLngError(CorrPoint(LZPo, 0.3))[0]).
        }
        else if PitchAngle() > 110 {
            return heading(90, PitchAngle() - 10, 0).
        }
    }
    else if runmode = 6 {
        return LandPid(line(0, 5, 3000, 50, LatLngError(CorrPoint(LZPo, 0.25))[1], 5, 50), 2, ship:velocity:surface, LatLngError(CorrPoint(LZPo, 0.25))[0]).
    }
    else if runmode = 7 {
        if TrueAlt() < 50 {
            return lookDirUp(ship:up:vector, facing:topvector).
        }
        return LandPid(line(0, -0.1, 1000, -10, TrueAlt(), -10, -0.1), 1.5, ship:velocity:surface, LatLngError(CorrPoint(LZPo, 0.1))[0]).
    }

    return heading(90, 90, 0).
}

function startup {
    set runmode to 1.

    set ToggleTex to false.

    set mecosteer to ship:facing.
}

function restart {
    set runmode to 2.

    set ToggleTex to false.
}