//
//  AppController.h
//  opiemac
//
//  Created by Ruaridh Thomson on 24/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OpieHeader.h"

@interface AppController : NSObject <NSApplicationDelegate> {
	IBOutlet NSWindow *window;
	
	IBOutlet NSImageView *testView;
	
	BOOL ringIsActive;
	
	Ring *launchedAppsRing;
	Ring *otherLARing;
	Ring *currentRing;
	
	IBOutlet NSMenu *statusMenu;
	NSStatusItem *statusItem;
	
	// Preferences
	IBOutlet NSWindow *prefWindow;
	
	NSView *currentView;
	IBOutlet NSView *contentView;
	IBOutlet NSView *generalView;
	IBOutlet NSView *aboutView;
	IBOutlet NSView *ringsView;
	
	IBOutlet NSToolbar *prefToolbar;
	IBOutlet NSToolbarItem *generalButton;
	IBOutlet NSToolbarItem *aboutButton;
	IBOutlet NSToolbarItem *ringsButtons;
	
	IBOutlet SRRecorderControl *theRingRecorderControl;
	IBOutlet NSSegmentedControl *ringPositionControl;
}

@property (readwrite, assign) Ring *_currentRing;

- (IBAction)testButton:(id)sender;
- (IBAction)test2Button:(id)sender;

- (void)animateRingIn;
- (void)mouseMovedForRing:(NSNotification *)aNote;
- (void)mouseDownForRing:(NSNotification *)aNote;
- (void)keyUpForRing:(NSNotification *)aNote;

// Preferences
- (void)setCurrentRing:(Ring *)aRing;
- (IBAction)switchPreferenceView:(id)sender;
- (void)loadView:(NSView *)theView;
- (IBAction)setRingCenterPosition:(id)sender;

@end
