//
//  LinkedHashMap.m
//  LinkedHashMap
//
//  Created by Tristin Forbus on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LinkedHashMap.h"

@implementation LinkedHashMap

-(id)init
{
    keyValueMap = [NSMutableDictionary dictionary];
    keyAddressMap = [NSMutableDictionary dictionary];
    keyValueList = [[[KVDoubleLinkedList alloc] init] autorelease];
    
    return self;
}


-(void)insertValue:(id)value withKey:(id)key
{
    Node* node = [keyValueList insert:value withKey:key];
    [keyValueMap setObject:value forKey:key];
    [keyAddressMap setObject:node forKey:key];
    
}


-(void)removeValueWithKey:(id)key
{
    [keyValueMap removeObjectForKey:key];
    [keyValueList removeNode:[keyAddressMap objectForKey:key]];
    [keyAddressMap removeObjectForKey:key];
}


-(void)setValue:(id)value forKey:(id)key
{
    [keyValueMap setValue:value forKey:key];
    Node* node = [keyAddressMap objectForKey:key];
    node.nodeValue = value;
}


-(id)valueForKey:(id)key
{
    return [keyValueMap objectForKey:key];
}


-(NSArray*)allKeys
{
    return [keyValueList asKeyArray];
}


-(NSArray*)allValues
{
    return [keyValueList asValueArray];
}

@end
