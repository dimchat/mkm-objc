//
//  MKMPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"
#import "MKMRSAPrivateKey.h"
#import "MKMECCPrivateKey.h"

#import "MKMPrivateKey.h"

@implementation MKMPrivateKey

- (instancetype)init {
    self = [self initWithAlgorithm:ACAlgorithmRSA];
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if ([self isMemberOfClass:[MKMPrivateKey class]]) {
        // create instance by subclass with algorithm
        NSString *algorithm = [keyInfo objectForKey:@"algorithm"];
        if ([algorithm isEqualToString:ACAlgorithmRSA]) {
            self = [[MKMRSAPrivateKey alloc] initWithDictionary:keyInfo];
        } else if ([algorithm isEqualToString:ACAlgorithmECC]) {
            self = [[MKMECCPrivateKey alloc] initWithDictionary:keyInfo];
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
    // 1. if the two key has the same content, return YES
    if ([super isEqual:object]) {
        return YES;
    }
    if ([object isKindOfClass:[MKMPrivateKey class]]) {
        // 2. try to verify by public key
        return [self.publicKey isMatch:(MKMPrivateKey *)object];
    } else {
        return NO;
    }
}

- (MKMPublicKey *)publicKey {
    // implements in subclass
    return nil;
}

@end

@implementation MKMPrivateKey (PersistentStore)

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMPrivateKey *SK = nil;
    
    // try RSA private key
    SK = [MKMRSAPrivateKey loadKeyWithIdentifier:identifier];
    if (SK) {
        return SK;
    }
    
    // try ECC private key
    SK = [MKMECCPrivateKey loadKeyWithIdentifier:identifier];
    if (SK) {
        return SK;
    }
    
    // key not found
    return SK;
}

@end
