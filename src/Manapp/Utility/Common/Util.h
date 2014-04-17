//
//  Util.h
//
//
//  Created by Thanh Le on 12/1/11.
//  Copyright 2011 SETA:CINQ Vietnam., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "MAAppDelegate.h"

@interface Util : NSObject<MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

+ (Util *) sharedUtil;
+ (MAAppDelegate *)appDelegate;

+ (BOOL)validateEmail:(NSString*)email;

+ (void)showMessage:(NSString *)message withTitle:(NSString *)title;
+ (void)showMessage:(NSString *)message withTitle:(NSString *)title andDelegate:(id)delegate;
+ (void)showMessage:(NSString *)message withTitle:(NSString *)title delegate:(id)delegate andTag:(NSInteger)tag;
+ (void)showMessage:(NSString *)message withTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSString *)otherTitle delegate:(id)delegate andTag:(NSInteger)tag;

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)dateFormat;
+ (NSString *)stringFromDateString:(NSString *)dateString;
+ (NSString *)getString:(NSInteger)i;
+ (NSNumber *)getSafeInt:(id)obj;
+ (NSNumber *)getSafeFloat:(id)obj;
+ (NSNumber *)getSafeBool:(id)obj;
+ (NSString *)getSafeString:(id)obj;
+ (BOOL)isNullOrNilObject:(id)object;
+ (BOOL)isEmpty:(NSString*)object;
- (void)showLoadingView;
- (void)showLoadingViewWithTitle:(NSString *)title;
- (void)showLoadingViewInWindow:(UIWindow *)window;
- (void)hideLoadingView;

+ (void)setValue:(id)value forKey:(NSString *)key;
+ (void)setValue:(id)value forKeyPath:(NSString *)keyPath;
+ (void)setObject:(id)obj forKey:(NSString *)key;
+ (id)valueForKey:(NSString *)key;
+ (id)valueForKeyPath:(NSString *)keyPath;
+ (id)objectForKey:(NSString *)key;
+ (void)removeObjectForKey:(NSString *)key;

+ (NSString *)getXIB:(Class)fromClass;
+ (UIView*)getView:(Class)fromClass;
+ (UITableViewCell*)getCell:(Class)fromClass owner:(id) owner;

+ (id)convertJSONToObject:(NSString*)str;
+ (NSString *)convertObjectToJSON:(id)obj;

+ (id)getJSONObjectFromFile:(NSString *)file;

+ (void)printAllSystemFonts;

+ (UIFont *)fontHelveticaWithSize:(CGFloat)fontSize;
+ (UIFont *)fontHelveticaBoldObliqueWithSize:(CGFloat)fontSize;
+ (UIFont *)fontHelveticaBoldWithSize:(CGFloat)fontSize;
+ (UIFont *)fontHelveticaObliqueWithSize:(CGFloat)fontSize;

+ (NSDate*)convertTwitterDateToNSDate:(NSString*)created_at;

+ (NSDictionary *) colorDictFromR:(CGFloat) r G:(CGFloat)g B:(CGFloat)b;
+(NSString*)trimSpace:(NSString *) input;
+ (BOOL) detectTimeFormat12Or24h;
+ (NSNumber*) getCurrentTimeStamp;
- (BOOL) isLastDateOfMonth:(NSDate*) date;
- (NSDate*) firstDateOfMonth:(NSDate*) date;
@end