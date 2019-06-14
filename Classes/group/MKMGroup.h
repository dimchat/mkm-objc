//
//  MKMGroup.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMGroup : MKMEntity

@property (readonly, strong, nonatomic) const MKMID *founder;
@property (readonly, strong, nonatomic, nullable) const MKMID *owner;

@property (readonly, copy, nonatomic) NSArray<const MKMID *> *members;

- (BOOL)existsMember:(const MKMID *)ID;

// +create(founder)
// -setName(name)
// -abdicate(member, owner)
// -invite(user, admin)
// -expel(member, admin)
// -join(user)
// -quit(member)

@end

#pragma mark - Group Data Source

@protocol MKMGroupDataSource <MKMEntityDataSource>

/**
 *  Get group founder
 *
 * @param group - group ID
 * @return fonder ID
 */
- (const MKMID *)founderOfGroup:(const MKMID *)group;

/**
 *  Get group owner
 *
 * @param group - group ID
 * @return owner ID
 */
- (nullable const MKMID *)ownerOfGroup:(const MKMID *)group;

/**
 *  Get group members list
 *
 * @param group - group ID
 * @return members list (ID)
 */
- (NSArray<const MKMID *> *)membersOfGroup:(const MKMID *)group;

@end

NS_ASSUME_NONNULL_END
