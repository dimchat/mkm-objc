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
//  MKMKeyParser.h
//  MingKeMing
//
//  Created by Albert Moky on 2020/4/7.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKMKeyParser <NSObject>

/**
 *  Encode public key to text string
 *
 * @param key - public key
 * @return PEM string
 */
- (NSString *)encodePublicKey:(SecKeyRef)key;

/**
 *  Encode private key to text string
 *
 * @param key - private key
 * @return PEM string
 */
- (NSString *)encodePrivateKey:(SecKeyRef)key;

/**
 *  Decode text string to public key
 *
 * @param pem - text string
 * @return public key
 */
- (SecKeyRef)decodePublicKey:(NSString *)pem;

/**
 *  Decode text string to private key
 *
 * @param pem - text string
 * @return private key
 */
- (SecKeyRef)decodePrivateKey:(NSString *)pem;

@end

#pragma mark -

#define MKMPEMParser()              [MKMPEM sharedInstance]
#define MKMPEMEncodePublicKey(key)  [MKMPEMParser() encodePublicKey:(key)]
#define MKMPEMEncodePrivateKey(key) [MKMPEMParser() encodePrivateKey:(key)]
#define MKMPEMDecodePublicKey(pem)  [MKMPEMParser() decodePublicKey:(pem)]
#define MKMPEMDecodePrivateKey(pem) [MKMPEMParser() decodePrivateKey:(pem)]

extern NSData *NSDataFromSecKeyRef(SecKeyRef keyRef);
extern NSString *RSAPublicKeyContentFromNSString(NSString *content);
extern NSString *RSAPrivateKeyContentFromNSString(NSString *content);

@interface MKMPEM : NSObject <MKMKeyParser>

// default parser
@property (strong, nonatomic) id<MKMKeyParser> parser;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
