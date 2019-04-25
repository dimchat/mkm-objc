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

- (BOOL)isEqual:(id)object {
    // 1. if the two keys have same contents, return YES
    if ([super isEqual:object]) {
        return YES;
    }
    if (![object isKindOfClass:[MKMSymmetricKey class]]) {
        return NO;
    }
    // 2. try to verify by en/decrypt
    MKMSymmetricKey *key = (MKMSymmetricKey *)object;
    static const NSString *promise = @"Moky loves May Lee forever!";
    NSData *data = [promise dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ciphertext = [key encrypt:data];
    NSData *plaintext = [self decrypt:ciphertext];
    return [plaintext isEqualToData:ciphertext];
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
