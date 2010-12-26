//
//  UCVideoServiceYoutube.m
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


#import "UCVideoServiceYoutube.h"

@implementation UCVideoServiceYoutube

- (NSString *)label
{
	return @"YouTube";
}

- (void)prepare
{
	videoID = [flashVars objectForKey:@"video_id"];
	if(videoID==nil) {
		NSString * scanString = [self pathString];
		if(scanString==nil) {
			[self foundNoDownload];
			return;
		}
		[[self class] scan:scanString from:@"/v/" to:@"&" into:&videoID];
		if(videoID==nil) {
			scanString = [self queryString];
			if(scanString==nil) {
				[self foundNoDownload];
				return;
			}
			[[self class] scan:scanString from:@"v=" to:@"&" into:&videoID];
		}
		if(videoID==nil) {
			scanString = [self queryString];
			if(scanString==nil) {
				[self foundNoDownload];
				return;
			}
			[[self class] scan:scanString from:@"video_id=" to:@"&" into:&videoID];
		}
	}
	if(videoID==nil) {
		[self foundNoDownload];
		return;
	}
	[videoID retain];
}

- (void)findURLs
{
	if(videoID==nil) { return; }
	[self foundAVideo:YES];
	[self foundOriginal:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID]]];
	[self foundPreview:[NSURL URLWithString:[NSString stringWithFormat:@"http://i1.ytimg.com/vi/%@/hqdefault.jpg", videoID]]];
}

@end
