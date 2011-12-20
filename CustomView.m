#import "CustomView.h"

@implementation CustomView

- (void)awakeFromNib {
    // Nothing
}

- (void)dealloc {
    [super dealloc];
}

/*
 * I'm pretty sure I overwrite everything this file stands for (inside each ring object). =/
 */
- (void)drawRect:(NSRect)rect {
    // Clear the drawing rect.
    [[NSColor clearColor] set];
    NSRectFill([self frame]);
    // A boolean tracks the previous shape of the window. If the shape changes, it's necessary for the
    // window to recalculate its shape and shadow.
    BOOL shouldDisplayWindow = NO;
	
    // Reset the window shape and shadow.
    if (shouldDisplayWindow) {
        [[self window] display];
        [[self window] setHasShadow:NO];
        //[[self window] setHasShadow:YES];
    }
}

@end
