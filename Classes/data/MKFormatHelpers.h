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
//  MKFormatHelpers.h
//  MingKeMing
//
//  Created by Albert Moky on 2023/12/6.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKDecryptKey;

@protocol MKTransportableData;
@protocol MKTransportableDataFactory;

@protocol MKPortableNetworkFile;
@protocol MKPortableNetworkFileFactory;

@protocol MKTransportableDataHelper <NSObject>

- (void)setTransportableDataFactory:(id<MKTransportableDataFactory>)factory
                          algorithm:(NSString *)name;
- (nullable id<MKTransportableDataFactory>)getTransportableDataFactory:(NSString *)algorithm;

- (id<MKTransportableData>)createTransportableData:(NSData *)data algorithm:(NSString *)name;

- (nullable id<MKTransportableData>)parseTransportableData:(nullable id)ted;

@end

@protocol MKPortableNetworkFileHelper <NSObject>

- (void)setPortableNetworkFileFactory:(id<MKPortableNetworkFileFactory>)factory;
- (nullable id<MKPortableNetworkFileFactory>)getPortableNetworkFileFactory;

- (id<MKPortableNetworkFile>)createPortableNetworkFile:(nullable id<MKTransportableData>)data
                                              filename:(nullable NSString *)name
                                                   url:(nullable NSURL *)locator
                                              password:(nullable id<MKDecryptKey>)key;

- (nullable id<MKPortableNetworkFile>)parsePortableNetworkFile:(nullable id)pnf;

@end

#pragma mark - Format FactoryManager

@interface MKFormatExtensions : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic, nullable) id<MKTransportableDataHelper> tedHelper;

@property (strong, nonatomic, nullable) id<MKPortableNetworkFileHelper> pnfHelper;

@end

NS_ASSUME_NONNULL_END
