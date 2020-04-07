// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
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
//  MKMBaseCoder.m
//  MingKeMing
//
//  Created by Albert Moky on 2020/4/7.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "base58.h"

#import "NSObject+Singleton.h"

#import "MKMBaseCoder.h"

@interface Base58 : NSObject <MKMBaseCoder>

@end

@implementation Base58

- (nullable NSString *)encode:(NSData *)data {
    NSString *output = nil;
    
    const unsigned char *pbegin = (const unsigned char *)[data bytes];
    const unsigned char *pend = pbegin + [data length];
    std::string str = EncodeBase58(pbegin, pend);
    output = [[NSString alloc] initWithCString:str.c_str()
                                      encoding:NSUTF8StringEncoding];
    
    return output;
}

- (nullable NSData *)decode:(NSString *)string {
    NSData *output = nil;
    
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    std::vector<unsigned char> vch;
    DecodeBase58(cstr, vch);
    std::string str(vch.begin(), vch.end());
    output = [[NSData alloc] initWithBytes:str.c_str() length:str.size()];
    
    return output;
}

@end

@interface Base64 : NSObject <MKMBaseCoder>

@end

@implementation Base64

- (nullable NSString *)encode:(NSData *)data {
    NSDataBase64EncodingOptions opt;
    opt = NSDataBase64EncodingEndLineWithCarriageReturn;
    return [data base64EncodedStringWithOptions:opt];
}

- (nullable NSData *)decode:(NSString *)string {
    NSDataBase64DecodingOptions opt;
    opt = NSDataBase64DecodingIgnoreUnknownCharacters;
    return [[NSData alloc] initWithBase64EncodedString:string options:opt];
}

@end

#pragma mark -

@implementation MKMBase58

SingletonImplementations(MKMBase58, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        self.coder = [[Base58 alloc] init];
    }
    return self;
}

- (nullable NSString *)encode:(NSData *)data {
    NSAssert(self.coder, @"Base58 coder not set yet");
    return [self.coder encode:data];
}

- (nullable NSData *)decode:(NSString *)string {
    NSAssert(self.coder, @"Base58 coder not set yet");
    return [self.coder decode:string];
}

@end

@implementation MKMBase64

SingletonImplementations(MKMBase64, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        self.coder = [[Base64 alloc] init];
    }
    return self;
}

- (nullable NSString *)encode:(NSData *)data {
    NSAssert(self.coder, @"Base64 coder not set yet");
    return [self.coder encode:data];
}

- (nullable NSData *)decode:(NSString *)string {
    NSAssert(self.coder, @"Base64 coder not set yet");
    return [self.coder decode:string];
}

@end
