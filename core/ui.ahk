#Requires AutoHotkey v2.0

global UI := unset
global UIc := Map()

; WM_LBUTTONDOWN = 0x0201
OnMessage(0x0201, UI_WM_LBUTTONDOWN)
; WM_LBUTTONDBLCLK = 0x0203
OnMessage(0x0203, UI_WM_LBUTTONDBLCLK)

UI_Create() {
  global UI, UIc

  UI := Gui("-Caption +AlwaysOnTop +ToolWindow", "Counter")
  UI.BackColor := "202225"
  UI.SetFont("s9 cFFFFFF", "Segoe UI")
  UI.MarginX := 12
  UI.MarginY := 10

  UIc["Title"] := UI.AddText("w260", "Counter")
  UIc["Title"].SetFont("s10 bold")

  UIc["Status"] := UI.AddText("w260 y+6", "")
  UIc["Profile"] := UI.AddText("w260 y+4", "")
  UIc["Profile"].SetFont("s8 cC8C8C")

  UI.AddText("w260 y+8 c808080", "Double-click: ON/OFF  •  Drag: move")

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

  PostMessage(0xA1, 2, 0, , "ahk_id " hwnd)  ; WM_NCLBUTTONDOWN, HTCAPTION
}

UI_WM_LBUTTONDBLCLK(wParam, lParam, msg, hwnd) {
  global UI
  if !IsSet(UI)
    return
  if (hwnd != UI.Hwnd)
    return

  ToggleEnabled()
}

UI_Update() {
  global State, UI, UIc
  if !IsSet(UI)
    return

  enabled := State["Enabled"]
  weapon := State["ActiveWeapon"]
  size := StrLen(State["ActiveProfile"])

  UIc["Status"].Text := (enabled ? "ON" : "OFF") "  •  " weapon
  UIc["Profile"].Text := "Profile: " size " chars"

  if enabled
    UIc["Status"].SetFont("c7CFC00")
  else
    UIc["Status"].SetFont("cD0D0D0")
}
