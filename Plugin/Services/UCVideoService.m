//
//  UCVideoService.m
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


#import "UCVideoService.h"
#import "UCVideoServiceYoutube.h"
#import "UCVideoServiceTumblr.h"
#import "UCVideoServiceXtube.h"
#import "UCVideoServiceVimeo.h"
#import "UCVideoServiceViddler.h"
#import "UCVideoServiceBliptv.h"
#import "UCVideoServiceUstream.h"
#import "UCVideoServiceFlickr.h"
#import "UCVideoServiceGoogle.h"
#import "UCVideoServiceTwitvid.h"


@implementation UCVideoService

+ (NSString *)domainForSrc:(NSURL *)src
{
	if(src==nil || [src host]==nil)
		{
		return nil;
		}

	NSString * host = [@"." stringByAppendingString:[src host]];
	NSRange dot = [host rangeOfString:@"." options:NSBackwardsSearch range:NSMakeRange(0, [host rangeOfString:@"." options:NSBackwardsSearch].location)];
	return [host substringFromIndex:dot.location+1];
}

+ (void)scan:(NSString *)scanString from:(NSString *)from to:(NSString *)to into:(NSString **)into
{
	NSScanner * scanner = [NSScanner scannerWithString:scanString];
	[scanner scanUpToString:from intoString:NULL];
	if([scanner scanString:from intoString:NULL]) {
		[scanner scanUpToString:to intoString:into];
	}
}

#pragma mark -

- (id)initWithSrc:(NSURL *)aSrc andFlashVars:(NSDictionary *)theFlashVars
{
	if([self isMemberOfClass:[UCVideoService class]])
		{
		Class ConcreteSubclass = [[NSDictionary dictionaryWithObjectsAndKeys:
			[UCVideoServiceYoutube class], @"youtube.com",
			[UCVideoServiceYoutube class], @"ytimg.com",
			[UCVideoServiceYoutube class], @"youtube-nocookie.com",
			[UCVideoServiceTumblr class], @"tumblr.com",
			[UCVideoServiceXtube class], @"xtube.com",
			[UCVideoServiceVimeo class], @"vimeo.com",
			[UCVideoServiceVimeo class], @"vimeocdn.com",
			[UCVideoServiceBliptv class], @"blip.tv",
			[UCVideoServiceViddler class], @"viddler.com",
			[UCVideoServiceUstream class], @"ustream.tv",
			[UCVideoServiceFlickr class], @"flickr.com",
			[UCVideoServiceGoogle class], @"google.com",
			[UCVideoServiceTwitvid class], @"twitvid.com",
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

- (void)setSrc:(NSURL *)aSrc
{
	[src release];
	src = [aSrc retain];
}

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
	[self prepare];
	[self findURLs];
}

- (void)findDownloadWithDelegate:(id)newDelegate
{
	[self setDelegate:newDelegate];
	[self prepare];
	[self findDownloadURL];
}

- (void)cancel
{
	[hintConnection cancel];
	[previewConnection cancel];
	delegate = nil;
}

#pragma mark Service Info

- (NSString *)label
{
	return nil;
}

- (BOOL)canFindDownload
{
	return NO;
}

- (BOOL)canPlayDirectly
{
	return YES;
}

@end

@implementation UCVideoService (Private)

- (void)prepare
{
}

- (void)findURLs
{
}

- (void)findDownloadURL
{
	if(![self canFindDownload]) {
		[self foundNoDownload];
	}
}

- (void)retrieveHint:(NSURL *)hintURL
{
	hintConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:hintURL] delegate:self];
	hintBuffer = [[NSMutableData alloc] init];
}

- (void)receivedHint:(NSString *)hint
{
}

- (void)foundAVideo:(BOOL)hasVideo
{
	[delegate service:self didFindAVideo:hasVideo];
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

- (void)foundNoDownload
{
	[delegate findDownloadFailedForService:self];
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
	return [src absoluteString];
}

- (NSString *)pathString
{
	return [src path];
}

- (NSString *)queryString
{
	return [src query];
}

@end

@implementation NSObject (UCFlashlessServiceDelegate)

- (void)service:(UCVideoService *)service didFindAVideo:(BOOL)hasVideo
{
}

- (void)service:(UCVideoService *)service didFindPreview:(NSURL *)preview
{
}

- (void)service:(UCVideoService *)service didFindDownload:(NSURL *)download
{
}

- (void)findDownloadFailedForService:(UCVideoService *)service
{
}

- (void)service:(UCVideoService *)service didFindOriginal:(NSURL *)original
{
}

- (void)service:(UCVideoService *)service didReceivePreviewData:(NSData *)data
{
}

@end
