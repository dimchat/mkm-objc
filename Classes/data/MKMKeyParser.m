// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  MKMKeyParser.m
//  MingKeMing
//
//  Created by Albert Moky on 2020/4/7.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMBaseCoder.h"

#import "MKMKeyParser.h"

static inline NSString *RSAKeyContentFromNSString(NSString *content,
                                                  NSString *tag) {
    NSString *sTag, *eTag;
    NSRange spos, epos;
    NSString *key = content;
    
    sTag = [NSString stringWithFormat:@"-----BEGIN RSA %@ KEY-----", tag];
    eTag = [NSString stringWithFormat:@"-----END RSA %@ KEY-----", tag];
    spos = [key rangeOfString:sTag];
    if (spos.length > 0) {
        epos = [key rangeOfString:eTag];
    } else {
        sTag = [NSString stringWithFormat:@"-----BEGIN %@ KEY-----", tag];
        eTag = [NSString stringWithFormat:@"-----END %@ KEY-----", tag];
        spos = [key rangeOfString:sTag];
        epos = [key rangeOfString:eTag];
    }
    
    if (spos.location != NSNotFound && epos.location != NSNotFound) {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e - s);
        key = [key substringWithRange:range];
    }
    
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    return key;
}

NSString *RSAPublicKeyContentFromNSString(NSString *content) {
    return RSAKeyContentFromNSString(content, @"PUBLIC");
}

NSString *RSAPrivateKeyContentFromNSString(NSString *content) {
    return RSAKeyContentFromNSString(content, @"PRIVATE");
}

static inline SecKeyRef SecKeyRefFromData(NSData *data,
                                          NSString *keyClass) {
    // Set the private key query dictionary.
    NSDictionary * dict;
    dict = @{(id)kSecAttrKeyType :(id)kSecAttrKeyTypeRSA,
             (id)kSecAttrKeyClass:keyClass,
             };
    CFErrorRef error = NULL;
    SecKeyRef keyRef = SecKeyCreateWithData((CFDataRef)data,
                                            (CFDictionaryRef)dict,
                                            &error);
    if (error) {
        NSLog(@"RSA failed to create sec key with data: %@", data);
        assert(keyRef == NULL); // the key ref should be empty when error
        assert(false);
        CFRelease(error);
        error = NULL;
    }
    return keyRef;
}

static inline SecKeyRef SecKeyRefFromPublicData(NSData *data) {
    return SecKeyRefFromData(data, (__bridge id)kSecAttrKeyClassPublic);
}

static inline SecKeyRef SecKeyRefFromPrivateData(NSData *data) {
    return SecKeyRefFromData(data, (__bridge id)kSecAttrKeyClassPrivate);
}

NSData *NSDataFromSecKeyRef(SecKeyRef keyRef) {
    CFErrorRef error = NULL;
    CFDataRef dataRef = SecKeyCopyExternalRepresentation(keyRef, &error);
    if (error) {
        NSLog(@"RSA failed to copy data with sec key: %@", keyRef);
        assert(dataRef == NULL); // the data ref should be empty when error
        assert(false);
        CFRelease(error);
        error = NULL;
    }
    return (__bridge_transfer NSData *)dataRef;
}

static inline NSString *NSStringFromRSAPublicKeyContent(NSString *content) {
    NSMutableString *mString = [[NSMutableString alloc] init];
    [mString appendString:@"-----BEGIN PUBLIC KEY-----\n"];
    NSUInteger pos1, pos2, len = content.length;
    NSString *substr;
    for (pos1 = 0, pos2 = 64; pos1 < len; pos1 = pos2, pos2 += 64) {
        if (pos2 > len) {
            pos2 = len;
        }
        substr = [content substringWithRange:NSMakeRange(pos1, pos2 - pos1)];
        [mString appendString:substr];
        [mString appendString:@"\n"];
    }
    [mString appendString:@"-----END PUBLIC KEY-----\n"];
    return mString;
}

static inline NSString *NSStringFromRSAPrivateKeyContent(NSString *content) {
    NSMutableString *mString = [[NSMutableString alloc] init];
    [mString appendString:@"-----BEGIN RSA PRIVATE KEY-----\n"];
    NSUInteger pos1, pos2, len = content.length;
    NSString *substr;
    for (pos1 = 0, pos2 = 64; pos1 < len; pos1 = pos2, pos2 += 64) {
        if (pos2 > len) {
            pos2 = len;
        }
        substr = [content substringWithRange:NSMakeRange(pos1, pos2 - pos1)];
        [mString appendString:substr];
        [mString appendString:@"\n"];
    }
    [mString appendString:@"-----END RSA PRIVATE KEY-----\n"];
    return mString;
}

@interface PEM : NSObject <MKMKeyParser>

@end

@implementation PEM

- (NSString *)encodePublicKey:(SecKeyRef)key {
    NSData *data = NSDataFromSecKeyRef(key);
    NSString *base64 = MKMBase64Encode(data);
    return NSStringFromRSAPublicKeyContent(base64);
}

- (NSString *)encodePrivateKey:(SecKeyRef)key {
    NSData *data = NSDataFromSecKeyRef(key);
    NSString *base64 = MKMBase64Encode(data);
    return NSStringFromRSAPrivateKeyContent(base64);
}

- (SecKeyRef)decodePublicKey:(NSString *)pem {
    NSString *base64 = RSAPublicKeyContentFromNSString(pem);
    NSData *data = MKMBase64Decode(base64);
    return SecKeyRefFromPublicData(data);
}

- (SecKeyRef)decodePrivateKey:(NSString *)pem {
    NSString *base64 = RSAPrivateKeyContentFromNSString(pem);
    NSData *data = MKMBase64Decode(base64);
    return SecKeyRefFromPrivateData(data);
}

@end

#pragma mark -

@implementation MKMPEM

SingletonImplementations(MKMPEM, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        self.parser = [[PEM alloc] init];
    }
    return self;
}

- (NSString *)encodePublicKey:(SecKeyRef)key {
    NSAssert(self.parser, @"PEM key parser not set yet");
    return [self.parser encodePublicKey:key];
}

- (NSString *)encodePrivateKey:(SecKeyRef)key {
    NSAssert(self.parser, @"PEM key parser not set yet");
    return [self.parser encodePrivateKey:key];
}

- (SecKeyRef)decodePublicKey:(NSString *)pem {
    NSAssert(self.parser, @"PEM key parser not set yet");
    return [self.parser decodePublicKey:pem];
}

- (SecKeyRef)decodePrivateKey:(NSString *)pem {
    NSAssert(self.parser, @"PEM key parser not set yet");
    return [self.parser decodePrivateKey:pem];
}

@end
