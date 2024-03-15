//Falcon9 Ascent Ver5
//Script Ver1

if ship:status = "prelaunch" {
    startup().
}
else {
    restart().
}

set ship:name to MissionName.
lock throttle to thrott().
lock steering to steer().
set steeringManager:rollts to 30.

set SettingCT to CountdownT.

ag1 on.
wait 5.

until runmode = 0 {
    //Countdown
    if runmode = 1 {
        if SettingCT > 3 and CountdownT = IgnitionT + 1 {
            WaterDeluge().
        }

        //Ignition
        if CountdownT = IgnitionT {
            EngineMode("Full").
        }

        //lift off
        if CountdownT = 0 {
            stage.

            set runmode to 2.
        }

        //wait 1s
        else {
            set CountdownT to CountdownT - 1.

            wait 1.
        }
    }

    //Vertical Ascent
    else if runmode = 2 {
        if ship:airspeed > 25 {
            set runmode to 3.
        }
    }

    //MECO
    else if runmode = 3 {
        if (LZLoc = "RTLS" and fuelamount("Falcon9Tank", "liquidfuel") < mecofuel) or (LZLoc = "ASDS" and lngerrordiff(refpoint(0.07, LZPo)) > 0) or (LZLoc = "Expendable" and fuelamount("Falcon9Tank", "liquidfuel") = 0) {
            set mecosteer to ship:facing.
            set meco to true.

            rcs on.

            wait 1.

            BoosterCPU:connection:sendmessage(eng).

            stage.
            set ship:control:fore to 1.

            wait 1.

            set ship:control:fore to 0.

            set runmode to 4.
        }
    }
    //SECO
    else if runmode = 4 {
        if ship:apoapsis > POrbit {
            set runmode to 5.
        }
    }
    //Maneuver Node
    else if runmode = 5 {
        //create node
        if not hasNode {
            if ship:altitude > 70000 {
                wait 0.
                CreateOrbit().
                set dv0 to tgnode:deltav.
            }
        }
        //execute node
        else {
            if tgnode:eta < burntime + 60 and warp <> 0 {
                set warp to 0.
            }
            if vdot(dv0, tgnode:deltav) < 0 or tgnode:deltav:mag < 0.1 {
                remove tgnode.

                unlock all.
                set runmode to 0.
            }
        }
    }

    //fairing separation
    if not fairingjet and ship:altitude > fairingalt {
        fairing("Falcon9Fairing").
    }

    wait 0.
}

reboot.

function thrott {
    if runmode = 1 or runmode = 2 or (runmode = 3 and meco = false) or runmode = 4 {
        return 1.
    }
    else if runmode = 5 {
        if hasNode and tgnode:eta < burntime {
            return min(tgnode:deltav:mag / (ACC(ship:maxthrust)[0] / 5), 1).
        }
    }

    return 0.
}

function steer {
    if runmode = 1 and runmode = 2 {
        return lookDirUp(ship:up:vector, facing:topvector).
    }
    else if runmode = 3 or runmode = 4 {
        if runmode = 2 and meco = true {
            return mecosteer.
        }
        else {
            if pitchangle() > GTAngle {
                return GravityTurn().
            }
            else {
                return heading(90, GTAngle, 0).
            }
        }
    }
    else if runmode = 5 {
        if hasNode {
            if tgnode:deltav:mag < 5 {
                return ship:facing.
            }
            else {
                return lookDirUp(tgnode:deltav, facing:topvector).
            }
        }
        else {
            return lookDirUp(ship:prograde:vector, facing:topvector).
        }
    }

    return heading(90, 90, 0).
}

function startup {
    set runmode to 1.

    set ascentroll to ship:facing:roll.

    set meco to false.
    set fairingjet to false.

    set BoosterCPU to processor("Falcon9Booster").

    if IgnitionT > CountdownT {
        set CountdownT to IgnitionT.
    }

    if LZLoc = "RTLS" {
        set mecofuel to fuelamount("Falcon9Tank", "liquidfuel") * 0.25.
    }
}

function restart {
    set runmode to 3.

    if ship:altitude > FairingAlt {
        set fairingjet to true.
    }
    else {
        set fairingjet to false.
    }

    rcs on.
}