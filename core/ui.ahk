#Requires AutoHotkey v2.0

global UI := unset
global UIc := Map()

OnMessage(0x0201, UI_WM_LBUTTONDOWN)

UI_Create() {
  global UI, UIc

  UI := Gui("-Caption +AlwaysOnTop +ToolWindow", "Counter Recoil")
  UI.BackColor := "121619"
  UI.SetFont("s9 cFFFFFF", "Segoe UI")
  UI.MarginX := 12
  UI.MarginY := 10

  UIc["Title"] := UI.AddText("w260", "Counter Recoil")
  UIc["Title"].SetFont("s10 bold")

  UIc["Status"] := UI.AddText("w260 y+6", "")
  UIc["Profile"] := UI.AddText("w260 y+4", "")
  UIc["Profile"].SetFont("s8 cC8C8C")

  UIc["WeaponImg"] := UI.AddPicture("w110 h40 y+8 BackgroundTrans", "")
  
  UIc["TriggerStatus"] := UI.AddText("w260 y+6", "")
  UIc["TriggerStatus"].SetFont("s8")

  UI.OnEvent("Close", (*) => ExitApp())

  UI_Update()
  UI.Show("AutoSize x20 y20")
}

UI_WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
  global UI
  if !IsSet(UI)
    return
  if (hwnd != UI.Hwnd)
    return

  PostMessage(0xA1, 2, 0, , "ahk_id " hwnd)
}

UI_Update() {
  global State, UI, UIc
  if !IsSet(UI)
    return

  enabled := State.Has("Enabled") ? State["Enabled"] : false
  weaponId := State.Has("ActiveWeapon") ? State["ActiveWeapon"] : "Off"
  weaponName := (weaponId = "Off") ? "Off" : Profiles_DisplayName(weaponId)

  UIc["Status"].Text := (enabled ? "ON" : "OFF") "  -  " weaponName

  if (!enabled || weaponId = "Off") {
    UIc["Status"].SetFont("cD0D0D0")
  } else {
    UIc["Status"].SetFont("c7CFC00")
  }

  if (weaponId = "Off") {
    UIc["WeaponImg"].Value := ""
  } else {
    UIc["WeaponImg"].Value := WeaponImagePathByDisplayName(weaponName)
  }

  UI_UpdateTriggerStatus()
}

UI_UpdateTriggerStatus() {
  global UIc
  try {
    global Trigger
    if !IsObject(Trigger) {
      UIc["TriggerStatus"].Text := "Trigger: N/A"
      UIc["TriggerStatus"].SetFont("c808080")
      return
    }

    cEnabled := Trigger.Has("Enabled") ? Trigger["Enabled"] : false
    trig := Trigger.Has("TriggerKey") ? Trigger["TriggerKey"] : "?"
    tog  := Trigger.Has("ToggleKey") ? Trigger["ToggleKey"] : ""

    UIc["TriggerStatus"].Text := "Trigger: " (cEnabled ? "ON" : "OFF")
      . "  •  Hold: " trig
      . (tog != "" ? "  •  Toggle: " tog : "")

    if (cEnabled) {
      UIc["TriggerStatus"].SetFont("c7CFC00")
    } else {
      UIc["TriggerStatus"].SetFont("cD0D0D0")
    }
  } catch {
    UIc["TriggerStatus"].Text := "Trigger: N/A"
    UIc["TriggerStatus"].SetFont("c808080")
  }
}

WeaponImagePathByDisplayName(displayName) {
  assetsDir := A_ScriptDir "\assets\"
  stem := NormalizeFileStem(displayName)

  p := assetsDir stem ".png"
  if FileExist(p)
    return p
  return ""
}

NormalizeFileStem(s) {
  s := StrLower(Trim(s))
  s := StrReplace(s, " ", "")
  return RegExReplace(s, '[\\/:*?"<>|]', "")
}
