//
//  UCVideoServiceVimeo.m
//  Flashless
//
//  Created by Christoph on 03.09.2009.
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


#import "UCVideoServiceVimeo.h"

@implementation UCVideoServiceVimeo

- (NSString *)label
{
	return @"Vimeo";
}

- (void)prepare
{
	videoID = [flashVars objectForKey:@"clip_id"];
	if(videoID==nil) {
		NSString * scanString = [self queryString];
		if(scanString==nil) {
			scanString = [self pathString];
			[[self class] scan:scanString from:@"/" to:@"/" into:&videoID];
		} else {
			[[self class] scan:scanString from:@"clip_id=" to:@"&" into:&videoID];
		}
	}
	if(videoID==nil) {
		[self foundNoDownload];
		return;
	}
	[videoID retain];
	[self retrieveHint:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.vimeo.com/moogaloop/load/clip:%@", videoID]]];
}

- (void)findURLs
{
	if(videoID==nil) { return; }
	[self foundAVideo:YES];
	[self foundOriginal:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.vimeo.com/%@", videoID]]];
}

- (void)receivedHint:(NSString *)hint
{
	if(hint==nil) {
		[self foundNoDownload];
		return;
	}
	NSString * previewFile = nil;

	[[self class] scan:hint from:@"<thumbnail>" to:@"</thumbnail>" into:&previewFile];
	if(previewFile!=nil) {
		[self foundPreview:[NSURL URLWithString:previewFile]];
	}
}

@end
