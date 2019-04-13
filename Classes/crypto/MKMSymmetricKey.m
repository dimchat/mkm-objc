//
//  MKMSymmetricKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAESKey.h"

#import "MKMSymmetricKey.h"

@implementation MKMSymmetricKey

- (instancetype)init {
    self = [self initWithAlgorithm:SCAlgorithmAES];
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if ([self isMemberOfClass:[MKMSymmetricKey class]]) {
        // create instance by subclass with algorithm
        NSString *algorithm = [keyInfo objectForKey:@"algorithm"];
        Class clazz = [[self class] classForAlgorithm:algorithm];
        if (clazz) {
            self = [[clazz alloc] initWithDictionary:keyInfo];
        } else {
            NSAssert(false, @"algorithm not support: %@", algorithm);
            self = nil;
        }
    } else if (self = [super initWithDictionary:keyInfo]) {
        //
    }
    return self;
}

@end

@implementation MKMSymmetricKey (Runtime)

static MKMCryptographyKeyMap *s_symmetricKeyClasses = nil;

+ (MKMCryptographyKeyMap *)keyClasses {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MKMCryptographyKeyMap *map = [[NSMutableDictionary alloc] init];
        // AES
        [map setObject:[MKMAESKey class] forKey:SCAlgorithmAES];
        // DES
        // ...
        s_symmetricKeyClasses = map;
    });
    return s_symmetricKeyClasses;
}

@end
