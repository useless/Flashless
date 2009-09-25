//
//  UCFlashlessBliptvService.m
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


#import "UCFlashlessBliptvService.h"

@implementation UCFlashlessBliptvService

- (void)dealloc
{
	[redirectConnection release];

	[super dealloc];
}

#pragma mark -

- (void)cancel
{
	[redirectConnection cancel];

	[super cancel];
}

- (NSString *)label
{
	return @"Blip.tv";
}

- (void)findURLs
{
	if([[src host] isEqualToString:@"e.blip.tv"])
		{
		[self redirectedTo:nil];
		}
	else
		{
		redirectConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:src] delegate:self];
		}
}

- (void)redirectedTo:(NSURL *)redirectedURL
{
	NSString * srcString = [self srcString];
	if(redirectedURL!=nil)
		{
		[self setSrc:redirectedURL];
		srcString = [self srcString];
		}
	else
		{
		srcString = [srcString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		}
	NSString * hintURLString = nil;
	NSScanner * scan = [NSScanner scannerWithString:srcString];
	[scan scanUpToString:@"file=" intoString:NULL];
	if([scan scanString:@"file=" intoString:NULL])
		{
		[scan scanUpToString:@"&" intoString:&hintURLString];
		}
	if(hintURLString==nil) { return; }
	[self retrieveHint:[NSURL URLWithString:hintURLString]];
}

- (void)receivedHint:(NSString *)hint
{
	if(hint==nil) { return; }
	NSString * originalURLString = nil;
	NSString * preview = nil;
	NSString * downloadURLString = nil;
	NSScanner * scan = [NSScanner scannerWithString:hint];
	[scan scanUpToString:@"<link>" intoString:NULL];
	if([scan scanString:@"<link>" intoString:NULL])
		{
		[scan scanUpToString:@"</link>" intoString:&originalURLString];
		}
	if(originalURLString!=nil)
		{
		[self foundOriginal:[NSURL URLWithString:originalURLString]];
		}

	[scan setScanLocation:0];
	[scan scanUpToString:@"<blip:thumbnail_src>" intoString:NULL];
	if([scan scanString:@"<blip:thumbnail_src>" intoString:NULL])
		{
		[scan scanUpToString:@"</blip:thumbnail_src>" intoString:&preview];
		}
	if(preview!=nil)
		{
		[self foundPreview:[NSURL URLWithString:[NSString stringWithFormat:@"http://a.images.blip.tv/%@", preview]]];
		}

	[scan setScanLocation:0];
	[scan scanUpToString:@"<media:content url=\"" intoString:NULL];
	if([scan scanString:@"<media:content url=\"" intoString:NULL])
		{
		[scan scanUpToString:@"\"" intoString:&downloadURLString];
		}
	if(downloadURLString!=nil)
		{
		[self foundDownload:[NSURL URLWithString:downloadURLString]];
		}
}

#pragma mark Connection Delegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	if(connection==redirectConnection && [[[request URL] host] isEqualToString:@"e.blip.tv"])
		{
		[connection cancel];
		[self redirectedTo:[request URL]];
		return nil;
		}
	else
		{
		return request;
		}
}

@end
