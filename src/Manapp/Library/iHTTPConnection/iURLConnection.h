//
//  iURLConnection.h
//  iCore for iOS
//
//  Created by Quan Dang Dinh on 8/27/10.
//  Copyright © 2012 Lumos Technology Ltd.,. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MESSAGE_GET_CONNECTION_INVALID_PRAMETER_VALUE @"Current instant of XMURLConnection using GET method. Parameter values must be string instead of others."

@interface iURLConnection : NSURLConnection {
	@protected
	NSString *_tag;
	BOOL _usePOST;
    NSDictionary *_parameterList;
}

@property (nonatomic, retain) NSString *Tag;
@property (nonatomic) BOOL UsePOST;
 
- (id)initWithTag:(NSString *)tag usePOST:(BOOL)usePOST;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString *)tag;
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString *)tag timeout:(int)timeout;

- (void)addParameter:(NSString *)parameterName withValue:(id)value;

- (void)removeParameter:(NSString *)parameterName;

- (id)getValueForParameter:(NSString *)parameterName;

@end
