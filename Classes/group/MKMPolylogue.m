//
//  MKMPolylogue.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/8.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"

#import "MKMPolylogue.h"

@implementation MKMPolylogue

/* designated initializer */
- (instancetype)initWithID:(MKMID *)ID {
    NSAssert(ID.type == MKMNetwork_Polylogue, @"polylogue ID error: %@", ID);
    if (self = [super initWithID:ID]) {
        //
    }
    return self;
}

- (nullable MKMID *)owner {
    NSAssert(_dataSource, @"group data source not set yet");
    MKMID *ID = [_dataSource ownerOfGroup:_ID];
    if ([ID isValid]) {
        NSAssert([[self founder] isEqual:ID], @"polylugue's owner is founder");
        return ID;
    }
    return [self founder];
}

@end
