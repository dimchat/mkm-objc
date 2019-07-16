//
//  NSData+Crypto.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Encode)

- (NSString *)base58Encode;
- (NSString *)base64Encode;

@end

@interface NSData (Hash)

- (NSData *)sha256;
- (NSData *)sha256d; // sha256(sha256(data))

- (NSData *)ripemd160;

@end

@interface NSData (AES)

- (nullable NSData *)AES256EncryptWithKey:(NSData *)key
                     initializationVector:(nullable NSData *)iv;

- (nullable NSData *)AES256DecryptWithKey:(NSData *)key
                     initializationVector:(nullable NSData *)iv;

@end

NS_ASSUME_NONNULL_END
