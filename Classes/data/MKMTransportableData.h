// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  MKMCryptographyKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2023/12/6.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/MKMDictionary.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Transportable Data
 *  ~~~~~~~~~~~~~~~~~~
 *  TED - Transportable Encoded Data
 *
 *      0. "{BASE64_ENCODE}"
 *      1. "base64,{BASE64_ENCODE}"
 *      2. "data:image/png;base64,{BASE64_ENCODE}"
 *      3. {
 *              algorithm : "base65",
 *              data      : "...",     // base64_encode(data)
 *              ...
 *      }
 */
@protocol MKMTransportableData <MKMDictionary>

/**
 *  Get encode algorithm
 */
@property (readonly, strong, nonatomic, nullable) NSString *algorithm;

/**
 *  Get original data
 */
@property (readonly, strong, nonatomic, nullable) NSData *data;

/**
 *  Get encoded string
 *
 * @return "{BASE64_ENCODE}}", or
 *         "base64,{BASE64_ENCODE}", or
 *         "data:image/png;base64,{BASE64_ENCODE}", or
 *         "{...}"
 */
@property (readonly, strong, nonatomic) NSString *string;

/**
 *  toJson()
 *
 * @return String, or Map
 */
@property (readonly, strong, nonatomic) NSObject *object;

@end

#define MKMAlgorithmTransportableDefault @"base64"
#define MKMAlgorithmBase64               @"base64"
#define MKMAlgorithmBase58               @"base58"
#define MKMAlgorithmHex                  @"hex"

#pragma mark - TED Factory

@protocol MKMTransportableDataFactory <NSObject>

/**
 *  Create TED
 *
 * @param data - original data
 * @return TED object
 */
- (id<MKMTransportableData>)createTransportableData:(NSData *)data;

/**
 *  Parse map object to key
 *
 * @param ted  - TED info
 * @return TED object
 */
- (nullable id<MKMTransportableData>)parseTransportableData:(NSDictionary *)ted;

@end

// Conveniences

#define MKMTransportableDataEncode(data)                                       \
                [MKMTransportableDataCreate(data, nil) object]                 \
                                    /* EOF 'MKMTransportableDataEncode(data)' */

#define MKMTransportableDataDecode(encoded)                                    \
                [MKMTransportableDataParse(encoded) data]                      \
                                 /* EOF 'MKMTransportableDataDecode(encoded)' */

#ifdef __cplusplus
extern "C" {
#endif

_Nullable id<MKMTransportableDataFactory> MKMTransportableDataGetFactory(NSString *algorithm);
void MKMTransportableDataSetFactory(NSString *algorithm, id<MKMTransportableDataFactory> factory);

_Nullable id<MKMTransportableData> MKMTransportableDataParse(_Nullable id ted);

id<MKMTransportableData> MKMTransportableDataCreate(NSData *data, NSString * _Nullable algorithm);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
