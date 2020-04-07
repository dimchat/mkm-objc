// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
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
//  NString+Crypto.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "base58.h"

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

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

@implementation NSString (Decode)

- (NSData *)hexDecode {
    NSMutableData *output = nil;
    
    NSString *str = self;
    // 1. remove ' ', ':', '-', '\n'
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    // 2. skip '0x' prefix
    char ch0, ch1;
    NSUInteger pos = 0;
    NSUInteger len = [self length];
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
