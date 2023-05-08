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
//  MKMDataCoder.m
//  MingKeMing
//
//  Created by Albert Moky on 2020/4/7.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "MKMDataCoder.h"

@implementation MKMHex

static id<MKMDataCoder> s_hex = nil;

+ (void)setCoder:(id<MKMDataCoder>)coder {
    s_hex = coder;
}

+ (id<MKMDataCoder>)getCoder {
    return s_hex;
}

+ (NSString *)encode:(NSData *)data {
    NSAssert(s_hex, @"Hex coder not set");
    return [s_hex encode:data];
}

+ (nullable NSData *)decode:(NSString *)string {
    NSAssert(s_hex, @"Hex coder not set");
    return [s_hex decode:string];
}

@end

@implementation MKMBase58

static id<MKMDataCoder> s_base58 = nil;

+ (void)setCoder:(id<MKMDataCoder>)coder {
    s_base58 = coder;
}

+ (id<MKMDataCoder>)getCoder {
    return s_base58;
}

+ (NSString *)encode:(NSData *)data {
    NSAssert(s_base58, @"Base-58 coder not set");
    return [s_base58 encode:data];
}

+ (nullable NSData *)decode:(NSString *)string {
    NSAssert(s_base58, @"Base-58 coder not set");
    return [s_base58 decode:string];
}

@end

@implementation MKMBase64

static id<MKMDataCoder> s_base64 = nil;

+ (void)setCoder:(id<MKMDataCoder>)coder {
    s_base64 = coder;
}

+ (id<MKMDataCoder>)getCoder {
    return s_base64;
}

+ (NSString *)encode:(NSData *)data {
    NSAssert(s_base64, @"Base-64 coder not set");
    return [s_base64 encode:data];
}

+ (nullable NSData *)decode:(NSString *)string {
    NSAssert(s_base64, @"Base-64 coder not set");
    return [s_base64 decode:string];
}

@end
