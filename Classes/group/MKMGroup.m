//
//  MKMGroup.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"

#import "MKMGroup.h"

@implementation MKMGroup

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSDictionary *dict = [[desc data] jsonDictionary];
    NSMutableDictionary *info = [dict mutableCopy];
    [info setObject:@(self.members.count) forKey:@"members"];
    return [info jsonString];
}

- (const MKMID *)founder {
    NSAssert(_dataSource, @"group data source not set yet");
    return [_dataSource founderOfGroup:_ID];
}

- (nullable const MKMID *)owner {
    NSAssert(_dataSource, @"group data source not set yet");
    return [_dataSource ownerOfGroup:_ID];
}

#pragma mark Members of Group

- (NSArray<const MKMID *> *)members {
    NSAssert(_dataSource, @"group data source not set yet");
    NSArray *list = [_dataSource membersOfGroup:_ID];
    return [list copy];
}

- (BOOL)existsMember:(const MKMID *)ID {
    if ([self.owner isEqual:ID]) {
        return YES;
    }
    NSAssert(_dataSource, @"group data source not set yet");
    NSArray<const MKMID *> *members = [self members];
    NSInteger count = [members count];
    if (count <= 0) {
        return NO;
    }
    const MKMID *member;
    while (--count >= 0) {
        member = [members objectAtIndex:count];
        if ([member isEqual:ID]) {
            return YES;
        }
    }
    return NO;
}

@end
