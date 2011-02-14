//
//  PreferencesController.h
//  opiemac
//
//  Created by Ruaridh Thomson on 24/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OpieHeader.h"

@interface PreferencesController : NSObject {
	IBOutlet NSWindow *prefWindow;
	
	NSView *currentView;
	IBOutlet NSView *contentView;
	IBOutlet NSView *generalView;
	IBOutlet NSView *aboutView;
	IBOutlet NSView *ringsView;
	
	IBOutlet NSToolbar *prefToolbar;
	IBOutlet NSToolbarItem *generalButton;
	IBOutlet NSToolbarItem *aboutButton;
	
	IBOutlet SRRecorderControl *ringHotkeyControl;
	KeyCombo ringGlobalHotKey;
}

- (IBAction)switchPreferenceView:(id)sender;

- (void)loadView:(NSView *)theView;

- (void)keyDownForRing;
- (void)keyUpForRing;

@end
