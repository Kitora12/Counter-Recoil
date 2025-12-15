IniGet(file, section, key, default := "") {
  try {
    return IniRead(file, section, key)
  } catch {
    return default
  }
}
