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
//  MKString.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMWrapper.h"

#import "MKString.h"

@interface MKString () {
    
    NSString *_storeString; // inner string
}

@end

@implementation MKString

/* designated initializer */
- (instancetype)initWithString:(NSString *)aString {
    if (self = [super init]) {
        _storeString = [[NSString alloc] initWithString:aString];
    }
    return self;
}

/* designated initializer */
- (instancetype)init {
    if (self = [super init]) {
        _storeString = [[NSString alloc] init];
    }
    return self;
}

/* designated initializer */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _storeString = [[NSString alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    id string = [[self class] allocWithZone:zone];
    string = [string initWithString:_storeString];
    return string;
}

- (NSString *)description {
    return _storeString;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: \"%@\">", [self class], _storeString];
}

- (BOOL)isEqual:(id)object {
    if (self == object || _storeString == object) {
        return YES;
    }
    object = MKGetString(object);
    return [_storeString isEqualToString:object];
}

- (NSUInteger)hash {
    return [_storeString hash];
}

#pragma mark -

- (NSString *)string {
    return _storeString;
}

- (NSUInteger)length {
    return [_storeString length];
}

- (unichar)characterAtIndex:(NSUInteger)index {
    return [_storeString characterAtIndex:index];
}

- (BOOL)isEmpty {
    return [_storeString length] == 0;
}

#pragma mark NSStringExtensionMethods

- (NSComparisonResult)compare:(NSString *)string {
    return [_storeString compare:string];
}

- (NSComparisonResult)compare:(NSString *)string
                      options:(NSStringCompareOptions)mask {
    return [_storeString compare:string options:mask];
}

- (NSComparisonResult)compare:(NSString *)string
                      options:(NSStringCompareOptions)mask
                        range:(NSRange)rangeOfReceiverToCompare {
    return [_storeString compare:string
                         options:mask
                           range:rangeOfReceiverToCompare];
}

- (NSComparisonResult)compare:(NSString *)string
                      options:(NSStringCompareOptions)mask
                        range:(NSRange)rangeOfReceiverToCompare
                       locale:(nullable id)locale {
    return [_storeString compare:string
                         options:mask
                           range:rangeOfReceiverToCompare
                          locale:locale];
}

- (NSComparisonResult)caseInsensitiveCompare:(NSString *)string {
    return [_storeString caseInsensitiveCompare:string];
}

- (NSComparisonResult)localizedCompare:(NSString *)string {
    return [_storeString localizedCompare:string];
}

- (NSComparisonResult)localizedCaseInsensitiveCompare:(NSString *)string {
    return [_storeString localizedCaseInsensitiveCompare:string];
}

- (NSComparisonResult)localizedStandardCompare:(NSString *)string {
    return [_storeString localizedStandardCompare:string];
}

- (BOOL)isEqualToString:(NSString *)aString {
    return [_storeString isEqualToString:aString];
}

- (BOOL)hasPrefix:(NSString *)str {
    return [_storeString hasPrefix:str];
}

- (BOOL)hasSuffix:(NSString *)str {
    return [_storeString hasSuffix:str];
}

- (NSRange)rangeOfString:(NSString *)searchString {
    return [_storeString rangeOfString:searchString];
}

- (NSRange)rangeOfString:(NSString *)searchString
                 options:(NSStringCompareOptions)mask {
    return [_storeString rangeOfString:searchString
                               options:mask];
}

- (NSRange)rangeOfString:(NSString *)searchString
                 options:(NSStringCompareOptions)mask
                   range:(NSRange)rangeOfReceiverToSearch {
    return [_storeString rangeOfString:searchString
                               options:mask
                                 range:rangeOfReceiverToSearch];
}

- (NSRange)rangeOfString:(NSString *)searchString
                 options:(NSStringCompareOptions)mask
                   range:(NSRange)rangeOfReceiverToSearch
                  locale:(nullable NSLocale *)locale {
    return [_storeString rangeOfString:searchString
                               options:mask
                                 range:rangeOfReceiverToSearch
                                locale:locale];
}

@end
