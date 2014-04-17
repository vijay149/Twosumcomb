//
//  MessageDTO.m
//  TwoSum
//
//  Created by quoc viet on 7/25/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "MessageDTO.h"
#import "NSString+Extension.h"

@implementation MessageDTO

- (id) initWithJsonDict:(NSDictionary *)jsonDict{
    self = [super init];
    
    if(self){
        if(jsonDict && [jsonDict isKindOfClass:[NSDictionary class]]){
            self.messageID = [Util getSafeString:[jsonDict objectForKey:@"id"]];
            self.message = [Util getSafeString:[jsonDict objectForKey:@"template"]];
            self.secondMessage = [Util getSafeString:[jsonDict objectForKey:@"second_template"]];
            self.categoryA = [Util getSafeString:[jsonDict objectForKey:@"a_category"]];
            self.categoryB = [Util getSafeString:[jsonDict objectForKey:@"b_category"]];
            self.subCategoryA = [Util getSafeString:[jsonDict objectForKey:@"a_subcategory"]];
            self.subCategoryB = [Util getSafeString:[jsonDict objectForKey:@"b_subcategory"]];
            self.eventDate = [Util getSafeString:[jsonDict objectForKey:@"event_time"]];
            self.type = [Util getSafeString:[jsonDict objectForKey:@"rules_id"]];
            
            NSInteger sex = [[jsonDict objectForKey:@"gender"] integerValue];
            if (sex == 1){
                self.sex = MANAPP_SEX_MALE;
            }
            else{
                self.sex = MANAPP_SEX_FEMALE;
            }
            
            NSString *range = [Util getSafeString:[jsonDict objectForKey:@"mood_range"]];
            if(range && range.length > 0 ){
                NSArray *ranges = [range componentsSeparatedByString:@"-"];
                if(ranges.count == 2){
                    for(NSInteger i = 0; i < ranges.count; i++){
                        NSString *rangeValue = [ranges[i] trimSpace];
                        if(rangeValue && ![rangeValue isEqualToString:@""]){
                            if(i == 0){
                                self.moodLower = [rangeValue integerValue];
                            }
                            else {
                                self.moodHigher = [rangeValue integerValue];
                            }
                        }
                    }
                }
            }
        }
    }
    
    return self;
}

- (void)dealloc{
    [super dealloc];
    [_categoryA release];
    [_categoryB release];
    [_message release];
    [_messageID release];
    [_secondMessage release];
    [_subCategoryA release];
    [_subCategoryB release];
}

@end
