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
	NSMutableDictionary * _flashVars;
	NSURL * _previewURL;
	NSURL * _downloadURL;
	NSString * _siteLabel;
	NSURL * _src;
	NSImage * _previewImage;
	
	NSBundle * _myBundle;
	
	NSURLConnection * _previewConnection;
	NSMutableData * _previewBuf;
	
	BOOL _mouseDown;
	BOOL _mouseInside;
	NSTrackingArea * _tracking;
}

- (id)initWithArguments:(NSDictionary *)arguments;

- (void)_drawPlayWithTint:(NSColor *)tint andHalo:(NSColor *)halo inRect:(NSRect)bounds;
- (void)_drawBadgeWithTint:(NSColor *)tint andHalo:(NSColor *)halo inRect:(NSRect)bounds;

- (void)_convertTypesForContainer;
- (void)_convertTypesForElement:(DOMElement *)element;

- (NSString *)_domainForSrc:(NSURL *)src;
- (NSString *)_labelForDomain:(NSString *)domain;
- (NSURL *)_srcFromAttributes:(NSDictionary *)attributes withBaseURL:(NSURL *)baseURL;
- (NSMutableDictionary *)_flashVarsFromAttributes:(NSDictionary *)attributes;
- (NSURL *)_previewURLForSrc:(NSURL *)src andFlashVars:(NSMutableDictionary *)flashVars;
- (NSURL *)_downloadURLForSrc:(NSURL *)src andFlashVars:(NSMutableDictionary *)flashVars;

- (NSMenu *)_prepareMenu;
- (void)_writeToPasteboard:(NSURL *)url;

- (void)loadFlash:(id)sender;
- (void)download:(id)sender;
- (void)copySource:(id)sender;
- (void)copyPreview:(id)sender;
- (void)copyDownload:(id)sender;
- (void)showAbout:(id)sender;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end
