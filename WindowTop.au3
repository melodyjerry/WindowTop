#NoTrayIcon
Opt("TrayMenuMode", 3) ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.
#Res
#Region AutoIt3Wrappers


	#AutoIt3Wrapper_Icon=Resources\Icon.ico

	#AutoIt3Wrapper_Res_Description=v3.0.8
;~ 	#AutoIt3Wrapper_Res_Fileversion=0
;~ 	#AutoIt3Wrapper_Res_ProductVersion=0
	#AutoIt3Wrapper_Res_LegalCopyright=© 2017-2019 gileli121@gmail.com
;~ 	#AutoIt3Wrapper_Res_Comment=WindowTop.info, sourceforge.net/projects/windowtop/ , BiGilSoft.com


	#Region Resources files
		#AutoIt3Wrapper_Res_File_Add=Resources\Images\WinBar\Buttons\Type A\set_top.png, rt_rcdata, img_set_top
		#AutoIt3Wrapper_Res_File_Add=Resources\Images\WinBar\Buttons\Type A\set_dark.png, rt_rcdata, img_set_dark
		#AutoIt3Wrapper_Res_File_Add=Resources\Images\WinBar\Buttons\Type A\set_opacity.png, rt_rcdata, img_set_opacity
		#AutoIt3Wrapper_Res_File_Add=Resources\Images\WinBar\Buttons\Type A\set_shrink.png, rt_rcdata, img_set_shrink


		#AutoIt3Wrapper_Res_File_Add=Resources\Images\save_win_config.png, rt_rcdata, save_win_config

		#AutoIt3Wrapper_Res_File_Add=Changing log.txt, rt_rcdata, ChangingLog

	#EndRegion

	#AutoIt3Wrapper_Run_AU3Check=n
;~ 	#AutoIt3Wrapper_Run_Au3Stripper=y
;~ 	#Au3Stripper_Parameters=/RM /SV=1 /SF=1 /PE

	#AutoIt3Wrapper_UseX64=y

#EndRegion

#Region INCLUDES

	; AUTOIT <INCLUDES>
	#include <MsgBoxConstants.au3>
	#include <StringConstants.au3>
	#include <WindowsConstants.au3>
	#include <WinAPI.au3>
	#include <WinAPISys.au3>



	#include <Array.au3>

	#include <ColorConstantS.au3>
	#include <Misc.au3>
	#include <Process.au3>
	#include <GUIConstantsEx.au3>
	#include <StaticConstants.au3>
	#include <EditConstants.au3>
	#include <ScreenCapture.au3>
	#include <AutoItConstants.au3>
	#include <TrayConstants.au3> ; Required for the $TRAY_CHECKED and $TRAY_ICONSTATE_SHOW constants.
	#include <APIMiscConstants.au3>
	#include <APIResConstants.au3>
	#include <ComboConstants.au3>
	#include <Color.au3>
	#include <IE.au3>
	#include <Date.au3>




	; Low-Level custom  UDFs

	#include 'Include_Third_Party\WinMagnifier.au3'
	#include 'Include_Third_Party\_Startup.au3'
	#include 'Include_Third_Party\NotifyBox.au3'
	#include 'Include_Third_Party\resources2.au3'
	#include 'Include_Third_Party\GUIHyperLink.au3'
	#include 'Include_Third_Party\GUIScrollbars_Ex.au3'


	#include 'Include\LowLevelFunctions.au3'
	#include 'Include\StrDB.au3'
	#include 'Include\Jobs\Jobs.au3'


	; SOFTWARE "INCLUDES"


	#include 'Include\_GuiCtrlIsMouseOver.au3'
	#include 'Include\GUIImageButton.au3'
	#include 'Include\MousePos.au3'


	; INCLUDE.GLOBALS
	#include 'Include\Common.Globals.au3'
	#include 'Include\aWins.Globals.au3'
	#include 'Include\GUIMenuButton.Globals.au3'
	#include 'Include\GUIMenuButton_WinOptions.Globals.au3'
	#include 'Include\MaintainWins.Globals.au3'
	#include 'Include\aExtraFuncCalls.Globals.au3'
	#include 'Include\Tray.Globals.au3'
	#include 'Include\OtherGUIs.Globals.au3'
	#include 'Include\AppHelper.Globals.au3'
	#include 'Include\TriggerEvery.Globals.au3'
	#include 'Include\SoftHotKeys.Globals.au3'

	; INCLUDE
	#include 'Include\Common.au3'
	#include 'Include\aWins.au3'
	#include 'Include\GUIMenuButton.au3'
	#include 'Include\GUIMenuButton_WinOptions.au3'
	#include 'Include\MaintainWins.au3'
	#include 'Include\aExtraFuncCalls.au3'
	#include 'Include\SoftHotKeys.au3'
	#include 'Include\Tray.au3'
	#include 'Include\OtherGUIs.au3'
	#include 'Include\AppHelper.au3'
	#include 'Include\TriggerEvery.au3'


	#include 'Include\OtherMenus.au3'

	#include 'Include\Settings.au3'
	#include 'Include\Debug.au3'

#EndRegion




; ___________________________________________________________








#Region get command from command line

If $CmdLine[0] Then
	Switch $CmdLine[1]
		Case 'helper'
			$bIsExternalProcess = True

	EndSwitch
EndIf
#EndRegion



#Region WindowTop - Second process (WindowTop.exe)

If $bIsExternalProcess Then

	$user32_dll = DllOpen('user32.dll')
	DllCall($user32_dll, "bool", "SetProcessDPIAware")

	_GDIPlus_Startup()

	AppHelper_Soldier_Init()
	If @error Then Exit

	AppHelper_Soldier_MainLoop()



	Exit
EndIf

#EndRegion

#Region Check if WindowTop is already running
	If @Compiled Then
		$tmp = ProcessList(@ScriptName)
		If IsArray($tmp) And $tmp[0][0] > 1 Then Exit MsgBox(64,Null,'WindowTop is already running!')
	EndIf
#EndRegion




TriggerEvery_CallNextFunc()


#Region Startup stuff
	$user32_dll = DllOpen('user32.dll')
	_GDIPlus_Startup()
	GUIRegisterMsg($WM_HOTKEY, SoftHotKeys_WM_HOTKEY)
	$SoftHotKeys_hGUI = GUICreate(Null)

	; Create hidden gui that is on top. the gui will be parent of some other guis
	$g_DummyTopGui = _WinAPI_CreateWindowEx($WS_EX_TOPMOST, 'AutoIt v3 GUI', 'WINDOWTOP_PARENT', $WS_POPUP, 0, 0, 0, 0, _WinAPI_GetDesktopWindow()) ; Fix the startup problem that the the menu button not show up when the program start with windows
	If Not $g_DummyTopGui Then
		If $CmdLine[0] And $CmdLine[1] = 'startup' Then Sleep(30000) ; If the first fix did not work, do the second fix
		$g_DummyTopGui = GUICreate('',0,0,-1,-1,-1,$WS_EX_TOPMOST)
	EndIf
#EndRegion


; Load the settings
	Settings_Load()


; On the first run, ask the user if he want that the program will start with windows
	StartWithWindowsQuestion()



#Region Create the tray menu

	$Tray_Donate_Button = TrayCreateItem('Donate to support the project')

    TrayCreateItem("") ; Create a separator line.

	#Region Info
	$Tray_ChangingLog_Button = TrayCreateItem('Changing log ...')
	$Tray_About_Button = TrayCreateItem("About WindowTop ...")
	$Tray_MorePrograms_Button = TrayCreateItem('More useful programs ...')
	#EndRegion

    TrayCreateItem("") ; Create a separator line.

	#Region Importent functions
	$Tray_StartWithWindows_Button = TrayCreateItem('Start with windows')
	$bIsStartUp = _StartupFolder_Exists()
	If $bIsStartUp Then TrayItemSetState(-1, $TRAY_CHECKED)
	$Tray_DisableMenubar_Button = TrayCreateItem('Disable toolbar menu over windows')
	If $bDisableMenuToolbar Then TrayItemSetState(-1, $TRAY_CHECKED)
	#EndRegion


	TrayCreateItem("") ; Create a separator line.

	#Region HotKeys
	$TrayMenu_HotKeys = TrayCreateMenu('HotKeys (Click to change)')


		$Tray_HK_TSetTop = TrayCreateItem(' ',$TrayMenu_HotKeys)
		Tray_HotKeys_TSetTop_SetText()

		$Tray_HK_SetWindowOpacity = TrayCreateItem(' ',$TrayMenu_HotKeys)
		Tray_HotKeys_SetWindowOpacity_SetText()

		$Tray_HK_TClickThroughForAllTransWins = TrayCreateItem(' ',$TrayMenu_HotKeys)
		Tray_HotKeys_TClickThroughForAllTransWins_SetText()

		$Tray_HK_SetShrinkMode = TrayCreateItem(' ',$TrayMenu_HotKeys)
		Tray_HotKeys_TShrink_SetText()

	#EndRegion


	$Tray_ToolBarOptions = TrayCreateItem('Toolbar options ...')


	#Region WindowTop Pro section - REMOVED
	#EndRegion

	TrayCreateItem("") ; Create a separator line.

	#Region Other functions
	$Tray_DisableClickThroughAllWindows_Button = TrayCreateItem('Disable "Click Through" mode for all windows')
	$Tray_UnSetAllWindowsFromTop_Button = TrayCreateItem('Disable "Set Top" for all windows')
	$Tray_UnShrinkAllWindows_Button = TrayCreateItem('Disable "Shrink" mode for all windows')
;~ 	$Tray_ShrinkAllWindows_Button = TrayCreateItem('Non-minimized windows --> Shrink!')
	$Tray_MinimizeAllShrinkedWinsToTaskbar = TrayCreateItem('Shrinked windows --> Minimize to taskbar')
	#EndRegion



	TrayCreateItem("") ; Create a separator line.
	$Tray_Exit_Button = TrayCreateItem("Exit")


    TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.
#EndRegion


; Show to the user that some feachers are not fully supported in windows 10
	;Windows10CompatibilityWarning()


; Register code that will run when the software shut douwn
	OnAutoItExitRegister(OnExit)


; Stuff for the main loop
	Global $timer_UpdateWins



#Region Main Loop that must alweys run

	While Sleep(10) ; Start main loop


		; Handle windows changes

			; Update the windows in aWins every 1 sec or on first check

				If TimerDiff($timer_UpdateWins) >= 1000 Then
					aWins_Update()
					$timer_UpdateWins = TimerInit()
				EndIf


		; Update software MSG before ...

			$Software_MSG = GUIGetMsg(1)

			;
				MaintainWins()

		; Call to a dynamic list of functions. every function that return True is removed from the list
			aExtraFuncCalls_CallFuncs()


		; React to another tray events
			Switch $Software_MSG[1]
				Case $GUIMenuButton_hOld
					Switch $Software_MSG[0]
						Case $GUIMeBu_SaveWinSettings
							;ConsoleWrite('$GUIMeBu_SaveWinSettings, active window: '& $GUIMenuButton_iActiveWin_old &' (L: '&@ScriptLineNumber&')'&@CRLF)

							FeatureOnlyProMSG(True)
					EndSwitch

			EndSwitch


		; React to tray events
			Switch TrayGetMsg()

				Case $Tray_Donate_Button
					ShellExecute("https://windowtop.info/support-project/")

				Case $Tray_About_Button ; Display a message box about the AutoIt version and installation path of the AutoIt executable.
					_NotifyBox(64, "About WindowTop",'Version: '&$ProgramVersion_Text & @CRLF &@CRLF& _
							'Project pages:'&@CRLF&@CRLF&'WindowTop.info'&@CRLF&'https://github.com/gileli121/WindowTop'&@CRLF&@CRLF& _
							'developed by gileli121@gmail.com / bigilsoft.com')

				Case $Tray_MorePrograms_Button
					ShellExecute('http://bigilsoft.com/')

				Case $Tray_Exit_Button ; Exit the loop.
					ExitLoop

				Case $Tray_StartWithWindows_Button
					If Not $bIsStartUp Then



						If Not StringInStr(@ScriptDir,'Program Files') Then
							If MsgBox($MB_YESNO,'Are you sure?','It is strongly recommend to install the software before this'&@CRLF& _
												'Are you sure you want to continue?') = $IDNO Then ContinueLoop

						EndIf

						InstallStartup()
						If Not @error Then
							TrayItemSetState($Tray_StartWithWindows_Button,$TRAY_CHECKED)
							$bIsStartUp = True
						Else
							MsgBox(16,'Error','Error adding the program to startup')
						EndIf
					Else
						_StartupFolder_Uninstall()
						If Not @error Then
							TrayItemSetState($Tray_StartWithWindows_Button,$TRAY_UNCHECKED)
							$bIsStartUp = False
						Else
							MsgBox(16,'Error','Error removing the program from startup')
						EndIf
					EndIf

				Case $Tray_ChangingLog_Button
					ChangingLog()



				Case $Tray_DisableMenubar_Button
					If Not $bDisableMenuToolbar Then
						TrayItemSetState($Tray_DisableMenubar_Button,$TRAY_CHECKED)
						If $GUIMenuButton_h <> -1 Then
							GUIMenuButton_Delete()
							$GUIMenuButton_iActiveWin = 0
						EndIf
						$bDisableMenuToolbar = True
					Else
						TrayItemSetState($Tray_DisableMenubar_Button,$TRAY_UNCHECKED)
						$bDisableMenuToolbar = False
					EndIf
					IniWrite($ini,'Main','DisableMenuToolbar',Number($bDisableMenuToolbar))

				Case $Tray_DisableClickThroughAllWindows_Button
					For $a = 1 To $aWins[0][0]
						If Not $aWins[$a][$C_aWins_idx_IsClickThrough] Then ContinueLoop
						aWins_ToggleClickThrough($a, False)
					Next
				Case $Tray_UnSetAllWindowsFromTop_Button

					For $a = 1 To $aWins[0][0]
						aWins_SetOnTop($a,False)
					Next


					$tmp = WinList("[REGEXPTITLE:[A-Za-z0-9]]")
					For $a = 1 To $tmp[0][0]
						If Not BitAND(WinGetState($tmp[$a][1]), $WIN_STATE_VISIBLE) Or Not _WinIsOnTop($tmp[$a][1]) Then ContinueLoop
						WinSetOnTop($tmp[$a][1],Null,False)
					Next
					$tmp = Null

				Case $Tray_UnShrinkAllWindows_Button
					If $bRunFeatureInThislProcess Then
						aWins_ShrinkAllWins_EnableDisable(False)
					Else
						Jobs_CallAction($AppHelper_Soldier_hCommunicationGUI, _
						$C_AppHelper_Soldier_Action_UnShrinkAllWindows, _
						Null, Null)
					EndIf
;~ 				Case $Tray_ShrinkAllWindows_Button
;~ 					aWins_ShrinkAllWins_EnableDisable(True)

				Case $Tray_MinimizeAllShrinkedWinsToTaskbar
					If $bRunFeatureInThislProcess Then
						aWins_MinimizeAllShrinkedWinsToTaskbar()
					Else
						Jobs_CallAction($AppHelper_Soldier_hCommunicationGUI, _
						$C_AppHelper_Soldier_Action_MinimizeAllShrinkedWinsToTaskbar, _
						Null, Null)
					EndIf



				; HOT KEYS


				Case $Tray_ToolBarOptions

					ToolBarOptions(True)


			#Region HotKeys
			#Region
				Case $Tray_HK_TClickThroughForAllTransWins
					SoftHotKeys_SetKeyGUI(True,$TClickThroughAnyOpcWin_aSKey)
				Case $Tray_HK_TSetTop
					SoftHotKeys_SetKeyGUI(True,$SetWindowTop_aSKey)
				Case $Tray_HK_SetWindowOpacity
					SoftHotKeys_SetKeyGUI(True,$SetWindowOpc_aSKey)
				Case $Tray_HK_SetShrinkMode
					SoftHotKeys_SetKeyGUI(True,$TShrink_aSKey)

				; Toolbar Options
			#EndRegion
			#EndRegion

			#Region WindowTop Pro - REMOVED
			#Region

			#EndRegion
			#EndRegion

			EndSwitch

	WEnd

#EndRegion
