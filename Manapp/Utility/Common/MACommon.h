//
//  MACommon.h
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

// define message function which replace DLog and will be use when debug to display loges
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#ifdef DEBUG
#define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#define ULog(...)
#endif

//application constain
// SERVER CONSTRAIN
#define MANAPP_SERVER_URL                              @"http://210.245.52.167/usa/manapp/api/"
// Define API URLs
#define MANAPP_LOGIN_API_PATH                             @"user/login"
#define MANAPP_FORGOT_PASSWORD_API_PATH                   @"user/forgotPassword"
#define MANAPP_SIGNUP_API_PATH                            @"user/register"

#define MANAPP_LOGIN_API_FULL_PATH                             [NSString stringWithFormat:@"%@%@", MANAPP_SERVER_URL, MANAPP_LOGIN_API_PATH]
#define MANAPP_FORGOT_PASSWORD_API_FULL_PATH                   [NSString stringWithFormat:@"%@%@", MANAPP_SERVER_URL, MANAPP_FORGOT_PASSWORD_API_PATH]
#define MANAPP_SIGNUP_API_FULL_PATH                            [NSString stringWithFormat:@"%@%@", MANAPP_SERVER_URL, MANAPP_SIGNUP_API_PATH]

//APP SETTING
#define MANAPP_MAXIMUM_NUMBER_OF_AVATAR 2

//APPLICATION PARTNER SETUP STEP
#define MANAPP_PARTNER_MANAGER_PROCESS_STEP_CREATION @"Create new partner step"
#define MANAPP_PARTNER_MANAGER_PROCESS_STEP_INPUT_ADDITIONAL_INFORMATION @"Edit additional data step"
#define MANAPP_PARTNER_MANAGER_PROCESS_STEP_INPUT_PREFERENCE_LIKE @"Edit like data step"
#define MANAPP_PARTNER_MANAGER_PROCESS_STEP_INPUT_SIZE @"Edit size data step"
#define MANAPP_PARTNER_MANAGER_PROCESS_STEP_INPUT_PREFERENCE_DISLIKE @"Edit dislike data step"

//application constraint key
//NSUserDefaultkey

#define MANAPP_DEFAULT_KEY_USER_TOKEN @"MANAPP_DEFAULT_KEY_USER_TOKEN"
#define MANAPP_DEFAULT_KEY_USER_ID @"MANAPP_DEFAULT_KEY_USER_ID"
#define MANAPP_DEFAULT_KEY_REMEMBER_ME @"MANAPP_DEFAULT_KEY_REMEMBER_ME"
#define MANAPP_DEFAULT_KEY_REMEMBER_USERNAME @"MAMAPP_DEFAULT_KEY_REMEMBER_USERNAME"
#define MANAPP_DEFAULT_KEY_REMEMBER_PASSWORD  @"MAMAPP_DEFAULT_KEY_REMEMBER_PASSWORD"
#define MANAPP_DEFAULT_KEY_NUMBER_TIME_LOGIN_FAIL  @"MANAPP_DEFAULT_KEY_NUMBER_TIME_LOGIN_FAIL"
#define MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN @"MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN"
#define MANAPP_DEFAULT_KEY_CURRENT_PARTNER_ID @"MANAPP_DEFAULT_KEY_CURRENT_PARTNER_ID"

//Message from server
#define MANAPP_MESSAGE_FROM_SERVER_DUPLICATE_EMAIL      @"This user's email address already exist"

//Event Setting
#define MANAPP_EVENT_RECURRING_DAILY                                 @"Every day"
#define MANAPP_EVENT_RECURRING_WEEKLY                                @"Every week"
#define MANAPP_EVENT_RECURRING_MONTHLY                               @"Every month"
#define MANAPP_EVENT_RECURRING_NEVER                                 @"Never"

#define MANAPP_EVENT_REMINDER_ITEM_1                                 @"5 seconds"
#define MANAPP_EVENT_REMINDER_ITEM_2                                 @"10 seconds"
#define MANAPP_EVENT_REMINDER_ITEM_3                                 @"15 seconds"
#define MANAPP_EVENT_REMINDER_ITEM_4                                 @"20 seconds"

//homepage
//setting picker
//define label
#define MANAPP_SETTING_MENU_ITEM_CREATE_AVATAR             @"Create new partner"           //label for the setting menu
#define MANAPP_SETTING_MENU_ITEM_CHANGE_PASSWORD           @"Change password"              //label for the setting menu
#define MANAPP_SETTING_MENU_ITEM_DELETE_CURRENT_PARTNER    @"Delete current partner"       //label for the setting menu
#define MANAPP_SETTING_MENU_ITEM_LOGOUT                    @"Logout"                       //label for the setting menu
#define MANAPP_SETTING_MENU_ITEM_PARTNER                   @"Profile: %@"                  //label for the setting menu