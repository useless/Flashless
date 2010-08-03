//
//  UCVideoServiceFlickr.m
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


#import "UCVideoServiceFlickr.h"

@implementation UCVideoServiceFlickr

- (void)dealloc
{
	[secret release];
	[node release];

	[super dealloc];
}

#pragma mark -

- (NSString *)label
{
	return @"Flickr";
}

- (BOOL)canFindDownload
{
	return (secret!=nil && node!=nil);
}

- (void)prepare
{
	videoID = [[flashVars objectForKey:@"photo_id"] retain];
	if(videoID==nil) { return; }
	[self foundAVideo:YES];
	findDownload=NO;
	[self retrieveHint:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/apps/video/video_mtl_xml.gne?v=x&photo_id=%@", videoID]]];
}

- (void)findDownloadURL
{
	if([self canFindDownload]) {
		findDownload=YES;
		[self retrieveHint:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/video_playlist.gne?node_id=%@&secret=%@", node, secret]]];
	} else {
		[self foundNoDownload];
	}
}

- (void)receivedHint:(NSString *)hint
{
	if(hint==nil) {
		[self foundNoDownload];
		return;
	}
	NSString * server = nil;
	NSString * URLString = nil;
	if(findDownload) {
		[[self class] scan:hint from:@"APP=\"" to:@"\"" into:&server];
		[[self class] scan:hint from:@"FULLPATH=\"" to:@"\"" into:&URLString];
		if(server!=nil && URLString!=nil) {
			[self foundDownload:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", server, [URLString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]]]];
		} else {
			[self foundNoDownload];
		}
	} else {
		[[self class] scan:hint from:@"<Item id=\"photo_server\">" to:@"</Item>" into:&server];
		[[self class] scan:hint from:@"<Item id=\"photo_secret\">" to:@"</Item>" into:&secret];
		[secret retain];
		if(server!=nil && secret!=nil) {
			[self foundPreview:[NSURL URLWithString:[NSString stringWithFormat:@"http://farm3.static.flickr.com/%@/%@_%@.jpg?0", server, videoID, secret]]];
		}

		[[self class] scan:hint from:@"<Item id=\"id\">" to:@"</Item>" into:&node];
		[node retain];
		[self foundAVideo:YES];

		[[self class] scan:hint from:@";url=" to:@"&" into:&URLString];
		if(URLString!=nil) {
			[self foundOriginal:[NSURL URLWithString:URLString]];
		}
	}
}

@end
