//
//  UCBlackwhitelist.m
//  Flashless
//
//  Created by Christoph on 06.08.09.
//  Copyright Useless Coding 2009. All rights reserved.
//

#import "UCBlackwhitelist.h"


@implementation UCBlackwhitelist

- (id) init
{
	self = [super init];
	if (self!=nil)
		{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blackwhitelistDidChange:) name:@"UCBlackwhitelistDidChange" object:self];
		}
	return self;
}


- (id)initWithBundleIdentifier:(NSString *)newBundleIdentifier
{
	self = [self init];
	if (self!=nil)
		{
		[self setBundleIdentifier:newBundleIdentifier];
		}
	return self;
}

- (void) dealloc
{
	[bundleIdentifier release];
	[blacklist release];
	[whitelist release];
	[defaultsDict release];
	
	[super dealloc];
}

#pragma mark -

- (void)setBundleIdentifier:(NSString *)newBundleIdentifier
{
	[bundleIdentifier release];
	bundleIdentifier = [newBundleIdentifier copy];
	
	[defaultsDict release];
	defaultsDict = nil;
	defaultsDict = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:newBundleIdentifier] mutableCopy];
	if(defaultsDict==nil)
		{
		defaultsDict = [[NSMutableDictionary alloc] init];
		}
	
	[blacklist release];
	blacklist = nil;
	blacklist = [[defaultsDict objectForKey:@"UCBlacklist"] mutableCopy];
	if(blacklist==nil)
		{
		blacklist = [[NSMutableArray alloc] init];
		}
	
	[whitelist release];
	whitelist = nil;
	whitelist = [[defaultsDict objectForKey:@"UCWhitelist"] mutableCopy];
	if(whitelist==nil)
		{
		whitelist = [[NSMutableArray alloc] init];
		}
	
	[defaultsDict setObject:blacklist forKey:@"UCBlacklist"];
	[defaultsDict setObject:whitelist forKey:@"UCWhitelist"];
}

- (void)blackwhitelistDidChange:(NSNotification *)notification
{
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:defaultsDict forName:bundleIdentifier];
}

- (void)blacklistHost:(NSString *)host
{
	[blacklist removeObject:host];
	[blacklist addObject:host];
	[whitelist removeObject:host];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UCBlackwhitelistDidChange" object:self];
}

- (void)whitelistHost:(NSString *)host
{
	[blacklist removeObject:host];
	[whitelist removeObject:host];
	[whitelist addObject:host];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UCBlackwhitelistDidChange" object:self];
}

- (BOOL)isWhiteHost:(NSString *)host
{
	return [whitelist containsObject:host];
}

- (BOOL)isBlackHost:(NSString *)host
{
	return [blacklist containsObject:host];
}

#pragma mark Data Source

@end
