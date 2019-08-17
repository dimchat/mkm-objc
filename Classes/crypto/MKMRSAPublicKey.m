//
//  MKMRSAPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMRSAKeyHelper.h"
#import "MKMRSAPrivateKey.h"

#import "MKMRSAPublicKey.h"

@interface MKMRSAPublicKey () {
    
    NSUInteger _keySize;
    
    NSString *_publicContent;
    SecKeyRef _publicKeyRef;
}

@property (nonatomic) NSUInteger keySize;

@property (strong, nonatomic) NSString *publicContent;

@property (nonatomic) SecKeyRef publicKeyRef;

@end

@implementation MKMRSAPublicKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        // lazy
        _keySize = 0;
        _publicContent = nil;
        _publicKeyRef = NULL;
    }
    
    return self;
}

- (void)dealloc {
    
    // clear key ref
    if (_publicKeyRef) {
        CFRelease(_publicKeyRef);
        _publicKeyRef = NULL;
    }
    
    //[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    MKMRSAPublicKey *key = [super copyWithZone:zone];
    if (key) {
        key.data = _data;
        key.keySize = _keySize;
        key.publicContent = _publicContent;
        key.publicKeyRef = _publicKeyRef;
    }
    return key;
}

- (void)setData:(NSData *)data {
    _data = data;
}

- (NSData *)data {
    if (!_data) {
        _data = [self.publicContent base64Decode];
    }
    return _data;
}

- (NSUInteger)keySize {
    while (_keySize == 0) {
        // get from key
        if (_publicKeyRef || self.publicContent) {
            size_t bytes = SecKeyGetBlockSize(self.publicKeyRef);
            _keySize = bytes * sizeof(uint8_t);
            break;
        }
        // get from dictionary
        NSNumber *size = [_storeDictionary objectForKey:@"keySize"];
        if (size == nil) {
            _keySize = 1024 / 8; // 128
        } else {
            _keySize = size.unsignedIntegerValue;
        }
        break;
    }
    return _keySize;
}

- (NSString *)publicContent {
    if (!_publicContent) {
        // RSA key data
        NSString *data = [_storeDictionary objectForKey:@"data"];
        if (!data) {
            data = [_storeDictionary objectForKey:@"content"];
        }
        if (data) {
            _publicContent = RSAPublicKeyContentFromNSString(data);
        }
    }
    return _publicContent;
}

- (void)setPublicKeyRef:(SecKeyRef)publicKeyRef {
    if (_publicKeyRef != publicKeyRef) {
        if (publicKeyRef) {
            publicKeyRef = (SecKeyRef)CFRetain(publicKeyRef);
        }
        if (_publicKeyRef) {
            CFRelease(_publicKeyRef);
        }
        _publicKeyRef = publicKeyRef;
    }
}

- (SecKeyRef)publicKeyRef {
    if (!_publicKeyRef) {
        NSString *publicContent = self.publicContent;
        if (publicContent) {
            // key from data
            NSData *data = [publicContent base64Decode];
            _publicKeyRef = SecKeyRefFromPublicData(data);
        }
    }
    return _publicKeyRef;
}

#pragma mark - Protocol

- (NSData *)encrypt:(NSData *)plaintext {
    NSAssert(self.publicKeyRef != NULL, @"RSA public key cannot be empty");
    NSAssert(plaintext.length > 0 && plaintext.length <= (self.keySize - 11),
             @"RSA data length error: %lu", plaintext.length);
    NSData *ciphertext = nil;
    
    CFErrorRef error = NULL;
    SecKeyAlgorithm alg = kSecKeyAlgorithmRSAEncryptionPKCS1;
    CFDataRef CT;
    CT = SecKeyCreateEncryptedData(self.publicKeyRef,
                                   alg,
                                   (CFDataRef)plaintext,
                                   &error);
    if (error) {
        NSAssert(!CT, @"RSA encrypted data should be empty when failed");
        NSAssert(false, @"RSA encrypt error: %@", error);
        CFRelease(error);
        error = NULL;
    } else {
        NSAssert(CT, @"RSA encrypted should not be empty");
        ciphertext = (__bridge_transfer NSData *)CT;
    }
    
    NSAssert(ciphertext, @"RSA encrypt failed");
    return ciphertext;
}

- (BOOL)verify:(NSData *)data withSignature:(NSData *)signature {
    NSAssert(self.publicKeyRef != NULL, @"RSA public key cannot be empty");
    NSAssert(data.length > 0, @"RSA data cannot be empty");
    if (signature.length != (self.keySize)) {
        // signature length not match RSA key
        return NO;
    }
    BOOL OK = NO;
    
    CFErrorRef error = NULL;
    SecKeyAlgorithm alg = kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256;
    OK = SecKeyVerifySignature(self.publicKeyRef,
                               alg,
                               (CFDataRef)data,
                               (CFDataRef)signature,
                               &error);
    if (error) {
        NSAssert(!OK, @"RSA verify error");
        //NSAssert(false, @"RSA verify error: %@", error);
        CFRelease(error);
        error = NULL;
    }
    
    return OK;
}

@end

@implementation MKMRSAPublicKey (PersistentStore)

+ (nullable instancetype)loadKeyWithIdentifier:(NSString *)identifier {
    MKMRSAPublicKey *PK = nil;
    
    // TODO: load RSA public key from persistent store
    
    // finally, try by private key
    MKMRSAPrivateKey *SK = [MKMRSAPrivateKey loadKeyWithIdentifier:identifier];
    PK = (MKMRSAPublicKey *)SK.publicKey;
    
    return PK;
}

@end
