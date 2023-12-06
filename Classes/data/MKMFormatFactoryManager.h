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
//  MKMFormatFactoryManager.h
//  MingKeMing
//
//  Created by Albert Moky on 2023/12/6.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/MKMTransportableData.h>
#import <MingKeMing/MKMPortableNetworkFile.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Format GeneralFactory
 *  ~~~~~~~~~~~~~~~~~~~~~
 */
@protocol MKMGeneralFormatFactory <NSObject>

/**
 *  split text string to array: ["{TEXT}", "{algorithm}"]
 */
- (NSArray<NSString *> *)split:(NSString *)text;

- (NSDictionary *)decode:(id)data defaultKey:(NSString *)aKey;


#pragma mark TED - Transportable Encoded Data

/**
 * Get encode algorithm
 */
- (nullable NSString *)algorithm:(NSDictionary<NSString *, id> *)ted
                    defaultValue:(nullable NSString *)aValue;

- (void)setTransportableDataFactory:(id<MKMTransportableDataFactory>)factory
                       forAlgorithm:(NSString *)algorithm;
- (nullable id<MKMTransportableDataFactory>)transportableDataFactoryForAlgorithm:(NSString *)algorithm;

- (id<MKMTransportableData>)createTransportableData:(NSData *)data withAlgorithm:(NSString *)algorithm;

- (nullable id<MKMTransportableData>)parseTransportableData:(nullable id)ted;

#pragma mark PNF - Portable Network File

- (void)setPortableNetworkFileFactory:(id<MKMPortableNetworkFileFactory>)factory;
- (nullable id<MKMPortableNetworkFileFactory>)portableNetworkFileFactory;

- (id<MKMPortableNetworkFile>)createPortableNetworkFile:(nullable id<MKMTransportableData>)data
                                               filename:(nullable NSString *)name
                                                    url:(nullable NSURL *)locator
                                               password:(nullable id<MKMDecryptKey>)key;

- (nullable id<MKMPortableNetworkFile>)parsePortableNetworkFile:(nullable id)pnf;

@end

#pragma mark -

@interface MKMGeneralFormatFactory : NSObject <MKMGeneralFormatFactory>

@end

@interface MKMFormatFactoryManager : NSObject

@property(strong, nonatomic) id<MKMGeneralFormatFactory> generalFactory;

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
