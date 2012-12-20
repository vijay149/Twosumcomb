//
//  iURLDownloaderDelegate.h
//  iCore for iOS
//
//  Created by Quan Dang Dinh on 8/27/10.
//  Copyright © 2012 Lumos Technology Ltd.,. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol iHTTPConnectionManagerDelegate<NSObject>

@required
- (void)startedDownloadWithTag:(NSString *)tag;
- (void)finishedDownloadWithTag:(NSString *)tag downloadedData:(NSMutableData *)data;

@optional
- (void)errorDownloadWithTag:(NSString *)tag error:(NSError *)error;
- (void)canceledDownloadWithTag:(NSString *)tag;

@end

