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

@interface Hex : NSObject <MKMDataCoder>

@end

static inline char hex_char(char ch) {
    if (ch >= '0' && ch <= '9') {
        return ch - '0';
    }
    if (ch >= 'a' && ch <= 'f') {
        return ch - 'a' + 10;
    }
    if (ch >= 'A' && ch <= 'F') {
        return ch - 'A' + 10;
    }
    return 0;
}

@implementation Hex

- (nullable NSString *)encode:(NSData *)data {
    NSMutableString *output = nil;
    
    const unsigned char *bytes = (const unsigned char *)[data bytes];
    NSUInteger len = [data length];
    output = [[NSMutableString alloc] initWithCapacity:(len*2)];
    for (int i = 0; i < len; ++i) {
        [output appendFormat:@"%02x", bytes[i]];
    }
    
    return output;
}

- (nullable NSData *)decode:(NSString *)string {
    NSMutableData *output = nil;
    
    NSString *str = string;
    // 1. remove ' ', ':', '-', '\n'
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    // 2. skip '0x' prefix
    char ch0, ch1;
    NSUInteger pos = 0;
    NSUInteger len = [string length];
    if (len > 2) {
        ch0 = [str characterAtIndex:0];
        ch1 = [str characterAtIndex:1];
        if (ch0 == '0' && (ch1 == 'x' || ch1 == 'X')) {
            pos = 2;
        }
    }
    
    // 3. decode bytes
    output = [[NSMutableData alloc] initWithCapacity:(len/2)];
    unsigned char byte;
    for (; (pos + 1) < len; pos += 2) {
        ch0 = [str characterAtIndex:pos];
        ch1 = [str characterAtIndex:(pos + 1)];
        byte = hex_char(ch0) * 16 + hex_char(ch1);
        [output appendBytes:&byte length:1];
    }
    
    return output;
}

@end

@interface Base64 : NSObject <MKMDataCoder>

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

@implementation MKMHex

static id<MKMDataCoder> s_hex = nil;

+ (id<MKMDataCoder>)coder {
    if (s_hex == nil) {
        s_hex = [[Hex alloc] init];
    }
    return s_hex;
}

+ (void)setCoder:(id<MKMDataCoder>)coder {
    s_hex = coder;
}

+ (nullable NSString *)encode:(NSData *)data {
    return [[self coder] encode:data];
}

+ (nullable NSData *)decode:(NSString *)string {
    return [[self coder] decode:string];
}

@end

@implementation MKMBase58

static id<MKMDataCoder> s_base58 = nil;

+ (void)setCoder:(id<MKMDataCoder>)coder {
    s_base58 = coder;
}

+ (nullable NSString *)encode:(NSData *)data {
    return [s_base58 encode:data];
}

+ (nullable NSData *)decode:(NSString *)string {
    return [s_base58 decode:string];
}

@end

@implementation MKMBase64

static id<MKMDataCoder> s_base64 = nil;

+ (id<MKMDataCoder>)coder {
    if (s_base64 == nil) {
        s_base64 = [[Base64 alloc] init];
    }
    return s_base64;
}

+ (void)setCoder:(id<MKMDataCoder>)coder {
    s_base64 = coder;
}

+ (nullable NSString *)encode:(NSData *)data {
    return [[self coder] encode:data];
}

+ (nullable NSData *)decode:(NSString *)string {
    return [[self coder] decode:string];
}

@end
