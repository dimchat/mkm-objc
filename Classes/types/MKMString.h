// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
//  MKMString.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Stringer
 *  ~~~~~~~~
 *  String wrapper
 */
@protocol MKMString <NSObject, NSCopying>

//- (BOOL)isEqual:(id)object;
//@property (readonly) NSUInteger hash;
@property (readonly, strong, nonatomic) NSString *string;

@property (readonly) NSUInteger length;
//- (unichar)characterAtIndex:(NSUInteger)index;


/**
 *  NSStringExtensionMethods
 */

//- (NSComparisonResult)compare:(NSString *)string;
//- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask;
//- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToCompare;
//- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToCompare locale:(nullable id)locale;
//- (NSComparisonResult)caseInsensitiveCompare:(NSString *)string;
//- (NSComparisonResult)localizedCompare:(NSString *)string;
//- (NSComparisonResult)localizedCaseInsensitiveCompare:(NSString *)string;

//- (NSComparisonResult)localizedStandardCompare:(NSString *)string API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

//- (BOOL)isEqualToString:(NSString *)aString;
//
//- (BOOL)hasPrefix:(NSString *)str;
//- (BOOL)hasSuffix:(NSString *)str;
//
//- (NSRange)rangeOfString:(NSString *)searchString;
//- (NSRange)rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask;
//- (NSRange)rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch;
//- (NSRange)rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch locale:(nullable NSLocale *)locale API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

@end

/**
 *  Constant String
 *  ~~~~~~~~~~~~~~~
 */
@interface MKMString : NSString <MKMString>

- (instancetype)initWithString:(NSString *)aString
NS_DESIGNATED_INITIALIZER;

- (instancetype)init
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
