//
//  FileHandler.m
//  Nimble
//
//  Created by Ruaridh Thomson on 17/12/2011.
//  Copyright 2011 Nimble. All rights reserved.
//

#import "FileHandler.h"

@implementation FileHandler

- (id)init
{
    self = [super init];
    if (self) {
        manager = [NSFileManager defaultManager];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)checkSupportPaths
{
    NSURL *applicationSupportFolder = [manager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    supportPath = [[NSString stringWithFormat:@"%@%@", [applicationSupportFolder path], @"/Nimble"] retain];
    ringPath = [[NSString stringWithFormat:@"%@%@", supportPath, @"/rings"] retain];
    themePath = [[NSString stringWithFormat:@"%@%@", supportPath, @"/themes"] retain];
    
    //NSLog(@"%@", supportPath);
    //NSLog(@"%@", ringPath);
    //NSLog(@"%@", themePath);
    
    // Basic checks. If the folders don't exist lets create them.
    BOOL supportFolderExists = [manager fileExistsAtPath:supportPath];
    if (!supportFolderExists) {
        [manager createDirectoryAtPath:supportPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    BOOL ringFolderExists = [manager fileExistsAtPath:ringPath];
    if (!ringFolderExists) {
        [manager createDirectoryAtPath:ringPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    BOOL themeFolderExists = [manager fileExistsAtPath:themePath];
    if (!themeFolderExists) {
        [manager createDirectoryAtPath:themePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

- (NSString *)ringWritePath
{
    return ringPath;
}

- (NSArray *)ringReadPaths
{
    NSArray *paths = [manager subpathsAtPath:ringPath];
    return paths;
}

- (void)removeRingAtPath:(NSString *)path
{
    [manager removeItemAtPath:path error:nil];
}

@end
