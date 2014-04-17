//
//  Note.h
//  Manapp
//
//  Created by Demigod on 07/03/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Partner;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * noteID;
@property (nonatomic, retain) Partner *partner;

@end
