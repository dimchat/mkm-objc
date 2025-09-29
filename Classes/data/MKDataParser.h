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
//  MKDataParser.h
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
@protocol MKStringCoder <NSObject>

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
@protocol MKObjectCoder <NSObject>

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
@protocol MKMapCoder <NSObject>

- (NSString *)encode:(NSDictionary *)object;

- (nullable NSDictionary *)decode:(NSString *)string;

@end

@interface MKMapCoder : NSObject <MKMapCoder>

@end

#pragma mark -

@interface MKUTF8 : NSObject

+ (void)setCoder:(id<MKStringCoder>)parser;
+ (nullable id<MKStringCoder>)getCoder;

+ (NSData *)encode:(NSString *)string;
+ (nullable NSString *)decode:(NSData *)utf8;

@end

@interface MKJSON : NSObject

+ (void)setCoder:(id<MKObjectCoder>)parser;
+ (nullable id<MKObjectCoder>)getCoder;

+ (NSString *)encode:(id)object;
+ (nullable id)decode:(NSString *)json;

@end

@interface MKJSONMap : NSObject

+ (void)setCoder:(id<MKMapCoder>)parser;
+ (nullable id<MKMapCoder>)getCoder;

+ (NSString *)encode:(NSDictionary *)object;
+ (nullable NSDictionary *)decode:(NSString *)json;

@end

#define MKUTF8Encode(string) [MKUTF8 encode:(string)]
#define MKUTF8Decode(data)   [MKUTF8 decode:(data)]

#define MKJsonEncode(object) [MKJSON encode:(object)]
#define MKJsonDecode(string) [MKJSON decode:(string)]

#define MKJsonMapEncode(object) [MKJSONMap encode:(object)]
#define MKJsonMapDecode(string) [MKJSONMap decode:(string)]

NS_ASSUME_NONNULL_END
