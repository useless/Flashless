//
//  UCVideoService.h
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


#import <Cocoa/Cocoa.h>

@interface UCVideoService : NSObject
{
	NSURL * src;
	NSDictionary * flashVars;

	NSString * videoID;
@private
	id delegate;
	NSURLConnection * hintConnection;
	NSURLConnection * previewConnection;
	NSMutableData * hintBuffer;
	NSMutableData * previewBuffer;
}

+ (NSString *)domainForSrc:(NSURL *)src;

- (id)initWithSrc:(NSURL *)aSrc andFlashVars:(NSDictionary *)theFlashVars;
- (void)setSrc:(NSURL *)aSrc;
- (id)delegate;
- (void)setDelegate:(id)newDelegate;
- (void)startWithDelegate:(id)newDelegate;
- (void)cancel;

- (NSString *)label;

- (BOOL)canFindDownload;
- (BOOL)canPlayDirectly;

@end

@interface UCVideoService (Private)

- (void)findURLs;
- (void)findDownloadURL;
- (void)retrieveHint:(NSURL *)hintURL;

- (void)receivedHint:(NSString *)hint;
- (void)foundAVideo:(BOOL)hasVideo;
- (void)foundPreview:(NSURL *)previewURL;
- (void)foundDownload:(NSURL *)downloadURL;
- (void)foundNoDownload;
- (void)foundOriginal:(NSURL *)originalURL;
- (void)receivedPreviewData:(NSData *)previewData;

- (NSString *)srcString;
- (NSString *)pathString;
- (NSString *)queryString;

@end

@interface NSObject (UCFlashlessServiceDelegate)

- (void)service:(UCVideoService *)service didFindAVideo:(BOOL)hasVideo;
- (void)service:(UCVideoService *)service didFindPreview:(NSURL *)preview;
- (void)service:(UCVideoService *)service didFindDownload:(NSURL *)download;
- (void)findDownloadFailedForService:(UCVideoService *)service;
- (void)service:(UCVideoService *)service didFindOriginal:(NSURL *)original;
- (void)service:(UCVideoService *)service didReceivePreviewData:(NSData *)data;

@end
