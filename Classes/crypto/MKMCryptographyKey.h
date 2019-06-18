//
//  MKMCryptographyKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Cryptography Key
 *
 *      keyInfo format: {
 *          algorithm: "RSA", // ECC, AES, ...
 *          data     : "{BASE64_ENCODE}",
 *          ...
 *      }
 */
@interface MKMCryptographyKey : MKMDictionary {
    
    NSString *_algorithm;
    NSData *_data;
}

@property (readonly, strong, nonatomic) NSString *algorithm;
@property (readonly, strong, nonatomic) NSData *data;

- (instancetype)initWithDictionary:(NSDictionary *)keyInfo
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithAlgorithm:(const NSString *)algorithm;

@end

@interface MKMCryptographyKey (Runtime)

+ (void)registerClass:(nullable Class)keyClass forAlgorithm:(NSString *)name;

+ (nullable instancetype)getInstance:(id)key;

@end

@interface MKMCryptographyKey (PersistentStore)

+ (nullable instancetype)loadKeyWithIdentifier:(const NSString *)identifier;

- (BOOL)saveKeyWithIdentifier:(const NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
