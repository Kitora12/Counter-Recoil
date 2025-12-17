global BoundHotkeys := []

Bindings_Apply() {
  global State, BoundHotkeys

  for hk in BoundHotkeys
    Hotkey(hk, "Off")
  BoundHotkeys := []

  config := A_ScriptDir "\config\config.ini"
  mouse  := A_ScriptDir "\config\mouse.ini"

  State["Sens"] := Number(IniGet(config, "Settings", "sens", "1.0"))
  State["ZoomSens"] := Number(IniGet(config, "Settings", "zoomsens", "1.0"))
  State["Smoothness"] := 0.7
  State["Modifier"] := 2.52 / Max(0.01, State["Sens"])

  Loop 9 {
    weaponId := "w" A_Index
    key := IniGet(config, "KeyBinds", weaponId)
    if (key != "") {
      Hotkey(key, SetWeapon.Bind(weaponId))
      BoundHotkeys.Push(key)
    }
  }

  offKey := IniGet(config, "KeyBinds", "Off")
  if (offKey != "") {
    Hotkey(offKey, (*) => SetWeapon("Off"))
    BoundHotkeys.Push(offKey)
  }

  pauseKey := IniGet(mouse, "Controls", "PauseKey")
  if (pauseKey != "") {
    Hotkey(pauseKey, ToggleEnabled)
    BoundHotkeys.Push(pauseKey)
  }

  shootKey := IniGet(mouse, "Controls", "shoot")
  if (shootKey != "") {
    hkDown := "~*" shootKey
    hkUp   := "~*" shootKey " Up"

    Hotkey(hkDown, Controller_OnShootDown)
    Hotkey(hkUp, Controller_OnShootUp)

    BoundHotkeys.Push(hkDown)
    BoundHotkeys.Push(hkUp)
  }

  exitKey := Trim(IniGet(mouse, "Controls", "ExitKey", ""))
  if (exitKey != "") {
    hk := "*" exitKey
    Hotkey(hk, App_Exit)
    BoundHotkeys.Push(hk)
  }
}

SetWeapon(weaponId, *) {
  global State

  State["ActiveWeapon"] := weaponId
  State["ActiveProfile"] := (weaponId = "Off") ? "" : Profiles_Load(weaponId)
  State["PatternSteps"] := (weaponId = "Off") ? [] : Profiles_ParseSteps(State["ActiveProfile"])

  UI_Update()
}

App_Exit(*) {
  TrayTip("Counter", "Exiting...", 1)
  ExitApp
}

ToggleEnabled(*) {
  global State
  State["Enabled"] := !State["Enabled"]

  if !State["Enabled"]
    State["Shooting"] := false

  TrayTip("Counter", "Enabled: " (State["Enabled"] ? "ON" : "OFF"), 1)
  UI_Update()
}
