//
//  AppController.h
//  opiemac
//
//  Created by Ruaridh Thomson on 24/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OpieHeader.h"

// Direct Imports
#import "NSArray+Datasource.h"

@interface AppController : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    FileHandler *handler;
    
	Ring *currentRing;
	NSMutableArray *allRings;
	
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
	
	IBOutlet NSTableView *ringTable;
	NSMutableArray *ringRecords;
    
    IBOutlet NSButton *openPrefsButton;
    
    // Anything past here is being tested.
    // Nothing
}

@property (readwrite, assign) Ring *_currentRing;

// Test
- (IBAction)testButton:(id)sender;

// General
- (void)removeAppFromFront;

// Preferences
- (void)setCurrentRing:(Ring *)aRing;
- (IBAction)switchPreferenceView:(id)sender;
- (void)loadView:(NSView *)theView;
- (IBAction)setRingCenterPosition:(id)sender;
- (IBAction)toggleBlurredBackground:(id)sender;

- (IBAction)openPreferences:(id)sender;
- (IBAction)ringPreferenceChanged:(id)sender;
- (IBAction)ringSizeChanged:(id)sender;
- (IBAction)setOpenPrefsUsingRing:(id)sender;
- (IBAction)toggleMenubarIcon:(id)sender;

- (IBAction)openURLWebsite:(id)sender;
- (IBAction)openURLFaq:(id)sender;
- (IBAction)openURLChangelog:(id)sender;

- (BOOL)loadRings;
- (void)saveRings;

// Delegates
- (NSDictionary *)tableViewRecordForTab:(NSString *)tabName iconName:(NSString *)iconName;
- (void)shortcutRecorder:(SRRecorderControl *)recorder keyComboDidChange:(KeyCombo)newKeyCombo;

@end
