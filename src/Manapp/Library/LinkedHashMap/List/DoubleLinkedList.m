//
//  DoubleLinkedList.m
//  LinkedHashMap
//
//  Created by Tristin Forbus on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DoubleLinkedList.h"

@implementation DoubleLinkedList

-(id)init
{
    head = nil;
    tail = nil;
    return self;
}

-(DListNode*)insert:(id)value
{
    DListNode* newNode = [[DListNode alloc] initWithValue:value];
    
    if(head == nil)
    {
        head = newNode;
        tail = newNode;
    }
    
    else
    {
        tail.next = newNode;
        newNode.previous = tail;
        tail = newNode;
    }
    
    return newNode;
}


-(DListNode*)removeNode:(DListNode*)value
{
    NSLog(@"Value being removed is %@", value.description);
    
    if(head == value && head == tail)
    {
        head = nil;
        tail = nil;
    }
    
    else if(head == value && head != tail)
    {
        head = head.next;
        head.previous = nil;
    }
    
    else if(head != value && tail != value)
    {
        value.next.previous = value.previous;
        value.previous.next = value.next;
        
        value.next = nil;
        value.previous = nil;
    }
    
    else
    {
        tail = value.previous;
        tail.next = nil;
    }
    
    return value;
}


-(NSString*)description
{
    NSString* builder = @"";
    DListNode* temp = head;
    
    while(temp != nil)
    {
        builder = [builder stringByAppendingString:temp.description]; 
        temp = temp.next;
    }
    
    return builder;
}


-(NSArray*)asArray
{
    NSMutableArray* array = [NSMutableArray array];
    DListNode* temp = head;
    
    while(temp != nil)
    {
        [array addObject:temp.nodeValue];
        temp = temp.next;
    }
    
    return [NSArray arrayWithArray:array];
}

@end
