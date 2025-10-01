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
//  MKMMeta.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKTransportableData.h"
#import "MKMAccountHelpers.h"

#import "MKMMeta.h"

id<MKMMetaFactory> MKMMetaGetFactory(NSString *type) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext.metaHelper getMetaFactory:type];
}

void MKMMetaSetFactory(NSString *type, id<MKMMetaFactory> factory) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    [ext.metaHelper setMetaFactory:factory forType:type];
}

id<MKMMeta> MKMMetaGenerate(NSString *type, id<MKSignKey> SK,
                            NSString * _Nullable seed) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext.metaHelper generateMetaWithKey:SK seed:seed forType:type];
}

id<MKMMeta> MKMMetaCreate(NSString *type, id<MKVerifyKey> PK,
                          NSString * _Nullable seed,
                          _Nullable id<MKTransportableData> fingerprint) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext.metaHelper createMetaWithKey:PK
                                        seed:seed
                                 fingerprint:fingerprint
                                     forType:type];
}

id<MKMMeta> MKMMetaParse(id meta) {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext.metaHelper parseMeta:meta];
}
