//
//  PollingTransactionReceiptProcessor.swift
//  CaverSwift
//
//  Created by won on 2021/07/20.
//

import Foundation

open class PollingTransactionReceiptProcessor: TransactionReceiptProcessor {
    let sleepDuration: Int // ms (1sec = 1000ms)
    let attempts: Int
    
    internal init(_ caver: Caver, _ sleepDuration: Int, _ attempts: Int) {
        self.sleepDuration = sleepDuration
        self.attempts = attempts
        super.init(caver)
    }
    
    public override func waitForTransactionReceipt(_ transactionHash: String) throws -> TransactionReceiptData? {
        return try getTransactionReceipt(transactionHash, sleepDuration, attempts)
    }
    
    private func getTransactionReceipt(_ transactionHash: String, _ sleepDuration: Int, _ attempts: Int) throws -> TransactionReceiptData? {
        var receiptOptional = try? sendTransactionReceiptRequest(transactionHash)
        
        for _ in (0..<attempts) {
            if receiptOptional == nil {
                do {
                    usleep(useconds_t(sleepDuration * 1000))
                }
            
                receiptOptional = try? sendTransactionReceiptRequest(transactionHash)
            } else {
                return receiptOptional
            }
        }
        
        throw CaverError.TransactionException("Transaction receipt was not generated after \((sleepDuration * attempts) / 1000) seconds for transaction: \(transactionHash)", transactionHash)
    }
}