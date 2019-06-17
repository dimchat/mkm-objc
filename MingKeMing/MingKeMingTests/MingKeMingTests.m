//
//  MingKeMingTests.m
//  MingKeMingTests
//
//  Created by Albert Moky on 2018/12/19.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <MingKeMing/MingKeMing.h>

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMImmortals.h"

static inline NSString *search_number(UInt32 code) {
    NSMutableString *number;
    number = [[NSMutableString alloc] initWithFormat:@"%010u", (unsigned int)code];;
    if ([number length] == 10) {
        [number insertString:@"-" atIndex:6];
        [number insertString:@"-" atIndex:3];
    }
    return number;
}

static inline void print_id(const MKMID *ID) {
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    [mDict setObject:@(ID.type) forKey:@"type"];
    [mDict setObject:@(ID.number) forKey:@"number"];
    [mDict setObject:@(ID.valid) forKey:@"valid"];
    
    if (ID.name) {
        [mDict setObject:ID.name forKey:@"name"];
    }
    if (ID.address) {
        [mDict setObject:ID.address forKey:@"address"];
    }
    if (ID.terminal) {
        [mDict setObject:ID.terminal forKey:@"terminal"];
    }
    NSLog(@"ID(%@): %@", ID, mDict);
}

@interface MingKeMingTests : XCTestCase

@end

@implementation MingKeMingTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testHash {
    
    NSString *string = @"moky";
    NSData *data = [string data];
    
    NSData *hash;
    NSString *res;
    NSString *exp;
    
    
    // sha256（moky）= cb98b739dd699aa44bb6ebba128d20f2d1e10bb3b4aa5ff4e79295b47e9ed76d
    exp = @"cb98b739dd699aa44bb6ebba128d20f2d1e10bb3b4aa5ff4e79295b47e9ed76d";
    hash = [data sha256];
    res = [hash hexEncode];
    NSLog(@"sha256(%@) = %@", string, res);
    NSAssert([res isEqual:exp], @"sha256 error: %@ != %@", res, exp);
    
    
    // ripemd160(moky) = 44bd174123aee452c6ec23a6ab7153fa30fa3b91
    exp = @"44bd174123aee452c6ec23a6ab7153fa30fa3b91";
    hash = [data ripemd160];
    res = [hash hexEncode];
    NSLog(@"ripemd160(%@) = %@", string, res);
    NSAssert([res isEqual:exp], @"ripemd160 error: %@ != %@", res, exp);
    
}

- (void)testEncode {
    
    NSString *string = @"moky";
    NSData *data = [string data];
    
    NSString *enc;
    
    // base58(moky) = 3oF5MJ
    enc = [data base58Encode];
    NSLog(@"base58(%@) = %@", string, enc);
    NSAssert([enc isEqualToString:@"3oF5MJ"], @"base 58 encode error");
    
    // base64(moky) = bW9reQ==
    enc = [data base64Encode];
    NSLog(@"base64(%@) = %@", string, enc);
    NSAssert([enc isEqualToString:@"bW9reQ=="], @"base 64 encode error");
}

- (void)testKeys {
    NSDictionary *key = @{@"algorithm": @"RSA",
                          @"data": @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDr2zVbMu4zFOdimKVD4DlW0Uol\nEtUocA9QESbKVdv8sjFY29JROrXNGHW0uD1cyGSLJyKVuDu7PnvgcUILeSpV+TEn\nNrMN5KSSTeWyOmh5n8NI5WqT3qpCk5vNMa4e/4/Yuh/Hy4d3KOmFO0cVa29e0GmV\nDHkGqw6f7uykdGVnNwIDAQAB\n-----END PUBLIC KEY-----"};
    MKMPublicKey *PK = [MKMPublicKey keyWithKey:key];
    NSLog(@"PK: %@", PK);
    NSLog(@"PK.json: %@", [PK jsonString]);
    NSString *data = [PK.data base64Encode];
    NSLog(@"PK.data: %@", data);
    
    NSAssert([data isEqualToString:@"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDr2zVbMu4zFOdimKVD4DlW0UolEtUocA9QESbKVdv8sjFY29JROrXNGHW0uD1cyGSLJyKVuDu7PnvgcUILeSpV+TEnNrMN5KSSTeWyOmh5n8NI5WqT3qpCk5vNMa4e/4/Yuh/Hy4d3KOmFO0cVa29e0GmVDHkGqw6f7uykdGVnNwIDAQAB"], @"data error");
}

- (void)testSymmetric {
    
    NSString *string = @"moky";
    NSData *data = [string data];
    
    MKMSymmetricKey *key;
    
    NSData *CT;
    NSData *dec;
    
    NSString *keyInfo = @"{\"algorithm\": \"AES\", \"data\": \"C2+xGizLL1G1+z9QLPYNdp/bPP/seDvNw45SXPAvQqk=\", \"iv\": \"SxPwi6u4+ZLXLdAFJezvSQ==\"}";
    NSDictionary *keyDict = [[keyInfo data] jsonDictionary];
    
    // 1
    key = [MKMSymmetricKey keyWithKey:keyDict];
    CT = [key encrypt:data];
    dec = [key decrypt:CT];
    NSLog(@"key: %@", key);
    NSLog(@"%@ -> %@ -> %@", string, [CT base64Encode], [dec UTF8String]);
    NSAssert([dec isEqual:data], @"en/decrypt error");
    
    NSString *base64 = @"0xtbqZN6x2aWTZn0DpCoCA==";
    NSAssert([[CT base64Encode] isEqualToString:base64], @"encrypt error");
    
    base64 = @"XX5qfromb3R078VVK7LwVA==";
    CT = [base64 base64Decode];
    dec = [key decrypt:CT];
    NSLog(@"%@ -> %@", base64, [dec UTF8String]);
    NSAssert([[dec UTF8String] isEqualToString:string], @"en/decrypt error");
    
    dec = [key decrypt:CT];
    NSLog(@"%@ -> %@", base64, [dec UTF8String]);

    
//    // 2
//    key = [[MKMSymmetricKey alloc] init];
//    NSLog(@"key: %@", key);
//    CT = [key encrypt:data];
//    NSLog(@"key: %@", key);
//    dec = [key decrypt:CT];
//    NSLog(@"%@ -> %@ -> %@", string, [CT base64Encode], [dec UTF8String]);
//    NSAssert([dec isEqual:data], @"en/decrypt error");
    
}

- (void)testAsymmetric {
    
    NSString *string = @"moky";
    NSData *data = [string data];
    
    MKMPrivateKey *SK = [[MKMPrivateKey alloc] init];
    MKMPublicKey *PK = SK.publicKey;
    NSLog(@"private key: %@", SK);
    NSLog(@"public key: %@", PK);
    
    NSData *CT = [PK encrypt:data];
    NSData *dec = [SK decrypt:CT];
    NSLog(@"%@ -> %@ -> %@", string, [CT base64Encode], [dec UTF8String]);
    NSAssert([dec isEqual:data], @"en/decrypt error");
    
    NSData *sig = [SK sign:data];
    NSLog(@"sign(%@) = %@", [data UTF8String], [sig base64Encode]);
    
    if ([PK verify:data withSignature:sig]) {
        NSLog(@"==== CORRECT!");
    } else {
        NSAssert(false, @"signature error");
    }
    
}

- (void)testMeta {
    
    NSString *name = @"moky";
    MKMPrivateKey *SK = [[MKMPrivateKey alloc] init];
    MKMPublicKey *PK = SK.publicKey;
    
    MKMMeta *meta = [[MKMMetaDefault alloc] initWithVersion:MKMMetaVersion_MKM
                                                       seed:name
                                                 privateKey:SK
                                                  publicKey:PK];
    
    const MKMID *ID = [meta generateID:MKMNetwork_Main];
    
    NSLog(@"meta: %@", meta);
    print_id(ID);
    
    NSAssert([meta matchID:ID], @"error");
    
}

- (void)testMeta2 {
    MKMPrivateKey *SK = [[MKMPrivateKey alloc] init];
    MKMPublicKey *PK = SK.publicKey;
    
    MKMMeta *meta = [[MKMMetaBTC alloc] initWithPublicKey:PK];
    const MKMID *ID = [meta generateID:MKMNetwork_BTCMain];
    
    NSLog(@"meta: %@", meta);
    print_id(ID);
    
    NSAssert([meta matchID:ID], @"error");
    
    NSString *satoshi = @"1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa";
    MKMID *ID2 = [MKMID IDWithID:satoshi];
    print_id(ID2);
}

- (void)testAccount {
    
    MKMImmortals *immortals = [[MKMImmortals alloc] init];
    
    MKMID *ID = [MKMID IDWithID:MKM_IMMORTAL_HULK_ID];
    MKMUser *user = [immortals userWithID:ID];
    
    NSLog(@"get user: %@", user);
    //NSLog(@"SK: %@", user.privateKey);
    //NSAssert([user.publicKey isMatch:user.privateKey], @"keys not match");
    
//    NSString *string;
//    NSData *data;
//    string = @"WH/wAcu+HfpaLq+vRblNnYufkyjTm4FgYyzW3wBDeRtXs1TeDmRxKVu7"
//    "nQI/sdIALGLXrY+O5mlRfhU8f8TuIBilZUlX/eIUpL4uSDYKVLaRG9pO"
//    "crCHKevjUpId9x/8KBEiMIL5LB0Vo7sKrvrqosCnIgNfHbXMKvMzwcqZ"
//    "EU8=";
//    data = [string base64Decode];
//    data = [user.privateKey decrypt:data];
//    string = [data UTF8String];
//    NSLog(@"RSA decrypt: %@", string);
//    
//    MKMSymmetricKey *pw;
//    pw = [[MKMSymmetricKey alloc] initWithJSONString:string];
//    
//    string = @"9cjCKG99ULCCxbL2mkc/MgF1saeRqJaCc+S12+HCqmsuF7TWK61EwTQWZSKskUeF";
//    data = [string base64Decode];
//    data = [pw decrypt:data];
//    string = [data UTF8String];
//    NSLog(@"AES decrypt: %@", string);
    
}

- (void)testRegister {
    MKMPrivateKey *SK;
    MKMPublicKey *PK;
    
    NSString *name = @"moky";
    MKMNetworkType network = MKMNetwork_Main;
    NSUInteger suffix = 9527;
    
    NSData *data = [name data];
    
    NSData *CT;
    MKMAddress *addr;
    UInt32 number;
    NSUInteger count;
    
    NSDate *time1, *time2;
    time1 = [[NSDate alloc] init];
    
    for (count = 0; count < NSUIntegerMax; ++count) {
        
        SK = [[MKMPrivateKey alloc] init];
        PK = SK.publicKey;
        
        CT = [SK sign:data];
        
        addr = [[MKMAddressBTC alloc] initWithData:CT network:network];
        
        number = addr.code;
        if (count % 100 == 0) {
            NSLog(@"[%lu] address: %@, number: %@", count, addr, search_number(number));
        }
        
        if (number % 10000 != suffix) {
            continue;
        }
        
        MKMMeta *meta = [[MKMMeta alloc] initWithVersion:MKMMetaDefaultVersion
                                               publicKey:PK
                                                    seed:name
                                             fingerprint:CT];
        
        const MKMID *ID = [meta generateID:network];

        NSLog(@"[%lu] address: %@, number: %@", count, addr, search_number(number));
        NSLog(@"GOT IT -> ID: %@, meta: %@, SK: %@", ID, meta, SK);
        break;
    }
    
    time2 = [[NSDate alloc] init];
    NSTimeInterval ti = [time2 timeIntervalSinceDate:time1];
    NSLog(@"count: %lu, time: %lu, speed: %f", count, (unsigned long)ti, count/ti);
}

@end
