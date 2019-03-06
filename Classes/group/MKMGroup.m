//
//  MKMGroup.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"

#import "MKMGroup.h"

@interface MKMGroup ()

@property (strong, nonatomic) MKMID *founder;

@property (strong, nonatomic) NSMutableArray<const MKMID *> *members;

@end

@implementation MKMGroup

- (instancetype)initWithID:(const MKMID *)ID {
    MKMID *founderID = nil;
    self = [self initWithID:ID founderID:founderID];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                 founderID:(const MKMID *)founderID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error");
    NSAssert(MKMNetwork_IsPerson(founderID.type), @"founder ID error");
    if (self = [super initWithID:ID]) {
        _founder = [founderID copy];
        _owner = nil;
        // lazy
        _members = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMGroup *social = [super copyWithZone:zone];
    if (social) {
        social.founder = _founder;
        social.owner = _owner;
        social.members = _members;
    }
    return social;
}

- (BOOL)isFounder:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"founder ID error");
    NSAssert(_founder, @"founder not set yet");
    return [_founder isEqual:ID];
}

- (BOOL)isOwner:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"owner ID error");
    NSAssert(_owner, @"owner not set yet");
    return [_owner isEqual:ID];
}

- (void)addMember:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"member ID error");
    if ([self hasMember:ID]) {
        // don't add same member twice
        return;
    }
    if (!_members) {
        _members = [[NSMutableArray alloc] init];
    }
    [_members addObject:ID];
}

- (void)removeMember:(const MKMID *)ID {
    NSAssert([self hasMember:ID], @"no such member found");
    [_members removeObject:ID];
}

- (BOOL)hasMember:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"member ID error");
    return [_members containsObject:ID];
}

@end
