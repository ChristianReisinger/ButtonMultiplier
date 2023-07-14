///////////////////////////////// What is ButtonMultiplier? ////////////////////////////////// 

ButtonMultiplier is a script to implement, based on the active window:
	- multiple functions for keys F1-F24 depending on how long the button is pressed
	- mouse gestures (optional) - the gesture button is right mouse button and cannot currently be changed

 * The suggested use case for this script is to set keys F13-F24 to mouse buttons with the corresponding software
 * A function or gesture can be any AHK script, defined in user profiles for each window
 * Duration by which functions for each button are seperated can be adjusted
 * Max number of functions per button can be adjusted

For details, read below

///////////////////////////////////// Before installing ///////////////////////////////////// 

 * Edit values in user/settings.ini if desired:

	- Duration_level_separation_milliseconds: number of milliseconds a button must be held down to activate the next 'duration level'.
	  A button can be assigned a different function for each duration level.

	- Gesture_max_duration_level: maximum number of 'duration levels' recognized when doing gestures.
	  Any level greater than this value behaves as if this maximum level is used.

	- FButtons: add the number of each F-key that should be recognized by the script, separated by spaces (no new lines!).
	  Only values from 1 to 24 are allowed

	- NOTE: AutoHotkey.exe may need to be configured to run as Administrator for some functionality
	  (Properties > Compatibility > "Run as Administrator" checkmark).

 * Add profiles to user\profiles\

	- The filename can be anything, but must end in ".ahk" (except "Default.ahk" which must exist)

	- The first line in each profile file (except Default) must be:
		;<profile_name> <ahk_window_title>

	  <profile_name> must be a string of only alphabetic characters A-Z, a-z.
	  <ahk_window_title> is the argument, including quotes, of the ahk WinActive() function, which determines the window this
	  profile should be active for. E.g. "ahk_exe my_program.exe"

	- To assign functions dependent on a buttons press duration, a profile must define the function
		<profile_name>_function(fkey_num,press_duration)

	- To assign gestures, a profile must define one or more of the functions
		<profile_name>_gesture(gesture_string)
		<profile_name>_wheel_up_gesture()
		<profile_name>_wheel_down_gesture()

	  If at least on of these is defined, gestures will be active. I.e. the hold-and-drag functionality of the gesture button (right mouse)
	  will be replaced by the gesture and thus no longer work.

	  gesture_string is a string containing the gestures in the order they are pressed, each with a leading space. Possible values of the gestures are
		left			when mouse is moved left
		right			when mouse is moved right
		up			when mouse is moved up
		down			when mouse is moved down
		L			when mouse is left-clicked
		WU			when mouse wheel is scrolled up by one click
		WD			when mouse wheel is scrolled down by one click
		f<num>d<dur_lvl>	when the F<num> key is pressed and released at duration level <dur_lvl>
	  e.g. " left right f16d2 WD up f20d0"

	- To assign functions to a held-down button state, a profile must define the function
		<profile_name>_repeat_while_pressed(fkey_num)
	  
	  This function is called every 20 ms as long as a button is held down. The global array fkey_repeat_action[fkey_num] is set to
		"init" when the button is first pressed
		"run" as long as the button is held down
		"end" when the button is released

	  Possible implementations are found in functions\RepeatableWhilePressed.ahk

	- For an exemplary definition of the profile functions, refer to user\TEMPLATE_Profile.ahk after installation

///////////////////////////////////// How to install //////////////////////////////////////// 

 * Put the needed utilities (see github):
	CycleWindowMonitor
   into util/
	
 * Run install.sh with bash (e.g. with cygwin) from the root directory (do not run from outside the root directory!)

 * To run the script, run ButtonMultiplier.ahk

 * Profiles can be changed (but not added) without reinstalling (except for the the first line), but the script must be reloaded (Ctrl+Alt+R)


///////////////////////////////////// Notes ///////////////////////////////////////////////// 

 * All files in autoexec\, impl\, install\ are internal and should not be edited

 * The user/ directory contains settings and profiles. The file user/profiles/Default.ahk must exist and define the
   default_function(fkey_num) and default_gesture(gesture_string) functions

 * The file user/TEMPLATE_Profile.ahk is only a template and is never used

 * The files functions\Functions.ahk, functions\RepeatableWhilePressed.ahk contain functions that can be used in the profile files.
   Functions in RepeatableWhilePressed.ahk contain functions for use in the <profile_name>_repeat_while_pressed(fkey_num) profile function.
   These files do not contain any internal implementation and can be edited

 * Ctrl + Alt + y hides the tray icon. Ctrl + Alt + r reloads the script and shows the tray icon.