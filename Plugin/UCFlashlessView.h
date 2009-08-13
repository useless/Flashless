//
//  UCFlashlessView.h
//  Flashless
//
//  Created by Christoph on 13.06.09.
//  Copyright Useless Coding 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface UCFlashlessView : NSView <WebPlugInViewFactory>
{
	DOMElement * _element;
	NSObject * _container;

	NSURL * _src;
	NSMutableDictionary * _flashVars;
	NSString * _siteLabel;

	NSURL * _previewURL;
	NSURL * _downloadURL;
	NSURL * _originalURL;

	NSImage * _previewImage;
	
	NSBundle * _myBundle;
	
	NSURLConnection * _previewConnection;
	NSMutableData * _previewBuf;
	
	BOOL _mouseDown;
	BOOL _mouseInside;
	NSTrackingArea * _tracking;
}

- (id)initWithArguments:(NSDictionary *)arguments;

- (void)_drawWithTint:(NSColor *)tint andHalo:(NSColor *)halo inRect:(NSRect)bounds asPlay:(BOOL)play;

- (void)_convertTypesForContainer;
- (void)_convertTypesForElement:(DOMElement *)element;
- (void)_removeFromContainer;

- (NSURL *)_srcFromAttributes:(NSDictionary *)attributes withBaseURL:(NSURL *)baseURL;
- (NSMutableDictionary *)_flashVarsFromAttributes:(NSDictionary *)attributes;

- (NSMenu *)_prepareMenu;
- (void)_writeToPasteboard:(NSURL *)url;

- (void)loadFlash:(id)sender;
- (void)openOriginal:(id)sender;
- (void)download:(id)sender;
- (void)whitelistFlash:(id)sender;
- (void)blacklistFlash:(id)sender;
- (void)remove:(id)sender;
- (void)showAll:(id)sender;
- (void)removeAll:(id)sender;
- (void)copySource:(id)sender;
- (void)copyPreview:(id)sender;
- (void)copyDownload:(id)sender;
- (void)showAbout:(id)sender;

- (void)allShouldRemove:(NSNotification *)notification;
- (void)allShouldShow:(NSNotification *)notification;

- (void) blacklistConfirmDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end
