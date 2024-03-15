//Falcon9 Ground Pad Ver1
//Script Ver1

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

clearScreen.

rcs on.

until runmode = 0 {
    //Waiting for leaving Secound Stage
    if runmode = 1 {
        enginemode("Three").

        wait 1.

        set runmode to 2.
    }
    //BoostBack turn
    else if runmode = 2 {
        if pitchangle() > bbAngle {
            set ship:control:pitch to 0.

            set runmode to 3.
        }
    }
    //BoostBack Burn
    else if runmode = 3 {
        if lngerrordiff(refpoint(0.05, LZ)) < 0 {
            set runmode to 4.

            brakes on.
        }
    }
    //Waiting for Entry
    else if runmode = 4 {
        if ship:verticalSpeed < 0 and  ship:altitude < 45000 and landth(ship:maxthrust, 25000, -310) > 1 {
            set runmode to 5.
            ToggleSoot("Falcon9Tank").
        }
    }
    //Entry Burn
    else if runmode = 5 {
        if ship:verticalSpeed > -310 {
            set  runmode to 6.
        }
    }
    //Griding
    else if runmode = 6 {
        if rcs and ship:altitude < 20000 {
            rcs off.
        }

        if landth(ship:maxthrust, 3000, sqrt(3000 * (5 * ((750 / ship:mass) - (constant:g * body:mass / body:radius ^ 2))))) > 1 {
            set steeringManager:pitchts to 10.
            set steeringManager:yawts to 10.

            set runmode to 7.
        }
    }
    //Landing Burn
    else if runmode = 7 {
        //Final Approach
        if landth(750, 0, 0) < 1 {
            enginemode("Center").
        }
        //LandingLeg Deploy
        if not legs and addons:tr:timetillimpact < 3 {
            legs on.
        }
        //Landed
        if ship:status = "landed" or ship:status = "splashed" or ship:verticalspeed > 0 {

            //rcs on.
            //sas on.

            set runmode to 0.

            set ship:control:pilotmainthrottle to 0.
        }
    }

    print errordiff(refpoint(0.1, LZ)) at (1, 1).
    print ship:groundspeed at (1, 2).

    wait 0.
}

function thrott {
    if runmode = 0 or runmode = 1 or runmode = 2 or runmode = 4 or runmode = 6 {
        return 0.
    }
    else if runmode = 3 {
        return 1.
    }
    else if runmode = 5 {
        return landth(ship:maxthrust, 25000, -310).
    }
    else if runmode = 7 {
        return landth(692.759, 0, 0).
    }
}

function steer {
    if runmode = 1 {
        return mecosteer.
    }
    else if runmode = 2 {
        if pitchangle() < bbAngle * 0.75 {
            set ship:control:pitch to 1.
        }
        else {
            //set ship:control:pitch to 0.
            set ship:control:pitch to -1.
            
            //return heading(-LZ:heading, bbAngle, 0).
            //return heading(-LZ:heading, pitchangle() + 5, 0).
        }

        //return ship:facing.
        return heading(-LZ:heading, pitchangle(), 0).
    }
    else if runmode = 3 {
        return heading(-LZ:heading, bbAngle, 0) - boostbackpid(refpoint(0.05, LZ)).
    }
    else if runmode = 4 or runmode = 5 {
        if ship:verticalSpeed < 0 and ship:altitude < 45000 {
            return steerpid(-1.5, 0.5, ship:velocity:surface, errorvector(refpoint(0.3, LZ))).
        }
        else {
            return lookDirUp(ship:up:vector, facing:topvector).
        }
    }
    else if runmode = 6 {
        return steerpid(line(0, 5, 500, 10, errordiff(refpoint(0.2, LZ)), true, 1), 1.7, ship:velocity:surface, errorvector(refpoint(0.2, LZ))).
    }
    else if runmode = 7 {
        if (errordiff(refpoint(0.1, LZ)) > 1 or ship:groundspeed > 3) and truealt() > 30 {
            return steerpid(-1.3, 1.5, ship:velocity:surface, errorvector(refpoint(0.1, LZ))).
        }
        else {
            return lookDirUp(ship:up:vector, facing:topvector).
        }
    }

    return heading(90, 90).
}

function startup {
    set runmode to 1.
    set eng to "Full".
    set mecosteer to ship:facing.
}

function restart {
    set runmode to 2.
    set eng to "Full".
}