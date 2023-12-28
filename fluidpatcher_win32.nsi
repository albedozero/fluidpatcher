; fluidpatcher

;--------------------------------

; The name of the installer
Name "FluidPatcher (win x86)"

; The file to write
OutFile "setup_fluidpatcher_win32.exe"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

; Build Unicode installer
Unicode True

; The default installation directory
InstallDir $PROGRAMFILES\FluidPatcher

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\GeekFunkLabs\FluidPatcher" "Install_Dir"

;--------------------------------

; StrContains
; This function does a case sensitive searches for an occurrence of a substring in a string. 
; It returns the substring if it is found. 
; Otherwise it returns null(""). 
; Written by kenglish_hi
; Adapted from StrReplace written by dandaman32
 
 
Var STR_HAYSTACK
Var STR_NEEDLE
Var STR_CONTAINS_VAR_1
Var STR_CONTAINS_VAR_2
Var STR_CONTAINS_VAR_3
Var STR_CONTAINS_VAR_4
Var STR_RETURN_VAR
 
Function StrContains
  Exch $STR_NEEDLE
  Exch 1
  Exch $STR_HAYSTACK
  ; Uncomment to debug
  ;MessageBox MB_OK 'STR_NEEDLE = $STR_NEEDLE STR_HAYSTACK = $STR_HAYSTACK '
    StrCpy $STR_RETURN_VAR ""
    StrCpy $STR_CONTAINS_VAR_1 -1
    StrLen $STR_CONTAINS_VAR_2 $STR_NEEDLE
    StrLen $STR_CONTAINS_VAR_4 $STR_HAYSTACK
    loop:
      IntOp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_1 + 1
      StrCpy $STR_CONTAINS_VAR_3 $STR_HAYSTACK $STR_CONTAINS_VAR_2 $STR_CONTAINS_VAR_1
      StrCmp $STR_CONTAINS_VAR_3 $STR_NEEDLE found
      StrCmp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_4 done
      Goto loop
    found:
      StrCpy $STR_RETURN_VAR $STR_NEEDLE
      Goto done
    done:
   Pop $STR_NEEDLE ;Prevent "invalid opcode" errors and keep the
   Exch $STR_RETURN_VAR  
FunctionEnd
 
!macro _StrContainsConstructor OUT NEEDLE HAYSTACK
  Push `${HAYSTACK}`
  Push `${NEEDLE}`
  Call StrContains
  Pop `${OUT}`
!macroend
 
!define StrContains '!insertmacro "_StrContainsConstructor"'


; Pages

Page license
Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

LicenseData LICENSE

;--------------------------------

; The stuff to install

Section -Prerequisites
  nsExec::ExecToStack "py -3.9-32 -VV"
  Pop $0 ; return code
  Pop $1 ; command output
  StrCmp $0 "error" instPython ; py command didn't work
  ${StrContains} $0 "Python 3.9" $1 ; correct python version?
  StrCmp $0 "" 0 donePython
  instPython:
	MessageBox MB_YESNO "Python 3.9 is required for FluidPatcher.$\nYour system does not appear to have 32-bit Python 3.9 installed.$\nWould you like to install it now?" /SD IDYES IDNO failedPython
	SetOutPath $TEMP
    File "bundled\python-3.9.13.exe"
	ExecWait "$TEMP\python-3.9.13.exe"
	IfErrors 0 donePython
  failedPython:
	MessageBox MB_OK "Required Python version not installed. Exiting."
	Quit
  donePython:
  nsExec::ExecToStack "py -3.9-32 -m pip -q show oyaml wxpython"
  Pop $0 ; return code
  Pop $1 ; command output
  ${StrContains} $0 "not found" $1 ; at least one package was not installed
  StrCmp $0 "" donePackages
    MessageBox MB_OK "Additional python packages are required.$\nPress OK to install them."
    ExecWait "py -3.9-32 -m pip install -U oyaml"
    ExecWait "py -3.9-32 -m pip install -U wxpython"
	IfErrors 0 donePackages
	MessageBox MB_OK "Failed to install required python packages. Exiting."
	Quit
  donePackages:
SectionEnd


Section "FluidPatcher (required)"

  SectionIn RO
  
  ; program installation directory
  SetOutPath $INSTDIR
  SetOverwrite on
  File "fluidsynth_win32\*"
  File "LICENSE"
  File "README.md"
  File /r "*.py"
  File /r "*.pyw"
  CreateDirectory "$INSTDIR\assets"
  SetOutPath "$INSTDIR\assets"
  File /r "assets\*"

  ; documents directory
  CreateDirectory "$DOCUMENTS\FluidPatcher"
  SetOutPath "$DOCUMENTS\FluidPatcher"
  IfFileExists "$DOCUMENTS\FluidPatcher\fluidpatcherconf.yaml" +7
    File "fluidpatcherconf.yaml"
    FileOpen $0 "$DOCUMENTS\FluidPatcher\fluidpatcherconf.yaml" a
    FileSeek $0 0 END
    FileWrite $0 "soundfontdir: $DOCUMENTS\FluidPatcher\sf2$\n"
    FileWrite $0 "bankdir: $DOCUMENTS\FluidPatcher\banks$\n"
    FileWrite $0 "mfilesdir: $DOCUMENTS\FluidPatcher\midi$\n"
    FileClose $0
  SetOverwrite off
  CreateDirectory "$DOCUMENTS\FluidPatcher\sf2"
  SetOutPath "$DOCUMENTS\FluidPatcher\sf2"
  File "SquishBox\sf2\*"
  CreateDirectory "$DOCUMENTS\FluidPatcher\banks"
  SetOutPath "$DOCUMENTS\FluidPatcher\banks"
  File "SquishBox\banks\*"
  CreateDirectory "$DOCUMENTS\FluidPatcher\midi"
  SetOutPath "$DOCUMENTS\FluidPatcher\midi"
  File "SquishBox\midi\*"

  ; Write the installation path into the registry
  WriteRegStr HKLM Software\GeekFunkLabs\FluidPatcher "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FluidPatcher" "DisplayName" "FluidPatcher"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FluidPatcher" "DisplayIcon" "$INSTDIR\assets\gfl_logo.ico"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FluidPatcher" "Publisher" "Geek Funk Labs"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FluidPatcher" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FluidPatcher" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FluidPatcher" "NoRepair" 1
  WriteUninstaller "$INSTDIR\uninstall.exe"
  
  ; Add the installation path to PATH
  EnVar::SetHKLM
  EnVar::AddValue "PATH" "$INSTDIR"
  
SectionEnd

Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\FluidPatcher"
  SetOutPath $INSTDIR
  CreateShortcut "$SMPROGRAMS\FluidPatcher\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortcut "$SMPROGRAMS\FluidPatcher\FluidPatcher.lnk" "pyw" '-3.9-32 fluidpatcher.pyw "$DOCUMENTS\FluidPatcher\fluidpatcherconf.yaml"' "$INSTDIR\assets\gfl_logo.ico" 0
  CreateShortcut "$SMPROGRAMS\FluidPatcher\README.lnk" "$INSTDIR\README.md"
  
SectionEnd

Section "Desktop Shortcut"

  SetOutPath $INSTDIR
  CreateShortcut "$DESKTOP\FluidPatcher.lnk" "pyw" '-3.9-32 fluidpatcher.pyw "$DOCUMENTS\FluidPatcher\fluidpatcherconf.yaml"' "$INSTDIR\assets\gfl_logo.ico" 0
  
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FluidPatcher"
  DeleteRegKey HKLM Software\GeekFunkLabs\FluidPatcher

  ; Remove the installation path from PATH
  EnVar::SetHKLM
  EnVar::DeleteValue "PATH" "$INSTDIR"

  ; Remove files
  RMDir /r $INSTDIR

  Delete "$SMPROGRAMS\FluidPatcher\*"
  RMDir "$SMPROGRAMS\FluidPatcher"

  Delete "$DESKTOP\FluidPatcher.lnk"


SectionEnd
