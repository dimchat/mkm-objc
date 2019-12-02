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
//  NSObject+JsON.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

@implementation NSObject (JsON)

- (NSData *)jsonData {
    NSData *data = nil;
    
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error = nil;
        data = [NSJSONSerialization dataWithJSONObject:self
                                               options:NSJSONWritingSortedKeys
                                                 error:&error];
        NSAssert(!error, @"json error: %@", error);
    } else {
        NSAssert(false, @"object format not support for json: %@", self);
    }
    
    return data;
}

- (NSString *)jsonString {
    return [[self jsonData] UTF8String];
}

@end

@implementation NSString (Convert)

- (NSData *)data {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@implementation NSData (Convert)

- (NSString *)UTF8String {
    const unsigned char * bytes = self.bytes;
    NSUInteger length = self.length;
    while (length > 0) {
        if (bytes[length-1] == 0) {
            --length;
        } else {
            break;
        }
    }
    return [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
}

@end

@implementation NSData (JsON)

- (id)jsonObject {
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingAllowFragments error:&error];
    NSAssert(!error, @"json error: %@", error);
    return obj;
}

- (id)jsonMutableContainer {
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:&error];
    NSAssert(!error, @"json error: %@", error);
    return obj;
}

- (NSString *)jsonString {
    return [self jsonObject];
}

- (NSArray *)jsonArray {
    return [self jsonObject];
}

- (NSDictionary *)jsonDictionary {
    return [self jsonObject];
}

- (NSMutableArray *)jsonMutableArray {
    return [self jsonMutableContainer];
}

- (NSMutableDictionary *)jsonMutableDictionary {
    return [self jsonMutableContainer];
}

@end
