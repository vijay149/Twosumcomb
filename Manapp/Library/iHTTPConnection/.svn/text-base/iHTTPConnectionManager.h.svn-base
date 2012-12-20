//
//  iHTTPConnectionManager.h
//  iCore for iOS
//
//  Created by Quan Dang Dinh on 8/27/10.
//  Copyright © 2012 Lumos Technology Ltd.,. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iHTTPConnectionManagerDelegate.h"

@class iURLConnection;

@interface iHTTPConnectionManager : NSObject {
	
    @protected
	NSMutableDictionary *_listReceivedData;
	NSMutableDictionary *_listUrlConnection;
	NSMutableDictionary *_listDelegate;
}

- (id)init;

- (void)downloadDataFromURL:(NSString *)url withTag:(NSString *)tag delegate:(id<iHTTPConnectionManagerDelegate>)delegate;

- (NSString *)downloadDataFromURL:(NSString *)url delegate:(id<iHTTPConnectionManagerDelegate>)delegate;

- (void)downloadDataFromURL:(NSString *)url withTag:(NSString *)tag cacheAllowance:(BOOL)cacheAllowance cacheTimeout:(int)cacheTimeout delegate:(id<iHTTPConnectionManagerDelegate>)delegate;

- (void)postData:(NSString *)data toURL:(NSString *)url withTag:(NSString *)tag delegate:(id <iHTTPConnectionManagerDelegate>)delegate;

- (void)downloadDataWithConnection:(iURLConnection *)connection delegate:(id<iHTTPConnectionManagerDelegate>)delegate;

- (void)cancelDownloadWithTag:(NSString *)tag;

@end
