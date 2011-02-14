//
//  AppController.m
//  opiemac
//
//  Created by Ruaridh Thomson on 24/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import "AppController.h"
#import "OpieHeader.h"

@implementation AppController

@synthesize _currentRing = currentRing;

- (id)init
{
	if (![super init])
		return nil;
	
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseMovedForRing:) name:@"mouseMovedForRing" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseDownForRing:) name:@"mouseDownForRing" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyUpForRing:) name:@"ringGlobalHotkeyUpTriggered" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateRingIn) name:@"ringGlobalHotkeyDownTriggered" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:NSApplicationWillResignActiveNotification object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidResignActive:) name:NSApplicationDidResignActiveNotification object:nil];
	
	[NSApp setDelegate:self];
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
	
	launchedAppsRing = [[Ring alloc] initWithName:@"launchedAppsRing"];
	otherLARing = [[Ring alloc] initWithName:@"otherLARing"];
	
	return self;
}

- (void)awakeFromNib
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setTitle:@"N"];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
	
	//Preferences
	/*
	SDGlobalShortcutsController *shortcutsController = [SDGlobalShortcutsController sharedShortcutsController];
	[shortcutsController addShortcutFromDefaultsKey:@"ringGlobalHotkey"
										withControl:ringHotkeyControl
											 target:self
									selectorForDown:@selector(animateRingIn)
											  andUp:@selector(keyUpForRing:)];
	 */
	[theRingRecorderControl setDelegate:self];
	[theRingRecorderControl setCanCaptureGlobalHotKeys:YES];
	
	[prefToolbar setSelectedItemIdentifier:[generalButton itemIdentifier]];
	[contentView addSubview:generalView];
	currentView = generalView;
	
	[self setCurrentRing:launchedAppsRing];
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark -
#pragma mark Delegates

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	
}

- (void)applicationWillHide:(NSNotification *)notification
{
	
}

- (void)applicationWillUnhide:(NSNotification *)notification
{
	
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
	
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
	
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
	
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	
}

#pragma mark -
#pragma mark IBActions

- (IBAction)testButton:(id)sender
{
	if (currentRing == launchedAppsRing) {
		[self setCurrentRing:otherLARing];
	} else if (currentRing == otherLARing) {
		[self setCurrentRing:launchedAppsRing];
	}
}

- (IBAction)test2Button:(id)sender
{
	[launchedAppsRing tintRingWithColour:[sender color]];
}

#pragma mark Animations

- (void)animateRingIn
{
	[launchedAppsRing animateRingIn];
}

- (void)mouseMovedForRing:(NSNotification *)aNote
{
	[launchedAppsRing mouseMovedForRing];
}

- (void)mouseDownForRing:(NSNotification *)aNote
{
	[launchedAppsRing keyUpForRing];
}

- (void)keyUpForRing:(NSNotification *)aNote
{
	[launchedAppsRing keyUpForRing];
}

#pragma mark -
#pragma mark Preferences

- (void)setCurrentRing:(Ring *)aRing
{
	[self willChangeValueForKey:@"currentRing"];
	currentRing = aRing;
	[theRingRecorderControl setKeyCombo:[currentRing currentKeyCombo]];
	[ringPositionControl setSelectedSegment:[currentRing ringPosition]];
	[self didChangeValueForKey:@"currentRing"];
}

- (IBAction)switchPreferenceView:(id)sender
{
	[prefToolbar setSelectedItemIdentifier:[sender itemIdentifier]];
	
	if ([sender tag] == 1) {
		[self loadView:generalView];
	} else if ([sender tag] == 2) {
		[self loadView:aboutView];
	} else if ([sender tag] == 3) {
		[self loadView:ringsView];
	}
}

- (void)loadView:(NSView *)theView
{
	/*
	[[[prefWindow contentView] animator] setFrame:[theView frame]];
	[contentView replaceSubview:currentView with:theView];
	currentView = theView;
	 */
	
	NSView *tempView = [[NSView alloc] initWithFrame: [[prefWindow contentView] frame]];
    [prefWindow setContentView: tempView];
    [tempView release];
	
	NSRect newFrame = [prefWindow frame];
    newFrame.size.height =	[theView frame].size.height + ([prefWindow frame].size.height - [[prefWindow contentView] frame].size.height); // Compensates for toolbar
    newFrame.size.width =	[theView frame].size.width;
    newFrame.origin.y +=	([[prefWindow contentView] frame].size.height - [theView frame].size.height); // Origin moves by difference in two views
    newFrame.origin.x +=	([[prefWindow contentView] frame].size.width - newFrame.size.width)/2; // Origin moves by difference in two views, halved to keep center alignment
    
	[prefWindow setFrame: newFrame display: YES animate: YES];
    [prefWindow setContentView: theView];
}

- (IBAction)setRingCenterPosition:(id)sender
{
	[currentRing setRingDrawingPosition:[sender selectedSegment]];
}

#pragma mark -
#pragma mark ShortcutRecorder Delegate

- (void)shortcutRecorder:(SRRecorderControl *)recorder keyComboDidChange:(KeyCombo)newKeyCombo
{
    [currentRing setGlobalHotkey:[theRingRecorderControl keyCombo]];
}

@end