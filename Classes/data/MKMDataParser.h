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

@protocol MKMDataParser <NSObject>

/**
 *  Encode object to bytes
 *
 * @param object - Dictionary, Array or String
 * @return bytes
 */
- (nullable NSData *)encode:(id)object;

/**
 *  Decode bytes to object
 *
 * @param bytes - data bytes
 * @return object
 */
- (nullable id)decode:(NSData *)bytes;

@end

#pragma mark -

@interface MKMJSON : NSObject

+ (void)setParser:(id<MKMDataParser>)parser;
+ (nullable NSData *)encode:(id)object;
+ (nullable id)decode:(NSData *)bytes;

@end

@interface MKMUTF8 : NSObject

+ (void)setParser:(id<MKMDataParser>)parser;
+ (nullable NSData *)encode:(NSString *)object;
+ (nullable NSString *)decode:(NSData *)bytes;

@end

#define MKMJSONEncode(object) [MKMJSON encode:(object)]
#define MKMJSONDecode(string) [MKMJSON decode:(string)]

#define MKMUTF8Encode(string) [MKMUTF8 encode:(string)]
#define MKMUTF8Decode(data)   [MKMUTF8 decode:(data)]

NS_ASSUME_NONNULL_END
