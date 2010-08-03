//
//  UCVideoServiceViddler.m
//  Flashless
//
//  Created by Christoph on 04.09.2009.
//  Copyright 2009-2010 Useless Coding.
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


#import "UCVideoServiceViddler.h"

@implementation UCVideoServiceViddler

- (NSString *)label
{
	return @"Viddler";
}

- (void)findURLs
{	
	videoID = [flashVars objectForKey:@"key"];
	if(videoID==nil) {
		NSString * path = [self pathString];
		if(path==nil) { return; }

		[[self class] scan:path from:@"simple/" to:@"/" into:&videoID];
		if(videoID==nil) {
			[[self class] scan:path from:@"simple_on_site/" to:@"/" into:&videoID];
		}
		if(videoID==nil) {
			[[self class] scan:path from:@"player/" to:@"/" into:&videoID];
		}
	}
	if(videoID==nil) { return; }
	[videoID retain];
	[self foundAVideo:YES];
	[self foundPreview:[NSURL URLWithString:[NSString stringWithFormat:@"http://cdn-thumbs.viddler.com/thumbnail_2_%@.jpg", videoID]]];
}

@end
