//
//  MKMPublicKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAsymmetricKey.h"

NS_ASSUME_NONNULL_BEGIN

// convert Dictionary to PublicKey
#define MKMPublicKeyFromDictionary(key)    [MKMPublicKey getInstance:(key)]

@class MKMPrivateKey;

/**
 *  AC Public Key
 *
 *      keyInfo format: {
 *          algorithm: "RSA", // ECC, ...
 *          data     : "{BASE64_ENCODE}",
 *          ...
 *      }
 */
@interface MKMPublicKey : MKMAsymmetricKey <MKMPublicKey>

- (BOOL)isMatch:(const MKMPrivateKey *)SK;

@end

NS_ASSUME_NONNULL_END
