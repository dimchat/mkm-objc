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
//  MKMProfile.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"

#import "MKMProfile.h"

@interface MKMVisa () {
    
    // public key to encrypt message
    id<MKMEncryptKey> _key;
}

@end

@implementation MKMVisa

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _key = nil;
    }
    return self;
}

- (nullable id<MKMEncryptKey>)key {
    if (!_key) {
        NSDictionary *dict = (NSDictionary *)[self propertyForKey:@"key"];
        id<MKMPublicKey> pKey = MKMPublicKeyFromDictionary(dict);
        if ([pKey conformsToProtocol:@protocol(MKMEncryptKey)]) {
            _key = (id<MKMEncryptKey>) pKey;
        }
    }
    return _key;
}

- (void)setKey:(id<MKMEncryptKey>)key {
    [self setProperty:key forKey:@"key"];
    _key = key;
}

- (nullable NSString *)avatar {
    return (NSString *)[self propertyForKey:@"avatar"];
}

- (void)setAvatar:(NSString *)avatar {
    [self setProperty:avatar forKey:@"avatar"];
}

@end

#pragma mark -

@interface MKMBulletin () {
    
    // Bot ID list as group assistants
    NSArray<id<MKMID>> *_assistants;
}

@end

@implementation MKMBulletin

- (nullable NSArray<id<MKMID>> *)assistants {
    if (!_assistants) {
        NSArray<NSString *> *array = (NSArray<NSString *> *)[self propertyForKey:@"assistants"];
        if (array.count > 0) {
            _assistants = [MKMID convert:array];
        }
    }
    return _assistants;
}

- (void)setAssistants:(NSArray<id<MKMID>> *)assistants {
    [self setProperty:assistants forKey:@"assistants"];
    _assistants = assistants;
}

@end
