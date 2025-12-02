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
//  MKMAddress.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <MingKeMing/MKString.h>
#import <MingKeMing/MKMEntityType.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKMAddress <MKString>

@property (readonly, nonatomic) MKMEntityType network; // Network ID

@end

#pragma mark - Address Factory

@protocol MKMMeta;

@protocol MKMAddressFactory <NSObject>

/**
 *  Generate addres with meta & type
 *
 * @param network - address type
 * @param meta - meta info
 * @return Address
 */
- (__kindof id<MKMAddress>)generateAddressWithMeta:(id<MKMMeta>)meta
                                              type:(MKMEntityType)network;

/**
 *  Parse string object to address
 *
 * @param address - address string
 * @return Address
 */
- (nullable __kindof id<MKMAddress>)parseAddress:(NSString *)address;

@end

#ifdef __cplusplus
extern "C" {
#endif

_Nullable id<MKMAddressFactory> MKMAddressGetFactory(void);
void MKMAddressSetFactory(id<MKMAddressFactory> factory);

__kindof id<MKMAddress> MKMAddressGenerate(id<MKMMeta> meta, MKMEntityType network);

_Nullable __kindof id<MKMAddress> MKMAddressParse(_Nullable id address);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
