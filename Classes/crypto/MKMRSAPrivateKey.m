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
    
    SecKeyRef _privateKeyRef;
    
    MKMRSAPublicKey *_publicKey;
}

@property (nonatomic) NSUInteger keySizeInBits;

@property (strong, nonatomic) NSString *privateContent;

@property (nonatomic) SecKeyRef privateKeyRef;

@end

@implementation MKMRSAPrivateKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        NSAssert([self.algorithm isEqualToString:ACAlgorithmRSA], @"algorithm error: %@", keyInfo);
        
        // lazy
        _keySizeInBits = 0;
        _privateContent = nil;
        _privateKeyRef = NULL;
        
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
        key.keySizeInBits = _keySizeInBits;
        key.privateContent = _privateContent;
        key.privateKeyRef = _privateKeyRef;
    }
    return key;
}

- (NSData *)data {
    if (!_data) {
        _data = [self.privateContent base64Decode];
    }
    return _data;
}

- (NSUInteger)keySizeInBits {
    while (_keySizeInBits == 0) {
        if (_privateKeyRef || self.privateContent) {
            size_t bytes = SecKeyGetBlockSize(self.privateKeyRef);
            _keySizeInBits = bytes * sizeof(uint8_t) * 8;
            break;
        }
        
        NSNumber *size;
        size = [_storeDictionary objectForKey:@"keySizeInBits"];
        if (size != nil) {
            _keySizeInBits = size.unsignedIntegerValue;
            break;
        }
        
        _keySizeInBits = 1024;
        [_storeDictionary setObject:@(_keySizeInBits) forKey:@"keySizeInBits"];
        break;
    }
    return _keySizeInBits;
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
        NSUInteger keySizeInBits = self.keySizeInBits;
        // 2.2. prepare parameters
        NSDictionary *params;
        params = @{(id)kSecAttrKeyType      :(id)kSecAttrKeyTypeRSA,
                   (id)kSecAttrKeySizeInBits:@(keySizeInBits),
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
        
        break;
    }
    return _privateKeyRef;
}

- (NSString *)publicContent {
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
            return NSStringFromRSAPublicKeyContent(content);
        }
    }
    
    SecKeyRef privateKeyRef = self.privateKeyRef;
    if (privateKeyRef) {
        // get public key content from private key
        SecKeyRef publicKeyRef = SecKeyCopyPublicKey(privateKeyRef);
        NSData *publicKeyData = NSDataFromSecKeyRef(publicKeyRef);
        CFRelease(publicKeyRef);
        NSString *content = [publicKeyData base64Encode];
        return NSStringFromRSAPublicKeyContent(content);
    }
    
    NSAssert(false, @"RSA failed to get public content");
    return nil;
}

- (nullable MKMPublicKey *)publicKey {
    if (!_publicKey) {
        NSString *publicContent = self.publicContent;
        if (publicContent) {
            NSDictionary *dict = @{@"algorithm":self.algorithm,
                                   @"data"     :publicContent,
                                   };
            _publicKey = [[MKMRSAPublicKey alloc] initWithDictionary:dict];
        }
    }
    return _publicKey;
}

#pragma mark - Protocol

- (nullable NSData *)decrypt:(const NSData *)ciphertext {
    NSAssert(self.privateKeyRef != NULL, @"RSA private key cannot be empty");
    NSAssert(ciphertext.length == (self.keySizeInBits/8), @"RSA ciphertext length error: %lu", ciphertext.length);
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

- (NSData *)sign:(const NSData *)data {
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
