#Requires AutoHotkey v2.0

global Trigger := Map(
    "Enabled", true,
    "BoundHotkeys", []
)

Trigger_InitFromIni(iniPath) {
    global Trigger

    Trigger["IniPath"] := iniPath

    ; Touches dans [KeyBinds]
    Trigger["TriggerKey"] := Trim(IniGet(iniPath, "KeyBinds", "TriggerKey", "x"))
    Trigger["ToggleKey"]  := Trim(IniGet(iniPath, "KeyBinds", "ToggleKey", ""))

    ; Paramètres dans [Settings]
    Trigger["luminanceThreshold"]   := Number(IniGet(iniPath, "Settings", "luminanceThreshold", "1.0"))
    Trigger["offsetX"]              := Integer(IniGet(iniPath, "Settings", "offsetX", "1"))
    Trigger["offsetY"]              := Integer(IniGet(iniPath, "Settings", "offsetY", "1"))
    Trigger["fireDelayMin"]         := Number(IniGet(iniPath, "Settings", "fireDelayMin", "5"))
    Trigger["fireDelayMax"]         := Number(IniGet(iniPath, "Settings", "fireDelayMax", "25"))
    Trigger["checkInterval"]        := Integer(IniGet(iniPath, "Settings", "checkInterval", "1"))
    Trigger["whiteIgnoreThreshold"] := Integer(IniGet(iniPath, "Settings", "whiteIgnoreThreshold", "200"))

    Trigger_ApplyHotkeys()
}

Trigger_ApplyHotkeys() {
    global Trigger

    ; GARDE-FOU : BoundHotkeys doit être un Array
    if !Trigger.Has("BoundHotkeys") || Type(Trigger["BoundHotkeys"]) != "Array"
        Trigger["BoundHotkeys"] := []

    for hk in Trigger["BoundHotkeys"] {
        try Hotkey(hk, "Off")
    }
    Trigger["BoundHotkeys"] := []

    hkTrigger := "*" Trigger["TriggerKey"]
    Hotkey(hkTrigger, Trigger_OnTriggerDown)
    Trigger["BoundHotkeys"].Push(hkTrigger)

    if (Trigger["ToggleKey"] != "") {
        hkToggle := "*" Trigger["ToggleKey"]
        Hotkey(hkToggle, Trigger_ToggleEnabled)
        Trigger["BoundHotkeys"].Push(hkToggle)
    }
}

Trigger_ToggleEnabled(*) {
    global Trigger
    Trigger["Enabled"] := !Trigger["Enabled"]
    TrayTip("Trigger", "Enabled: " (Trigger["Enabled"] ? "ON" : "OFF"), 1)
    try UI_Update()
}

Trigger_OnTriggerDown(*) {
    global Trigger
    if !Trigger["Enabled"]
        return
    Trigger_RunWhileKeyDown(Trigger["TriggerKey"])
}

Trigger_RunWhileKeyDown(keyName) {
    global Trigger

    luminanceThreshold := Trigger["luminanceThreshold"]
    offsetX            := Trigger["offsetX"]
    offsetY            := Trigger["offsetY"]
    fireDelayMin       := Trigger["fireDelayMin"]
    fireDelayMax       := Trigger["fireDelayMax"]
    checkInterval      := Trigger["checkInterval"]
    whiteIgnoreTh      := Trigger["whiteIgnoreThreshold"]

    MouseGetPos &mouseX, &mouseY
    baseColor := PixelGetColor(mouseX + offsetX, mouseY + offsetY, "RGB")

    bR := (baseColor >> 16) & 0xFF
    bG := (baseColor >> 8)  & 0xFF
    bB :=  baseColor        & 0xFF
    baseLum := Trigger_GetLuminance(bR, bG, bB)

    while GetKeyState(keyName, "P") {
        if !Trigger["Enabled"]
            break

        MouseGetPos &mouseX, &mouseY
        currColor := PixelGetColor(mouseX + offsetX, mouseY + offsetY, "RGB")

        cR := (currColor >> 16) & 0xFF
        cG := (currColor >> 8)  & 0xFF
        cB :=  currColor        & 0xFF

        if (cR > whiteIgnoreTh && cG > whiteIgnoreTh && cB > whiteIgnoreTh) {
            if (checkInterval > 0)
                Sleep checkInterval
            continue
        }

        currLum := Trigger_GetLuminance(cR, cG, cB)
        if (Abs(currLum - baseLum) > luminanceThreshold) {
            Sleep 1
            confirmColor := PixelGetColor(mouseX + offsetX, mouseY + offsetY, "RGB")

            cR2 := (confirmColor >> 16) & 0xFF
            cG2 := (confirmColor >> 8)  & 0xFF
            cB2 :=  confirmColor        & 0xFF

            confirmLum := Trigger_GetLuminance(cR2, cG2, cB2)
            if (Abs(currLum - confirmLum) < 10) {
                delay := Random(fireDelayMin, fireDelayMax)
                Trigger_DoClick()
                Sleep Round(delay)
            }
        }

        if (checkInterval > 0)
            Sleep checkInterval
    }
}

Trigger_DoClick() {
    DllCall("mouse_event", "UInt", 0x02, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
    DllCall("mouse_event", "UInt", 0x04, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
}

Trigger_GetLuminance(r, g, b) {
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
}
