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

static inline NSString *search_number(UInt32 code) {
    NSMutableString *number;
    number = [[NSMutableString alloc] initWithFormat:@"%010u", (unsigned int)code];;
    if ([number length] == 10) {
        [number insertString:@"-" atIndex:6];
        [number insertString:@"-" atIndex:3];
    }
    return number;
}

static inline void print_id(MKMID *ID) {
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
    
    string = @"5Kd3NBUAdUnhyzenEwVLy9pBKxSwXvE9FMPyR4UKZvpe6E3AgLr";
    data = [string base58Decode];
    NSLog(@"base58 decode: %@", [data hexEncode]);
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
    key = MKMSymmetricKeyFromDictionary(keyDict);
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

    
    // 2
    key = MKMSymmetricKeyWithAlgorithm(SCAlgorithmAES);
    NSLog(@"key: %@", key);
    CT = [key encrypt:data];
    NSLog(@"key: %@", key);
    dec = [key decrypt:CT];
    NSLog(@"%@ -> %@ -> %@", string, [CT base64Encode], [dec UTF8String]);
    NSAssert([dec isEqual:data], @"en/decrypt error");
    
}

- (void)testAsymmetric {
    
    NSString *string = @"moky";
    NSData *data = [string data];
    
    MKMPrivateKey *SK = MKMPrivateKeyWithAlgorithm(ACAlgorithmRSA);
    MKMPublicKey *PK = SK.publicKey;
    NSLog(@"private key: %@", SK);
    NSLog(@"public key: %@", PK);
    
    NSData *CT = [(id<MKMEncryptKey>)PK encrypt:data];
    NSData *dec = [(id<MKMDecryptKey>)SK decrypt:CT];
    NSLog(@"%@ -> %@ -> %@", string, [CT base64Encode], [dec UTF8String]);
    NSAssert([dec isEqual:data], @"en/decrypt error");
    
    NSData *sig = [SK sign:data];
    NSLog(@"sign(%@) = %@", [data UTF8String], [sig base64Encode]);
    
    if ([PK verify:data withSignature:sig]) {
        NSLog(@"==== CORRECT!");
    } else {
        NSAssert(false, @"signature error");
    }
    
    NSDictionary *spKey;
    spKey = @{@"algorithm": @"RSA",
              @"data": @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDET7fvLupUBUc6ImwJejColybq\n"
              "rU+Y6PwiCKhblGbwVqbvapD2A1hjEu4EtL6mm3v7hcgsO3Df33/ShRua6GW9/JQV\n"
              "DLfdznLfuTg8w5Ug+dysJfbrmB1G7nbqDYEyXQXNRWpQsLHYSD/ihaSKWNnOuV0c\n"
              "7ieJEzQAp++O+d3WUQIDAQAB"
              };
    PK = MKMPublicKeyFromDictionary(spKey);
    NSLog(@"sp key: %@", PK);
    
    spKey = @{@"algorithm": @"RSA",
              @"data": @"MIICXAIBAAKBgQDET7fvLupUBUc6ImwJejColybqrU+Y6PwiCKhblGbwVqbvapD2\n"
              "A1hjEu4EtL6mm3v7hcgsO3Df33/ShRua6GW9/JQVDLfdznLfuTg8w5Ug+dysJfbr\n"
              "mB1G7nbqDYEyXQXNRWpQsLHYSD/ihaSKWNnOuV0c7ieJEzQAp++O+d3WUQIDAQAB\n"
              "AoGAA+J7dnBYWv4JPyth9ayNNLLcBmoUUIdwwNgow7orsM8YKdXzJSkjCT/dRarR\n"
              "eIDMaulmcQiils2IjSEM7ytw4vEOPWY0AVj2RPhD83GcYyw9sUcTaz22R5UgsQ8X\n"
              "7ikqBX+YO+diVBf2EqAoEihdO8App6jtlsQGsUjjlrKQIMECQQDSphyRLixymft9\n"
              "bip7N6YZA5RoiO1yJhPn6X2EQ0QxX8IwKlV654jhDcLsPBUJsbxYK0bWfORZLi8V\n"
              "+ambjnbxAkEA7pNmEvw/V+zw3DDGizeyRbhYgeZxAgKwXd8Vxd6pFl4iQRmvu0is\n"
              "d94jZzryBycP6HSRKN11stnDJN++5TEVYQJALfTjoqDqPY5umazhQ8SeTjLDvBKz\n"
              "iwXXre743VQ3mnYDzbJOt+OvrznrXtK03EqUhr/aUo0o3HQA/dBcOn3YYQJBAM98\n"
              "yAh48wogGnYVwYbwgI3cPrVy2hO6jPKHAyOce4flhHsDwO7rzHtPaZDtFfMciNxN\n"
              "DLXyrNtIQkx+f0JLBuECQCUfuJGL+qbExpD3tScBJPAIJ8ZVRVbTcL3eHC9q6gx3\n"
              "7Fmn9KfbQrUHPwwdo5nuK+oVVYnFkyKGPSer7ras8ro="
              };
    SK = MKMPrivateKeyFromDictionary(spKey);

    CT = [(id<MKMEncryptKey>)PK encrypt:data];
    dec = [(id<MKMDecryptKey>)SK decrypt:CT];
    NSLog(@"sp: %@ -> %@ -> %@", string, [CT base64Encode], [dec UTF8String]);
    
    sig = [SK sign:data];
    NSLog(@"sign(%@) = %@", [data UTF8String], [sig base64Encode]);
}

- (void)testMeta {
    
    NSString *name = @"moky";
    MKMPrivateKey *SK = MKMPrivateKeyWithAlgorithm(ACAlgorithmRSA);
    
    MKMMeta *meta = MKMMetaGenerate(MKMMetaDefaultVersion, SK, name);
    MKMID *ID = [meta generateID:MKMNetwork_Main];
    
    NSLog(@"meta: %@", meta);
    print_id(ID);
    
    NSAssert([meta matchID:ID], @"error");
    
}

//- (void)testMeta2 {
//    MKMPrivateKey *SK = MKMPrivateKeyWithAlgorithm(ACAlgorithmRSA);
//
//    MKMMeta *meta = MKMMetaGenerate(MKMMetaVersion_BTC, SK, nil);
//    MKMID *ID = [meta generateID:MKMNetwork_BTCMain];
//
//    NSLog(@"meta: %@", meta);
//    print_id(ID);
//
//    NSAssert([meta matchID:ID], @"error");
//
//    NSString *satoshi = @"1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa";
//    MKMID *ID2 = MKMIDFromString(satoshi);
//    print_id(ID2);
//}

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
        
        SK = MKMPrivateKeyWithAlgorithm(ACAlgorithmRSA);
        PK = SK.publicKey;
        
        CT = [SK sign:data];
        
        addr = [MKMAddressDefault generateWithData:CT network:network];
        
        number = addr.code;
        if (count % 100 == 0) {
            NSLog(@"[%lu] address: %@, number: %@", count, addr, search_number(number));
        }
        
        if (number % 10000 != suffix) {
            continue;
        }
        
        NSDictionary *dict = @{@"version"    :@(MKMMetaDefaultVersion),
                               @"key"        :PK,
                               @"seed"       :name,
                               @"fingerprint":[CT base64Encode],
                               };
        
        MKMMeta *meta = MKMMetaFromDictionary(dict);
        
        MKMID *ID = [meta generateID:network];

        NSLog(@"[%lu] address: %@, number: %@", count, addr, search_number(number));
        NSLog(@"GOT IT -> ID: %@, meta: %@, SK: %@", ID, meta, SK);
        break;
    }
    
    time2 = [[NSDate alloc] init];
    NSTimeInterval ti = [time2 timeIntervalSinceDate:time1];
    NSLog(@"count: %lu, time: %lu, speed: %f", count, (unsigned long)ti, count/ti);
}

static inline void checkX(NSString *metaJson, NSString *skJson) {
    NSDictionary *dict = [[metaJson data] jsonDictionary];
    MKMMeta *meta = MKMMetaFromDictionary(dict);
    MKMID *ID = [meta generateID:MKMNetwork_Main];
    NSLog(@"meta: %@", meta);
    NSLog(@"ID: %@", ID);
    
    dict = [[skJson data] jsonDictionary];
    MKMPrivateKey *SK = MKMPrivateKeyFromDictionary(dict);
    NSLog(@"private key: %@", SK);
    assert([(id<MKMPublicKey>)meta.key isMatch:SK]);
    
    NSString *name = @"moky";
    NSData *data = [name data];
    NSData *CT = [(id<MKMEncryptKey>)meta.key encrypt:data];
    NSData *PT = [(id<MKMDecryptKey>)SK decrypt:CT];
    NSString *hex = [CT hexEncode];
    NSString *res = [PT UTF8String];
    NSLog(@"encryption: %@ -> %@ -> %@", name, hex, res);
}

- (void)testPythonMeta {
    NSLog(@"checking data from Python ...");
    NSString *s1 = @"{\"version\": 1, \"seed\": \"moky\", \"key\": {\"algorithm\": \"RSA\", \"data\": \"-----BEGIN PUBLIC KEY-----\\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDbTf58ScygpB7tbOSN5/9dZIEB\\ncbKjnwUxW8cWdEo765gGXUsNUQUgThFC4csLsFTvqVhGxn3+WfDIwrvzF/2HWJu8\\nUvo3LkG3ZGP8US9y2Mvp9VaCWz8ZwyMe4fcWus8dRs8fdTatLeoZVGQDv9SdE2Vx\\nuPvJw3gHyR9dOKq37QIDAQAB\\n-----END PUBLIC KEY-----\"}, \"fingerprint\": \"MTHQiV/6sCAtOM6CJ2clJgKHu4Lyw34rzoWLsARPL61Z4ivz/q2y9dXIN49A0B+RT6z7+vqI6NGseTLZoc1wT7EHN5qDIYWMdJjOd7YGv5K/AFQCMkZxcpDb51ryWC22/n2bi1MvkH+b3lhQjwvtwqq05K1nDixUTFqAEcNQDOg=\"}\n";
    NSString *s2 = @"{\"algorithm\": \"RSA\", \"data\": \"-----BEGIN RSA PRIVATE KEY-----\\nMIICXAIBAAKBgQDbTf58ScygpB7tbOSN5/9dZIEBcbKjnwUxW8cWdEo765gGXUsN\\nUQUgThFC4csLsFTvqVhGxn3+WfDIwrvzF/2HWJu8Uvo3LkG3ZGP8US9y2Mvp9VaC\\nWz8ZwyMe4fcWus8dRs8fdTatLeoZVGQDv9SdE2VxuPvJw3gHyR9dOKq37QIDAQAB\\nAoGADLCdbHM3xkbg7EOsEQMO7YhKh7scx2eE/SdupH+7qO53yEx/MojQ517lFE3s\\n+iLss0aFD2lecoihTHiqOAWYG7CfMRg7OaG5Kx7MCZdo/fm28DtiymjpB6nR1SFu\\nmroBWN2rDWHiYBSLeZM8Efh8ONhSue6zMwCIzatBfhrp5JkCQQDfuevIWO9WYRQi\\ndpvDdHzf7uK7ypAs+h90NdJ5P2ihYW7EkSioTu1tskI+d71p/pzTWMd6u/3wWKGV\\n95Yz2wQ5AkEA+vDJToLYObUStmGp+FVsKU4JezHfd831pMcx09nG3d3AIHcJfKx7\\nJzY6k1KVUE3nPHMwhIxEV1AOsOiImU7ZVQJBAKL7b5AZceoMeL2OiHTAJMSB470I\\nmTWa1VU0bGsVzWRbdXVPhj3umbrjNK0LT/qqmJbCwzdfQmRYPQbiQhLux8kCQG4x\\nzISwipkUvcnfK0+E24Fr5lf196bZh7Q7UNMx/9Uv6o2XGFBqQY5fjutgyXbBLvjp\\nsHWUTvJ0km73Pfzslh0CQGLWIE3osF9bLOy7xhLzbVFf3y0yFI/0/pyYvBMZ3yCy\\nw65R9OCcY2PFM2SGEw+nQtopShcpKT0xG30P11TO9oA=\\n-----END RSA PRIVATE KEY-----\"}\n";
    checkX(s1, s2);
}

- (void)testJavaMeta {
    NSLog(@"checking data from Java ...");
    NSString *s1 = @"{\"seed\":\"moky\",\"fingerprint\":\"m76nBPhABBTG4LmLlxzp4s3o2n4EdEsjDE60EHDtQme8gY9mPf7sr41eDbbpmzH2QnNlulh2Jh8ryr99rYnjBFe7o0HtWpOP1ea/kTCZb1qRHKgg0/JvDghYoHAElAdMHWtJMTwxCJIW+ei9HjQ4MZ10oCLmxFwtIN+qokcAcH4=\",\"version\":1,\"key\":{\"mode\":\"ECB\",\"padding\":\"PKCS1\",\"data\":\"-----BEGIN PUBLIC KEY-----\\r\\nMIGJAoGBAMOJODxrdcYaVtEvTMW3KmG3X4xhEor9+LWN03X4WyCk+PHncC4UtvYgMdfHXaL5JZXu\\r\\nPf52UOv5pNM21eo3SnRC2TN+DzwNKnLV83LxMuGMl/CPPmstdQVwg8Ru5NNNnEvtH3TxgmzfDRDm\\r\\ncfFEJp9PF27WfVpr4niWCy7NAHMTAgMBAAE=\\r\\n-----END PUBLIC KEY-----\",\"digest\":\"SHA256\",\"algorithm\":\"RSA\"}}\n";
    NSString *s2 = @"{\"mode\":\"ECB\",\"padding\":\"PKCS1\",\"data\":\"-----BEGIN PUBLIC KEY-----\\r\\nMIGJAoGBAMOJODxrdcYaVtEvTMW3KmG3X4xhEor9+LWN03X4WyCk+PHncC4UtvYgMdfHXaL5JZXu\\r\\nPf52UOv5pNM21eo3SnRC2TN+DzwNKnLV83LxMuGMl/CPPmstdQVwg8Ru5NNNnEvtH3TxgmzfDRDm\\r\\ncfFEJp9PF27WfVpr4niWCy7NAHMTAgMBAAE=\\r\\n-----END PUBLIC KEY-----\\n-----BEGIN RSA PRIVATE KEY-----\\r\\nMIICXgIBAAKBgQDDiTg8a3XGGlbRL0zFtypht1+MYRKK/fi1jdN1+FsgpPjx53AuFLb2IDHXx12i\\r\\n+SWV7j3+dlDr+aTTNtXqN0p0Qtkzfg88DSpy1fNy8TLhjJfwjz5rLXUFcIPEbuTTTZxL7R908YJs\\r\\n3w0Q5nHxRCafTxdu1n1aa+J4lgsuzQBzEwIDAQABAoGATsOUeooS2+S6OfMiqrX4hXoXK/XiQUjC\\r\\niWeC2Y9cLc8mVFMU1gsUFBqt2Sx+pGpV4IoiQMEqIZPi+A2rp3f0LiH3oYpap4rBEJKpHO8dvNAy\\r\\n2yZjAAuwnVBw5Eahdh+vjxVAeblckPP1ktpl9KNJpnLFeT4wToJm7e2o4VZABokCQQDyZfFYiY0O\\r\\nqJQEtf2gAwCQDF/zk2r7HebW0lwhSkD+xup5akaGW5PJArIF2YMMs494DL/ACSlEDME2KhW+69uH\\r\\nAkEAzoIZnx1/E16+UwDQp3UtPL6oIaeVRtz4yjdq7RHBESvVrSi3M3n9artgv8qLyAstRuuw7Hz4\\r\\nlYvWuuGGS1NHFQJBAJ8xhlSwWZxz6GpDn6MT9a2lAus0OQFc/Pq+wtT2MENjHiDJRDH/OMq9427m\\r\\nECQqVSHxtYkIOzq+6bGJ6CgwPEcCQQCD6GqBTpALSWt9DXo6XQjGUmqHBMq/dwqb8IYmZD7UvxFA\\r\\nCE/tW7DZ6lLEb5aV8z26nXZnuPP4YliJCuGDX/B5AkEAyhXbQ2V1Vtf0ouuIEJoUvxlvqVMgKl9k\\r\\npydPVhWIoW4bj2NBnMgkptbt3GuK55NxvUCDfAgVD02VsObeW67L+Q==\\r\\n-----END RSA PRIVATE KEY-----\",\"digest\":\"SHA256\",\"algorithm\":\"RSA\"}\n";
    checkX(s1, s2);
}

@end
