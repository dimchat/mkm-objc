// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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
//  MKMEntity.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAddress.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMID;
@class MKMMeta;
@class MKMProfile;

@protocol MKMEntityDataSource;

@interface MKMEntity : NSObject <NSCopying> {
    
    // convenience for instance accessing
    MKMID *_ID;
}

@property (readonly, copy, nonatomic) MKMID *ID;        // name@address

@property (readonly, nonatomic) MKMNetworkType type;    // Network ID
@property (readonly, nonatomic) UInt32 number;          // search number

@property (readonly, strong, nonatomic) MKMMeta *meta;
@property (readonly, strong, nonatomic, nullable) __kindof MKMProfile *profile;
@property (readonly, strong, nonatomic) NSString *name; // profile.name or seed

@property (weak, nonatomic) __kindof id<MKMEntityDataSource> dataSource;

- (instancetype)initWithID:(MKMID *)ID NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - Entity Data Source

@protocol MKMEntityDataSource <NSObject>

/**
 *  Get meta for entity ID
 *
 * @param ID - entity ID
 * @return meta object
 */
- (nullable MKMMeta *)metaForID:(MKMID *)ID;

/**
 *  Get profile for entity ID
 *
 * @param ID - entity ID
 * @return profile object
 */
- (nullable __kindof MKMProfile *)profileForID:(MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
