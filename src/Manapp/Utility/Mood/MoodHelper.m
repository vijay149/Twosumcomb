//
//  MoodHelper.m
//  Manapp
//
//  Created by Demigod on 13/03/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "MoodHelper.h"
#import "Partner.h"
#import "PartnerMood.h"
#import "DatabaseHelper.h"
#import "NSDate+Helper.h"
#import "EGOCache.h"

#define DAYOFCYCLE 30
#define CYCLE2
#define MOOD_DEFAULT 50
@implementation MoodHelper

+(CGFloat) convertMoodToSliderValue:(CGFloat) mood{
    return (1 - mood/100);
}

+(CGFloat) convertMoodToSliderValue2:(CGFloat) mood {
    return (mood/100);
}

+(CGFloat) convertSliderValueToMood:(CGFloat) sliderValue{
    return 100 - sliderValue * 100;
}

+(CGFloat) convertSliderReverseValueToMood:(CGFloat) sliderValue{
    return sliderValue * 100;
}

+(CGFloat) calculateMoodAtDate:(NSDate *)date forPartner:(Partner *) partner{
    NSArray *moods = [[DatabaseHelper sharedHelper] getAllMoodForPartner:partner];
    
    //check if there is any mood available
    if(moods.count > 0){
        //get the first mood (the first one)
        PartnerMood *firstMood = [moods objectAtIndex:0];
        //check the cycle number
        NSLog(@"added time %@",firstMood.addedTime);
        NSInteger cycle = [NSDate dayBetweenDay:[firstMood.addedTime beginningAtMidnightOfDay] andDay:[date beginningAtMidnightOfDay]]/ 30;
        NSInteger day = [NSDate dayBetweenDay:[firstMood.addedTime beginningAtMidnightOfDay] andDay:[date beginningAtMidnightOfDay]]% 30 + 1;

        PartnerMood *moodAtDate = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:date];
        if (moodAtDate) {
            if ([moodAtDate.isUserInput boolValue]) {
                 NSString *key = [NSString stringWithFormat:@"kMood_%d_%d_%f_%d", cycle, day, [firstMood.addedTime timeIntervalSince1970], partner.partnerID.integerValue];
                [[EGOCache globalCache] setString:[NSString stringWithFormat:@"%f", [moodAtDate.moodValue floatValue]] forKey:key];
                return [moodAtDate.moodValue floatValue];
            }
        }
        
        CGFloat result = [MoodHelper moodAtCycle:cycle forDay:day firstMoodDate:firstMood.addedTime forPartner:partner];
        return result;
    }
    else{
        return 0;
    }
}


 //comment by issues
 //https://setaintl2008.atlassian.net/browse/MA-323
+(NSString *) textForMood:(CGFloat)mood forPartner:(Partner *)partner{
    NSString *moodText = nil;
    
    if(mood == 0){
        return nil;
    }
    else if(mood > 0 && mood <= 20){
        return [NSString stringWithFormat:@"Look like %@ is in really bad mood",partner.name];
    }
    else if(mood > 20 && mood <= 40){
        return [NSString stringWithFormat:@"%@ is kinda upset",partner.name];
    }
    else if(mood > 40 && mood <= 60){
        return [NSString stringWithFormat:@"%@ feel like everything is ok",partner.name];
    }
    else if(mood > 60 && mood <= 80){
        return [NSString stringWithFormat:@"%@ is having a good spirit",partner.name];
    }
    else{
        return [NSString stringWithFormat:@"Everything is so greate, %@ say",partner.name];
    }
    
    return moodText;
}

 
//day will go from 1 to 30
+(CGFloat) moodAtCycle:(NSInteger) cycle forDay:(NSInteger) day firstMoodDate:(NSDate *) firstDate forPartner:(Partner *)partner{
    NSString *key = [NSString stringWithFormat:@"kMood_%d_%d_%f_%d", cycle, day, [firstDate timeIntervalSince1970], partner.partnerID.integerValue];
    if ([[EGOCache globalCache] hasCacheForKey:key]) {
        NSString *moodStr = [[EGOCache globalCache] stringForKey:key];
        return [moodStr floatValue];
    }
    
    if (cycle < 0) {
        [[EGOCache globalCache] setString:[NSString stringWithFormat:@"%d", MA_MOOD_UNAVAILABLE_VALUE] forKey:key];
        return MA_MOOD_UNAVAILABLE_VALUE;
    } else if(cycle == 0){
//    if(cycle == 0){
        //make sure to use (day - 1) because day = 1 mean the same day
        PartnerMood *mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[firstDate dateByAddDays:(day-1)]];
        if(mood){
            [[EGOCache globalCache] setString:[NSString stringWithFormat:@"%f", mood.moodValue.floatValue] forKey:key];
            return mood.moodValue.floatValue;
        }
        else{
            [[EGOCache globalCache] setString:[NSString stringWithFormat:@"%d", MA_MOOD_UNAVAILABLE_VALUE] forKey:key];
            return MA_MOOD_UNAVAILABLE_VALUE;
        }
    }
    else if(cycle == 1 || cycle == 2){
        if(day == 1){
            CGFloat previousMood = [self moodAtCycle:(cycle - 1) forDay:day firstMoodDate:firstDate forPartner:partner];
             //HuongNT add MA_432
            //C1D1 = C2D1 = Avg of Day 1 + 28
            CGFloat previous28thMood = [self moodAtCycle:(cycle - 1) forDay:28 firstMoodDate:firstDate forPartner:partner];
           
            if(previousMood == MA_MOOD_UNAVAILABLE_VALUE){
                previousMood = MOOD_DEFAULT;
            }
            CGFloat resultMood = (previousMood+previous28thMood)/2;

           [[EGOCache globalCache] setString:[NSString stringWithFormat:@"%f", resultMood] forKey:key];
            return resultMood;
        }
        else{
           
            //HUONGNT ADD
            NSInteger dayModule3 = day/3;
            
            NSInteger addValueModule = dayModule3*3+1;
            
            CGFloat moodInPreviousCycleDay1 = [self moodAtCycle:(cycle-1) forDay:(day - 1) firstMoodDate:firstDate forPartner:partner];
            CGFloat moodInPreviousCycleDay2 = [self moodAtCycle:(cycle - 1) forDay:day firstMoodDate:firstDate forPartner:partner];
            CGFloat moodInPreviousModule3Cycle = [self moodAtCycle:(cycle - 1) forDay:addValueModule firstMoodDate:firstDate forPartner:partner];
            if (moodInPreviousModule3Cycle == MA_MOOD_UNAVAILABLE_VALUE) {
                moodInPreviousModule3Cycle = MOOD_DEFAULT;
            }
            
            if(moodInPreviousCycleDay1 == MA_MOOD_UNAVAILABLE_VALUE){
                moodInPreviousCycleDay1 = MOOD_DEFAULT;
            }
            
            if(moodInPreviousCycleDay2 == MA_MOOD_UNAVAILABLE_VALUE){
                [[EGOCache globalCache] setString:[NSString stringWithFormat:@"%f", (moodInPreviousCycleDay1 + moodInPreviousModule3Cycle)/2] forKey:key];
                return (moodInPreviousCycleDay1 + moodInPreviousModule3Cycle)/2;
            }
            else{
                [[EGOCache globalCache] setString:[NSString stringWithFormat:@"%f", (moodInPreviousCycleDay1 + moodInPreviousCycleDay2)/2] forKey:key];
                return (moodInPreviousCycleDay1 + moodInPreviousCycleDay2)/2;
            }
            
        }
    }
    else if(cycle >=3 || cycle <= 12) { //Cycle 13 = Avg (C10+C11+C12)
        CGFloat moodInPreviousCycle1 = [self moodAtCycle:(cycle - 1) forDay:day firstMoodDate:firstDate forPartner:partner];
        CGFloat moodInPreviousCycle2 = [self moodAtCycle:(cycle - 2) forDay:day firstMoodDate:firstDate forPartner:partner];
        CGFloat moodInPreviousCycle3 = [self moodAtCycle:(cycle - 3) forDay:day firstMoodDate:firstDate forPartner:partner];
       
        if(moodInPreviousCycle1 == MA_MOOD_UNAVAILABLE_VALUE){
            moodInPreviousCycle1 = MOOD_DEFAULT;
        }
        if(moodInPreviousCycle2 == MA_MOOD_UNAVAILABLE_VALUE){
            moodInPreviousCycle2 = MOOD_DEFAULT;
        }
        if(moodInPreviousCycle3 == MA_MOOD_UNAVAILABLE_VALUE){
            moodInPreviousCycle3 = MOOD_DEFAULT;
        }
           
        [[EGOCache globalCache] setString:[NSString stringWithFormat:@"%f", (moodInPreviousCycle1 + moodInPreviousCycle2 + moodInPreviousCycle3)/3] forKey:key];
        return (moodInPreviousCycle1 + moodInPreviousCycle2 + moodInPreviousCycle3)/3;
    }
    else if(cycle == 13){
        CGFloat moodInSameDayInCycle1 = [self moodAtCycle:0 forDay:day firstMoodDate:firstDate forPartner:partner];
        CGFloat moodInSameDayInCycle12 = [self moodAtCycle:12 forDay:day firstMoodDate:firstDate forPartner:partner];
       
        if(moodInSameDayInCycle1 == MA_MOOD_UNAVAILABLE_VALUE){
            moodInSameDayInCycle1 = MOOD_DEFAULT;
        }
        if(moodInSameDayInCycle12 == MA_MOOD_UNAVAILABLE_VALUE){
            moodInSameDayInCycle12 = MOOD_DEFAULT;
        }
            
        [[EGOCache globalCache] setString:[NSString stringWithFormat:@"%f", (moodInSameDayInCycle1 + moodInSameDayInCycle12)/2] forKey:key];
        return (moodInSameDayInCycle1 + moodInSameDayInCycle12)/2;
    }
    else{//Avg of Cycle 1 + 13	Avg of Cycle 2 + 14
        
        CGFloat moodInSameDayInCycle1 = [self moodAtCycle:(cycle-1-12) forDay:day firstMoodDate:firstDate forPartner:partner];
        CGFloat moodInSameDayInPreviousCycle = [self moodAtCycle:(cycle - 1) forDay:day firstMoodDate:firstDate forPartner:partner];
        
        if(moodInSameDayInCycle1 == MA_MOOD_UNAVAILABLE_VALUE){
            moodInSameDayInCycle1 = MOOD_DEFAULT;
        }
        if(moodInSameDayInPreviousCycle == MA_MOOD_UNAVAILABLE_VALUE){
            moodInSameDayInPreviousCycle = MOOD_DEFAULT;
        }
         
        [[EGOCache globalCache] setString:[NSString stringWithFormat:@"%f", (moodInSameDayInCycle1 + moodInSameDayInPreviousCycle)/2] forKey:key];
        return (moodInSameDayInCycle1 + moodInSameDayInPreviousCycle)/2;
    }
}

#pragma mark - helper functions
+ (NSInteger)getPoseByMood:(CGFloat)mood {
    if(mood < 13){
        return 0;
    }
    else if(mood < 40){
        return 1;
    }
    else if(mood < 60){
        return 2;
    }
    else if(mood < 80){
        return 3;
    }
    else{
        return 4;
    }
    
}


//The of the star for the 5 moods from Happiest to Saddest.
//Saffron           #FBB917 (80-99)
//Yellow            #FFFF00 (60-79
//Yellow Green      #52D017 (40-59
//Light Sea Green	#3EA99F (20-39)
//Earth Blue        #0000A0 (0 - 19 )
+ (NSString*) getImageNameStarForSlideOnMood:(CGFloat) value {
    NSString *imageName = @"";
    int newValue = (int) roundf(value);
    if (newValue >= 0 && newValue <= 12) { // Cuongnt change value 13 to 19 (why is 13???)
        imageName = @"icon_slide_star_blue";
    } else if (newValue >= 12 && newValue <= 39) {
        imageName = @"icon_slide_star_light_sea_green";
    } else if (newValue >= 40 && newValue <= 59) {
        imageName = @"icon_slide_star_yellow_green";
    } else if (newValue >= 60 && newValue <= 79) {
        imageName = @"icon_slide_star_yellow";
    } else if (newValue >= 80) {
        imageName = @"icon_slide_star_saffron";
    }
    return imageName;
}

@end
