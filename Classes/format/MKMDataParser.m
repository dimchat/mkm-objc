// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
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
//  MKMDataParser.m
//  MingKeMing
//
//  Created by Albert Moky on 2020/4/7.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMDataParser.h"

@interface JSON : NSObject <MKMDataParser>

@end

@implementation JSON

- (nullable NSData *)encode:(nonnull NSObject *)container {
    if (![NSJSONSerialization isValidJSONObject:container]) {
        NSAssert(false, @"object format not support for json: %@", container);
        return nil;
    }
    static NSJSONWritingOptions opt = NSJSONWritingSortedKeys;
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:container
                                                   options:opt
                                                     error:&error];
    NSAssert(!error, @"JSON encode error: %@", error);
    return data;
}

- (nullable NSObject *)decode:(nonnull NSData *)json {
    static NSJSONReadingOptions opt = NSJSONReadingAllowFragments;
    //static NSJSONReadingOptions opt = NSJSONReadingMutableContainers;
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:json
                                             options:opt
                                               error:&error];
    //NSAssert(!error, @"JSON decode error: %@", error);
    return obj;
}

@end

@interface UTF8 : NSObject <MKMDataParser>

@end

@implementation UTF8

- (nullable NSData *)encode:(nonnull NSString *)string {
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (nullable NSString *)decode:(nonnull NSData *)data {
    const unsigned char *bytes = (const unsigned char *)[data bytes];
    // rtrim '\0'
    NSInteger pos = data.length - 1;
    for (; pos >= 0; --pos) {
        if (bytes[pos] != 0) {
            break;
        }
    }
    NSUInteger length = pos + 1;
    return [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
}

@end

#pragma mark -

@implementation MKMJSON

SingletonImplementations(MKMJSON, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        self.parser = [[JSON alloc] init];
    }
    return self;
}

- (nullable NSData *)encode:(nonnull NSObject *)container {
    NSAssert(self.parser, @"JSON data parser not set yet");
    return [self.parser encode:container];
}

- (nullable NSObject *)decode:(nonnull NSData *)json {
    NSAssert(self.parser, @"JSON data parser not set yet");
    return [self.parser decode:json];
}

@end

@implementation MKMUTF8

SingletonImplementations(MKMUTF8, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        self.parser = [[UTF8 alloc] init];
    }
    return self;
}

- (nullable NSData *)encode:(nonnull NSString *)string {
    NSAssert(self.parser, @"UTF8 data parser not set yet");
    return [self.parser encode:string];
}

- (nullable NSString *)decode:(nonnull NSData *)bytes {
    NSAssert(self.parser, @"UTF8 data parser not set yet");
    return [self.parser decode:bytes];
}

@end