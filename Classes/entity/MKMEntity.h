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
//  MKMEntity.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKMID;
@protocol MKMMeta;
@protocol MKMDocument;

@protocol MKMEntityDataSource;

@interface MKMEntity : NSObject <NSCopying> {
    
    // convenience for instance accessing
    id<MKMID> _ID;
}

@property (readonly, copy, nonatomic) id<MKMID> ID;     // name@address

@property (readonly, nonatomic) MKMNetworkType type;    // Network ID

@property (readonly, strong, nonatomic) id<MKMMeta> meta;

@property (weak, nonatomic) __kindof id<MKMEntityDataSource> dataSource;

- (instancetype)initWithID:(id<MKMID>)ID NS_DESIGNATED_INITIALIZER;

/**
 *  Get entity profile with document type
 */
- (nullable __kindof id<MKMDocument>)documentWithType:(nullable NSString *)type;

@end

#pragma mark - Entity Data Source

@protocol MKMEntityDataSource <NSObject>

/**
 *  Get meta for entity ID
 *
 * @param ID - entity ID
 * @return meta object
 */
- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID;

/**
 *  Get profile for entity ID
 *
 * @param ID - entity ID
 * @return profile object
 */
- (nullable __kindof id<MKMDocument>)documentForID:(id<MKMID>)ID
                                          withType:(nullable NSString *)type;

@end

NS_ASSUME_NONNULL_END
