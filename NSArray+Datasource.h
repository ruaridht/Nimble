//
//  NSArray+Datasource.h
//  Nimble
//
//  Created by Ruaridh Thomson on 05/01/2011.
//  Copyright 2011 Ruaridh Thomson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMutableArray (NSTableViewDataSource)

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row;
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex;
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView;

@end
