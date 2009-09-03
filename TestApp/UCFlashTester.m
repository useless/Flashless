//
//  UCFlashTester.m
//  Flashless TestApp
//
//  Created by Christoph on 13.06.09.
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


#import "UCFlashTester.h"


@implementation UCFlashTester

- (void)awakeFromNib
{
/*	[flashView initWithArguments:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"http://example.com/play.swf", @"src",
			nil], WebPlugInAttributesKey,
		[NSURL URLWithString:@"http://example.com"], WebPlugInBaseURLKey,
		nil]];
*/	[flashView _initWithArguments:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"http://www.youtube.com/v/0ciPntuvX0c&hl=en&fs=1&rel=0&hd=1", @"src",
			nil], WebPlugInAttributesKey,
		[NSURL URLWithString:@"http://www.fscklog.com/"], WebPlugInBaseURLKey,
		nil]];

}

- (IBAction)initializePlugin:(id)sender
{
	[flashView webPlugInInitialize];
}

- (IBAction)startPlugin:(id)sender
{
	[flashView webPlugInStart];
}

- (IBAction)stopPlugin:(id)sender
{
	[flashView webPlugInStop];
}

- (IBAction)destroyPlugin:(id)sender
{
	[flashView webPlugInDestroy];
}

- (IBAction)refresh:(id)sender
{
	[flashView setNeedsDisplay:YES];
}

- (void)windowWillClose:(NSNotification *)notification
{
	[NSApp terminate:self];
}

@end
