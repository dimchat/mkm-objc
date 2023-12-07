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

#import "MKMTransportableData.h"
#import "MKMFactoryManager.h"

#import "MKMMeta.h"

id<MKMMetaFactory> MKMMetaGetFactory(MKMMetaType version) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory metaFactoryForType:version];
}

void MKMMetaSetFactory(MKMMetaType version, id<MKMMetaFactory> factory) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    [man.generalFactory setMetaFactory:factory forType:version];
}

id<MKMMeta> MKMMetaGenerate(MKMMetaType version,
                            id<MKMSignKey> SK,
                            NSString * _Nullable seed) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory generateMetaWithType:version key:SK seed:seed];
}

id<MKMMeta> MKMMetaCreate(MKMMetaType version,
                          id<MKMVerifyKey> PK,
                          NSString * _Nullable seed,
                          _Nullable id<MKMTransportableData> fingerprint) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory createMetaWithType:version
                                              key:PK
                                             seed:seed
                                      fingerprint:fingerprint];
}

id<MKMMeta> MKMMetaParse(id meta) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory parseMeta:meta];
}
