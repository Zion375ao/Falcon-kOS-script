//Falcon9 Main Script Ver7

//Continue Ascent
if ship:status = "sub_orbital" {
    runOncePath("0:/Falcon/Falcon9/Ver7/Falcon9Ascent_Ver7.ks").
}
//Choose Action Mode
else {
    local actionGUI to gui(200).
    set title to actionGUI:addlabel("Falcon9 Action Mode").
    set actionGUI:x to 100.
    set actionGUI:y to 100.

    //Launch
    if ship:status = "prelaunch" {
        local box1 to actionGUI:addhlayout().
        box1:addspacing(50).

        set button1 to box1:addbutton("Launch").
        set button1:onclick to {runfile("0:/Falcon/Falcon9/Ver7/Falcon9Ascent_Ver7.ks").}.
    }
    //Transfer
    if ship:status = "orbiting" {
        local box2 to actionGUI:addhlayout().
        box2:addspacing(50).

        set button2 to box2:addbutton("Transfer").
        set button2:onclick to {}.
    }
    //Static Fire Test
    if ship:status = "prelaunch" {
        local box3 to actionGUI:addhlayout().
        box3:addspacing(50).

        set button3 to box3:addbutton("Static Fire").
        set button3:onclick to {runfile("0:/Falcon/Falcon9/Ver7/Falcon9_StaticFire_Ver7.ks").}.
    }

    //close GUI
    local boxClose to actionGUI:addhlayout().
    boxClose:addspacing(100).

    set buttonClose to boxClose:addbutton("Close").
    set buttonClose:onclick to {
        actionGUI:hide().
        wait until ag1.
        actionGUI:show().
    }.

    actionGUI:show().

    wait until defined SelectMode.

    function runfile {
        parameter filename.

        actionGUI:hide().
        runOncePath(filename).
        set SelectMode to true.
    }
}