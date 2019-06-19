//
//  MKMChatroom.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"

#import "MKMChatroom.h"

@implementation MKMChatroom

#pragma mark Admins of Chatroom

- (NSArray<MKMID *> *)admins {
    NSAssert(_dataSource, @"chatroom data source not set yet");
    NSArray *list = [_dataSource adminsOfChatroom:_ID];
    return [list copy];
}

- (BOOL)existsAdmin:(MKMID *)ID {
    if ([self.owner isEqual:ID]) {
        return YES;
    }
    NSAssert(_dataSource, @"chatroom data source not set yet");
    NSArray<MKMID *> *admins = [self admins];
    NSInteger count = [admins count];
    if (count <= 0) {
        return NO;
    }
    MKMID *admin;
    while (--count >= 0) {
        admin = [admins objectAtIndex:count];
        if ([admin isEqual:ID]) {
            return YES;
        }
    }
    return NO;
}

@end
