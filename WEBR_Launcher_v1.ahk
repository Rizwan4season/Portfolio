; ==============================================================================
; WEB-R TECH - Client Support & Automation Portal Launcher
; Target Platform: AutoHotkey v1 (1.1.37+)
; Description: Launches index.html inside a dedicated, standalone Application
;              Window (NO browser address bar, NO browser tabs, NO browser UI)
;              with Always-On-Top enabled.
; ==============================================================================

#Requires AutoHotkey v1.1+
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input
SetTitleMatchMode, 2

; ------------------------------------------------------------------------------
; 1. PATH RESOLUTION
; ------------------------------------------------------------------------------
htmlFile := A_ScriptDir . "\index.html"
if (!FileExist(htmlFile)) {
    MsgBox, 16, WEB-R TECH Error, Target file not found:`n%htmlFile%
    ExitApp
}

; Format path into a valid file:/// URL
fileUrl := "file:///" . StrReplace(htmlFile, "\", "/")

; Locate Edge or Chrome executable
browserExe := ""
browserList := ["C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
              , "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
              , "C:\Program Files\Google\Chrome\Application\chrome.exe"
              , "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"]

for index, path in browserList {
    if (FileExist(path)) {
        browserExe := path
        break
    }
}

if (browserExe = "") {
    browserExe := "msedge.exe" ; Fallback to system PATH
}

; Unique isolated user data directory for the desktop app instance
userDataDir := A_Temp . "\WEBR_Tech_DesktopApp"

; Window dimensions
winWidth := 1340
winHeight := 880

; ------------------------------------------------------------------------------
; 2. LAUNCH STANDALONE APPLICATION WINDOW (No Browser Chrome / No Tabs)
; ------------------------------------------------------------------------------
appCmd := """" . browserExe . """ "
        . "--app=""" . fileUrl . """ "
        . "--window-size=" . winWidth . "," . winHeight . " "
        . "--user-data-dir=""" . userDataDir . """ "
        . "--no-first-run --no-default-browser-check"

Run, %appCmd%

; Target window signature based on document title
winTarget := "WEB-R TECH"

; ------------------------------------------------------------------------------
; 3. WINDOW MANAGEMENT (ALWAYS ON TOP & FOCUS)
; ------------------------------------------------------------------------------
; Wait up to 10 seconds for the application window to initialize
WinWait, %winTarget%,, 10
if (ErrorLevel) {
    MsgBox, 48, WEB-R TECH, Could not detect application window.`nPlease ensure Microsoft Edge or Chrome is installed.
    ExitApp
}

; Obtain unique Window Handle (HWND)
WinGet, hApp, ID, %winTarget%

; Force Always On Top on the application window as requested
WinSet, AlwaysOnTop, On, ahk_id %hApp%

; Activate and center the window on primary screen
WinActivate, ahk_id %hApp%

SysGet, screenW, 78 ; SM_CXVIRTUALSCREEN
SysGet, screenH, 79 ; SM_CYVIRTUALSCREEN
if (screenW = 0 || screenH = 0) {
    SysGet, screenW, 0 ; SM_CXSCREEN
    SysGet, screenH, 1 ; SM_CYSCREEN
}

posX := (screenW - winWidth) // 2
posY := (screenH - winHeight) // 2
if (posX >= 0 && posY >= 0) {
    WinMove, ahk_id %hApp%,, %posX%, %posY%, %winWidth%, %winHeight%
}

; ------------------------------------------------------------------------------
; 4. LIFECYCLE MONITORING
; ------------------------------------------------------------------------------
; Wait until the user closes the application window, then cleanly exit AHK script
WinWaitClose, ahk_id %hApp%
ExitApp

; ------------------------------------------------------------------------------
; HOTKEYS (Active only while WEB-R Window has focus)
; ------------------------------------------------------------------------------
#If WinActive("ahk_id " . hApp)
; Esc closes the app
Esc::
    WinClose, ahk_id %hApp%
return

; Ctrl+T toggles Always-On-Top status
^t::
    WinSet, AlwaysOnTop, Toggle, ahk_id %hApp%
    TrayTip, WEB-R TECH, Always-On-Top Toggled, 1
return
#If
