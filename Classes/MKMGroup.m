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

- (nullable __kindof MKMProfile *)profile {
    MKMProfile *tai = [super profile];
    if (!tai || [tai isValid]) {
        // no need to verify
        return tai;
    }
    // try to verify with owner's meta.key
    MKMID *owner = [self owner];
    if ([owner isValid]) {
        MKMMeta *meta = [self.dataSource metaForID:owner];
        if ([tai verify:meta.key]) {
            // signature correct
            return tai;
        }
    }
    // profile error? continue to process by subclass
    return tai;
}

- (MKMID *)founder {
    if (!_founder) {
        NSAssert(self.dataSource, @"group data source not set yet");
        _founder = [self.dataSource founderOfGroup:_ID];
    }
    return _founder;
}

- (MKMID *)owner {
    NSAssert(self.dataSource, @"group data source not set yet");
    return [self.dataSource ownerOfGroup:_ID];
}

- (NSArray<MKMID *> *)members {
    NSAssert(self.dataSource, @"group data source not set yet");
    NSArray *list = [self.dataSource membersOfGroup:_ID];
    return [list copy];
}

@end
