//Falcon9 ASDS Ver7

if ship:status = "prelaunch" {
    wait until not core:messages:empty.

    StartUp().
}
else {
    Restart().
}

set ship:name to "Falcon9 Booster".

lock throttle to Thrott().
lock steering to Steer().
set steeringManager:rollts to 50.
//set steeringManager:pitchts to 5.
//set steeringManager:yawts to 5.
set steeringManager:maxstoppingtime to 1.
set steeringManager:pitchpid:kd to steeringManager:pitchpid:kd + 5.
set steeringManager:yawpid:kd to steeringManager:yawpid:kd + 5.

rcs on.

until RunMode = 0 {
    //Waiting for leaving Secound Stage
    if RunMode = 1 {
        EngineMode("Three").

        wait 3.

        brakes on.

        set RunMode to 2.
    }

    //Waiting for Entry
    else if RunMode = 2 {
        if ship:verticalSpeed < 0 and  ship:altitude < 45000 and LandTh(ship:maxthrust, 25000, -310) > 1 {
            rcs off.

            set RunMode to 3.
        }
    }

    //Entry Burn
    else if RunMode = 3 {
        if ship:altitude < 31000 and not ToggleTex {
            ToggleSoot("Falcon9Tank").
            wait 0.1.
            ToggleSoot("Role").
            wait 0.1.
            ToggleSoot("MainEngine").

            set ToggleTex to true.
        }
        if ship:verticalSpeed > -310 {
            rcs on.

            set steeringManager:maxstoppingtime to 2.

            set RunMode to 4.
        }
    }
    //Gruding
    else if RunMode = 4 {
        if rcs and ship:altitude < 20000 {
            rcs off.
        }

        if LandTh(ship:maxthrust, 3000, sqrt(3000 * (5 * ((750 / ship:mass) - (constant:g * body:mass / body:radius^2))))) > 1 {
            set RunMode to 5.
        }
    }
    //Landing Burn
    else if RunMode = 5 {
        //Final Approach
        if LandTh(750, LZAlt, 0) < 1 {
            EngineMode("Center").
        }

        //LandingLeg Deploy
        if not legs and addons:tr:timetillimpact < 3 {
            legs on.
        }

        //Landed
        if ship:status = "landed" or ship:status = "splashed" or ship:verticalspeed > 0 {
            set ship:control:pilotmainthrottle to 0.
            unlock all.

            set RunMode to 0.
        }
    }

    wait 0.
}

function thrott {
    if RunMode = 3 {
        return LandTh(ship:maxthrust, 25000, -310).
    }
    else if RunMode = 5 {
        return LandTh(692.759, LZAlt, 0).
    }

    return 0.
}

function steer {
    if RunMode = 1 {
        return MECOSteer.
    }
    else if RunMode = 2 or RunMode = 3 {
        if ship:verticalSpeed < 0 and ship:altitude < 55000 {
            return LandPid(-1.5, 0.5, ship:velocity:surface, LatLngError(CorrPoint(LZPo, 0.25))[0]).
        }
    }
    else if RunMode = 4 {
        return LandPid(line(0, 1, 100, 25, LatLngError(CorrPoint(LZPo, 0.2))[1], 1, 25), 2, ship:velocity:surface, LatLngError(CorrPoint(LZPo, 0.2))[0]).
    }
    else if RunMode = 5 {
        if TrueAlt() < 30 {
            return lookDirUp(ship:up:vector, facing:topvector).
        }
        return LandPid(line(0, -0.1, 1000, -10, TrueAlt(), -10, -0.1), 1, ship:velocity:surface, LatLngError(CorrPoint(LZPo, 0.15))[0]).
    }

    return heading(90, 90, 0).
}

function startup {
    set RunMode to 1.
    set ToggleTex to false.

    set MECOSteer to ship:facing.
}

function restart {
}
