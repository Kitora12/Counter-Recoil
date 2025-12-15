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

  SetTimer(Controller_RunPattern, -0)
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

      delay := step["delay"]
      if (delay > 0) {
        slept := 0
        while (slept < delay && State["Shooting"]) {
          chunk := Min(15, delay - slept)
          Sleep chunk
          slept += chunk
        }
      }
    }
  }
}

SmoothMouseMoveRel(dx, dy, smoothness := 0.7) {
  smoothness := Max(0.05, Min(1.0, smoothness))

  steps := Round(6 + (1.0 - smoothness) * 18)  ; 6..24
  stepX := dx / steps
  stepY := dy / steps

  Loop steps {
    MouseMove stepX, stepY, 0, "R"  ; relatif
    Sleep 1
  }
}
