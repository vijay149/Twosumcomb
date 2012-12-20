//
//  iURLConnection.m
//  iCore for iOS
//
//  Created by Quan Dang Dinh on 8/27/10.
//  Copyright © 2012 Lumos Technology Ltd.,. All rights reserved.
//

#import "iURLConnection.h"

#pragma mark Class implementation
@implementation iURLConnection

@synthesize Tag = _tag;
@synthesize UsePOST = _usePOST;

#pragma mark Constructors
- (id)initWithTag:(NSString *)tag usePOST:(BOOL)usePOST{
    self = [super init];
	if (self) {
		_tag = [tag retain];
		_usePOST = usePOST;
		_parameterList = [[NSDictionary alloc] init];
	}
	
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString *)tag{
    self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
	if (self) {
		_tag = [tag retain];
		_usePOST = NO;
		_parameterList = [[NSDictionary alloc] init];
	}
	
	return self;
}
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString *)tag timeout:(int)timeout
{
    self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
	if (self) {
		_tag = [tag retain];
		_usePOST = NO;
		_parameterList = [[NSDictionary alloc] init];
	}
	
	return self;
}
- (void)prepareConnection{

}

#pragma mark Parameters hander functions
- (void)addParameter:(NSString *)parameterName withValue:(id)value{
	[_parameterList setValue:value forKey:parameterName];
}

- (void)removeParameter:(NSString *)parameterName{
    [_parameterList setNilValueForKey:parameterName];
}

- (id)getValueForParameter:(NSString *)parameterName{
    return [_parameterList valueForKey:parameterName];
}

#pragma mark Destructor
- (void)dealloc{
	[_tag release]; _tag = nil;
	[_parameterList release]; _parameterList = nil;
	[super dealloc];
}
@end
