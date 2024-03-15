//Falcon9 Ascent Ver7

if ship:status = "prelaunch" {
    StartUp().
}
else {
    Restart().
}

set ship:name to MissionName.
lock Throttle to Thrott().
lock Steering to Steer().
set SteeringManager:rollts to 30.

ag1 on.
wait 5.

until RunMode = 0 {
    //Countdown
    if RunMode = 1 {
        //Water Deluge System Activate
        if CountdownT = IgnitionT + 1 {
            WaterDeluge().
        }

        //Ignition
        if CountdownT = IgnitionT {
            EngineMode("Full").
        }

        //lift off
        if CountdownT = 0 {
            stage.

            set RunMode to 2.
        }

        //wait 1s
        else {
            set CountdownT to CountdownT - 1.

            wait 1.
        }
    }

    //Vertical Ascent
    else if RunMode = 2 {
        if ship:airspeed > 25 {
            set RunMode to 3.
        }
    }

    //MECO
    else if RunMode = 3 {
        if (LZSt = "RTLS" and FuelAmount("Falcon9Tank", "liquidfuel") < MECOFuel) or (LZSt = "ASDS" and LatLngError(CorrPoint(LZPo, 0.07))[3] > 0) or (LZSt = "Expendable" and FuelAmount("Falcon9Tank", "liquidfuel") = 0) {
            set MECOSteer to ship:facing.
            set MECO to true.

            rcs on.

            wait 1.

            BoosterCPU:connection:sendmessage("MECO").

            stage.
            set ship:control:fore to 1.

            wait 2.

            set ship:control:fore to 0.

            set RunMode to 4.
        }
    }
    //SECO
    else if RunMode = 4 {
        if ship:apoapsis > POrbit {
            set RunMode to 5.
        }
    }
    //Maneuver Node
    else if RunMode = 5 {
        //create node
        if not hasNode {
            if ship:altitude > 70000 {
                wait 0.
                CreateNode().
                set dv0 to tgNode:deltav.
            }
        }
        //execute node
        else {
            if tgNode:eta < burntime + 60 and warp <> 0 {
                set warp to 0.
            }
            if vdot(dv0, tgNode:deltav) < 0 or tgNode:deltav:mag < 0.1 {
                remove tgNode.

                unlock all.
                set RunMode to 0.
            }
        }
    }

    //fairing separation
    if not FairingJet and ship:altitude > fairingalt {
        fairing("Falcon9Fairing").

        set fairingjet to true.
    }

    wait 0.
}

reboot.

function Thrott {
    if RunMode = 1 or RunMode = 2 or (RunMode = 3 and not MECO) or RunMode = 4 {
        return 1.
    }
    else if RunMode = 5 {
        if hasNode and tgNode:eta < burntime {
            return min(tgNode:deltav:mag / (ACC(ship:maxthrust)[0] / 5), 1).
        }
    }

    return 0.
}

function Steer {
    if RunMode = 1 and RunMode = 2 {
        //return lookDirUp(ship:up:vector, facing:topvector).
        return lookDirUp(ship:up:vector, AscentSteer:topvector).
    }
    else if RunMode = 3 or RunMode = 4 {
        if RunMode = 2 and MECO = true {
            return MECOSteer.
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
    else if RunMode = 5 {
        if hasNode {
            if tgNode:deltav:mag < 5 {
                return ship:facing.
            }
            else {
                return lookDirUp(tgNode:deltav, facing:topvector).
            }
        }
        else {
            return lookDirUp(ship:prograde:vector, facing:topvector).
        }
    }

    return heading(90, 90, 0).
}

function StartUp {
    set RunMode to 1.

    set AscentSteer to ship:facing.

    set MECO to false.
    set FairingJet to false.

    set BoosterCPU to processor("Falcon9Booster").

    if IgnitionT > CountdownT {
        set CountdownT to IgnitionT.
    }

    if LZSt = "RTLS" {
        set MECOFuel to FuelAmount("Falcon9Tank", "liquidfuel") * 0.23.
    }
}

function Restart {
    set RunMode to 3.

    if ship:altitude > FairingAlt {
        set FairingJet to true.
    }
    else {
        set FairingJet to false.
    }

    rcs on.
}