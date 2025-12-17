Controller_OnShootDown(*) {
  global State

  if !State["Enabled"]
    return
  if (State["ActiveWeapon"] = "Off")
    return
  if (State["PatternSteps"].Length = 0)
    return
  if State["Shooting"]
    return

  State["Shooting"] := true

  SetTimer(Controller_RunPattern, -1)
  UI_Update()
}

Controller_OnShootUp(*) {
  global State
  State["Shooting"] := false
  UI_Update()
}

Controller_RunPattern() {
  global State

  while State["Shooting"] {
    for step in State["PatternSteps"] {
      if !State["Shooting"]
        break

      dx := step["dx"] * State["Modifier"]
      dy := step["dy"] * State["Modifier"]

      SmoothMouseMoveRel(dx, dy, State["Smoothness"])

      if (step["delay"] > 0)
        Sleep step["delay"]
    }
  }
}


SmoothMouseMoveRel(dx, dy, smoothness) {
  steps := 3
  stepX := dx / steps
  stepY := dy / steps

  Loop steps {
      dx -= stepX
      dy -= stepY
      DllCall("mouse_event", "UInt", 0x01
          , "Int", Round(dx)
          , "Int", Round(dy)
          , "UInt", 0
          , "UPtr", 0)
      Sleep smoothness
  }
}
