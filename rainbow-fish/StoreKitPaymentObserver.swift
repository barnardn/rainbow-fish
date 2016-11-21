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

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Payment queue observer have updated transaction info!")
        var notification: StoreKitPurchaseResultType?
        var havePurchases = false
        var lastTransactionError: NSError?
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                let productId = transaction.payment.productIdentifier
                AppController.appController.appConfiguration.purchaseStatus = NSNumber(value: SKPaymentTransactionState.purchased.rawValue as Int)
                AppController.appController.appConfiguration.purchasedProduct = productId
                havePurchases = true
                notification = .Completed
            case .restored:
                let productId = transaction.original!.payment.productIdentifier
                AppController.appController.appConfiguration.purchaseStatus = NSNumber(value: SKPaymentTransactionState.purchased.rawValue as Int)
                AppController.appController.appConfiguration.purchasedProduct = productId
                print("restored product id: \(productId)")
                havePurchases = true
                notification = .Completed
            case .deferred:
                AppController.appController.appConfiguration.purchaseStatus = NSNumber(value: SKPaymentTransactionState.deferred.rawValue as Int)
                notification = .Deferred
            case .failed:
                if !havePurchases {
                    AppController.appController.appConfiguration.purchaseStatus = NSNumber(value: SKPaymentTransactionState.failed.rawValue as Int)
                    AppController.appController.appConfiguration.lastTransactionError = transaction.error?.localizedDescription
                    lastTransactionError = transaction.error as NSError?
                    notification = .Failed
                }
            case .purchasing:
                AppController.appController.appConfiguration.purchaseStatus = NSNumber(value: SKPaymentTransactionState.purchasing.rawValue as Int)
            }
            AppController.appController.appConfiguration.save()
            if transaction.transactionState != .deferred && transaction.transactionState != .purchasing {
                queue.finishTransaction(transaction)
                if transactions.count == 1 {
                    self.postNotification(notification!, error: transaction.error as NSError?)
                }
            }
        }
        if havePurchases {
            AppController.appController.appConfiguration.purchaseStatus = NSNumber(value: SKPaymentTransactionState.purchased.rawValue as Int)
            self.postNotification(.Completed, error: nil)
        } else if let transactionError = lastTransactionError {
            AppController.appController.appConfiguration.purchaseStatus = NSNumber(value: SKPaymentTransactionState.failed.rawValue as Int)
            self.postNotification(.Failed, error: transactionError)
        }
        
    }
    
    func postNotification(_ notificationType: StoreKitPurchaseResultType, error: NSError?) {
        var userInfo = [AnyHashable: Any]()
        userInfo[StoreKitPurchaseResultTypeKey] = notificationType.rawValue
        if let error = error {
            userInfo[StoreKitPurchaseErrorUserInfoKey] = error
        }
        let notification = Notification(name: Notification.Name(rawValue: StoreKitPurchaseNotificationName), object: nil, userInfo: userInfo)
        DispatchQueue.main.async(execute: { () -> Void in
            NotificationCenter.default.post(notification)
        })
    }
    
}
