//
//  MKMRSAPrivateKey+PersistentStore.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "MKMRSAKeyHelper.h"

#import "MKMRSAPrivateKey+PersistentStore.h"

@interface MKMRSAPrivateKey (Hacking)

@property (nonatomic) SecKeyRef privateKeyRef;

@end

@implementation MKMRSAPrivateKey (PersistentStore)

static NSString *s_application_tag = @"chat.dim.rsa.private";

+ (nullable instancetype)loadKeyWithIdentifier:(NSString *)identifier {
    MKMRSAPrivateKey *SK = nil;
    
    NSString *label = identifier;
    NSData *tag = [s_application_tag data];
    
    NSDictionary *query;
    query = @{(id)kSecClass               :(id)kSecClassKey,
              (id)kSecAttrApplicationLabel:label,
              (id)kSecAttrApplicationTag  :tag,
              (id)kSecAttrKeyType         :(id)kSecAttrKeyTypeRSA,
              (id)kSecAttrKeyClass        :(id)kSecAttrKeyClassPrivate,
              (id)kSecAttrSynchronizable  :(id)kCFBooleanTrue,
              
              (id)kSecMatchLimit          :(id)kSecMatchLimitOne,
              (id)kSecReturnRef           :(id)kCFBooleanTrue,
              };
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, &result);
    if (status == errSecSuccess) { // noErr
        // private key
        SecKeyRef privateKeyRef = (SecKeyRef)result;
        NSData *skData = NSDataFromSecKeyRef(privateKeyRef);
        // public key
        SecKeyRef publicKeyRef = SecKeyCopyPublicKey(privateKeyRef);
        NSData *pkData = NSDataFromSecKeyRef(publicKeyRef);
        CFRelease(publicKeyRef);
        
        NSString *algorithm = ACAlgorithmRSA;
        NSString *pkFmt = @"-----BEGIN PUBLIC KEY----- %@ -----END PUBLIC KEY-----";
        NSString *skFmt = @"-----BEGIN RSA PRIVATE KEY----- %@ -----END RSA PRIVATE KEY-----";
        NSString *pkc = [NSString stringWithFormat:pkFmt, [pkData base64Encode]];
        NSString *skc = [NSString stringWithFormat:skFmt, [skData base64Encode]];
        NSString *content = [pkc stringByAppendingString:skc];
        NSDictionary *keyInfo = @{@"algorithm":algorithm,
                                  @"data"     :content,
                                  };
        SK = [[MKMRSAPrivateKey alloc] initWithDictionary:keyInfo];
    } else {
        // sec key item not found
        NSAssert(status == errSecItemNotFound, @"RSA item status error: %d", status);
    }
    if (result) {
        CFRelease(result);
        result = NULL;
    }
    
    return SK;
}

- (BOOL)saveKeyWithIdentifier:(NSString *)identifier {
    if (!self.privateKeyRef) {
        NSAssert(false, @"RSA privateKeyRef cannot be empty");
        return NO;
    }
    
    NSString *label = identifier;
    NSData *tag = [s_application_tag data];
    
    NSDictionary *query;
    query = @{(id)kSecClass               :(id)kSecClassKey,
              (id)kSecAttrApplicationLabel:label,
              (id)kSecAttrApplicationTag  :tag,
              (id)kSecAttrKeyType         :(id)kSecAttrKeyTypeRSA,
              (id)kSecAttrKeyClass        :(id)kSecAttrKeyClassPrivate,
              (id)kSecAttrSynchronizable  :(id)kCFBooleanTrue,
              
              (id)kSecMatchLimit          :(id)kSecMatchLimitOne,
              (id)kSecReturnRef           :(id)kCFBooleanTrue,
              };
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, &result);
    if (status == errSecSuccess) { // noErr
        // already exists, delete it firest
        NSMutableDictionary *mQuery = [query mutableCopy];
        [mQuery removeObjectForKey:(id)kSecMatchLimit];
        [mQuery removeObjectForKey:(id)kSecReturnRef];
        
        status = SecItemDelete((CFDictionaryRef)mQuery);
        if (status != errSecSuccess) {
            NSAssert(false, @"RSA failed to erase key: %@", mQuery);
        }
    } else {
        // sec key item not found
        NSAssert(status == errSecItemNotFound, @"RSA item status error: %d", status);
    }
    if (result) {
        CFRelease(result);
        result = NULL;
    }
    
    // add key item
    NSMutableDictionary *attributes = [query mutableCopy];
    [attributes removeObjectForKey:(id)kSecMatchLimit];
    [attributes removeObjectForKey:(id)kSecReturnRef];
    //[attributes setObject:(__bridge id)self.privateKeyRef forKey:(id)kSecValueRef];
    [attributes setObject:self.data forKey:(id)kSecValueData];
    
    status = SecItemAdd((CFDictionaryRef)attributes, &result);
    if (result) {
        CFRelease(result);
        result = NULL;
    }
    if (status == errSecSuccess) {
        return YES;
    } else {
        NSAssert(false, @"RSA failed to update key");
        return NO;
    }
}

@end
