// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
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

@property (readonly, strong, nonatomic) id<MKMID> founder;
@property (readonly, strong, nonatomic) id<MKMID> owner;

@property (readonly, copy, nonatomic) NSArray<id<MKMID>> *members;

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
- (nullable id<MKMID>)founderOfGroup:(id<MKMID>)group;

/**
 *  Get group owner
 *
 * @param group - group ID
 * @return owner ID
 */
- (nullable id<MKMID>)ownerOfGroup:(id<MKMID>)group;

/**
 *  Get group members list
 *
 * @param group - group ID
 * @return members list (ID)
 */
- (nullable NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group;

@end

NS_ASSUME_NONNULL_END
