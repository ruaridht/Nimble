//
//  PreferencesController.m
//  opiemac
//
//  Created by Ruaridh Thomson on 24/01/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import "PreferencesController.h"
#import "OpieHeader.h"

@implementation PreferencesController

- (id)init
{
	if (![super init])
		return nil;
	
	//blah
	
	return self;
}

- (void)awakeFromNib
{
	[prefToolbar setSelectedItemIdentifier:[generalButton itemIdentifier]];
	[contentView addSubview:generalView];
	currentView = generalView;
	
	/*
	KeyCombo ringTrigger = { NSCommandKeyMask, 49 };
	if([[NSUserDefaults standardUserDefaults] objectForKey: @"ringTriggerKeyCode"])
		ringTrigger.code = [[[NSUserDefaults standardUserDefaults] objectForKey: @"ringTriggerKeyCode"] intValue];
	if([[NSUserDefaults standardUserDefaults] objectForKey: @"ringTriggerKeyFlags"])
		ringTrigger.flags = [[[NSUserDefaults standardUserDefaults] objectForKey: @"ringTriggerKeyFlags"] intValue];
	
	[ringHotkeyControl setDelegate:self];
	[ringHotkeyControl setKeyCombo:ringTrigger];
	[ringHotkeyControl setCanCaptureGlobalHotKeys:YES];
	[ringHotkeyControl setAllowsKeyOnly:YES escapeKeysRecord:YES];
	*/
	/*
	id tmp = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask
													handler:^(NSEvent *event) {
														
														KeyCombo theCode = [ringHotkeyControl keyCombo];
														
														if ([event keyCode]==theCode.code && [event modifierFlags]==theCode.flags) {
															NSLog(@"Event keydown success");
														}
														
														NSLog(@"Test");
														
													}];
	
	NSLog(@"%@", tmp);
	 */
	
	SDGlobalShortcutsController *shortcutsController = [SDGlobalShortcutsController sharedShortcutsController];
	[shortcutsController addShortcutFromDefaultsKey:@"ringGlobalHotkey"
										withControl:ringHotkeyControl
											 target:self
									selectorForDown:@selector(keyDownForRing)
											  andUp:@selector(keyUpForRing)];
}

- (void)dealloc
{
	[super dealloc];
}

- (void)keyDownForRing
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ringGlobalHotkeyDownTriggered" object:nil];
}

- (void)keyUpForRing
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ringGlobalHotkeyUpTriggered" object:nil];
}

#pragma mark -
#pragma mark IBActions

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
	[contentView replaceSubview:currentView with:theView];
	currentView = theView;
}


// Note: SDGlobalShortcuts handles all this!
/*
#pragma mark -
#pragma mark Shortcut Recorder

- (void)toggleGlobalHotKey:(SRRecorderControl*)sender
{
    KeyCombo keyCombo = [sender keyCombo];
    /*
	if (sender == ringHotkeyControl) {
		
		DDHotKeyCenter *u = [[DDHotKeyCenter alloc] init];
		[u unregisterHotKeyWithKeyCode:ringGlobalHotKey.code modifierFlags:ringGlobalHotKey.flags];
		[u release];
		
		DDHotKeyCenter *c = [[DDHotKeyCenter alloc] init];
		if (![c registerHotKeyWithKeyCode:keyCombo.code modifierFlags:keyCombo.flags target:self action:@selector(keyHit) object:nil]) {
			NSLog(@"Unable to register hotkey");
		} else {
			NSLog(@"Registered hotkey change");
		}
		[c release];
		
		ringGlobalHotKey = keyCombo;
	}
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
	if (aRecorder == ringHotkeyControl) {
		[[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt: newKeyCombo.code] forKey: @"ringTriggerKeyCode"];
		[[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt: newKeyCombo.flags] forKey: @"ringTriggerKeyFlags"];
		[self toggleGlobalHotKey:ringHotkeyControl];
    }
	
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(signed short)keyCode andFlagsTaken:(unsigned int)flags reason:(NSString **)aReason
{
	return NO;
}

*/
@end
