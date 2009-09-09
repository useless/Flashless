//
//  UCFlashlessGoogleService.m
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


#import "UCFlashlessGoogleService.h"

@implementation UCFlashlessGoogleService

- (void)dealloc
{
	[videoFile release];

	[super dealloc];
}

#pragma mark -

- (NSString *)label;
{
	return @"Google Video";
}

- (NSURL *)previewURL
{	
	NSString * thumbnail;
	NSScanner * scan = [NSScanner scannerWithString:[self queryString]];
	[scan scanUpToString:@"docid=" intoString:NULL];
	if([scan scanString:@"docid=" intoString:NULL])
		{
		[scan scanUpToString:@"&" intoString:&videoID];
		}
	if(videoID==nil) { return nil; }
	[videoID retain];
	[scan setScanLocation:0];
	[scan scanUpToString:@"videoURL=" intoString:NULL];
	if([scan scanString:@"videoURL=" intoString:NULL])
		{
		[scan scanUpToString:@"&" intoString:&videoFile];
		}
	[videoFile retain];
	[scan setScanLocation:0];
	[scan scanUpToString:@"thumbnailUrl=" intoString:NULL];
	if([scan scanString:@"thumbnailUrl=" intoString:NULL])
		{
		[scan scanUpToString:@"&" intoString:&thumbnail];
		if(thumbnail!=nil)
			{
			return [NSURL URLWithString:[thumbnail stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			}
		}
	return nil;
}

- (NSURL *)downloadURL
{
	if(videoFile==nil) { return nil; }
	return [NSURL URLWithString:[videoFile stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURL *)originalURL
{
	if(videoID==nil) { return nil; }
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://video.google.com/videoplay?docid=%@", videoID]];
}

@end
