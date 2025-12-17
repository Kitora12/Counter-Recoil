Profiles_Load(weaponId) {
  config := A_ScriptDir "\config\config.ini"

  profileName := Trim(IniGet(config, "Profiles", weaponId, weaponId))
  if (profileName = "")
    profileName := weaponId

  path := A_ScriptDir "\profiles\" profileName ".profile"

  if !FileExist(path)
    return ""

  return FileRead(path, "UTF-8")
}

Profiles_DisplayName(weaponId) {
  config := A_ScriptDir "\config\config.ini"

  try {
    section := IniRead(config, "Profiles")
  } catch {
    return weaponId
  }

  for line in StrSplit(section, "`n", "`r") {
    line := Trim(line)
    if (line = "" || SubStr(line, 1, 1) = ";" || SubStr(line, 1, 1) = "#")
      continue

    parts := StrSplit(line, "=", , 2)
    if (parts.Length < 2)
      continue

    name := Trim(parts[1])
    id   := Trim(parts[2])

    if (id = weaponId)
      return name
  }

  return weaponId
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
