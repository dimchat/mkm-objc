//
//  MKMChatroom.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMChatroom : MKMGroup

@property (readonly, copy, nonatomic) NSArray<MKMID *> *admins;

- (BOOL)existsAdmin:(MKMID *)ID;

// -hire(admin, owner)
// -fire(admin, owner)
// -resign(admin)

@end

#pragma mark - Chatroom Delegate

@protocol MKMChatroomDataSource <MKMGroupDataSource>

/**
 *  Get chatroom admin list
 *
 * @param chatroom - group ID
 * @return admins list (ID)
 */
- (NSArray<MKMID *> *)adminsOfChatroom:(MKMID *)chatroom;

@end

NS_ASSUME_NONNULL_END
