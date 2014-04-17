//
//  MAManagedObjectCloner.h
//  TwoSum
//
//  Created by Duong Van Dinh on 1/2/14.
//  Copyright (c) 2014 Seta. All rights reserved.
//

@interface ManagedObjectCloner : NSObject {
}
+(NSManagedObject *)clone:(NSManagedObject *)source inContext:(NSManagedObjectContext *)context;
@end
