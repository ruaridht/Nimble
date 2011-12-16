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
	
	[NSApp setDelegate:self];
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
	
	allRings = [[NSMutableArray array] retain];
    ringRecords = [[NSMutableArray array] retain];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAppFromFront) name:@"escapeWindow" object:nil];
	
	return self;
}

- (void)awakeFromNib
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setTitle:@"N"];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
	
    // TODO: This is wrong at the moment.
    //[ringRecords addObject:[self tableViewRecordForTab:@"Rings" iconName:NULL]];
    
	if ([self loadRings])
		[self setCurrentRing:[allRings objectAtIndex:0]];
	
	[ringTable setDataSource:ringRecords]; // Does not implement NSTableViewDelegate ... but it does!
	[ringTable setDelegate:self];
	[ringTable setTarget:self];
	
	[theRingRecorderControl setDelegate:self];
	
	NSVTextFieldCell *cell;
	cell = [[NSVTextFieldCell alloc] init];
	[cell setVerticalAlignment:YES];
    [cell setTruncatesLastVisibleLine:YES];
	NSTableColumn *column = [ringTable tableColumnWithIdentifier:@"name"];
	[column setDataCell:cell];
    [column setResizingMask: NSTableColumnAutoresizingMask];
	[cell release];
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark -
#pragma mark Delegates

/*
 * Some funky delegates that I might have use for. :)
 */

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
	[currentRing animateRingOut];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
	
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	
}

#pragma mark -
#pragma mark IBActions

- (void)removeAppFromFront
{
    // Probs shouldn't do this.
    //[NSApp deactivate];
}

- (IBAction)testButton:(id)sender
{
	if (currentRing == [allRings objectAtIndex:0]) {
		[self setCurrentRing:[allRings objectAtIndex:1]];
	} else if (currentRing == [allRings objectAtIndex:1]) {
		[self setCurrentRing:[allRings objectAtIndex:0]];
	}
    
    NSLog(@"Size of allRings: %i", [allRings count]);
    NSLog(@"What's in ringRecords: %@", [ringRecords count]);
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
#pragma mark TableView Delegates

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if (tableColumn == nil && [[ringRecords objectAtIndex:row] objectForKey:@"icon"] == [NSNull null]) {
		return [[NSTextFieldCell alloc] init];
	}
	
	return [tableColumn dataCellForRow:row];
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
	if ([[ringRecords objectAtIndex:row] objectForKey:@"icon"] == [NSNull null])
		return YES;
	
	return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	if ([[ringRecords objectAtIndex:rowIndex] objectForKey:@"icon"] == [NSNull null])
		return NO;
	
	return YES;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	if ([[ringRecords objectAtIndex:row] objectForKey:@"icon"] == [NSNull null])
		return 20.0;
	
	return 32.0;
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
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

	return theValue;
}


- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
	//NSLog(@"TableViewSelectionIsChanging");
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	int theRow = [ringTable selectedRow];
	if (theRow != -1){
		id theRing;
		theRing = [allRings objectAtIndex:theRow];
		[self setCurrentRing:theRing];
	}
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	return YES;
}

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
    //NSLog(@"Hotkey: %@", [theRingRecorderControl keyComboString]);
    [currentRing setGlobalHotkey:[theRingRecorderControl keyCombo]];
}

#pragma mark -
#pragma mark Ring Loading and Saving

/*
 *	Returns true if all rings have been loaded/saved properly, and false if there are any errors.
 */
- (BOOL)loadRings
{
	Ring *ring1 = [[[Ring alloc] initWithName:@"Launched Apps"] retain];
	//Ring *ring2 = [[[Ring alloc] initWithName:@"Spaces"] retain];
	
	[allRings addObject:ring1];
	//[allRings addObject:ring2];
	
	for (Ring *r in allRings) {
		[ringRecords addObject:[self tableViewRecordForTab:[r ringName] iconName:@"circleCentre"]];
	}
	
	return YES;
}

/*
 *	Returns true if all rings have been loaded/saved properly, and false if there are any errors.
 */
- (BOOL)saveRings
{
	return NO;
}

@end