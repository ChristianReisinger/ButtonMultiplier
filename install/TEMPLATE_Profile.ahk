;<profile_name>	<ahk_window_title>

; NOTE: ';' is an AHK comment, anything after it on the same line is ignored by AHK.
;	The first line above is used by install.sh, with the exception of Default.ahk
;	See README.txt for details

<profile_name>_function(fkey_num,press_duration) {
	d := press_duration

	Switch fkey_num {
		; for each F-key, add a Case statement like here, e.g. 'Case 13: Switch ...' for F13
		
		Case 13: Switch
		{
			; for each duration level, add a Case statement like here.
			; E.g. 'Case d == 1:' is run when the button was held at least as long as the duration set in settings.ini,
			; 'Case d == 2:' is run when it is pressed at least twice as long as the same duration, etc.
			; 'Default:' is run for any duration level without a Case statement

			Case d == 0: ; add any AHK code here, e.g. 'SendInput ^{Tab}' to press Ctrl + Tab
			Case d == 1: 
			Default: 
		}
	
		Case 14: Switch
		{
			Case d == 0: 
			Case d == 1: 
			Default: 
		}
	
		Case 15: Switch
		{
			Case d == 0: 
			Case d == 1: 
			Default: 
		}
	
		Case 16: Switch
		{
			Case d == 0: 
			Case d == 1: 
			Default: 
		}
	
		Case 17: Switch
		{
			Case d == 0: 
			Case d == 1: 
			Default: 
		}
	
		Case 18: Switch
		{
			Case d == 0: 
			Case d == 1: 
			Default: 
		}
	
		Case 19: Switch
		{
			Case d == 0: 
			Case d == 1: 
			Default: 
		}
	
		Case 20: Switch
		{
			Case d == 0: 
			Case d == 1: 
			Default: 
		}
	
		Case 21: Switch
		{
			Case d == 0: 
			Case d == 1: 
			Default: 
		}
}

}


<profile_name>_repeat_while_pressed(fkey_num) {
	; called every 20 milliseconds as long as a button is held down, see README.txt for details

	Switch fkey_num {
		; for each F-key, add a Case statement like here

		Case 13: <RepeatableWhilePressed_Function>(fkey_num)
	}
}


<profile_name>_gesture(gesture_string) {
	; called with the corresponding gesture string when the gesture button is released. See README.txt for details.

	Switch gesture_string {

		; Add a Case statement for each gesture, e.g. 'Case " left up":'
		; The Default statement calls a gesture defined in Default.ahk, if it is not defined here

		Case " ": 	; add any AHK code here
		Case " ":
		Default:	default_gesture(gesture_string)
	}
}


<profile_name>_wheel_up_gesture() {
	; called on mouse wheel up while gesture button is held down
}


<profile_name>_wheel_down_gesture() {
	; called on mouse wheel down while gesture button is held down
}