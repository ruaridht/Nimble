// Header file for Opie Mac

#import <QuartzCore/QuartzCore.h>
#import <Carbon/Carbon.h>
#import <AppKit/AppKit.h>

#import <ShortcutRecorder/ShortcutRecorder.h>
#import <SDGlobalShortcuts/SDGlobalShortcuts.h>

#import <dlfcn.h>
#import <math.h>

#import "CustomWindow.h"
#import "CustomView.h"
#import "NSString+Crop.h"
#import "FileHandler.h"

#import "Ring.h"
#import "RingTheme.h"

#import "NSVTextFieldCell.h"
#import "NSArray+Datasource.h"

// Static Definitions
#define RING_NAME       @"NAME_OF_RING"
#define RING_BLUR       @"RING_BG_BLUR"
#define RING_STICKY     @"RING_STICKY"
#define RING_KEYCODE    @"RING_KEYCODE"
#define RING_MODS       @"RING_MODIFIERS"
#define RING_KEYCOMBO   @"RING_KEYCOMBO"
#define RING_SIZE       @"RING_SIZE"
#define RING_THEME      @"RING_THEME"
#define RING_POSITION   @"RING_POSITION"
#define RING_ICON_SIZE  @"RING_ICON_SIZE"
#define RING_ICON_RAD   @"RING_ICON_RADIUS"