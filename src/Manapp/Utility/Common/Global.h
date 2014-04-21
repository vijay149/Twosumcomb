//
//  Global.h
//  SetaBase
//
//  Created by Thanh Le on 8/9/12.
//  Copyright (c) 2012 Setacinq. All rights reserved.
//

#ifndef SetaBase_Global_h
#define SetaBase_Global_h

//Common class
#import "Logging.h"
#import "Util.h"
//Some useful macro
#import "Macro.h"
#import "enum.h"
#import "MACommon.h"

//Define all key here
#define kBaseURL @"http://highoncoding.com"
#define IPAD_XIB_POSTFIX @"~iPad"

#define MA_NAVIGATION_COMMON_LEFT_BUTTON_TAG 954
#define MA_NAVIGATION_COMMON_RIGHT_BUTTON_TAG 955
#define MA_NAVIGATION_COMMON_NOTE_BUTTON_TAG 956
#define MA_NAVIGATION_COMMON_SUMMARY_BUTTON_TAG 957
#define kAppName            @"TwoSum"
#define kAppFont            @"BankGothic Md BT"
#define kFontAppleGothic    @"AppleGothic"


//NSUserdefault key
#define kAppFirstRunTime @"kAppFirstRunTime"

//color
#define kColorChannelR @"R"
#define kColorChannelG @"G"
#define kColorChannelB @"B"

//login api
#define kAPIStatus @"success"
#define kAPIMessage @"message"
#define kAPILoginUserId @"userId"
#define kAPILoginUserState @"userStatus"
#define kAPILoginToken @"token"

#define kAPISignUpUserId @"userId"

//common ui
#define MA_BACK_BUTTON_TEXT LSSTRING(@"Back")
#define MA_HOME_BUTTON_TEXT LSSTRING(@"Home")
#define MA_CANCEL_BUTTON_TEXT LSSTRING(@"Cancel")
#define MA_SAVE_BUTTON_TEXT LSSTRING(@"Save")
#define MA_ADD_BUTTON_TEXT LSSTRING(@"Add")

//avatar
#define AVATAR_CATEGORY_SHOE                    @"shoe"
#define AVATAR_CATEGORY_PANT                    @"pant"
#define AVATAR_CATEGORY_SHIRT                   @"shirt"
#define AVATAR_CATEGORY_HAIR                    @"hair"
#define AVATAR_CATEGORY_BEARD                   @"beard"
#define AVATAR_CATEGORY_GLASS                   @"glass"
#define AVATAR_CATEGORY_ACCESSORY               @"accessory"

#define AVATAR_CATEGORY_SHOE_ZINDEX             6
#define AVATAR_CATEGORY_PANT_ZINDEX             7
#define AVATAR_CATEGORY_SHIRT_ZINDEX            8
#define AVATAR_CATEGORY_HAIR_ZINDEX             5
#define AVATAR_CATEGORY_BEARD_ZINDEX             5
#define AVATAR_CATEGORY_GLASS_ZINDEX            9
#define AVATAR_CATEGORY_ACCESSORY_ZINDEX        10

// using speak box on home view
#define kIsLastItem                             46
#define kRangeCrashOnSubCategory                2147483647

#define kYearForever                            2050

#define kIndexHelpShowHomepage                  5
           

/**
 *  created partner or not
 */
#define kIsCreatedPartner                       @"isCreatedPartner"


typedef enum {
    MODE_REMINDER,
    MODE_REPEAT,

} MODE_VIEW;

#endif
