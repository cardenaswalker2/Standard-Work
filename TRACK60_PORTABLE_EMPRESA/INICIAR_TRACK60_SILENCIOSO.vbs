' =========================================================================
' TRACK60 - LANZADOR SILENCIOSO CORPORATIVO (GRUPO DARNEL)
' Ejecuta el servidor y la interfaz gráfica sin mostrar ventana negra de CMD
' =========================================================================

Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

strPath = FSO.GetParentFolderName(WScript.ScriptFullName)
strBat = Chr(34) & strPath & "\INICIAR_TRACK60.bat" & Chr(34)

' Ejecuta el script BAT con estilo 0 (completamente oculto en segundo plano)
WshShell.Run strBat, 0, False

Set WshShell = Nothing
Set FSO = Nothing

