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
    
    SecKeyRef _publicKeyRef;
}

@property (nonatomic) NSUInteger keySizeInBits;

@property (strong, nonatomic) NSString *publicContent;

@property (nonatomic) SecKeyRef publicKeyRef;

@end

@implementation MKMRSAPublicKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        NSAssert([self.algorithm isEqualToString:ACAlgorithmRSA], @"algorithm error: %@", keyInfo);
        
        // lazy
        _keySizeInBits = 0;
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
        key.keySizeInBits = _keySizeInBits;
        key.publicContent = _publicContent;
        key.publicKeyRef = _publicKeyRef;
    }
    return key;
}

- (NSData *)data {
    if (!_data) {
        _data = [self.publicContent base64Decode];
    }
    return _data;
}

- (NSUInteger)keySizeInBits {
    while (_keySizeInBits == 0) {
        if (_publicKeyRef || self.publicContent) {
            size_t bytes = SecKeyGetBlockSize(self.publicKeyRef);
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
        if (publicKeyRef) CFRetain(publicKeyRef);
        if (_publicKeyRef) CFRelease(_publicKeyRef);
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

- (NSData *)encrypt:(const NSData *)plaintext {
    NSAssert(self.publicKeyRef != NULL, @"public key cannot be empty");
    NSAssert(plaintext.length > 0 && plaintext.length <= (self.keySizeInBits/8 - 11), @"data length error: %lu", plaintext.length);
    NSData *ciphertext = nil;
    
    CFErrorRef error = NULL;
    SecKeyAlgorithm alg = kSecKeyAlgorithmRSAEncryptionPKCS1;
    CFDataRef CT;
    CT = SecKeyCreateEncryptedData(self.publicKeyRef,
                                   alg,
                                   (CFDataRef)plaintext,
                                   &error);
    if (error) {
        NSAssert(!CT, @"encrypted data should be empty when failed");
        NSAssert(false, @"error: %@", error);
    } else {
        NSAssert(CT, @"encrypted should not be empty");
        ciphertext = (__bridge_transfer NSData *)CT;
    }
    
    NSAssert(ciphertext, @"encrypt failed");
    return ciphertext;
}

- (BOOL)verify:(const NSData *)data withSignature:(const NSData *)signature {
    NSAssert(self.publicKeyRef != NULL, @"public key cannot be empty");
    NSAssert(signature.length == (self.keySizeInBits/8), @"signature length error: %lu", signature.length);
    NSAssert(data.length > 0, @"data cannot be empty");
    BOOL OK = NO;
    
    CFErrorRef error = NULL;
    SecKeyAlgorithm alg = kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256;
    OK = SecKeyVerifySignature(self.publicKeyRef,
                               alg,
                               (CFDataRef)data,
                               (CFDataRef)signature,
                               &error);
    if (error) {
        NSAssert(!OK, @"error");
        //NSAssert(false, @"verify error: %@", error);
    }
    
    return OK;
}

@end

@implementation MKMRSAPublicKey (PersistentStore)

+ (nullable instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMRSAPublicKey *PK = nil;
    
    // TODO: load RSA public key from persistent store
    
    // finally, try by private key
    MKMRSAPrivateKey *SK = [MKMRSAPrivateKey loadKeyWithIdentifier:identifier];
    PK = (MKMRSAPublicKey *)SK.publicKey;
    
    return PK;
}

@end
