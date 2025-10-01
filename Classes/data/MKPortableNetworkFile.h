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
//  MKPortableNetworkFile.h
//  MingKeMing
//
//  Created by Albert Moky on 2023/12/6.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/MKDictionary.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKDecryptKey;
@protocol MKTransportableData;

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
@protocol MKPortableNetworkFile <MKDictionary>

/**
 *  When file data is too big, don't set it in this dictionary,
 *  but upload it to a CDN and set the download URL instead.
 */
@property (strong, nonatomic, nullable) NSData *data;

@property (strong, nonatomic, nullable) NSString *filename;

/**
 *  Download URL
 */
@property (strong, nonatomic, nullable) NSURL *URL;

/**
 *  Password for decrypting the downloaded data from CDN,
 *  default is a plain key, which just return the same data when decrypting.
 */
@property (strong, nonatomic, nullable) __kindof id<MKDecryptKey> password;

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

@protocol MKPortableNetworkFileFactory <NSObject>

/**
 *  Create PNF
 *
 * @param data     - file data (not encrypted)
 * @param name     - file name
 * @param locator  - download URL
 * @param key      - decrypt key for downloaded data
 * @return PNF object
 */
- (id<MKPortableNetworkFile>)createPortableNetworkFile:(nullable id<MKTransportableData>)data
                                              filename:(nullable NSString *)name
                                                   url:(nullable NSURL *)locator
                                              password:(nullable id<MKDecryptKey>)key;

/**
 *  Parse map object to PNF
 *
 * @param pnf - PNF info
 * @return PNF object
 */
- (nullable id<MKPortableNetworkFile>)parsePortableNetworkFile:(NSDictionary *)pnf;

@end

#pragma mark - Conveniences

// Create from remote URL
#define MKPortableNetworkFileFromURL(url, password)                            \
                MKPortableNetworkFileCreate(nil, nil, url, password)           \
                         /* EOF 'MKPortableNetworkFileFromURL(url, password)' */

// Create from file data
#define MKPortableNetworkFileFromData(data, filename)                          \
                MKPortableNetworkFileCreate(                                   \
                    MKTransportableDataCreate(data, nil), filename, nil, nil   \
                )                                                              \
                       /* EOF 'MKPortableNetworkFileFromData(data, filename)' */

#ifdef __cplusplus
extern "C" {
#endif

_Nullable id<MKPortableNetworkFileFactory> MKPortableNetworkFileGetFactory(void);
void MKPortableNetworkFileSetFactory(id<MKPortableNetworkFileFactory> factory);

id<MKPortableNetworkFile> MKPortableNetworkFileCreate(_Nullable id<MKTransportableData> data,
                                                      NSString * _Nullable filename,
                                                      NSURL * _Nullable url,
                                                      _Nullable id<MKDecryptKey> password);

_Nullable id<MKPortableNetworkFile> MKPortableNetworkFileParse(_Nullable id pnf);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
