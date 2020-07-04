;// Addon for one-window setup. Guide how to use it: 
;//         https://tangar.info/en/tangaria-game
;//
;numlock off
SetNumLockState, AlwaysOff
;capslock off
SetCapsLockState, AlwaysOff
; ////////////////////////////////////////
;winkey -> F11
LWin::F11
;capslock -> F10
~Capslock::F10
;numlock -> F9
Numlock::
{
KeyWait, NumLock
sendinput, {F9}
}
; /////////////////////////////////////// NOT USED:
;Remapping Num5 -> f8;
;vk0C::F8 // NO NEED
;tab -> F7
;Tab::F7 // NO NEED
;` (tilda) -> F6
;vkC0::F6 // NO NEED
;ESC -> F5 // do be able to do so, you need to arrange ESC manually in .prf BEWARE: if you would open '%' screen - you won't be able to exit it with remapped ESC (/rfed this problem)
;vk1B::F5
;////////////////////////////////////////
;Fixing alt-problem
~LAlt Up:: return
;Activate addon WinKey+LMC at the window
MButton & LButton::
Winset, Alwaysontop, On, A
WinSet, Style, -0xC00000, A
WinSet, Style, -0xC40000, A
;//////////////////////////////////////////////////////////////////////////
;// when new client version is out: change header ↓
WinSet, Region, 0-30 W1920 H1080, PWMAngband 1.4.0 (Beta 13) 
;// If you wish to hide first stroke of gaming window:
;// remove ";" at beginning of this line.
;// Also change W1300 H550 at your resolution, for example W1680 H1050. 
;//////////////////////////////////////////////////////////////////////////
; TERM-1
WinSet, Style, -0xC00000, Term-1 ;
WinSet, Style, -0xC40000, Term-1 ;
WinSet, Region, 0-30 W1920 H1080, Term-1 ; hide term header
WinMove, Term-1, , 0, -30 ; move term-1 up
; TERM-5
WinSet, Region, 0-70 W1920 H1080, Term-5 ; hide term header
WinMove, Term-5, , 1490, -103 ; move term-5 up
;;
WinSet, Region, 0-30 W1920 H1080, ZZoom - V1.0 ;
;;

;WinSet, Region, 275-34  1660-34 1660-988 275-988, Term-6 ; could be used to cut screen from Term-6
return ;
;Deactivate addon WinKey+RMC at the window
MButton & RButton::
WinSet, Style, +0xC00000, A
return ;