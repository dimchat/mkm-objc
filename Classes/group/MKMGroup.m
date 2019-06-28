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
#import "MKMProfile.h"

#import "MKMGroup.h"

@interface MKMGroup () {
    
    MKMID *_founder;
}

@property (strong, nonatomic) MKMID *founder;

@end

@implementation MKMGroup

/* designated initializer */
- (instancetype)initWithID:(MKMID *)ID {
    if (self = [super initWithID:ID]) {
        _founder = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMGroup *group = [super copyWithZone:zone];
    if (group) {
        group.founder = _founder;
    }
    return group;
}

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSDictionary *dict = [[desc data] jsonDictionary];
    NSMutableDictionary *info = [dict mutableCopy];
    [info setObject:@(self.members.count) forKey:@"members"];
    return [info jsonString];
}

- (MKMID *)founder {
    if (_founder) {
        return _founder;
    }
    NSAssert(_dataSource, @"group data source not set yet");
    _founder = [_dataSource founderOfGroup:_ID];
    return _founder;
}

- (nullable MKMID *)owner {
    NSAssert(_dataSource, @"group data source not set yet");
    return [_dataSource ownerOfGroup:_ID];
}

#pragma mark Members of Group

- (NSArray<MKMID *> *)members {
    NSAssert(_dataSource, @"group data source not set yet");
    NSArray *list = [_dataSource membersOfGroup:_ID];
    return [list copy];
}

- (BOOL)existsMember:(MKMID *)ID {
    if ([self.owner isEqual:ID]) {
        return YES;
    }
    NSAssert(_dataSource, @"group data source not set yet");
    NSArray<MKMID *> *members = [self members];
    NSInteger count = [members count];
    if (count <= 0) {
        return NO;
    }
    MKMID *member;
    while (--count >= 0) {
        member = [members objectAtIndex:count];
        if ([member isEqual:ID]) {
            return YES;
        }
    }
    return NO;
}

- (MKMProfile *)profile {
    MKMProfile *tao = [super profile];
    if (!tao) {
        return nil;
    }
    // try to verify with owner's meta.key
    MKMID *owner = [self owner];
    MKMMeta *meta = [_dataSource metaForID:owner];
    MKMPublicKey *key = [meta key];
    if ([tao verify:key]) {
        // signature correct
        return tao;
    }
    // profile error, continue to process by subclass
    return tao;
}

@end
