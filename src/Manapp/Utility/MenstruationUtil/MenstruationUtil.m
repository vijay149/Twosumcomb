//
//  MenstruationUtil.m
//  TwoSum
//
//  Created by Duong Van Dinh on 10/15/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "MenstruationUtil.h"
#import "MASession.h"
#import "NSDate+Helper.h"
#import "Util.h"
#import "Partner.h"
#define kMaxNumberOfMessage 5

@implementation MenstruationUtil

+ (void) checkCurrentDateWithCountDownDateMenstruation {
    if([MASession sharedSession].currentPartner.sex.boolValue != MANAPP_SEX_MALE){
        NSDate * dateExpiration = (NSDate*)[Util objectForKey:kMenstruatationExpiration];
        NSLog(@"dateExpiration: %@",dateExpiration);
        NSLog(@"NSDate date : %@",[NSDate date]);
        // if menstruatation == current time
        NSLog(@"dateExpiration to string %@",[dateExpiration toString]);
        NSLog(@"[[NSDate date] toString] %@",[[NSDate date] toString]);
        if (dateExpiration && [[dateExpiration toString] isEqualToString:[[NSDate date] toString]]) {
            if (![[Util objectForKey:kMessageShowed] boolValue]) {
                [Util showMessage:@"Women aren't completely predictable as you know, double check you've got her flow" withTitle:kAppName];
                [Util setValue:[NSNumber numberWithBool:YES] forKey:kMessageShowed];
            }
            // count show message for each day
            int countDown =  [[Util objectForKey:kCountDownMenstruatationExpiration] integerValue];
            DLog(@"countDown %d",countDown);
            if (countDown < kMaxNumberOfMessage) {
                countDown++;
                [Util setValue:[dateExpiration dateByAddDays:10] forKey:kMenstruatationExpiration];
                //                [Util setValue:[dateExpiration dateByAddMinute:1] forKey:kMenstruatationExpiration];
                //              [Util setValue:[dateExpiration dateByAddDays:1] forKey:kMenstruatationExpiration];
                
                [Util setValue:[NSNumber numberWithBool:NO] forKey:kMessageShowed];
                [Util setValue:[NSNumber numberWithInt:countDown] forKey:kCountDownMenstruatationExpiration];
            }
            if (countDown == kMaxNumberOfMessage) {
                // create later 10 day
                // tao ra 1 key tiep theo la 10 ngay sau.
                [Util setValue:[NSNumber numberWithBool:YES] forKey:kMessageShowed];
                [Util setValue:[NSNumber numberWithInt:0] forKey:kCountDownMenstruatationExpiration];
                [Util setValue:nil forKey:kMenstruatationExpiration];
            }
        }
    }
}
@end
