//
//  NSArray+Datasource.m
//  Nimble
//
//  Created by Ruaridh Thomson on 05/01/2011.
//  Copyright 2011 Ruaridh Thomson. All rights reserved.
//

#import "NSArray+Datasource.h"

@implementation NSMutableArray (NSTableViewDataSource)

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{  
	id theRecord, theValue;
	
	if (aTableColumn == nil && [[self objectAtIndex:rowIndex] objectForKey:@"icon"] == [NSNull null]) {
		theValue = [[self objectAtIndex:rowIndex] objectForKey:@"name"];
	}
	else {
		theRecord = [self objectAtIndex:rowIndex];
		theValue = [theRecord objectForKey:[aTableColumn identifier]];
	}
	
	if (theValue == [NSNull null])
		return nil;
	
	return theValue;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [self count];  
}

#pragma mark -
#pragma mark Delegate Methods

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	
	if (tableColumn == nil && [[self objectAtIndex:row] objectForKey:@"icon"] == [NSNull null]) {
		return [[NSTextFieldCell alloc] init];
	}
	
	return [tableColumn dataCellForRow:row];
	
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
	if ([[self objectAtIndex:row] objectForKey:@"icon"] == [NSNull null])
		return YES;
	
	return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	if ([[self objectAtIndex:rowIndex] objectForKey:@"icon"] == [NSNull null])
		return NO;
	
	return YES;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	if ([[self objectAtIndex:row] objectForKey:@"icon"] == [NSNull null])
		return 20.0;
	
	return 32.0;
}

- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{	
	/*
	 int theRow = [profileTable selectedRow];
	 if (theRow != -1) {
	 id theRecord = [records objectAtIndex:theRow];
	 if ([[theRecord objectForKey:@"type"] isEqualToString:@"combat"]) {
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"SwitchProfileViewToSelection" object:@"combat"];
	 } else if ([[theRecord objectForKey:@"type"] isEqualToString:@"mailAction"]) {
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"SwitchProfileViewToSelection" object:@"mailAction"];
	 }
	 } else {
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"SwitchProfileViewToSelection" object:@"default"];
	 }
	 */
	// This is the datasource for the profileTable in ProfileController. So we send the notification back.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SwitchProfileViewToSelection" object:nil];
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	return YES;
}

@end