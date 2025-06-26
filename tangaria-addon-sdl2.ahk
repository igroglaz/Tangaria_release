;// SDL2 Tangaria addon
;//
;//numlock off
SetNumLockState, AlwaysOff
;//capslock off
SetCapsLockState, AlwaysOff
;////////////////////////////////////////
;//winkey -> F13
LWin::F13
;//capslock -> F14
~Capslock::F14
;//numlock -> F15
PrintScreen::F15

;// alt+f4 = ctrl + '\'
!F4::SendInput ^\

;/////////////////////////////////////// NOT USED:
;//Remapping Num5 -> f8;
;// vk0C::F8 // NO NEED
;// tab -> F7
;// Tab::F7 // NO NEED
;//` (tilda) -> F6
;// vkC0::F6 // NO NEED
;//ESC -> F5 // you be able to do so, but you need to arrange ESC manually in .prf BEWARE:
;// if you would open '%' screen - you won't be able to exit it with remapped ESC
;// vk1B::F5
;//////////////////////////////////////// disable alt+tab
!Tab::Return
;////////////////////////////////////////
;//Fixing alt-problem
~LAlt Up:: return
;////////////////////////////////////////
;//Prevent language change
*!Shift::
KeyWait,Shift ;// Wait for the Shift key to be released.
KeyWait,Alt   ;// Wait for the Alt key to be released.
return

*+Alt::
KeyWait,Alt   ;// Wait for the Alt key to be released.
KeyWait,Shift ;// Wait for the Shift key to be released.
return