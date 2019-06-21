//
//  MKMMember.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"

#import "MKMMember.h"

@interface MKMMember ()

@property (strong, nonatomic) MKMID *group;

@end

@implementation MKMMember

- (instancetype)initWithID:(MKMID *)ID {
    NSAssert(false, @"DON'T call me");
    MKMID *group = nil;
    return [self initWithGroup:group account:ID];
}

/* designated initializer */
- (instancetype)initWithGroup:(MKMID *)group
                      account:(MKMID *)ID {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"member ID error: %@", ID);
    NSAssert(!group || MKMNetwork_IsGroup(group.type), @"group ID error: %@", group);
    if (self = [super initWithID:ID]) {
        _group = group;
        _role = MKMMember_Member;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMMember *member = [super copyWithZone:zone];
    if (member) {
        member.group = _group;
        member.role = _role;
    }
    return member;
}

@end

#pragma mark -

@implementation MKMFounder

- (instancetype)initWithGroup:(MKMID *)group
                      account:(MKMID *)ID {
    if (self = [super initWithGroup:group account:ID]) {
        _role = MKMMember_Founder;
    }
    return self;
}

@end

@implementation MKMOwner

- (instancetype)initWithGroup:(MKMID *)group
                      account:(MKMID *)ID {
    if (self = [super initWithGroup:group account:ID]) {
        _role = MKMMember_Owner;
    }
    return self;
}

@end

@implementation MKMAdmin

- (instancetype)initWithGroup:(MKMID *)group
                      account:(MKMID *)ID {
    if (self = [super initWithGroup:group account:ID]) {
        _role = MKMMember_Admin;
    }
    return self;
}

@end
