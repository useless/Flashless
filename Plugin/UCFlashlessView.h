//
//  UCFlashlessView.h
//  Flashless
//
//  Created by Christoph on 13.06.09.
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
#import <WebKit/WebKit.h>
#import "UCFlashlessService.h"

typedef enum {
	UCDefaultFlashIcon,
	UCPlayFlashIcon,
	UCDownloadFlashIcon,
	UCTryDownloadFlashIcon,
	UCOriginalFlashIcon,
	UCDirectPlayFlashIcon
} UCFlashIconType;

typedef enum {
	UCDefaultStatus,
	UCWaitingStatus,
	UCWarningStatus,
	UCErrorStatus
} UCStatusType;

typedef enum {
	UCShouldNothing,
	UCShouldDownloadNow,
	UCShouldPlayNow
} UCShouldType;

enum {
	UCOriginalModifiers = NSCommandKeyMask,
	UCDirectPlayModifiers = NSShiftKeyMask,
	UCDownloadModifiers = NSAlternateKeyMask,
	UCNewWindowModifiers = NSAlternateKeyMask
};

#define MODIFIERS_EQUAL(a,b)	((a&(~(NSUInteger)0xFFFF))==(b&(~(NSUInteger)0xFFFF)))

@interface UCFlashlessView : NSView <WebPlugInViewFactory>
{
@private
	DOMElement * _element;
	NSObject * _container;

	NSURL * _src;
	NSMutableDictionary * _flashVars;
	UCFlashlessService * _service;
	NSString * _siteLabel;
	BOOL _hasVideo;
	BOOL _canFindDownload;
	BOOL _canPlayDirectly;

	NSURL * _previewURL;
	NSURL * _downloadURL;
	NSURL * _originalURL;

	NSImage * _previewImage;

	NSBundle * _myBundle;

	BOOL _sheetOpen;
	UCShouldType _should;
	UCStatusType _status;
	BOOL _mouseDown;
	BOOL _mouseInside;
	NSUInteger _modifierFlags;
	NSTrackingArea * _tracking;
}

- (void)playFlash:(id)sender;
- (void)playDirectly:(id)sender;
- (void)openOriginal:(id)sender;
- (void)openOriginalWindow:(id)sender;
- (void)download:(id)sender;
- (void)whitelistFlash:(id)sender;
- (void)blacklistFlash:(id)sender;
- (void)remove:(id)sender;
- (void)playAll:(id)sender;
- (void)removeAll:(id)sender;
- (void)copySource:(id)sender;
- (void)copyPreview:(id)sender;
- (void)copyOriginal:(id)sender;
- (void)copyDownload:(id)sender;
- (void)showAbout:(id)sender;

- (void)windowDidUpdate:(NSNotification *)aNotification;

- (void)allShouldRemove:(NSNotification *)notification;
- (void)allShouldPlay:(NSNotification *)notification;

@end
