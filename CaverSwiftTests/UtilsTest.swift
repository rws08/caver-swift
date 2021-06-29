//
//  UtilsTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/06/23.
//

import XCTest
@testable import CaverSwift
@testable import BigInt
@testable import ASN1

class isAddressTest: XCTestCase {
    func testLowerCaseAddressTest() throws {
        let lowercase = ["0xff6916ea19a50878e39c41aaadfeb0cab1b41dad",
                         "0x4834113481fbbac68565987d30f5216bc5719d3b",
                         "ff6916ea19a50878e39c41aaadfeb0cab1b41dad",
                         "4834113481fbbac68565987d30f5216bc5719d3b"]
        for item in lowercase {
            XCTAssertTrue(Utils.isAddress(item), "fail : \(item)")
        }
    }
    
    func testUpperCaseAddressTest() throws {
        let uppercase = ["0xFF6916EA19A50878E39C41AAADFEB0CAB1B41DAD",
                         "0x4834113481FBBAC68565987D30F5216BC5719D3B",
                         "4834113481FBBAC68565987D30F5216BC5719D3B",
                         "FF6916EA19A50878E39C41AAADFEB0CAB1B41DAD"]
        for item in uppercase {
            XCTAssertTrue(Utils.isAddress(item), "fail : \(item)")
        }
    }
    
    func testChecksumAddressTest() throws {
        let checksumAddress = ["0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB",
                               "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb",
                               "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359",
                               "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed"]
        for item in checksumAddress {
            XCTAssertTrue(Utils.isAddress(item), "fail : \(item)")
        }
    }
    
    func testInvalidAddressTest() throws {
        let checksumAddress = ["0xff6916ea19a50878e39c41cab1b41da",// Length is not 40
                               "0xKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK", // Not Hex String
                               "0x2058a550ea824841e991ef386c3aD63D088303B3"] // Invalid checksum address.
        for item in checksumAddress {
            XCTAssertFalse(Utils.isAddress(item), "fail : \(item)")
        }
    }
}

class isValidPrivateKeyTest: XCTestCase {
    func testValidPrivateKey() throws {
        let key = PrivateKey.generate().privateKey
        XCTAssertTrue(Utils.isValidPrivateKey(key))
    }
    
    func testInvalidPrivateKey() throws {
        let keys = ["0xff6916ea19a50878e39c41cab1b41d0xff6916ea19a50878e39c41cab1bdd41dK",// Length is not 64
                    "0xff6916ea19a50878e39c41cab1b41d0xff6916ea19a50878e39c41cab1bdd4KK"] // Not Hex String
        for item in keys {
            XCTAssertFalse(Utils.isValidPrivateKey(item), "fail : \(item)")
            XCTAssertFalse(Utils.isAddress(item), "fail : \(item)")
        }
    }
}

class isKlaytnWalletKeyTest: XCTestCase {
    func testValidWalletKey() throws {
        guard let walletKey = try? KeyringFactory.generate().getKlaytnWalletKey() else { return }
        XCTAssertTrue(Utils.isKlaytnWalletKey(walletKey))
    }
    
    func testInValidWalletKey() throws {
        let keys = ["0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a6433098481" + "0x01" + "0xfc26de905386050894cddbb5a824318b96dde595", // invalid type
                    "0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a6433098481" + "0xfc26de905386050894cddbb5a824318b96dde595", // no Type
                    "0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a6433098481" + "0x00" + "0xfc26de905386050894cddbb5a824318b96dde59", // invalid address - invalid length
                    "0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a6433098481" + "0x00" + "fc26de905386050894cddbb5a824318b96dde595", // invalid address - no prefix
                    "0x63526af77dc34846a0909e5486f972c4a07074f0c94a2b9575a6433098481" + "0x00" + "0xfc26de905386050894cddbb5a824318b96dde595", // invalid privateKey - invalid length
                    "63526af77dc34846a0909e5486f972c4a07074f0c94a2b9577675a6433098481" + "0x00" + "0xfc26de905386050894cddbb5a824318b96dde595"] // invalid type - no prefix
        for item in keys {
            XCTAssertFalse(Utils.isAddress(item), "fail : \(item)")
        }
    }
}

class isValidPublicKeyTest: XCTestCase {
    func testUncompressedKey() throws {
        guard let key = try? KeyringFactory.generate().getPublicKey() else { return }
        XCTAssertTrue(Utils.isValidPublicKey(key))
    }
    
    func testUncompressedKeyWithTag() throws {
        let key = "0x04019b186993b620455077b6bc37bf61666725d8d87ab33eb113ac0414cd48d78ff46e5ea48c6f22e8f19a77e5dbba9d209df60cbcb841b7e3e81fe444ba829831"
        XCTAssertTrue(Utils.isValidPublicKey(key))
    }
    
    func testCompressedKey() throws {
        guard let key = try? KeyringFactory.generate().getPublicKey(),
              let key = try? Utils.compressPublicKey(key) else { return }
        
        XCTAssertTrue(Utils.isValidPublicKey(key))
    }
    
    func testInvalidLength_UncompressedKey() throws {
        let key = "0a7694872b7f0862d896780c476eefe5dcbcab6145853401f95a610bbbb0f726c1013a286500f3b524834eaeb383d1a882e16f4923cef8a5316c33772b3437"
        XCTAssertFalse(Utils.isValidPublicKey(key))
    }
    
    func testInvalidLength_CompressedKey() throws {
        let key = "0x03434dedfc2eceed1e98fddfde3ebc57512c57f017195988cd5de62b722656b93"
        XCTAssertFalse(Utils.isValidPublicKey(key))
    }
    
    func testInvalidIndicator_CompressedKey() throws {
        let key = "0x05434dedfc2eceed1e98fddfde3ebc57512c57f017195988cd5de62b722656b943"
        XCTAssertFalse(Utils.isValidPublicKey(key))
    }
    
    func testInvalidPoint() throws {
        let key = "0x4be11ff42d8fc1954fb9ed52296db1657564c5e38517764664fb7cf4306a1e163a2686aa755dd0291aa2f291c3560ef4bf4b46c671983ff3e23f11a1b744ff4a"
        XCTAssertFalse(Utils.isValidPublicKey(key))
    }
}

class decompressPublicKeyTest: XCTestCase {
    func testDecompressPublicKey() throws {
        let compressed = "03434dedfc2eceed1e98fddfde3ebc57512c57f017195988cd5de62b722656b943"
        guard let uncompressed = try? Utils.decompressPublicKey(compressed) else { return }
        
        XCTAssertTrue(Utils.isValidPublicKey(uncompressed))
    }
    func testAlreadyDecompressedKey() throws {
        guard let expectedUncompressed = try? PrivateKey.generate().getPublicKey(false),
              let actualUncompressed = try? Utils.decompressPublicKey(expectedUncompressed) else { return }
        
        XCTAssertTrue(Utils.isValidPublicKey(actualUncompressed))
        XCTAssertEqual(expectedUncompressed, actualUncompressed)
    }
    func testAlreadyDecompressedKeyWithTag() throws {
        let expected = "0x04019b186993b620455077b6bc37bf61666725d8d87ab33eb113ac0414cd48d78ff46e5ea48c6f22e8f19a77e5dbba9d209df60cbcb841b7e3e81fe444ba829831"
        guard let uncompressed = try? Utils.decompressPublicKey(expected) else { return }
        
        XCTAssertEqual(expected, uncompressed)
    }
}

class compressPublicKeyTest: XCTestCase {
    func testCompressPublicKey() throws {
        guard let uncompressed = try? PrivateKey.generate().getPublicKey(false),
              let compressed = try? Utils.compressPublicKey(uncompressed) else { return }
        
        XCTAssertTrue(Utils.isValidPublicKey(compressed))
    }
    func testAlreadyCompressedKey() throws {
        guard let expectedCompressed = try? PrivateKey.generate().getPublicKey(true),
              let actualCompressed = try? Utils.compressPublicKey(expectedCompressed) else { return }
        
        XCTAssertTrue(Utils.isValidPublicKey(actualCompressed))
        XCTAssertEqual(expectedCompressed, actualCompressed)
    }
    func testAlreadyCompressedKeyWithTag() throws {
        let key = "0x04019b186993b620455077b6bc37bf61666725d8d87ab33eb113ac0414cd48d78ff46e5ea48c6f22e8f19a77e5dbba9d209df60cbcb841b7e3e81fe444ba829831"
        guard let expected = try? Utils.compressPublicKey("019b186993b620455077b6bc37bf61666725d8d87ab33eb113ac0414cd48d78ff46e5ea48c6f22e8f19a77e5dbba9d209df60cbcb841b7e3e81fe444ba829831"),
              let compressed = try? Utils.compressPublicKey(key) else { return }
        
        XCTAssertEqual(expected, compressed)
    }
}
