// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
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
//  MKMDataDigester.h
//  MingKeMing
//
//  Created by Albert Moky on 2020/4/7.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKMDataDigester <NSObject>

- (NSData *)digest:(NSData *)data;

@end

#pragma mark -

@interface MKMMD5 : NSObject

+ (void)setDigester:(id<MKMDataDigester>)hasher;
+ (NSData *)digest:(NSData *)data;

@end

@interface MKMRIPEMD160 : NSObject

+ (void)setDigester:(id<MKMDataDigester>)hasher;
+ (NSData *)digest:(NSData *)data;

@end

@interface MKMSHA1 : NSObject

+ (void)setDigester:(id<MKMDataDigester>)hasher;
+ (NSData *)digest:(NSData *)data;

@end

@interface MKMSHA256 : NSObject

+ (void)setDigester:(id<MKMDataDigester>)hasher;
+ (NSData *)digest:(NSData *)data;

@end

@interface MKMKECCAK256 : NSObject

+ (void)setDigester:(id<MKMDataDigester>)hasher;
+ (NSData *)digest:(NSData *)data;

@end

#define MKMMD5Digest(data)       [MKMMD5 digest:(data)]
#define MKMRIPEMD160Digest(data) [MKMRIPEMD160 digest:(data)]
#define MKMSHA1Digest(data)      [MKMSHA1 digest:(data)]
#define MKMSHA256Digest(data)    [MKMSHA256 digest:(data)]
#define MKMKECCAK256Digest(data) [MKMKECCAK256 digest:(data)]

NS_ASSUME_NONNULL_END
