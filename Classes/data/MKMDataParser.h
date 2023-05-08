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
//  MKMDataParser.h
//  MingKeMing
//
//  Created by Albert Moky on 2020/4/7.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  String Coder
 *  ~~~~~~~~~~~~
 *  UTF-8, UTF-16, GBK, GB2312, ...
 *
 *  1. encode string to binary data;
 *  2. decode binary data to string.
 */
@protocol MKMStringCoder <NSObject>

/**
 *  Encode local string to binary data
 *
 * @param string - local string
 * @return binary data
 */
- (NSData *)encode:(NSString *)string;

/**
 *  Decode binary data to local string
 *
 * @param data - binary data
 * @return local string
 */
- (nullable NSString *)decode:(NSData *)data;

@end

/*
 *  Object Coder
 *  ~~~~~~~~~~~~
 *  JsON, XML, ...
 *
 *  1. encode object to string;
 *  2. decode string to object.
 */
@protocol MKMObjectCoder <NSObject>

/**
 *  Encode Map/List object to String
 *
 * @param object - Map or List
 * @return serialized string
 */
- (NSString *)encode:(id)object;

/**
 *  Decode String to Map/List object
 *
 * @param string - serialized string
 * @return Map or List
 */
- (nullable id)decode:(NSString *)string;

@end

/**
 *  coder for json <=> map
 */
@protocol MKMMapCoder <NSObject>

- (NSString *)encode:(NSDictionary *)object;
- (nullable NSDictionary *)decode:(NSString *)string;

@end

/**
 *  coder for json <=> list
 */
@protocol MKMListCoder <NSObject>

- (NSString *)encode:(NSArray *)object;
- (nullable NSArray *)decode:(NSString *)string;

@end

@interface MKMMapCoder : NSObject <MKMMapCoder>

@end

@interface MKMListCoder : NSObject <MKMListCoder>

@end

#pragma mark -

@interface MKMUTF8 : NSObject

+ (void)setCoder:(id<MKMStringCoder>)parser;
+ (nullable id<MKMStringCoder>)getCoder;

+ (NSData *)encode:(NSString *)string;
+ (nullable NSString *)decode:(NSData *)utf8;

@end

@interface MKMJSON : NSObject

+ (void)setCoder:(id<MKMObjectCoder>)parser;
+ (nullable id<MKMObjectCoder>)getCoder;

+ (NSString *)encode:(id)object;
+ (nullable id)decode:(NSString *)json;

@end

@interface MKMJSONMap : NSObject

+ (void)setCoder:(id<MKMMapCoder>)parser;
+ (nullable id<MKMMapCoder>)getCoder;

+ (NSString *)encode:(NSDictionary *)object;
+ (nullable NSDictionary *)decode:(NSString *)json;

@end

@interface MKMJSONList : NSObject

+ (void)setCoder:(id<MKMListCoder>)parser;
+ (nullable id<MKMListCoder>)getCoder;

+ (NSString *)encode:(NSArray *)object;
+ (nullable NSArray *)decode:(NSString *)json;

@end

#define MKMUTF8Encode(string) [MKMUTF8 encode:(string)]
#define MKMUTF8Decode(data)   [MKMUTF8 decode:(data)]

#define MKMJSONEncode(object) [MKMJSON encode:(object)]
#define MKMJSONDecode(string) [MKMJSON decode:(string)]

#define MKMJSONMapEncode(object) [MKMJSONMap encode:(object)]
#define MKMJSONDMapecode(string) [MKMJSONMap decode:(string)]

#define MKMJSONListEncode(object) [MKMJSONList encode:(object)]
#define MKMJSONListDecode(string) [MKMJSONList decode:(string)]

NS_ASSUME_NONNULL_END
