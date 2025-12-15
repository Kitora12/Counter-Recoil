Profiles_Load(weaponId) {
  path := A_ScriptDir "\profiles\" weaponId ".profile"
  if !FileExist(path)
    return ""
  return FileRead(path, "UTF-8")
}

Profiles_ParseSteps(profileText) {
  steps := []
  if (profileText = "")
    return steps

  for line in StrSplit(profileText, "`n", "`r") {
    line := Trim(line)
    if (line = "")
      continue
    if (SubStr(line, 1, 1) = ";" || SubStr(line, 1, 1) = "#")
      continue

    ; retire commentaire fin de ligne
    semi := InStr(line, ";")
    if (semi)
      line := Trim(SubStr(line, 1, semi - 1))

    parts := StrSplit(line, ",")
    if (parts.Length < 3)
      continue

    dx := Number(Trim(parts[1]))
    dy := Number(Trim(parts[2]))
    delay := Integer(Trim(parts[3]))

    steps.Push(Map("dx", dx, "dy", dy, "delay", delay))
  }
  return steps
}
