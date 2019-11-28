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
//  MKMProfile.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"

#import "MKMUser.h"

#import "MKMProfile.h"

@interface MKMProfile () {
    
    // public key to encrypt message
    id<MKMEncryptKey> _key;
}

@end

@implementation MKMProfile

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _key = nil;
    }
    return self;
}

- (NSString *)name {
    NSString *string = (NSString *)[self propertyForKey:@"name"];
    if (!string) {
        NSArray *array = (NSArray *)[self propertyForKey:@"names"];
        if ([array count] > 0) {
            string = [array objectAtIndex:0];
        }
    }
    return string;
}

- (void)setName:(NSString *)name {
    [self setProperty:name forKey:@"name"];
}

@end

static NSMutableArray<Class> *profile_classes(void) {
    static NSMutableArray<Class> *classes = nil;
    SingletonDispatchOnce(^{
        classes = [[NSMutableArray alloc] init];
        // extended profile...
    });
    return classes;
}

@implementation MKMProfile (Runtime)

+ (void)registerClass:(Class)profileClass {
    NSAssert(![profileClass isEqual:self], @"only subclass");
    NSAssert([profileClass isSubclassOfClass:self], @"error: %@", profileClass);
    NSMutableArray<Class> *classes = profile_classes();
    if (profileClass && ![classes containsObject:profileClass]) {
        // parse profile with new class first
        [classes insertObject:profileClass atIndex:0];
    }
}

+ (nullable instancetype)getInstance:(id)profile {
    if (!profile) {
        return nil;
    }
    if ([profile isKindOfClass:[MKMProfile class]]) {
        // return Profile object directly
        return profile;
    }
    NSAssert([profile isKindOfClass:[NSDictionary class]], @"profile error: %@", profile);
    if ([self isEqual:[MKMProfile class]]) {
        // try to create instance by each subclass
        MKMProfile *tai = nil;
        NSMutableArray<Class> *classes = profile_classes();
        for (Class clazz in classes) {
            @try {
                tai = [clazz getInstance:profile];
                if (tai) {
                    // create by this subclass successfully
                    break;
                }
            } @catch (NSException *exception) {
                // profile not match? try next
            } @finally {
                //
            }
        }
        if (tai) {
            return tai;
        }
    }
    // subclass
    return [[self alloc] initWithDictionary:profile];
}

@end

#pragma mark -

@implementation MKMProfile (User)

- (nullable id<MKMEncryptKey>)key {
    if (!_key) {
        NSObject *dict = [self propertyForKey:@"key"];
        _key = MKMPublicKeyFromDictionary(dict);
    }
    return _key;
}

- (void)setKey:(id<MKMEncryptKey>)key {
    _key = key;
    [self setProperty:key forKey:@"key"];
}

- (nullable NSString *)avatar {
    return (NSString *)[self propertyForKey:@"avatar"];
}

- (void)setAvatar:(NSString *)avatar {
    [self setProperty:avatar forKey:@"avatar"];
}

@end

@implementation MKMProfile (Group)

- (nullable NSString *)logo {
    return (NSString *)[self propertyForKey:@"logo"];
}

- (void)setLogo:(NSString *)logo {
    [self setProperty:logo forKey:@"logo"];
}

@end
