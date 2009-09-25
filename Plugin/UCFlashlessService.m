//
//  UCFlashlessService.m
//  Flashless
//
//  Created by Christoph on 04.08.09.
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


#import "UCFlashlessService.h"
#import "UCFlashlessYoutubeService.h"
#import "UCFlashlessXtubeService.h"
#import "UCFlashlessVimeoService.h"
#import "UCFlashlessViddlerService.h"
#import "UCFlashlessBliptvService.h"
#import "UCFlashlessUstreamService.h"
#import "UCFlashlessFlickrService.h"
#import "UCFlashlessGoogleService.h"
#import "UCFlashlessTwitvidService.h"


@implementation UCFlashlessService

+ (NSString *)domainForSrc:(NSURL *)src
{
	if(src==nil)
		{
		return nil;
		}

	NSString * host = [@"." stringByAppendingString:[src host]];
	NSRange dot = [host rangeOfString:@"." options:NSBackwardsSearch range:NSMakeRange(0, [host rangeOfString:@"." options:NSBackwardsSearch].location)];
	return [host substringFromIndex:dot.location+1];
}

#pragma mark -

- (id)initWithSrc:(NSURL *)aSrc andFlashVars:(NSDictionary *)theFlashVars
{
	if([self isMemberOfClass:[UCFlashlessService class]])
		{
		Class ConcreteSubclass = [[NSDictionary dictionaryWithObjectsAndKeys:
			[UCFlashlessYoutubeService class], @"youtube.com",
			[UCFlashlessYoutubeService class], @"ytimg.com",
			[UCFlashlessYoutubeService class], @"youtube-nocookie.com",
			[UCFlashlessXtubeService class], @"xtube.com",
			[UCFlashlessVimeoService class], @"vimeo.com",
			[UCFlashlessBliptvService class], @"blip.tv",
			[UCFlashlessViddlerService class], @"viddler.com",
			[UCFlashlessUstreamService class], @"ustream.tv",
			[UCFlashlessFlickrService class], @"flickr.com",
			[UCFlashlessGoogleService class], @"google.com",
			[UCFlashlessTwitvidService class], @"twitvid.com",
		nil] objectForKey:[[self class] domainForSrc:aSrc]];

		if(ConcreteSubclass!=nil)
			{
			[self release];
			self = [[ConcreteSubclass alloc] initWithSrc:aSrc andFlashVars:theFlashVars];
			return self;
			}
		}

	self = [self init];
	if(self!=nil)
		{
		src = [aSrc retain];
		flashVars = [theFlashVars retain];
		delegate = nil;
		}
	return self;
}

- (void)dealloc
{
	[src release];
	[flashVars release];
	[hintBuffer release];
	[previewBuffer release];
	[hintConnection release];
	[previewConnection release];

	[super dealloc];
}

#pragma mark -

- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)newDelegate
{
	// Do not retain delegates.
	delegate = newDelegate;
}

- (void)startWithDelegate:(id)newDelegate
{
	[self setDelegate:newDelegate];
	[self findURLs];
}

- (void)cancel
{
	[hintConnection cancel];
	[previewConnection cancel];
	[self stopFinding];
	delegate = nil;
}

#pragma mark Service Info

- (NSString *)label
{
	return nil;
}

- (BOOL)canDownload
{
	return NO;
}

- (BOOL)canPlayDirectly
{
	return NO;
}

@end

@implementation UCFlashlessService (Private)

- (void)findURLs
{
}

- (void)findDownloadURL
{
}

- (void)retreiveHint:(NSURL *)hintURL
{
	hintConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:hintURL] delegate:self];
	hintBuffer = [[NSMutableData alloc] init];
}

- (void)stopFinding
{
}

- (void)receivedHint:(NSString *)hint
{
}

- (void)foundPreview:(NSURL *)previewURL
{
	[delegate service:self didFindPreview:previewURL];
	previewConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:previewURL] delegate:self];
	previewBuffer = [[NSMutableData alloc] init];
}

- (void)foundDownload:(NSURL *)downloadURL
{
	[delegate service:self didFindDownload:downloadURL];
}

- (void)foundOriginal:(NSURL *)originalURL
{
	[delegate service:self didFindOriginal:originalURL];
}

- (void)receivedPreviewData:(NSData *)previewData
{
	[delegate service:self didReceivePreviewData:previewData];
}

#pragma mark URLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if(connection==previewConnection)
		{
		[previewBuffer appendData:data];
		}
	else if(connection==hintConnection)
		{
		[hintBuffer appendData:data];
		}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if(connection==previewConnection)
		{
		[self receivedPreviewData:previewBuffer];
		[previewBuffer autorelease];
		previewBuffer = nil;
		}
	else if(connection==hintConnection)
		{
		NSString * hint = [[NSString alloc] initWithData:hintBuffer encoding:NSUTF8StringEncoding];
		[self receivedHint:hint];
		[hint release];
		}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

#pragma mark URL Helper

- (NSString *)srcString
{
	return [[src absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)pathString
{
	return [[[src path] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)queryString
{
	return [[src query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end

@implementation NSObject (UCFlashlessServiceDelegate)

- (void)service:(UCFlashlessService *)service didFindPreview:(NSURL *)preview
{
}

- (void)service:(UCFlashlessService *)service didFindDownload:(NSURL *)download
{
}

- (void)service:(UCFlashlessService *)service didFindOriginal:(NSURL *)original
{
}

- (void)service:(UCFlashlessService *)service didReceivePreviewData:(NSData *)data
{
}

@end
