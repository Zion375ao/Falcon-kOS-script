//Falcon Heavy RTLS Ver2

if ship:status = "prelaunch" {
    wait until not core:messages:empty.

    StartUp().
}
else {
    Restart().
}

set ship:name to "Falcon Heavy Booster".

lock throttle to Thrott().
lock steering to Steer().
set steeringManager:rollts to 50.
set steeringManager:pitchpid:kd to steeringManager:pitchpid:kd + 5.
set steeringManager:yawpid:kd to steeringManager:yawpid:kd + 5.

rcs on.

until RunMode = 0 {
    //Waiting for Leaving
    if RunMode = 1 {
        EngineMode(MyEngine, "Three").
        ThrustLimit(MyEngine, 100).
        GridFinLimit("FHGridFin", 0).

        wait 1.

        set RunMode to 2.
    }

    //BoostBack Turn
    else if RunMode = 2 {
        if PitchAngle() > bbAngle * 0.9 {
            //rcs off.
            set steeringManager:maxstoppingtime to 5.

            set RunMode to 3.
        }
    }

    //Boostback Burn
    else if RunMode = 3 {
        if LatLngError(CorrPoint(LZPo, 0.05))[3] < 0 {
            brakes on.
            //rcs on.
            set steeringManager:maxstoppingtime to 1.
            set steeringManager:pitchts to 30.
            set steeringManager:yawts to 30.

            set RunMode to 4.
        }
    }

    //Waiting for Entry
    else if RunMode = 4 {
        if ship:verticalSpeed < 0 and ship:altitude < 45000 and LandTh(ship:maxthrust, 25000, -310) > 1 {
            rcs off.

            set RunMode to 5.
        }
    }

    //Entry Burn
    else if RunMode = 5 {
        if ship:altitude < 31000 and not ToggleTex {
            ToggleSoot(MyTank).
            ToggleSoot(Role).
            ToggleSoot(MyEngine).

            set ToggleTex to true.
        }

        if ship:verticalSpeed > -310 {
            rcs on.

            set steeringManager:maxstoppingtime to 2.
            GridFinLimit("FHGridFin", 35).

            set RunMode to 6.
        }
    }

    //Griding
    else if RunMode = 6 {
        if rcs and ship:altitude < 20000 {
            rcs off.
            GridFinLimit("FHGridFin", 50).
        }

        if LandTh(ship:maxthrust, 3000, sqrt(3000 * (5 * ((750 / ship:mass) - constant:g * body:mass / body:radius^2)))) > 1 {
            GridFinLimit("FHGridFin", 40).
            set RunMode to 7.
        }
    }

    //Landing Burn
    else if RunMode = 7 {
        if LandTh(750, LZAlt, 0) < 1 {
            EngineMode(MyEngine, "Center").
        }

        //LandingLeg Deploy
        if not legs and ImpactData()["tillImpact"] < 3 {
            legs on.
        }

        //Landed
        if ship:status = "landed" or ship:status = "splashed" or ship:verticalspeed > -0.5 {
            set ship:control:pilotmainthrottle to 0.
            unlock all.

            set RunMode to 0.
        }
    }

    wait 0.
}

function Thrott {
    if RunMode = 3 {
        return 1.
    }
    else if RunMode = 5 {
        return LandTh(ship:maxthrust, 25000, -310).
    }
    else if RunMode = 7 {
        return LandTh(692.759, LZAlt, 0).
    }

    return 0.
}

function Steer {
    if Role = "FHCenterBooster" and RunMode = 1 {
        return SepSteer.
    }
    if RunMode = 1 or RunMode = 2 {
        if PitchAngle() < bbAngle * 0.75 {
            set steeringManager:maxstoppingtime to 10.
        }
        else {
            set steeringManager:maxstoppingtime to 1.
        }

        return lookDirUp(heading(-LZPo:heading, PitchAngle() + 30):vector, SepSteer:topvector).
    }
    else if RunMode = 3 {
        return heading(-LZPo:heading, bbAngle, 0) - boostbackpid(CorrPoint(LZPo, 0.05)).
    }
    else if RunMode = 4 or RunMode = 5 {
        if ship:verticalSpeed < 0 and ship:altitude < 45000 {
            return LandPid(-1.5, 1, ship:velocity:surface, LatLngError(CorrPoint(LZPo, 0.3))[0]).
        }
        else if PitchAngle() > 110 {
            return heading(90, PitchAngle() - 5, 0).
        }
    }
    else if RunMode = 6 {
        return LandPid(line(1000, 1, 2500, 35, TrueAlt(), 1.5, 35), 3, ship:velocity:surface, LatLngError(CorrPoint(LZPo, 0.2))[0]).
    }
    else if RunMode = 7 {
        return LandPid(line(0, -0.1, 1000, -10, TrueAlt(), -10, -0.1), 3, ship:velocity:surface, LatLngError(LZPo)[0]).
    }

    return heading(90, 90, 0).
}

function StartUp {
    ControlPoint(Role).

    set RunMode to 1.
    set ToggleTex to false.

    set SepSteer to ship:facing.
}

function Restart {
}