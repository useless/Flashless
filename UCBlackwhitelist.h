//
//  UCBlackwhitelist.h
//  Flashless
//
//  Created by Christoph on 06.08.09.
//  Copyright Useless Coding 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UCBlackwhitelist : NSObject
{
@private
	NSString * bundleIdentifier;
	NSMutableDictionary * defaultsDict;
	NSMutableArray * blacklist;
	NSMutableArray * whitelist;
}

+ (UCBlackwhitelist *)sharedBlackwhitelist;

- (id)initWithBundleIdentifier:(NSString *)newBundleIdentifier;

- (void)setBundleIdentifier:(NSString *)newBundleIdentifier;

- (void)blackwhitelistDidChange:(NSNotification *)notification;

- (void)blacklistHost:(NSString *)host;
- (void)whitelistHost:(NSString *)host;

- (BOOL)isWhiteHost:(NSString *)host;
- (BOOL)isBlackHost:(NSString *)host;

@end
