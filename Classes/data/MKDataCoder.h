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
//  MKDataCoder.h
//  MingKeMing
//
//  Created by Albert Moky on 2020/4/7.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Data Coder
 *  ~~~~~~~~~~
 *  Hex, Base58, Base64, ...
 *
 *  1. encode binary data to string;
 *  2. decode string to binary data.
 */
@protocol MKDataCoder <NSObject>

/**
 *  Encode binary data to text string
 *
 * @param data - binary data
 * @return Base58/64 string
 */
- (NSString *)encode:(NSData *)data;

/**
 *  Decode text string to binary data
 *
 * @param string - base58/64 string
 * @return binary data
 */
- (nullable NSData *)decode:(NSString *)string;

@end

#pragma mark -

@interface MKHex : NSObject

+ (void)setCoder:(id<MKDataCoder>)coder;
+ (nullable id<MKDataCoder>)getCoder;

+ (NSString *)encode:(NSData *)data;
+ (nullable NSData *)decode:(NSString *)string;

@end

@interface MKBase58 : NSObject

+ (void)setCoder:(id<MKDataCoder>)coder;
+ (nullable id<MKDataCoder>)getCoder;

+ (NSString *)encode:(NSData *)data;
+ (nullable NSData *)decode:(NSString *)string;

@end

@interface MKBase64 : NSObject

+ (void)setCoder:(id<MKDataCoder>)coder;
+ (nullable id<MKDataCoder>)getCoder;

+ (NSString *)encode:(NSData *)data;
+ (nullable NSData *)decode:(NSString *)string;

@end

#define MKHexEncode(data)       [MKHex encode:(data)]
#define MKHexDecode(string)     [MKHex decode:(string)]

#define MKBase58Encode(data)    [MKBase58 encode:(data)]
#define MKBase58Decode(string)  [MKBase58 decode:(string)]

#define MKBase64Encode(data)    [MKBase64 encode:(data)]
#define MKBase64Decode(string)  [MKBase64 decode:(string)]

NS_ASSUME_NONNULL_END
