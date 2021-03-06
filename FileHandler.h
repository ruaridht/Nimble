//
//  FileHandler.h
//  Nimble
//
//  Created by Ruaridh Thomson on 17/12/2011.
//  Copyright 2011 Ruaridh Thomson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHandler : NSObject {
    NSFileManager *manager;
    
    NSString *supportPath;
    NSString *ringPath;
    NSString *themePath;
}

- (id)init;
- (void)checkSupportPaths;

- (NSString *)ringWritePath;
- (NSArray *)ringReadPaths;

- (void)removeRingAtPath:(NSString *)path;

@end
