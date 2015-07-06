//
//  StoreKitController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 7/5/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation
import StoreKit


class StoreKitController: NSObject {
    
    private let ProductConfigurationPlist = "purchase-options.plist"
    var productRequestCompletion: (([StoreKitProduct])->Void)?
    var forSaleProducts: [String:SKProduct]?
    
    lazy var configuredProducts: [StoreKitProduct] = {
        return StoreKitProduct.productsFromFile(self.ProductConfigurationPlist)
    }()
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    func validateProductIdentifiers(completion:([StoreKitProduct])->Void) {
        let identifiers = self.configuredProducts.map { (product)  in
            return product.name as NSString
        }
        let productIdentifiers = Set<NSObject>(arrayLiteral: identifiers)
        var request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        self.productRequestCompletion = completion
        request.start()
        
    }
    
    func productListingForIdentifier(identifier: String) -> StoreKitProduct? {
        let results = self.configuredProducts.filter {
            return $0.productID == identifier
        }
        return results.first
    }
    
    func formattedPrice(price: NSDecimalNumber, forLocale locale: NSLocale) -> String {
        var numberFormatter = NSNumberFormatter()
        numberFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
        numberFormatter.locale = locale
        numberFormatter.numberStyle = .CurrencyStyle
        return numberFormatter.stringFromNumber(price)!
    }
    
}

extension StoreKitController: SKProductsRequestDelegate {
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        var forSale = [String:SKProduct]()
        var productListings = [StoreKitProduct]()
        for prod in response.products as! [SKProduct]  {
            let identifier = prod.productIdentifier as String
            forSale[identifier] = prod
            if var prodListing = self.productListingForIdentifier(identifier) {
                prodListing.displayPrice = self.formattedPrice(prod.price, forLocale: prod.priceLocale)
                prodListing.displayPriceValue = prod.price.floatValue
                productListings.append(prodListing)
            }
        }
        self.forSaleProducts = forSale
        self.productRequestCompletion?(productListings)
    }
}