; WARNING:	This Default profile and functions in it _must_ exist

default_function(fkey_num,press_duration) {
	d := press_duration

	Switch fkey_num {

		Case 13: Switch
		{
			Case d == 0: 
			Case d == 1: 
			Default: 
		}
	}
}
	

default_repeat_while_pressed(fkey_num) {
	
	Switch fkey_num {

		Case 13: 
	}
}


default_gesture(gesture_string) {

	Switch gesture_string {

		Case " up":		
	}
}