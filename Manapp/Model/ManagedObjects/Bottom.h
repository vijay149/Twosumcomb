//
//  Bottom.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PartnerAvatar;

@interface Bottom : NSManagedObject

@property (nonatomic, retain) NSString * bottomID;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * name;
@property (nonatomic, retain) NSSet *fkBottomToPartnerAvatar;
@end

@interface Bottom (CoreDataGeneratedAccessors)

- (void)addFkBottomToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)removeFkBottomToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)addFkBottomToPartnerAvatar:(NSSet *)values;
- (void)removeFkBottomToPartnerAvatar:(NSSet *)values;

@end
