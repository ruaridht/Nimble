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
	
	allRings = [[NSMutableArray array] retain];
	
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
	
	if ([self loadRings])
		[self setCurrentRing:[allRings objectAtIndex:0]];
	
	ringRecords = [[NSMutableArray alloc] init];
	[ringTable setDataSource:self];
	[ringTable setDelegate:self];
	[ringTable setTarget:self];
	
	NSVTextFieldCell *cell;
	cell = [[NSVTextFieldCell alloc] init];
	[cell setVerticalAlignment:YES];
	NSTableColumn *column = [ringTable tableColumnWithIdentifier:@"name"];
	[column setDataCell:cell];
	[cell release];
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
	if (currentRing == [allRings objectAtIndex:0]) {
		[self setCurrentRing:[allRings objectAtIndex:1]];
	} else if (currentRing == [allRings objectAtIndex:1]) {
		[self setCurrentRing:[allRings objectAtIndex:0]];
	}
}

- (IBAction)test2Button:(id)sender
{
	NSLog(@"Size of allRings: %i", [allRings count]);
}

/*
#pragma mark Animations

- (void)animateRingIn
{
	[currentRing animateRingIn];
}

- (void)mouseMovedForRing:(NSNotification *)aNote
{
	[currentRing mouseMovedForRing];
}

- (void)mouseDownForRing:(NSNotification *)aNote
{
	[currentRing keyUpForRing];
}

- (void)keyUpForRing:(NSNotification *)aNote
{
	[currentRing keyUpForRing];
}
 */

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
#pragma mark TableView Delegates

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	
	if (tableColumn == nil && [[ringRecords objectAtIndex:row] objectForKey:@"icon"] == [NSNull null]) {
		return [[NSTextFieldCell alloc] init];
	}
	
	NSLog(@"Test1");
	return [tableColumn dataCellForRow:row];
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
	if ([[ringRecords objectAtIndex:row] objectForKey:@"icon"] == [NSNull null])
		return YES;
	
	NSLog(@"Test2");
	return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	if ([[ringRecords objectAtIndex:rowIndex] objectForKey:@"icon"] == [NSNull null])
		return NO;
	
	NSLog(@"Test3");
	return YES;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	if ([[ringRecords objectAtIndex:row] objectForKey:@"icon"] == [NSNull null])
		return 20.0;
	
	NSLog(@"Test4");
	return 32.0;
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSLog(@"Test5");
	return [ringRecords count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex 
{
	id theRecord, theValue;
	
	if (aTableColumn == nil && [[ringRecords objectAtIndex:rowIndex] objectForKey:@"icon"] == [NSNull null]) {
		theValue = [[ringRecords objectAtIndex:rowIndex] objectForKey:@"name"];
	}
	else {
		theRecord = [ringRecords objectAtIndex:rowIndex];
		theValue = [theRecord objectForKey:[aTableColumn identifier]];
	}
	
	if (theValue == [NSNull null])
		return nil;
	
	NSLog(@"Test6");
	return theValue;
}


- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
	NSLog(@"Why?");
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	int theRow = [ringTable selectedRow];
	if (theRow != -1){
		id theRing;
		theRing = [allRings objectAtIndex:theRow];
		[self setCurrentRing:theRing];
	}
	NSLog(@"Test7");
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	NSLog(@"Test8");
	return YES;
}

/*
 *	Returns true if all rings have been loaded/saved properly, and false if there are any errors.
 */
/*
- (NSDictionary *)tableViewRecordForTab:(NSString *)tabName icon:(id)icon view:(id)view
{
	NSMutableDictionary *record = [NSMutableDictionary dictionary];
	
	[record setObject:icon forKey:@"icon"];
	[record setObject:tabName forKey:@"name"];
	[record setObject:view forKey:@"view"];
	
	return record;
}
 */
- (NSDictionary *)tableViewRecordForTab:(NSString *)tabName iconName:(NSString *)iconName
{
	NSMutableDictionary *record = [NSMutableDictionary dictionary];
	
	[record setObject:[NSImage imageNamed:iconName] forKey:@"icon"];
	[record setObject:tabName forKey:@"name"];
	
	return record;
}

#pragma mark -
#pragma mark ShortcutRecorder Delegate

- (void)shortcutRecorder:(SRRecorderControl *)recorder keyComboDidChange:(KeyCombo)newKeyCombo
{
    [currentRing setGlobalHotkey:[theRingRecorderControl keyCombo]];
}

#pragma mark -
#pragma mark Ring Loading and Saving

/*
 *	Returns true if all rings have been loaded/saved properly, and false if there are any errors.
 */
- (BOOL)loadRings
{
	Ring *ring1 = [[[Ring alloc] initWithName:@"launchedAppsRing"] retain];
	Ring *ring2 = [[[Ring alloc] initWithName:@"otherLARing"] retain];
	
	[allRings addObject:ring1];
	[allRings addObject:ring2];
	
	for (Ring *r in allRings) {
		[ringRecords addObject:[self tableViewRecordForTab:[r ringName] iconName:@"circleCentre"]];
	}
	
	return YES;
}

- (BOOL)saveRings
{
	return NO;
}

@end