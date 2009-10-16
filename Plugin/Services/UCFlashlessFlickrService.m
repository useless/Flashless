//
//  UCFlashlessFlickrService.m
//  Flashless
//
//  Created by Christoph on 04.09.09.
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


#import "UCFlashlessFlickrService.h"

@implementation UCFlashlessFlickrService

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
	return YES;
}

- (void)findURLs
{
	videoID = [[flashVars objectForKey:@"photo_id"] retain];
	if(videoID==nil) { return; }
	[self foundAVideo:YES];
	findDownload=NO;
	[self retrieveHint:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/apps/video/video_mtl_xml.gne?v=x&photo_id=%@", videoID]]];
}

- (void)findDownloadURL
{
	if(secret==nil || node==nil)
		{
		return;
		}
	findDownload=YES;
	[self retrieveHint:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/video_playlist.gne?node_id=%@&secret=%@", node, secret]]];
}

- (void)receivedHint:(NSString *)hint
{
	if(hint==nil) { return; }
	NSString * server = nil;
	NSString * URLString = nil;
	NSScanner * scan = [NSScanner scannerWithString:hint];
	if(findDownload)
		{
		[scan scanUpToString:@"APP=\"" intoString:NULL];
		if([scan scanString:@"APP=\"" intoString:NULL])
			{
			[scan scanUpToString:@"\"" intoString:&server];
			}
		[scan scanUpToString:@"FULLPATH=\"" intoString:NULL];
		if([scan scanString:@"FULLPATH=\"" intoString:NULL])
			{
			[scan scanUpToString:@"\"" intoString:&URLString];
			}

		if(server!=nil && URLString!=nil)
			{
			[self foundDownload:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", server, [URLString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]]]];
			}
		}
	else
		{
		[scan scanUpToString:@"<Item id=\"photo_server\">" intoString:NULL];
		if([scan scanString:@"<Item id=\"photo_server\">" intoString:NULL])
			{
			[scan scanUpToString:@"</Item>" intoString:&server];
			}
		[scan scanUpToString:@"<Item id=\"photo_secret\">" intoString:NULL];
		if([scan scanString:@"<Item id=\"photo_secret\">" intoString:NULL])
			{
			[scan scanUpToString:@"</Item>" intoString:&secret];
			}
		[secret retain];
		if(server!=nil && secret!=nil)
			{
			[self foundPreview:[NSURL URLWithString:[NSString stringWithFormat:@"http://farm3.static.flickr.com/%@/%@_%@.jpg?0", server, videoID, secret]]];
			}

		[scan setScanLocation:0];
		[scan scanUpToString:@"<Item id=\"id\">" intoString:NULL];
		if([scan scanString:@"<Item id=\"id\">" intoString:NULL])
			{
			[scan scanUpToString:@"</Item>" intoString:&node];
			}
		[node retain];

		[scan setScanLocation:0];
		[scan scanUpToString:@";url=" intoString:NULL];
		if([scan scanString:@";url=" intoString:NULL])
			{
			[scan scanUpToString:@"&" intoString:&URLString];
			}
		if(URLString!=nil)
			{
			[self foundOriginal:[NSURL URLWithString:URLString]];
			}
		}
}

@end
