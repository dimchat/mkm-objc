//
//  MKMAESKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMAESKey.h"

static inline NSData *random_data(NSUInteger size) {
    unsigned char *buf = malloc(size * sizeof(unsigned char));
    arc4random_buf(buf, size);
    return [[NSData alloc] initWithBytesNoCopy:buf length:size freeWhenDone:YES];
}

@interface MKMAESKey ()

@property (nonatomic) NSUInteger keySize;

@property (strong, nonatomic) NSData *data; // Key Data
@property (strong, nonatomic) NSData *iv;   // Initialization Vector

@end

@implementation MKMAESKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        NSAssert([self.algorithm isEqualToString:SCAlgorithmAES], @"algorithm error: %@", keyInfo);
        
        // lazy
        _keySize = 0;
        
        _data = nil;
        _iv = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMAESKey *key = [super copyWithZone:zone];
    if (key) {
        key.keySize = _keySize;
        
        key.data = _data;
        key.iv = _iv;
    }
    return key;
}

- (NSUInteger)keySize {
    while (_keySize == 0) {
        if (self.data) {
            _keySize = self.data.length;
            break;
        }
        
        NSNumber *size = [_storeDictionary objectForKey:@"keySize"];
        if (size != nil) {
            _keySize = size.unsignedIntegerValue;
            break;
        }
        
        _keySize = kCCKeySizeAES256; // 32
        [_storeDictionary setObject:@(_keySize) forKey:@"keySize"];
        break;
    }
    return _keySize;
}

- (void)setData:(NSData *)data {
    _data = data;
}

- (NSData *)data {
    while (!_data) {
        NSString *PW;
        
        // data
        PW = [_storeDictionary objectForKey:@"data"];
        if (PW) {
            _data = [PW base64Decode];
            break;
        }
        
        // random password
        NSUInteger size = kCCKeySizeAES256;
        NSNumber *keySize = [_storeDictionary objectForKey:@"keySize"];
        if (keySize != nil) {
            size = [keySize unsignedIntegerValue];
        }
        _data = random_data(size);
        PW = [_data base64Encode];
        [_storeDictionary setObject:PW forKey:@"data"];
        
        // random initialization vector
        NSUInteger blockSize = kCCBlockSizeAES128;
        _iv = random_data(blockSize);
        NSString *IV = [_iv base64Encode];
        [_storeDictionary setObject:IV forKey:@"iv"];
        
        break;
    }
    return _data;
}

- (NSData *)iv {
    if (!_iv) {
        NSString *iv = [_storeDictionary objectForKey:@"iv"];
        if (!iv) {
            iv = [_storeDictionary objectForKey:@"initializationVector"];
        }
        _iv = [iv base64Decode];
    }
    return _iv;
}

#pragma mark - Protocol

- (NSData *)encrypt:(NSData *)plaintext {
    NSData *ciphertext = nil;
    NSAssert(self.keySize == kCCKeySizeAES256, @"only support AES-256 now");
    
    // AES encrypt algorithm
    if (self.keySize == kCCKeySizeAES256) {
        ciphertext = [plaintext AES256EncryptWithKey:self.data
                                initializationVector:self.iv];
    }
    
    return ciphertext;
}

- (nullable NSData *)decrypt:(NSData *)ciphertext {
    NSData *plaintext = nil;
    NSAssert(self.keySize == kCCKeySizeAES256, @"only support AES-256 now");
    
    // AES decrypt algorithm
    if (self.keySize == kCCKeySizeAES256) {
        plaintext = [ciphertext AES256DecryptWithKey:self.data
                                initializationVector:self.iv];
    }
    
    return plaintext;
}

@end
