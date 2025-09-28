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
//  MKMDataParser.m
//  MingKeMing
//
//  Created by Albert Moky on 2020/4/7.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "MKMDataParser.h"

@implementation MKMUTF8

static id<MKStringCoder> s_utf8 = nil;

+ (void)setCoder:(id<MKStringCoder>)parser {
    s_utf8 = parser;
}

+ (id<MKStringCoder>)getCoder {
    return s_utf8;
}

+ (NSData *)encode:(id)object {
    NSAssert(s_utf8, @"UTF-8 coder not set");
    return [s_utf8 encode:object];
}

+ (nullable id)decode:(NSData *)bytes {
    NSAssert(s_utf8, @"UTF-8 coder not set");
    return [s_utf8 decode:bytes];
}

@end

@implementation MKMJSON

static id<MKMObjectCoder> s_json = nil;

+ (void)setCoder:(id<MKMObjectCoder>)parser {
    s_json = parser;
}

+ (id<MKMObjectCoder>)getCoder {
    return s_json;
}

+ (NSString *)encode:(id)object {
    NSAssert(s_json, @"JsON coder not set");
    return [s_json encode:object];
}

+ (nullable id)decode:(NSString *)json {
    NSAssert(s_json, @"JsON coder not set");
    return [s_json decode:json];
}

@end

@implementation MKMMapCoder

- (NSString *)encode:(NSDictionary *)object {
    return [MKMJSON encode:object];
}

- (nullable NSDictionary *)decode:(NSString *)string {
    return [MKMJSON decode:string];
}

@end

@implementation MKMListCoder

- (NSString *)encode:(NSArray *)object {
    return [MKMJSON encode:object];
}

- (nullable NSArray *)decode:(NSString *)string {
    return [MKMJSON decode:string];
}

@end

@implementation MKMJSONMap

static id<MKMMapCoder> s_json_map = nil;

+ (void)setCoder:(id<MKMMapCoder>)parser {
    s_json_map = parser;
}

+ (id<MKMMapCoder>)getCoder {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!s_json_map) {
            s_json_map = [[MKMMapCoder alloc] init];
        }
    });
    return s_json_map;
}

+ (NSString *)encode:(NSDictionary *)object {
    id<MKMMapCoder> coder = [self getCoder];
    NSAssert(coder, @"JSON Map coder not set");
    return [coder encode:object];
}

+ (nullable NSDictionary *)decode:(NSString *)json {
    id<MKMMapCoder> coder = [self getCoder];
    NSAssert(coder, @"JSON Map coder not set");
    return [coder decode:json];
}

@end

@implementation MKMJSONList

static id<MKMListCoder> s_json_list = nil;

+ (void)setCoder:(id<MKMListCoder>)parser {
    s_json_list = parser;
}

+ (id<MKMListCoder>)getCoder {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!s_json_list) {
            s_json_list = [[MKMListCoder alloc] init];
        }
    });
    return s_json_list;
}

+ (NSString *)encode:(NSArray *)object {
    NSAssert(s_json_list, @"JSON List coder not set");
    return [s_json_list encode:object];
}

+ (nullable NSArray *)decode:(NSString *)json {
    NSAssert(s_json_list, @"JSON List coder not set");
    return [s_json_list decode:json];
}

@end
