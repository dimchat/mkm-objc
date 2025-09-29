// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
//  MKPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKCryptoHelpers.h"

#import "MKPrivateKey.h"

id<MKPrivateKeyFactory> MKPrivateKeyGetFactory(NSString *algorithm) {
    MKCryptoExtensions *ext = [MKCryptoExtensions sharedInstance];
    return [ext.privateHelper getPrivateKeyFactory:algorithm];
}

void MKPrivateKeySetFactory(NSString *algorithm, id<MKPrivateKeyFactory> factory) {
    MKCryptoExtensions *ext = [MKCryptoExtensions sharedInstance];
    [ext.privateHelper setPrivateKeyFactory:factory algorithm:algorithm];
}

id<MKPrivateKey> MKPrivateKeyGenerate(NSString *algorithm) {
    MKCryptoExtensions *ext = [MKCryptoExtensions sharedInstance];
    return [ext.privateHelper generatePrivateKey:algorithm];
}

id<MKPrivateKey> MKPrivateKeyParse(id key) {
    MKCryptoExtensions *ext = [MKCryptoExtensions sharedInstance];
    return [ext.privateHelper parsePrivateKey:key];
}
