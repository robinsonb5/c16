#include "keyboard.h"

/* Key -> gamepad mapping.  We override this to disable joy emulation since we want
   the keyboard to be a keyboard! */

unsigned char joy_keymap[]=
{
	-1,-1,-1,-1,-1,-1,-1,-1,
	-1,-1,-1,-1,-1,-1,-1,-1
/*	// Port 2
	KEY_CAPSLOCK,
	KEY_LCTRL,	// Button C
	KEY_ALT,	// Button B
	KEY_LSHIFT,	// Button A
	KEY_W,
	KEY_S,
	KEY_A,
	KEY_D,
	// Port 1
	KEY_ENTER,
	KEY_ALTGR,	// Button C
	KEY_RCTRL,	// Button B
	KEY_RSHIFT,	// Button A
	KEY_UPARROW,
	KEY_DOWNARROW,
	KEY_LEFTARROW,
	KEY_RIGHTARROW,
*/
};


/* Initial ROM */
const char *bootrom_name="C16     ROM";
const char bootrom_type=-1;

