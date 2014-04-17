//
//  Util.m
//
//
//  Created by Thanh Le on 12/1/11.
//  Copyright 2011 SETA:CINQ Vietnam., Ltd. All rights reserved.
//

#import "Util.h"
#import "NSString+Extension.h"
#import "AFJSONUtilities.h"

#define kCalendarType NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit

@implementation Util

+ (Util *)sharedUtil {
    static Util *_sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUtil = [[Util alloc] init];
    });
    
    return _sharedUtil;
}

#pragma mark Validator
+ (BOOL)validateEmail:(NSString*)email
{
	email = [email lowercaseString];
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *regExPredicate =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:email];
}

- (void)dealloc {
    [HUD release];
    HUD = nil;
    [super dealloc];
}

+ (MAAppDelegate *)appDelegate {
    MAAppDelegate *appDelegate = (MAAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate;
}

+ (void)showMessage:(NSString *)message withTitle:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

+ (void)showMessage:(NSString *)message withTitle:(NSString *)title andDelegate:(id)delegate
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    [alert release];
}

+ (void)showMessage:(NSString *)message withTitle:(NSString *)title delegate:(id)delegate andTag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = tag;
    [alert show];
    [alert release];
}

+ (void)showMessage:(NSString *)message withTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSString *)otherTitle delegate:(id)delegate andTag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle, nil];
    alert.tag = tag;
    alert.delegate = delegate;
    [alert show];
    [alert release];
}

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:dateFormat];
    NSDate *ret = [formatter dateFromString:dateString];
    [formatter release];
    return ret;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    NSString *ret = [formatter stringFromDate:date];
    [formatter release];
    return ret;
}

+ (NSString *)stringFromDateString:(NSString *)dateString
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *utcDate = [formatter dateFromString:dateString];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
    [formatter setDateFormat:@"MM/dd/yyyy h:mm a"];
    return [formatter stringFromDate:utcDate];
}

#pragma mark
+ (NSString*)getString:(NSInteger)i {
    return [[NSNumber numberWithInt:i] stringValue];
}
+ (NSNumber *)getSafeInt:(id)obj {
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    if ([obj length] == 0) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    return [NSNumber numberWithInt:[obj intValue]];
}

+ (NSNumber *)getSafeFloat:(id)obj {
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    if ([obj length] == 0) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    return [NSNumber numberWithFloat:[obj floatValue]];
}

+ (NSNumber *)getSafeBool:(id)obj {
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    if ([obj length] == 0) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    return [NSNumber numberWithBool:[obj boolValue]];
}

+ (NSString *)getSafeString:(id)obj {
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
        return @"";
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return @"";
    }
    return [obj stringValue];
}

+ (BOOL)isNullOrNilObject:(id)object
{
    if ([object isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (object == nil) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEmpty:(NSString*)object {
    return (object == nil || [object isEqualToString:@""] == 0) ? YES : NO;
}

+ (NSString *)getXIB:(Class)fromClass
{
	NSString *className = NSStringFromClass(fromClass);
	
	if (IS_IPAD()) {
		className = [className stringByAppendingString:IPAD_XIB_POSTFIX];
	} else {
		
	}
	return className;
}

+ (UIView*)getView:(Class)fromClass{
	NSArray* views = [[NSBundle mainBundle] loadNibNamed:[Util getXIB:fromClass] owner:nil options:nil];
	for (UIView *view in views) {
		if([view isKindOfClass:fromClass]) {
			return view;
			break;
		}
	}
	return nil;
}

+ (UITableViewCell*)getCell:(Class)fromClass owner:(id) owner{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(fromClass)
                                                 owner:owner options:nil];
    for (id oneObject in nib)
        if ([oneObject isKindOfClass:fromClass]){
            return (UITableViewCell *)oneObject;
        }
    return nil;
}

#pragma mark Loading View
- (void)showLoadingView {
    [self showLoadingViewWithTitle:@""];
}

- (void)showLoadingViewWithTitle:(NSString *)title
{
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:[Util appDelegate].window];
        [[Util appDelegate].window addSubview:HUD];
        HUD.labelText = title;
        HUD.animationType = MBProgressHUDAnimationFade;
        HUD.dimBackground = NO;
        HUD.delegate = self;
    }
    [HUD show:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    HUD.delegate = nil;
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

- (void)hideLoadingView {
    [HUD hide:YES];
}

- (void)showLoadingViewInWindow:(UIWindow *)window
{
	if (!window) {
		window = [Util appDelegate].window;
	}
	
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:window];
        [window addSubview:HUD];
        HUD.labelText = nil;
        HUD.animationType = MBProgressHUDAnimationFade;
        HUD.dimBackground = YES;
    }
    [HUD show:YES];
}

+ (void)setValue:(id)value forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKeyPath:keyPath];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setObject:(id)obj forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)valueForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

+ (id)valueForKeyPath:(NSString *)keyPath
{
    return [[NSUserDefaults standardUserDefaults] valueForKeyPath:keyPath];
}

+ (id)objectForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)removeObjectForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)convertJSONToObject:(NSString*)str {
	NSError *error = nil;
	NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *responseDict;
	
	if (data) {
		responseDict = AFJSONDecode(data, &error);
	} else {
		responseDict = nil;
	}
	
	return responseDict;
}

+ (NSString *)convertObjectToJSON:(id)obj {
	NSError *error = nil;
	NSData *data = AFJSONEncode(obj, &error);
	
	if (error) {
		return @"";
	}
	return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

+ (id)getJSONObjectFromFile:(NSString *)file {
	NSString *textPAth = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];
	
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:textPAth encoding:NSUTF8StringEncoding error:&error];  //error checking omitted
	
	id returnData = [Util convertJSONToObject:content];
	return returnData;
}

+ (void)printAllSystemFonts
{
    printf("--------------------------------------------------------------------\n");
    NSArray *familyNames = [UIFont familyNames];
    for( NSString *familyName in familyNames ){
        printf( "Family: %s \n", [familyName UTF8String] );
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        for( NSString *fontName in fontNames ){
            printf( "\tFont: %s \n", [fontName UTF8String] );
        }
    }
    printf("--------------------------------------------------------------------\n");
}

+ (UIFont *)fontHelveticaWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Helvetica" size:fontSize];
}

+ (UIFont *)fontHelveticaBoldObliqueWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Helvetica-BoldOblique" size:fontSize];
}

+ (UIFont *)fontHelveticaBoldWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
}

+ (UIFont *)fontHelveticaObliqueWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Helvetica-Oblique" size:fontSize];
}

+ (NSDate*)convertTwitterDateToNSDate:(NSString*)created_at
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"EEE LLL d HH:mm:ss Z yyyy"];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
	
	NSDate *convertedDate = [dateFormatter dateFromString:created_at];
	
    return convertedDate;
}

+ (NSDictionary *) colorDictFromR:(CGFloat) r G:(CGFloat)g B:(CGFloat)b{
    NSMutableDictionary *color = [[[NSMutableDictionary alloc] init] autorelease];
    [color setObject:[NSNumber numberWithFloat:r] forKey:kColorChannelR];
    [color setObject:[NSNumber numberWithFloat:g] forKey:kColorChannelG];
    [color setObject:[NSNumber numberWithFloat:b] forKey:kColorChannelB];
    return color;
}

+(NSString*)trimSpace:(NSString *) input {
    if (input && input.length > 0) {
        return [input stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    } else {
        return @"";
    }
}

+ (BOOL) detectTimeFormat12Or24h {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    [formatter release];
    NSLog(@"%@\n",(is24h ? @"YES" : @"NO"));
    return is24h ? YES : NO;
}

+ (NSNumber*) getCurrentTimeStamp {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
   return [NSNumber numberWithDouble: timeStamp];
}

- (BOOL) isLastDateOfMonth:(NSDate*) date {
    BOOL isLast = NO;
    if (date) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:kCFCalendarUnitDay | kCFCalendarUnitMonth | kCFCalendarUnitYear fromDate:date];
        NSInteger day = [components day];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSRange rng = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
        NSUInteger numberOfDaysInMonth = rng.length;
        if (day == numberOfDaysInMonth) {
            DLogInfo(@"yes");
            isLast = YES;
        }
    }
    return isLast;
}

- (NSDate*) firstDateOfMonth:(NSDate*) date {
    NSDate *dayOneInCurrentMonth = nil;
    if (date) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorian components:(NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:date];
        components.day = 1;
        dayOneInCurrentMonth = [gregorian dateFromComponents:components];
    }
    return dayOneInCurrentMonth;
}

@end
