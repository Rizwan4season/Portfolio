; ==============================================================================
; WEB-R TECH - Client Support & Automation Portal Launcher (AHK v2 Companion)
; Target Platform: AutoHotkey v2.0+
; Description: Embeds index.html inside a native AHK v2 Gui with AlwaysOnTop
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

htmlFile := A_ScriptDir . "\index.html"
if (!FileExist(htmlFile)) {
    MsgBox("Target file not found:`n" . htmlFile, "WEB-R TECH Error", 0x10)
    ExitApp()
}

fileUrl := "file:///" . StrReplace(htmlFile, "\", "/")
userDataDir := A_Temp . "\WEBR_Tech_DesktopApp_v2"

; Launch as standalone application window with AHK v2 process management
winWidth := 1340
winHeight := 880

edgeCmd := 'msedge.exe --app="' . fileUrl . '" --window-size=' . winWidth . ',' . winHeight . ' --user-data-dir="' . userDataDir . '"'

Run(edgeCmd,,, &appPID)

if (WinWait("ahk_pid " . appPID,, 6)) {
    WinSetAlwaysOnTop(1, "ahk_pid " . appPID)
    WinActivate("ahk_pid " . appPID)
}

WinWaitClose("ahk_pid " . appPID)
ExitApp()

#HotIf WinActive("ahk_pid " . appPID)
Esc::WinClose("ahk_pid " . appPID)
^t::WinSetAlwaysOnTop(-1, "ahk_pid " . appPID)
#HotIf
