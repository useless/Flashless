//
//  UCBlackwhitelist.m
//  Flashless
//
//  Created by Christoph on 06.08.09.
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


#import "UCBlackwhitelist.h"

static UCBlackwhitelist * sharedInstance = nil;

@implementation UCBlackwhitelist

+ (UCBlackwhitelist *)sharedBlackwhitelist
{
	if(sharedInstance==nil)
		{
		sharedInstance = [[self alloc] initWithBundleIdentifier:[[NSBundle bundleForClass:self] bundleIdentifier]];
		}

	return sharedInstance;
}

- (id) init
{
	self = [super init];
	if (self!=nil)
		{
		isPersistent=NO;
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];

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

	isPersistent = [[defaultsDict objectForKey:@"UCIsPersistent"] boolValue];

	[defaultsDict setObject:isPersistent?@"YES":@"NO" forKey:@"UCIsPersistent"];
	[defaultsDict setObject:blacklist forKey:@"UCBlacklist"];
	[defaultsDict setObject:whitelist forKey:@"UCWhitelist"];
}

- (void)blackwhitelistDidChange:(NSNotification *)notification
{
	if(isPersistent)
		{
		[[NSUserDefaults standardUserDefaults] setPersistentDomain:defaultsDict forName:bundleIdentifier];
		}
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

@end
