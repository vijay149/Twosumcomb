//
//  MACommon.h
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

// define message function which replace DLog and will be use when debug to display loges

#ifndef SetaBase_COMMON_h
#define SetaBase_COMMON_h

#define Translate(text)                    NSLocalizedString(text, nil)

//application constain
// SERVER CONSTRAIN

//local url @"http://172.16.90.15/usa/ManApp/ManApp_backend/api/"
// @"http://210.245.52.167:4567/usa/ManApp/ManApp_backend/api/"
//new url

/**
 *  Local URL
 */
//#define MANAPP_SERVER_URL @"http://172.16.90.28/manapp/api/"
//// http://210.245.52.167:8182/manapp/api/
//#define MANAPP_HELP_URL @"http://172.16.90.28/manapp/help/manapp.php"
////@"http://210.245.52.167:8182/manapp/help/manapp.php"


/**
 *  Server URL
 */
#ifdef DEBUG
#define MANAPP_SERVER_URL                              @"http://backend.twosumapp.com/api/"//@"http://localhost:8888/manapp/api/"//@"http://210.245.52.167:8182/manapp/api/" //
//#define MANAPP_SERVER_URL    @"http://172.16.90.28/manapp/api/"

//@"http://backend.twosumapp.com/api/"
//@"http://210.245.52.167:8182/manapp/api/"
//@"http://172.16.90.28/manapp/api/"//

#define MANAPP_HELP_URL                                 @"http://backend.twosumapp.com/help/manapp.php"//@"http://210.245.52.167:8182/manapp/help/manapp.php"//
#else
#define MANAPP_SERVER_URL                              @"http://backend.twosumapp.com/api/"
#define MANAPP_HELP_URL                                @"http://backend.twosumapp.com/api/help/manapp.php"
#endif

//Date time type
#define MANAPP_DATETIME_DEFAULT_TYPE NSDateFormatterMediumStyle
#define MANAPP_DATETIME_TIME_DEFAULT_TYPE NSDateFormatterMediumStyle
#define MANAPP_TIME_DEFAULT_TYPE NSDateFormatterShortStyle

// Define API URLs
#define MANAPP_LOGIN_API_PATH                             @"user/login"
#define MANAPP_FORGOT_PASSWORD_API_PATH                   @"user/forgotPassword"
#define MANAPP_FORGOT_USERNAME_API_PATH                   @"user/forgotUsername"
#define MANAPP_SIGNUP_API_PATH                            @"user/register"
#define MANAPP_VERIFY_USER_EMAIL_API_PATH                 @"user/verifyEmail"
#define MANAPP_CHANGE_USER_EMAIL_API_PATH                 @"user/changeEmail"
#define MANAPP_CHANGE_USER_PASSWORD_API_PATH              @"user/changePass"
#define MANAPP_CHANGE_USER_CHECK_ACTIVE_API_PATH          @"user/checkActive"
#define MANAPP_MESSAGE_PATH                               @"template/index"
#define MANAPP_MESSAGE_EXCEPTION_PATH                     @"template/exception/date/"

#define MANAPP_LOGIN_API_FULL_PATH                             [NSString stringWithFormat:@"%@%@", MANAPP_SERVER_URL, MANAPP_LOGIN_API_PATH]
#define MANAPP_FORGOT_PASSWORD_API_FULL_PATH                   [NSString stringWithFormat:@"%@%@", MANAPP_SERVER_URL, MANAPP_FORGOT_PASSWORD_API_PATH]
#define MANAPP_SIGNUP_API_FULL_PATH                            [NSString stringWithFormat:@"%@%@", MANAPP_SERVER_URL, MANAPP_SIGNUP_API_PATH]

//APP SETTING
#define MANAPP_MAXIMUM_NUMBER_OF_AVATAR_DEFAULT_NOT_ACTIVE 1
#define MANAPP_MAXIMUM_NUMBER_OF_AVATAR_DEFAULT 2
#define MANAPP_SEX_MALE YES
#define MANAPP_SEX_FEMALE NO
#define MA_DEFAULT_MOOD_VALUE 50
#define MA_MOOD_CYCLE_STEP 3

//Measurement key
#define MANAPP_MEASUREMENT_NAME_KEY     @"Name"
#define MANAPP_MEASUREMENT_SEX_KEY      @"Sex"
#define MANAPP_MEASUREMENT_SEX_MALE     1
#define MANAPP_MEASUREMENT_SEX_FEMALE   0
#define MANAPP_MEASUREMENT_SEX_BOTH     2

//APPLICATION PARTNER SETUP STEP
#define MANAPP_PARTNER_MANAGER_PROCESS_STEP_CREATION                        @"Create new partner step"
#define MANAPP_PARTNER_MANAGER_PROCESS_STEP_INPUT_ADDITIONAL_INFORMATION    @"Edit additional data step"
#define MANAPP_PARTNER_MANAGER_PROCESS_STEP_INPUT_PREFERENCE_LIKE           @"Edit like data step"
#define MANAPP_PARTNER_MANAGER_PROCESS_STEP_INPUT_SIZE                      @"Edit size data step"
#define MANAPP_PARTNER_MANAGER_PROCESS_STEP_INPUT_PREFERENCE_DISLIKE        @"Edit dislike data step"

//application constraint key
//NSUserDefaultkey

#define MANAPP_DEFAULT_KEY_USER_TOKEN               @"MANAPP_DEFAULT_KEY_USER_TOKEN"
#define MANAPP_DEFAULT_KEY_USER_ID                  @"MANAPP_DEFAULT_KEY_USER_ID"
#define MANAPP_DEFAULT_KEY_REMEMBER_ME              @"MANAPP_DEFAULT_KEY_REMEMBER_ME"
#define MANAPP_DEFAULT_KEY_REMEMBER_USERNAME        @"MAMAPP_DEFAULT_KEY_REMEMBER_USERNAME"
#define MANAPP_DEFAULT_KEY_REMEMBER_PASSWORD        @"MAMAPP_DEFAULT_KEY_REMEMBER_PASSWORD"
#define MANAPP_DEFAULT_KEY_NUMBER_TIME_LOGIN_FAIL   @"MANAPP_DEFAULT_KEY_NUMBER_TIME_LOGIN_FAIL"
#define MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN     @"MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN"
#define MANAPP_DEFAULT_KEY_CURRENT_PARTNER_ID       @"MANAPP_DEFAULT_KEY_CURRENT_PARTNER_ID"

//Message from server
#define MANAPP_MESSAGE_FROM_SERVER_DUPLICATE_EMAIL      @"This user's email address already exist"

//Event Setting
#define MANAPP_EVENT_RECURRING_DAILY                                 @"Every day"
#define MANAPP_EVENT_RECURRING_WEEKLY                                @"Every week"
#define MANAPP_EVENT_RECURRING_MONTHLY                               @"Every month"
#define MANAPP_EVENT_RECURRING_YEARLY                                @"Every year"
#define MANAPP_EVENT_RECURRING_NEVER                                 @"Never"

#define MANAPP_EVENT_REMINDER_ITEM_NONE                                         @"None"
#define MANAPP_EVENT_REMINDER_ITEM_AT_EVENT                                     @"At Event"
#define MANAPP_EVENT_REMINDER_ITEM_15_MINUTES                                   @"15 Minutes"
#define MANAPP_EVENT_REMINDER_ITEM_30_MINUTES                                   @"30 Minutes"
#define MANAPP_EVENT_REMINDER_ITEM_1_HOUR                                       @"1 Hour"
#define MANAPP_EVENT_REMINDER_ITEM_2_HOUR                                       @"2 Hours"
#define MANAPP_EVENT_REMINDER_ITEM_4_HOUR                                       @"4 Hours"
#define MANAPP_EVENT_REMINDER_ITEM_1_DAY                                        @"1 Day"
#define MANAPP_EVENT_REMINDER_ITEM_2_DAY                                        @"2 Days"
#define MANAPP_EVENT_REMINDER_ITEM_1_WEEK                                       @"1 Week"
#define MANAPP_EVENT_REMINDER_ITEM_2_WEEK                                       @"2 Weeks"
#define MANAPP_EVENT_REMINDER_ITEM_1_MONTH                                      @"1 Month"

#define MANAPP_EVENT_TYPE_EVENT                                     0
#define MANAPP_EVENT_TYPE_BIRTHDAY                                  1
#define MANAPP_EVENT_TYPE_FIRSTMEET                                 2

//Calendar
#define MANAPP_MENSTRATIONVIEW_DEFAULT_LAST_PERIOD            @"/  /"

//fertle and mestration
#define PERIOD_USING_BIRTH_CONTROL                      28
#define PERIOD_WITHOUT_USING_BIRTH_CONTROL              30

//homepage
//setting picker
//define label
#define MANAPP_SETTING_MENU_ITEM_CREATE_AVATAR             @"Create new partner"           //label for the setting menu
#define MANAPP_SETTING_MENU_ITEM_CHANGE_PASSWORD           @"Change password"              //label for the setting menu
#define MANAPP_SETTING_MENU_ITEM_DELETE_CURRENT_PARTNER    @"Delete current partner"       //label for the setting menu
#define MANAPP_SETTING_MENU_ITEM_LOGOUT                    @"Logout"                       //label for the setting menu
#define MANAPP_SETTING_MENU_ITEM_PARTNER                   @"Select %@"                  //label for the setting menu
#define MANAPP_SETTING_MENU_ITEM_CHANGE_EMAIL              @"Change Email"           //label for the setting menu
#define MANAPP_SETTING_MENU_ITEM_RESET_NOTIFICATIONS       @"Reset Notification"           //label for the setting menu

#define MANAPP_MESSAGE_TYPE_MOOD   @"0"
#define MANAPP_MESSAGE_TYPE_GEN    @"1"
#define MANAPP_MESSAGE_TYPE_SIZE   @"2"
#define MANAPP_MESSAGE_TYPE_LIKES  @"3"
#define MANAPP_MESSAGE_TYPE_EVENT  @"4"
#define MANAPP_MESSAGE_TYPE_INFO   @"5"
#define MANAPP_MESSAGE_TYPE_MOOD_FUTURE   @"6"
#define MANAPP_MESSAGE_TYPE_DISLIKE       @"7"
#define MANAPP_MESSAGE_EVENT_TIME_SPERM       @"Sperm"
#define MANAPP_MESSAGE_EVENT_TIME_RED_CIRCLE  @"Red circle"
#define MANAPP_MESSAGE_EVENT_TIME_ONE_WEEK    @"One week from birthday"
#define MANAPP_MESSAGE_EVENT_TIME_TWO_WEEK    @"Two week from birthday"
#define MANAPP_MESSAGE_EVENT_TIME_ONE_MONTH   @"One month from anniversary"

#define MANAPP_MESSAGE_PLACEHOLDER_NAME       @"(Name)"
#define MANAPP_MESSAGE_PLACEHOLDER_DOB        @"(DOB)"
#define MANAPP_MESSAGE_PLACEHOLDER_CATEGORY_A @"(A)"
#define MANAPP_MESSAGE_PLACEHOLDER_CATEGORY_B @"(B)"
#define kSaveNoteDidFinish                    @"kSaveNoteDidFinish"
#define kValueMoodSelected                    @"kValueMoodSelected"
#define kIsWeek                               @"kIsWeek"
#define kSaveEroZoneDidFinish                 @"kSaveEroZoneDidFinish"
#define kSpecialZoneEnough                    @"kSpecialZoneEnough"
#define kMenstruatationExpiration             @"kMenstruatationExpiration"
#define kMenstruatation10daysLater            @"kMenstruatation10daysLater"
#define kCountDownMenstruatationExpiration    @"kCountDownMenstruatationExpiration"
#define kMessageShowed                        @"kMessageShowed"
#define kLatestUpdateMessage                  @"kLatestUpdateMessage"
#define kMoodDefaultFirstStart                @"kMoodDefaultFirstStart"
//kMessageDeleted = 1 // deleted from server
#define kMessageDeletedFromServer             @"1"
#endif