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
//  MKMString.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMString.h"

@interface MKMString () {
    
    NSString *_storeString; // inner string
}

@end

@implementation MKMString

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

- (NSString *)string {
    return _storeString;
}

- (NSUInteger)hash {
    return [_storeString hash];
}

- (BOOL)isEqualIgnoreCase:(NSString *)other {
    if (self == other) {
        return YES;
    }
    if ([other conformsToProtocol:@protocol(MKMString)]) {
        other = [(MKMString *)other string];
    }
    return [MKMString string:_storeString equalsIgnoreCase:other];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([object conformsToProtocol:@protocol(MKMString)]) {
        object = [object string];
    }
    return [_storeString isEqualToString:object];
}

- (NSUInteger)length {
    return [_storeString length];
}

- (unichar)characterAtIndex:(NSUInteger)index {
    return [_storeString characterAtIndex:index];
}

#pragma mark -

- (NSString *)description {
    return _storeString;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: \"%@\">", [self class], _storeString];
}

@end

@implementation MKMString (Comparison)

+ (BOOL)string:(NSString *)str1 equalsIgnoreCase:(NSString *)str2 {
    NSAssert(str1 && str2, @"strings should not be empty: %@, %@", str1, str2);
    return [str1 caseInsensitiveCompare:str2] == NSOrderedSame;
}

@end
