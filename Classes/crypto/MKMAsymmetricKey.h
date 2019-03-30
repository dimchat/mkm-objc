//
//  MKMAsymmetricKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMCryptographyKey.h"

NS_ASSUME_NONNULL_BEGIN

#define ACAlgorithmRSA @"RSA"
#define ACAlgorithmECC @"ECC"

#define MKMPublicKeyClassFromAlgorithmString(algorithm)                        \
            [MKMPublicKey classForAlgorithm:(algorithm)]                       \
                               /* EOF 'MKMPublicKeyClassFromAlgorithmString() */

#define MKMPrivateKeyClassFromAlgorithmString(algorithm)                       \
           [MKMPrivateKey classForAlgorithm:(algorithm)]                       \
                              /* EOF 'MKMPrivateKeyClassFromAlgorithmString() */

@protocol MKMPublicKey <NSObject>
@optional

/**
 *  CT = encrypt(text, PK)
 */
- (NSData *)encrypt:(const NSData *)plaintext;

/**
 *  OK = verify(data, signature, PK)
 */
- (BOOL)verify:(const NSData *)data withSignature:(const NSData *)signature;

@end

@protocol MKMPrivateKey <NSObject>
@optional

/**
 *  text = decrypt(CT, SK);
 */
- (nullable NSData *)decrypt:(const NSData *)ciphertext;

/**
 *  signature = sign(data, SK);
 */
- (NSData *)sign:(const NSData *)data;

@end

/**
 *  Asymmetric Cryptography Key
 *
 *      keyInfo format: {
 *          algorithm: "RSA", // ECC, ...
 *          data     : "{BASE64_ENCODE}",
 *          ...
 *      }
 */
@interface MKMAsymmetricKey : MKMCryptographyKey

@end

NS_ASSUME_NONNULL_END
