//
//  MKMRSAPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMRSAKeyHelper.h"
#import "MKMRSAPublicKey.h"

#import "MKMRSAPrivateKey.h"

@interface MKMRSAPrivateKey () {
    
    NSUInteger _keySize;
    
    NSString *_privateContent;
    SecKeyRef _privateKeyRef;
    
    NSString *_publicContent;
    MKMRSAPublicKey *_publicKey;
}

@property (nonatomic) NSUInteger keySize;

@property (strong, nonatomic) NSString *privateContent;
@property (nonatomic) SecKeyRef privateKeyRef;

@property (strong, nonatomic) NSString *publicContent;
@property (strong, atomic, nullable) MKMRSAPublicKey *publicKey;

@end

@implementation MKMRSAPrivateKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        // lazy
        _keySize = 0;
        
        _privateContent = nil;
        _privateKeyRef = NULL;
        
        _publicContent = nil;
        _publicKey = nil;
    }
    
    return self;
}

- (void)dealloc {
    
    // clear key ref
    if (_privateKeyRef) {
        CFRelease(_privateKeyRef);
        _privateKeyRef = NULL;
    }
    
    //[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    MKMRSAPrivateKey *key = [super copyWithZone:zone];
    if (key) {
        key.data = _data;
        key.keySize = _keySize;
        
        key.privateContent = _privateContent;
        key.privateKeyRef = _privateKeyRef;
        
        key.publicContent = _publicContent;
        key.publicKey = _publicKey;
    }
    return key;
}

- (void)setData:(NSData *)data {
    _data = data;
}

- (NSData *)data {
    if (!_data) {
        _data = [self.privateContent base64Decode];
    }
    return _data;
}

- (NSUInteger)keySize {
    while (_keySize == 0) {
        // get from key
        if (_privateKeyRef || self.privateContent) {
            size_t bytes = SecKeyGetBlockSize(self.privateKeyRef);
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

- (NSString *)privateContent {
    if (!_privateContent) {
        // RSA key data
        NSString *data = [_storeDictionary objectForKey:@"data"];
        if (!data) {
            data = [_storeDictionary objectForKey:@"content"];
        }
        if (data) {
            _privateContent = RSAPrivateKeyContentFromNSString(data);
        }
    }
    return _privateContent;
}

- (void)setPrivateKeyRef:(SecKeyRef)privateKeyRef {
    if (_privateKeyRef != privateKeyRef) {
        if (privateKeyRef) {
            privateKeyRef = (SecKeyRef)CFRetain(privateKeyRef);
        }
        if (_privateKeyRef) {
            CFRelease(_privateKeyRef);
        }
        _privateKeyRef = privateKeyRef;
    }
}

- (SecKeyRef)privateKeyRef {
    while (!_privateKeyRef) {
        // 1. get private key from data content
        NSString *privateContent = self.privateContent;
        if (privateContent) {
            // key from data
            NSData *data = [privateContent base64Decode];
            _privateKeyRef = SecKeyRefFromPrivateData(data);
            break;
        }
        
        // 2. generate key pairs
        NSAssert(!_publicKey, @"RSA public key should not be set yet");
        
        // 2.1. key size
        NSUInteger keySize = self.keySize;
        // 2.2. prepare parameters
        NSDictionary *params;
        params = @{(id)kSecAttrKeyType      :(id)kSecAttrKeyTypeRSA,
                   (id)kSecAttrKeySizeInBits:@(keySize * 8),
                   //(id)kSecAttrIsPermanent:@YES,
                   };
        // 2.3. generate
        CFErrorRef error = NULL;
        _privateKeyRef = SecKeyCreateRandomKey((CFDictionaryRef)params,
                                               &error);
        if (error) {
            NSAssert(!_privateKeyRef, @"RSA key ref should be empty when failed");
            NSAssert(false, @"RSA failed to generate key: %@", error);
            CFRelease(error);
            error = NULL;
            break;
        }
        NSAssert(_privateKeyRef, @"RSA private key ref should be set here");
        
        // 2.4. key to data
        NSData *privateKeyData = NSDataFromSecKeyRef(_privateKeyRef);
        if (privateKeyData) {
            _privateContent = [privateKeyData base64Encode];
            NSString *pem = NSStringFromRSAPrivateKeyContent(_privateContent);
            [_storeDictionary setObject:pem forKey:@"data"];
        } else {
            NSAssert(false, @"RSA failed to get data from private key ref");
        }
        
        // 3. other parameters
        [_storeDictionary setObject:@"ECB" forKey:@"mode"];
        [_storeDictionary setObject:@"PKCS1" forKey:@"padding"];
        [_storeDictionary setObject:@"SHA256" forKey:@"digest"];
        
        break;
    }
    return _privateKeyRef;
}

- (NSString *)publicContent {
    while (!_publicContent) {
        // RSA key data
        NSString *data = [_storeDictionary objectForKey:@"data"];
        if (!data) {
            data = [_storeDictionary objectForKey:@"content"];
        }
        if (data) {
            // get public key content from data
            NSRange range = [data rangeOfString:@"PUBLIC KEY"];
            if (range.location != NSNotFound) {
                // get public key from data string
                NSString *content = RSAPublicKeyContentFromNSString(data);
                _publicContent = NSStringFromRSAPublicKeyContent(content);
                break;
            }
        }
        
        SecKeyRef privateKeyRef = self.privateKeyRef;
        if (privateKeyRef) {
            // get public key content from private key
            SecKeyRef publicKeyRef = SecKeyCopyPublicKey(privateKeyRef);
            NSData *publicKeyData = NSDataFromSecKeyRef(publicKeyRef);
            CFRelease(publicKeyRef);
            NSString *content = [publicKeyData base64Encode];
            _publicContent = NSStringFromRSAPublicKeyContent(content);
        }
        break;
    }
    
    NSAssert(_publicContent, @"RSA failed to get public content");
    return _publicContent;
}

- (nullable __kindof MKMPublicKey *)publicKey {
    if (!_publicKey) {
        NSString *publicContent = self.publicContent;
        if (publicContent) {
            NSDictionary *dict = @{@"algorithm":ACAlgorithmRSA,
                                   @"data"     :publicContent,
                                   @"mode"     :@"ECB",
                                   @"padding"  :@"PKCS1",
                                   @"digest"   :@"SHA256",
                                   };
            _publicKey = [[MKMRSAPublicKey alloc] initWithDictionary:dict];
        }
    }
    return _publicKey;
}

- (void)setPublicKey:(nullable MKMRSAPublicKey *)publicKey {
    _publicKey = publicKey;
}

#pragma mark - Protocol

- (nullable NSData *)decrypt:(NSData *)ciphertext {
    NSAssert(self.privateKeyRef != NULL, @"RSA private key cannot be empty");
    if (ciphertext.length != (self.keySize)) {
        // ciphertext length not match RSA key
        return nil;
    }
    NSData *plaintext = nil;
    
    CFErrorRef error = NULL;
    SecKeyAlgorithm alg = kSecKeyAlgorithmRSAEncryptionPKCS1;
    CFDataRef CT;
    CT = SecKeyCreateDecryptedData(self.privateKeyRef,
                                   alg,
                                   (CFDataRef)ciphertext,
                                   &error);
    if (error) {
        NSAssert(!CT, @"RSA decrypted data should be empty when failed");
        NSAssert(false, @"RSA decrypt error: %@", error);
        CFRelease(error);
        error = NULL;
    } else {
        NSAssert(CT, @"RSA decrypted data should not be empty");
        plaintext = (__bridge_transfer NSData *)CT;
    }
    
    NSAssert(plaintext, @"RSA decrypt failed");
    return plaintext;
}

- (NSData *)sign:(NSData *)data {
    NSAssert(self.privateKeyRef != NULL, @"RSA private key cannot be empty");
    NSAssert(data.length > 0, @"RSA data cannot be empty");
    NSData *signature = nil;
    
    CFErrorRef error = NULL;
    SecKeyAlgorithm alg = kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256;
    CFDataRef CT;
    CT = SecKeyCreateSignature(self.privateKeyRef,
                               alg,
                               (CFDataRef)data,
                               &error);
    if (error) {
        NSAssert(!CT, @"RSA signature should be empty when failed");
        NSAssert(false, @"RSA sign error: %@", error);
        CFRelease(error);
        error = NULL;
    } else {
        NSAssert(CT, @"RSA signature should not be empty");
        signature = (__bridge_transfer NSData *)CT;
    }
    
    NSAssert(signature, @"RSA sign failed");
    return signature;
}

@end
