//
//  StoreKitPaymentObserver.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 7/11/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation
import StoreKit

enum StoreKitPurchaseNotification: String {
    case Completed = "StoreKitPurchaseNotificationCompleted"
    case Derferred = "StoreKitPurchaseNotificationDeferred"
    case Failed = "StoreKitPurchaseNotificationFailed"
    case InProgress = "StoreKitPurchaseNotificationInProgress"
}

let StoreKitPurchaseErrorUserInfoKey = "StoreKitPurchaseErrorUserInfoKey"

class StoreKitPaymentObserver: NSObject, SKPaymentTransactionObserver {

    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction in transactions as! [SKPaymentTransaction] {
            switch transaction.transactionState {
            case .Purchased, .Restored:
                let productId = transaction.payment.productIdentifier
                AppController.appController.appConfiguration.purchaseStatus = NSNumber(integer: SKPaymentTransactionState.Purchased.rawValue)
                AppController.appController.appConfiguration.purchasedProduct = productId
            case .Deferred:
                AppController.appController.appConfiguration.purchaseStatus = NSNumber(integer: SKPaymentTransactionState.Deferred.rawValue)
            case .Failed:
                AppController.appController.appConfiguration.purchaseStatus = NSNumber(integer: SKPaymentTransactionState.Failed.rawValue)
                AppController.appController.appConfiguration.lastTransactionError = transaction.error.localizedDescription
            case .Purchasing:
                AppController.appController.appConfiguration.purchaseStatus = NSNumber(integer: SKPaymentTransactionState.Purchasing.rawValue)
            }
            queue.finishTransaction(transaction)
        }
    }
    
    func PostNotification(notificationType: StoreKitPurchaseNotification, error: NSError?) {
        var notification = NSNotification(name: notificationType.rawValue, object: nil)
        if let error = error {
            notification = NSNotification(name: notificationType.rawValue, object: nil, userInfo: [StoreKitPurchaseErrorUserInfoKey : error])
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotification(notification)
        })
    }
    
}
