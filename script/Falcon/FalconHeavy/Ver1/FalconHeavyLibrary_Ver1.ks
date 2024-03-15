//Falcon Heavy Library Ver1
//Script Ver1

//-------------------------------------------------------------------

//Center Core LZ
set LZlist to list().

//Expendable
LZlist:add(list()).
LZlist[0]:add("Expendable"). //LZ status
LZlist[0]:add("Expendable Booster"). //LZ title

//LZ 1
LZlist:add(list()).
LZlist[1]:add("LZ"). //LZ status
LZlist[1]:add("Triple Pad Side 1 (M)"). //LZ title
LZlist[1]:add(latlng(-0.141231, -74.686727)). //LZ latlng
LZlist[1]:add(0). //LZ alt

//LZ 2
LZlist:add(list()).
LZlist[2]:add("LZ"). //LZ status
LZlist[2]:add("Triple Pad Side 2 (M)"). //LZ title
LZlist[2]:add(latlng(-0.161191, -74.686885)). //LZ latlng
LZlist[2]:add(0). //LZ alt

//LZ 3
LZlist:add(list()).
LZlist[3]:add("LZ"). //LZ status
LZlist[3]:add("Triple Pad Side 3 (S)"). //LZ title
LZlist[3]:add(latlng(-0.151208, -74.692589)). //LZ latlng
LZlist[3]:add(0). //LZ alt

//LZ 4
LZlist:add(list()).
LZlist[4]:add("LZ"). //LZ status
LZlist[4]:add("Main Pad (L)"). //LZ title
LZlist[4]:add(latlng(-0.156078, -74.605781)). //LZ latlng
LZlist[4]:add(0). //LZ alt

//LZ 5
LZlist:add(list()).
LZlist[5]:add("LZ"). //LZ status
LZlist[5]:add("Double Pad 1 (M)"). //LZ title
LZlist[5]:add(latlng(-0.197051, -74.561683)). //LZ latlng
LZlist[5]:add(0). //LZ alt

//LZ 6
LZlist:add(list()).
LZlist[6]:add("LZ"). //LZ status
LZlist[6]:add("Double Pad 2 (M)"). //LZ title
LZlist[6]:add(latlng(-0.197262, -74.538421)). //LZ latlng
LZlist[6]:add(0). //LZ alt

//ASDS 1
LZlist:add(list()).
LZlist[7]:add("ASDS"). //LZ status
LZlist[7]:add("Of Course I Still Love You"). //LZ title
LZlist[7]:add(latlng(-0.156077, -60.460386)). //LZ latlng
LZlist[7]:add(3.48). //LZ alt

//ASDS 2
LZlist:add(list()).
LZlist[8]:add("ASDS"). //LZ status
LZlist[8]:add("A Shortfall of Gravitas"). //LZ title
LZlist[8]:add(latlng(-0.156077, -55.382944)). //LZ latlng
LZlist[8]:add(5.11). //LZ alt

//-------------------------------------------------------------------

//Side Booster LZ
set SideLZlist to list().

//Expendable
SideLZlist:add(list()).
SideLZlist[0]:add("Expendable").
SideLZlist[0]:add("Expendable Booster").

//LZ 1 & 2
SideLZlist:add(list()).
SideLZlist[1]:add("LZ").
SideLZlist[1]:add("Triple Pad Side (M)"). //LZ title
SideLZlist[1]:add(latlng(-0.141231, -74.686727)). //LZ 1 latlng
SideLZlist[1]:add(0). //LZ 1 alt
SideLZlist[1]:add(latlng(-0.161191, -74.686885)). //LZ 2 latlng
SideLZlist[1]:add(0). //LZ 2 alt

//LZ 5 & 6
SideLZlist:add(list()).
SideLZlist[2]:add("LZ").
SideLZlist[2]:add("Double Pad (M)"). //LZ title
SideLZlist[2]:add(latlng(-0.197051, -74.561683)). //LZ 1 latlng
SideLZlist[2]:add(0). //LZ 1 alt
SideLZlist[2]:add(latlng(-0.197262, -74.538421)). //LZ 2 latlng
SideLZlist[2]:add(0). //LZ 2 alt

//-------------------------------------------------------------------

//Function

function curve {
}

function line {
    parameter x1, y1, x2, y2, variable, AllowMin, minValue to 0.

    local ansA to 0.
    local ansB to 0.

    if x1 = 0 {
        set ansB to y1.
        set ansA to (y2 - ansB) / x2.
    }
    else {
        local mul to - (x2 / x1).
        local result_y to y1 * mul + y2.
        local result_b to mul + 1.

        set ansB to result_y / result_b.
        set ansA to (y1 - ansB) / x1.
    }

    if AllowMin {
        return variable * ansA + ansB.
    }
    else {
        local value to variable * ansA + ansB.

        if value > minValue {
            return value.
        }
        else {
            return minValue.
        }
    }
}

function truealt {
    local shipradar to alt:radar.

    if exalt > shipradar{
        return 0.
    }
    else {
        return shipradar - exalt.
    }
}

function fuelamount {
    parameter tag, res.

    local fuelRemain to 0.

    for tank in ship:partstagged(tag) {
        for fuel in tank:resources {
            if fuel:name = res {
                set fuelRemain to fuelRemain + fuel:amount.
            }
        }
    }

    return fuelRemain.
}

function acc {
    parameter power.

    return power / ship:mass.
}

function accVec {
    parameter power, TGvector, holizontal to false.

    if holizontal = false {
        return power * cos(180 - vAng(TGvector, ship:up:vector)) / ship:mass.
    }
    else {
        return power * sin(180 - vAng(TGvector, ship:up:vector)) / ship:mass.
    }
}

function pitchangle {
    return 90 - arctan2(vdot(vcrs(ship:up:vector, ship:north:vector), facing:forevector), vdot(ship:up:vector, facing:forevector)).
}

function impactpoint {
    if addons:tr:hasimpact {
        return addons:tr:impactpos.
    }
    else {
        return ship:geoPosition.
    }
}

function refpoint {
    parameter mag, tgt.

    return latlng((tgt:lat + (tgt:lat - ship:geoPosition:lat) * mag), (tgt:lng + (tgt:lng - ship:geoPosition:lng) * mag)).
}

function laterror {
    parameter tgt.

    return impactpoint():lat - tgt:lat.
}

function lngerror {
    parameter tgt.

    return impactpoint():lng - tgt:lng.
}

function lngerrordiff {
    parameter tgt.

    if lngerror(tgt) < 0 {
        return - abs(errorvector(tgt):z).
    }
    else {
        return abs(errorvector(tgt):z).
    }
}

function errorvector {
    parameter tgt.

    return impactpoint():position - tgt:position.
}

function errordiff {
    parameter tgt, radius to ship:body:radius + altitude.
    
    //return sqrt((errorvector(tgt):x) ^ 2 + (errorvector(tgt):z) ^ 2).
    local A to sin((impactpoint():lat - tgt:lat) / 2)^2 + cos(impactpoint:lat) * sin((impactpoint:lng - tgt:lng) / 2)^2.
    return radius * constant():PI * arcTan2(sqrt(A), sqrt(1 - A)) / 90.
}

function shiperrordiff {
    parameter tgt.

    local shiperrorvector to ship:geoposition:position - tgt:position.
    return sqrt((shiperrorvector:x) ^ 2 + (shiperrorvector:z) ^ 2).
}

function gravityturn {
    return heading(90, 90 - (ship:apoapsis / 1500)).
}

set boostbackyaw to pidloop(5, 3, 7, -7, 7).
set boostbackyaw:setpoint to 0.
function boostbackpid {
    parameter tgt.
    
    return r(boostbackyaw:update(time:seconds, laterror(tgt)), 0, 0).
}

function steerpid {
    parameter aoa, mag, vel, pos.

    local velvector to - vel.
    local result to (velvector + pos) * mag.
    if vang(result, velvector) > aoa {
        set result to velvector:normalized + tan(aoa) * pos:normalized.
    }
    return lookdirup(result, facing:topvector).
}

function landth {
    parameter power, tgalt, tgspeed.

    local landacc to accVec(power, ship:velocity:surface) - (constant:g * body:mass / body:radius ^ 2).
    local stopdist to (ship:verticalspeed ^ 2 - tgspeed ^ 2) / (2 * landacc).
    return (stopdist + tgalt) / truealt().
}

function entryth {
    parameter power, tgt.

    local entryacc to accVec(power, ship:velocity:surface, true).
    local stopdist to (ship:groundspeed ^ 2) / (2 * entryacc).
    return (stopdist) / errordiff(tgt).
}

function createnode {
    local gm to constant:g * kerbin:mass.
    local rap to ship:apoapsis + 600000.
    local vap to sqrt(gm * ((2 / rap) - (1 / ship:orbit:semimajoraxis))).
    local tgv to sqrt(gm * ((2 / rap) - (1 / rap))).
    local burnV to tgv - vap.

    set tgnode to node(timespan(eta:apoapsis), 0, 0, burnV).
    add tgnode.

    set burntime to (tgnode:deltav:mag / acc(ship:maxthrust)) / 2.
}

function fairing {
    parameter tag.

    for decoupler in ship:partstagged(tag) {
        if decoupler:hasmodule("proceduralfairingdecoupler") {
            decoupler:getmodule("proceduralfairingdecoupler"):doevent("jettison fairing").
        }
        if decoupler:hasmodule("ModuleDecouple") {
            decoupler:getmodule("ModuleDecouple"):doevent("Decouple").
        }
    }
    set fairingjet to true.
}

function enginemode {
    parameter tag, mode.

    local engine to ship:partstagged(tag).
    local engineTE to engine[0]:getmodule("ModuleTundraEngineSwitch").
    local engineFX to engine[0]:getmodule("ModuleEnginesFX").

    if defined eng = false {
        set eng to "Full".
        if engineFX:hasevent("Activate Engine") {
            engineFX:doevent("Activate Engine").

            set enginestatus to true.
        }
    }

    if mode = "Shutdown" and eng <> mode {
        if engineFX:hasevent("Shutdown Engine") {
            engineFX:doevent("Shutdown Engine").
        }

        set enginestatus to false.
    }
    else if eng <> mode {

        if mode = "Center" {
            if eng = "Three" {
                nextmode().
            }
            else if eng = "Full" {
                previousmode().
            }
        }
        else if mode = "Three" {
            if eng = "Full" {
                nextmode().
            }
            else if eng = "Center" {
                previousmode().
            }
        }
        else if mode = "Full" {
            if eng = "Center" {
                nextmode().
            }
            else if eng = "Three" {
                previousmode().
            }
        }

        set eng to mode.
    }

    function nextmode {
        if engineTE:hasevent("Next Engine Mode") {
                engineTE:doevent("Next Engine Mode").
        }
    }

    function previousmode {
        if engineTE:hasevent("Previous Engine Mode") {
                engineTE:doevent("Previous Engine Mode").
        }
    }
}

function thrustlimit {
    parameter tag, thrott.

    local engine to ship:partstagged(tag).
    local engineFX to engine[0]:getmodule("ModuleEnginesFX").

    engineFX:setfield("Thrust Limiter", thrott).
}

function WaterDeluge {
    local base to ship:partstagged("LaunchPadBase").
    local baseFX to base[0]:getmodule("ModuleEnginesFX").
    if baseFX:hasevent("Activate Engine") {
        baseFX:doevent("Activate Engine").
    }
}

function ToggleSoot {
    parameter tag.

    local TGtank to ship:partstagged(tag).
    local tankTX to TGtank[0]:getmodule("ModuleTundraSoot").

    tankTX:doaction("Toggle Soot", true).
}

function controlpoint {
    parameter tag.

    local commandpart to ship:partstagged(tag).
    commandpart[0]:getmodule("ModuleCommand"):doevent("Control From Here").
}