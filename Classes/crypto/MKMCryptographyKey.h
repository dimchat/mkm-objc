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

+ (instancetype)keyWithKey:(id)key;

- (instancetype)initWithDictionary:(NSDictionary *)keyInfo
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithJSONString:(const NSString *)json;

- (instancetype)initWithAlgorithm:(const NSString *)algorithm;

@end

typedef NSMutableDictionary<const NSString *, Class> MKMCryptographyKeyMap;

@interface MKMCryptographyKey (Runtime)

+ (MKMCryptographyKeyMap *)keyClasses;

+ (void)registerClass:(nullable Class)keyClass forAlgorithm:(const NSString *)name;

+ (nullable Class)classForAlgorithm:(const NSString *)name;

@end

@interface MKMCryptographyKey (PersistentStore)

+ (nullable instancetype)loadKeyWithIdentifier:(const NSString *)identifier;

- (BOOL)saveKeyWithIdentifier:(const NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
