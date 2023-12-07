// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  MKMPortableNetworkFile.h
//  MingKeMing
//
//  Created by Albert Moky on 2023/12/6.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/MKMTransportableData.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKMDecryptKey;

/**
 *  Transportable File
 *  ~~~~~~~~~~~~~~~~~~
 *  PNF - Portable Network File
 *
 *      0.  "{URL}"
 *      1. "base64,{BASE64_ENCODE}"
 *      2. "data:image/png;base64,{BASE64_ENCODE}"
 *      3. {
 *              data     : "...",        // base64_encode(fileContent)
 *              filename : "avatar.png",
 *
 *              URL      : "http://...", // download from CDN
 *              // before fileContent uploaded to a public CDN,
 *              // it can be encrypted by a symmetric key
 *              key      : {             // symmetric key to decrypt file content
 *                  algorithm : "AES",   // "DES", ...
 *                  data      : "{BASE64_ENCODE}",
 *                  ...
 *              }
 *      }
 */
@protocol MKMPortableNetworkFile <MKMDictionary>

/**
 *  When file data is too big, don't set it in this dictionary,
 *  but upload it to a CDN and set the download URL instead.
 */
@property (strong, nonatomic, nullable) NSData *data;

@property (strong, nonatomic, nullable) NSString *filename;

/**
 *  Download URL
 */
@property (strong, nonatomic, nullable) NSURL *url;

/**
 *  Password for decrypting the downloaded data from CDN,
 *  default is a plain key, which just return the same data when decrypting.
 */
@property (strong, nonatomic, nullable) id<MKMDecryptKey> password;

/**
 *  Get encoded string
 *
 * @return "URL", or
 *         "base64,{BASE64_ENCODE}", or
 *         "data:image/png;base64,{BASE64_ENCODE}", or
 *         "{...}"
 */
@property (readonly, strong, nonatomic) NSString *string;

/**
 *  toJson()
 *
 * @return String, or Map
 */
@property (readonly, strong, nonatomic) NSObject *object;

@end

#pragma mark - PNF Factory

@protocol MKMPortableNetworkFileFactory <NSObject>

/**
 *  Create PNF
 *
 * @param data     - file data (not encrypted)
 * @param name     - file name
 * @param locator  - download URL
 * @param key      - decrypt key for downloaded data
 * @return PNF object
 */
- (id<MKMPortableNetworkFile>)createPortableNetworkFile:(nullable id<MKMTransportableData>)data
                                               filename:(nullable NSString *)name
                                                    url:(nullable NSURL *)locator
                                               password:(nullable id<MKMDecryptKey>)key;

/**
 *  Parse map object to PNF
 *
 * @param pnf - PNF info
 * @return PNF object
 */
- (nullable id<MKMPortableNetworkFile>)parsePortableNetworkFile:(NSDictionary *)pnf;

@end

// Create from remote URL
#define MKMPortableNetworkFileFromURL(url, password)                           \
                MKMPortableNetworkFileCreate(nil, nil, url, password)          \
                        /* EOF 'MKMPortableNetworkFileFromURL(url, password)' */

// Create from file data
#define MKMPortableNetworkFileFromData(data, filename)                         \
                MKMPortableNetworkFileCreate(                                  \
                    MKMTransportableDataCreate(data, nil), filename, nil, nil  \
                )                                                              \
                      /* EOF 'MKMPortableNetworkFileFromData(data, filename)' */

#ifdef __cplusplus
extern "C" {
#endif

_Nullable id<MKMPortableNetworkFileFactory> MKMPortableNetworkFileGetFactory(void);
void MKMPortableNetworkFileSetFactory(id<MKMPortableNetworkFileFactory> factory);

_Nullable id<MKMPortableNetworkFile> MKMPortableNetworkFileParse(_Nullable id pnf);

id<MKMPortableNetworkFile> MKMPortableNetworkFileCreate(_Nullable id<MKMTransportableData> data,
                                                        NSString * _Nullable filename,
                                                        NSURL * _Nullable url,
                                                        _Nullable id<MKMDecryptKey> password);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
