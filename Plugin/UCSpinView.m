//
//  UCSpinner.m
//  Flashless
//
//  Created by Christoph on 19.11.09.
//  Copyright Useless Coding 2009.
/*
Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/


#import "UCSpinView.h"


@implementation UCSpinView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if(self!=nil)
		{
		animationDelay = 0.15;
		step = 0;
		tint = [[NSColor blackColor] retain];
		halo = [[NSColor clearColor] retain];
		spinning = NO;
		}
	return self;
}

- (void)dealloc
{
	[animationTimer release];
	[tint release];
	[halo release];

	[super dealloc];
}

#pragma mark -

- (void)setTint:(NSColor *)newTint
{
	[tint release];
	tint = [newTint retain];
}

- (void)setHalo:(NSColor *)newHalo
{
	[halo release];
	halo = [newHalo retain];
}

- (void)drawRect:(NSRect)rect
{
	if(!spinning)
		{
		return;
		}

	const NSInteger count = 8;
	const CGFloat slice = 6.283185307179586/count;

	NSRect bounds = [self bounds];
	CGFloat diameter = MIN(bounds.size.width, bounds.size.height);
	NSPoint center = NSMakePoint(bounds.size.width/2, bounds.size.height/2);

	NSBezierPath * shape = [NSBezierPath bezierPathWithOvalInRect:bounds];
	[halo set];
	[shape fill];

	[NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
	[NSBezierPath setDefaultLineWidth:diameter*0.1];
	CGFloat inner = diameter*0.2;
	CGFloat outer = diameter*0.4;
	CGFloat phi;

	step = step % count;

	for(NSInteger i=0; i<count; i++)
		{
		[[tint colorWithAlphaComponent:1-sqrt(i)*0.25] set];

		phi = (step+i)*slice;
		[NSBezierPath strokeLineFromPoint:NSMakePoint(center.x+cos(phi)*inner, center.y+sin(phi)*inner)
			toPoint:NSMakePoint(center.x+cos(phi)*outer, center.y+sin(phi)*outer)];
		}
}

- (void)startAnimation:(id)sender
{
	spinning = YES;
	if(animationTimer==nil)
		{
		animationTimer = [[NSTimer scheduledTimerWithTimeInterval:animationDelay target:self selector:@selector(animate:) userInfo:NULL repeats:YES] retain];
		}
	[animationTimer fire];
}

- (void)stopAnimation:(id)sender
{
	spinning = NO;
	[animationTimer invalidate];
	[animationTimer release];
	animationTimer = nil;
	[self setNeedsDisplay:YES];
}

- (void)animate:(NSTimer *)aTimer
{
	step--;
	[self setNeedsDisplay:YES];
}

@end
