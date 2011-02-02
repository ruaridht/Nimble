//
//  RingTheme.h
//  opiemac
//
//  Created by Ruaridh Thomson on 01/02/2011.
//  Copyright 2011 Life Up North. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RingTheme : NSObject {
	NSImage *centerImage;
	NSImage *mouseImage;
	NSImage *appBG;
	NSImage *ringBG;
}

@property (assign) NSImage *centerImage;
@property (assign) NSImage *mouseImage;
@property (assign) NSImage *appBG;
@property (assign) NSImage *ringBG;

- (id)initWithCenter:(NSImage *)theCenter mouse:(NSImage *)theMouse app:(NSImage *)theApp ring:(NSImage *)theRing;

@end
