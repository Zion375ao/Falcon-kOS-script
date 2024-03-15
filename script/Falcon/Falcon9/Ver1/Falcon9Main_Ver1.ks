//Falcon9 Main Script Ver1
//Script Ver1

//Continue Ascent
if ship:status = "sub_orbital" {
    runOncePath("0:/Falcon/Falcon9/Ver1/Falcon9Ascent_Ver1.ks").
}
//Choose Action Mode
else {
    local actionGUI to gui(200).
    local title to actionGUI:addlabel("Falcon9 Action Mode").
    set actionGUI:x to 100.
    set actionGUI:y to 100.

    //Launch
    if ship:status = "prelaunch" {
        local box1 to actionGUI:addhlayout().
        box1:addspacing(50).

        set button1 to box1:addbutton("Launch").
        set button1:onclick to {runfile("0:/Falcon/Falcon9/Ver1/Falcon9Ascent_Ver1.ks").}.
    }
    //Landing
    if ship:status = "orbiting" {
        local box2 to actionGUI:addhlayout().
        box2:addspacing(50).

        set button2 to box2:addbutton("Landing").
        set button2:onclick to {runfile().}.
    }
    //Transfer
    if ship:status = "orbiting" {
        local box3 to actionGUI:addhlayout().
        box3:addspacing(50).

        set button3 to box3:addbutton("Transfer").
        set button3:onclick to {runfile().}.
    }
    //Static Fire Test
    if ship:status = "prelaunch" {
        local box4 to actionGUI:addhlayout().
        box4:addspacing(50).

        set button4 to box4:addbutton("Static Fire").
        set button4:onclick to {runfile("0:/Falcon/Falcon9/Ver1/Falcon9_StaticFire_Ver1.ks").}.
    }

    //close GUI
    local boxClose to actionGUI:addhlayout().
    boxClose:addspacing(100).

    set buttonClose to boxClose:addbutton("Close").
    set buttonClose:onclick to {actionGUI:hide().}.

    actionGUI:show().

    wait until defined SelectMode.

    function runfile {
        parameter filename.

        actionGUI:hide().
        runOncePath(filename).
        set SelectMode to true.
    }
}