//
//  StoreKitPaymentObserver.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 7/11/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation
import StoreKit

enum StoreKitPurchaseResultType: String {
    case Completed = "StoreKitPurchaseNotificationCompleted"
    case Deferred = "StoreKitPurchaseNotificationDeferred"
    case Failed = "StoreKitPurchaseNotificationFailed"
    case InProgress = "StoreKitPurchaseNotificationInProgress"
}

let StoreKitPurchaseNotificationName = "StoreKitPurchaseNotificationName"
let StoreKitPurchaseResultTypeKey = "StoreKitPurchaseResultTypeKey"
let StoreKitPurchaseErrorUserInfoKey = "StoreKitPurchaseErrorUserInfoKey"

class StoreKitPaymentObserver: NSObject, SKPaymentTransactionObserver {

    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Payment queue observer have updated transaction info!")
        var notification: StoreKitPurchaseResultType?
        var havePurchases = false
        var lastTransactionError: NSError?
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased:
                let productId = transaction.payment.productIdentifier
                AppController.appController.appConfiguration.purchaseStatus = NSNumber(integer: SKPaymentTransactionState.Purchased.rawValue)
                AppController.appController.appConfiguration.purchasedProduct = productId
                havePurchases = true
                notification = .Completed
            case .Restored:
                let productId = transaction.originalTransaction!.payment.productIdentifier
                AppController.appController.appConfiguration.purchaseStatus = NSNumber(integer: SKPaymentTransactionState.Purchased.rawValue)
                AppController.appController.appConfiguration.purchasedProduct = productId
                print("restored product id: \(productId)")
                havePurchases = true
                notification = .Completed
            case .Deferred:
                AppController.appController.appConfiguration.purchaseStatus = NSNumber(integer: SKPaymentTransactionState.Deferred.rawValue)
                notification = .Deferred
            case .Failed:
                if !havePurchases {
                    AppController.appController.appConfiguration.purchaseStatus = NSNumber(integer: SKPaymentTransactionState.Failed.rawValue)
                    AppController.appController.appConfiguration.lastTransactionError = transaction.error?.localizedDescription
                    lastTransactionError = transaction.error
                    notification = .Failed
                }
            case .Purchasing:
                AppController.appController.appConfiguration.purchaseStatus = NSNumber(integer: SKPaymentTransactionState.Purchasing.rawValue)
            }
            AppController.appController.appConfiguration.save()
            if transaction.transactionState != .Deferred && transaction.transactionState != .Purchasing {
                queue.finishTransaction(transaction)
                if transactions.count == 1 {
                    self.postNotification(notification!, error: transaction.error)
                }
            }
        }
        if havePurchases {
            AppController.appController.appConfiguration.purchaseStatus = NSNumber(integer: SKPaymentTransactionState.Purchased.rawValue)
            self.postNotification(.Completed, error: nil)
        } else if let transactionError = lastTransactionError {
            AppController.appController.appConfiguration.purchaseStatus = NSNumber(integer: SKPaymentTransactionState.Failed.rawValue)
            self.postNotification(.Failed, error: transactionError)
        }
        
    }
    
    func postNotification(notificationType: StoreKitPurchaseResultType, error: NSError?) {
        var userInfo = [NSObject : AnyObject]()
        userInfo[StoreKitPurchaseResultTypeKey] = notificationType.rawValue
        if let error = error {
            userInfo[StoreKitPurchaseErrorUserInfoKey] = error
        }
        let notification = NSNotification(name: StoreKitPurchaseNotificationName, object: nil, userInfo: userInfo)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotification(notification)
        })
    }
    
}
