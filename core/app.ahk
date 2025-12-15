App_Start() {
  global State

  DirCreate(A_ScriptDir "\config")
  DirCreate(A_ScriptDir "\profiles")

  State["ActiveWeapon"] := "Off"
  State["ActiveProfile"] := ""
  State["PatternSteps"] := []
  State["Shooting"] := false

  Bindings_Apply()
  UI_Create()
}

App_Reload() {
  Bindings_Apply()
  TrayTip("Counter", "Hotkeys reloaded.", 1)
  UI_Update()
}
