//
//  MoodHelper.h
//  Manapp
//
//  Created by Demigod on 13/03/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Partner;

#define MA_MOOD_UNAVAILABLE_VALUE -1

@interface MoodHelper : NSObject

+(CGFloat) convertMoodToSliderValue:(CGFloat) mood;
+(CGFloat) convertMoodToSliderValue2:(CGFloat) mood;
+(CGFloat) convertSliderValueToMood:(CGFloat) sliderValue;

+(CGFloat) convertSliderReverseValueToMood:(CGFloat) sliderValue;

+(CGFloat) calculateMoodAtDate:(NSDate *)date forPartner:(Partner *) partner;

//comment by issues https://setaintl2008.atlassian.net/browse/MA-323
+(NSString *) textForMood:(CGFloat)mood forPartner:(Partner *)partner;

+(CGFloat) moodAtCycle:(NSInteger) cycle forDay:(NSInteger) day firstMoodDate:(NSDate *) firstDate forPartner:(Partner *)partner;

+ (NSString*) getImageNameStarForSlideOnMood:(CGFloat) value;

+ (NSInteger)getPoseByMood:(CGFloat)mood;
@end
