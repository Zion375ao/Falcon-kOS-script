//Falcon9 Ascent Ver2
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
            enginemode("full").
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
    //MECO
    else if runmode = 2 {
        if (LZPo = "LZ" and fuelamount("Falcon9Tank", "liquidfuel") < mecofuel) or (LZPo = "ASDS" and lngerrordiff(refpoint(0.07, LZ)) > 0) or (LZPo = "Expendable" and fuelamount("Falcon9Tank", "liquidfuel") = 0) {
            set mecosteer to ship:facing.
            set meco to true.

            rcs on.

            wait 1.

            BoosterCPU:connection:sendmessage(eng).
            stage.
            set ship:control:fore to 1.

            wait 2.

            set ship:control:fore to 0.

            set runmode to 3.
        }
    }
    //SECO
    else if runmode = 3 {
        if ship:apoapsis > POrbit {
            set runmode to 4.
        }
    }
    //Maneuver Node
    else if runmode = 4 {
        //create node
        if not hasNode {
            if ship:altitude > 70000 {
                wait 0.
                createnode().
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
    if runmode = 1 {
        return 1.
    }
    else if runmode = 2 {
        if meco {
            return 0.
        }
        else {
            return 1.
        }
    }
    else if runmode = 3 {
        return 1.
    }
    else if runmode = 4 {
        if hasNode and tgnode:eta < burntime {
            return min(tgnode:deltav:mag / (acc(ship:maxthrust) / 5), 1).
        }
        else {
            return 0.
        }
    }
}

function steer {
    if runmode = 1 {
        return heading(90, 90, 0).
    }
    else if runmode = 2 or runmode = 3 {
        if runmode = 2 and meco = true {
            return mecosteer.
        }
        else if ship:apoapsis > 500 {
            if pitchangle() > GTAngle {
                return gravityturn().
            }
            else {
                return heading(90, GTAngle, 0).
            }
        }
        else {
            return heading(90, 90, 0).
        }
    }
    else if runmode = 4 {
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
}

function startup {
    set runmode to 1.

    set meco to false.
    set fairingjet to false.

    set BoosterCPU to processor("Falcon9Booster").

    if IgnitionT > CountdownT {
        set CountdownT to IgnitionT.
    }

    if LZPo = "LZ" {
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