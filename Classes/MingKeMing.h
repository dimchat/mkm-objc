//
//  MingKeMing.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for MingKeMing.
FOUNDATION_EXPORT double MingKeMingVersionNumber;

//! Project version string for MingKeMing.
FOUNDATION_EXPORT const unsigned char MingKeMingVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MingKeMing/PublicHeader.h>

#if !defined(__MING_KE_MING__)
#define __MING_KE_MING__ 1

// Extends
//#import <MingKeMing/NSObject+Singleton.h>
//#import <MingKeMing/NSObject+JsON.h>
//#import <MingKeMing/NSObject+Compare.h>
//#import <MingKeMing/NSData+Crypto.h>
//#import <MingKeMing/NSString+Crypto.h>
//#import <MingKeMing/NSArray+Merkle.h>
//#import <MingKeMing/NSDictionary+Binary.h>
//#import <MingKeMing/NSDate+Timestamp.h>

// Types
//#import <MingKeMing/MKMString.h>
//#import <MingKeMing/MKMDictionary.h>

// Cryptography
//#import <MingKeMing/MKMCryptographyKey.h>
//-- Symmetric
#import <MingKeMing/MKMSymmetricKey.h>
//---- AES
//#import <MingKeMing/MKMAESKey.h>
//-- Asymmetric
//#import <MingKeMing/MKMAsymmetricKey.h>
#import <MingKeMing/MKMPublicKey.h>
#import <MingKeMing/MKMPrivateKey.h>
//---- RSA
//#import <MingKeMing/MKMRSAKeyHelper.h>
//#import <MingKeMing/MKMRSAPublicKey.h>
//#import <MingKeMing/MKMRSAPrivateKey.h>
//#import <MingKeMing/MKMRSAPrivateKey+PersistentStore.h>
//---- ECC
//#import <MingKeMing/MKMECCPublicKey.h>
//#import <MingKeMing/MKMECCPrivateKey.h>

// Entity
#import <MingKeMing/MKMID.h>
#import <MingKeMing/MKMAddress.h>
#import <MingKeMing/MKMMeta.h>
#import <MingKeMing/MKMEntity.h>

// History
#import <MingKeMing/MKMHistoryOperation.h>
#import <MingKeMing/MKMHistoryTransaction.h>
#import <MingKeMing/MKMHistoryBlock.h>
#import <MingKeMing/MKMHistory.h>
#import <MingKeMing/MKMEntityHistoryDelegate.h>
#import <MingKeMing/MKMAccountHistoryDelegate.h>
#import <MingKeMing/MKMGroupHistoryDelegate.h>
#import <MingKeMing/MKMChatroomHistoryDelegate.h>
#import <MingKeMing/MKMConsensus.h>
#import <MingKeMing/MKMUser+History.h>

// Group
#import <MingKeMing/MKMMember.h>
#import <MingKeMing/MKMGroup.h>
#import <MingKeMing/MKMPolylogue.h>
#import <MingKeMing/MKMChatroom.h>

//-
#import <MingKeMing/MKMAccount.h>
#import <MingKeMing/MKMUser.h>
#import <MingKeMing/MKMContact.h>

#import <MingKeMing/MKMProfile.h>
#import <MingKeMing/MKMBarrack.h>
#import <MingKeMing/MKMBarrack+LocalStorage.h>
//#import <MingKeMing/MKMImmortals.h>

#endif /* ! __MING_KE_MING__ */
