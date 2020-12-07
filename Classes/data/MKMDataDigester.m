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
//  MKMDataDigester.m
//  MingKeMing
//
//  Created by Albert Moky on 2020/4/7.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "MKMDataDigester.h"

@interface MD5 : NSObject <MKMDataDigester>

@end

@implementation MD5

- (NSData *)digest:(NSData *)data {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], digest);
    return [[NSData alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
}

@end

@interface SHA1 : NSObject <MKMDataDigester>

@end

@implementation SHA1

- (NSData *)digest:(NSData *)data {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([data bytes], (CC_LONG)[data length], digest);
    return [[NSData alloc] initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

@end

@interface SHA256 : NSObject <MKMDataDigester>

@end

@implementation SHA256

- (NSData *)digest:(NSData *)data {
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([data bytes], (CC_LONG)[data length], digest);
    return [[NSData alloc] initWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

@end

#pragma mark -

@implementation MKMMD5

static id<MKMDataDigester> s_md5 = nil;

+ (id<MKMDataDigester>)digester {
    if (s_md5 == nil) {
        s_md5 = [[MD5 alloc] init];
    }
    return s_md5;
}

+ (void)setDigester:(id<MKMDataDigester>)hasher {
    s_md5 = hasher;
}

+ (NSData *)digest:(NSData *)data {
    return [[self digester] digest:data];
}

@end

@implementation MKMRIPEMD160

static id<MKMDataDigester> s_ripemd160 = nil;

+ (void)setDigester:(id<MKMDataDigester>)hasher {
    s_ripemd160 = hasher;
}

+ (NSData *)digest:(NSData *)data {
    return [s_ripemd160 digest:data];
}

@end

@implementation MKMSHA1

static id<MKMDataDigester> s_sha1 = nil;

+ (id<MKMDataDigester>)digester {
    if (s_sha1 == nil) {
        s_sha1 = [[SHA1 alloc] init];
    }
    return s_sha1;
}

+ (void)setDigester:(id<MKMDataDigester>)hasher {
    s_sha1 = hasher;
}

+ (NSData *)digest:(NSData *)data {
    return [[self digester] digest:data];
}

@end

@implementation MKMSHA256

static id<MKMDataDigester> s_sha256 = nil;

+ (id<MKMDataDigester>)digester {
    if (s_sha256 == nil) {
        s_sha256 = [[SHA256 alloc] init];
    }
    return s_sha256;
}

+ (void)setDigester:(id<MKMDataDigester>)hasher {
    s_sha256 = hasher;
}

+ (NSData *)digest:(NSData *)data {
    return [[self digester] digest:data];
}

@end

@implementation MKMKECCAK256

static id<MKMDataDigester> s_keccak256 = nil;

+ (void)setDigester:(id<MKMDataDigester>)hasher {
    s_keccak256 = hasher;
}

+ (NSData *)digest:(NSData *)data {
    return [s_keccak256 digest:data];
}

@end
