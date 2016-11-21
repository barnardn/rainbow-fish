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
    
    fileprivate let ProductConfigurationPlist = "purchase-options.plist"
    var productRequestCompletion: (([StoreKitProduct])->Void)?
    var forSaleProducts: [String:SKProduct]?
    
    lazy var configuredProducts: [StoreKitProduct] = {
        return StoreKitProduct.productsFromFile(self.ProductConfigurationPlist)
    }()
    
    lazy var restorePurchasesProduct: StoreKitProduct = {
        var restoreProduct = StoreKitProduct()
        restoreProduct.name = NSLocalizedString("Restore Previous Purchases", comment:"restore previous purchase product name")
        restoreProduct.summary = NSLocalizedString("Choose this option to restore your previous purchase of Rainbow Fish", comment:"restore product summary")
        restoreProduct.displayPriceValue = 0.0
        restoreProduct.displayPrice = NSLocalizedString("Free", comment:"restore product display price of Free")
        return restoreProduct
    }()
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    func validateProductIdentifiers(_ completion:@escaping ([StoreKitProduct])->Void) {
        let identifiers = self.configuredProducts.map { (product)  in
            return product.productID as String
        }
        let productIdentifiers = Set(identifiers)
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        self.productRequestCompletion = completion
        request.start()
    }
    
    func productListingForIdentifier(_ identifier: String) -> StoreKitProduct? {
        let results = self.configuredProducts.filter {
            return $0.productID == identifier
        }
        return results.first
    }
    
    func skProduct(forProduct product: StoreKitProduct) -> SKProduct? {
        return self.forSaleProducts?[product.productID]
    }
    
    func formattedPrice(_ price: NSDecimalNumber, forLocale locale: Locale) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = NumberFormatter.Behavior.behavior10_4
        numberFormatter.locale = locale
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: price)!
    }
    
}

extension StoreKitController: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        var forSale = [String:SKProduct]()
        var productListings = [StoreKitProduct]()
        for prod in response.products {
            let identifier = prod.productIdentifier as String
            forSale[identifier] = prod
            if var prodListing = self.productListingForIdentifier(identifier) {
                prodListing.displayPrice = self.formattedPrice(prod.price, forLocale: prod.priceLocale)
                prodListing.displayPriceValue = prod.price.floatValue
                prodListing.name = prod.localizedTitle
                prodListing.summary = prod.localizedDescription
                productListings.append(prodListing)
            }
        }
        self.forSaleProducts = forSale
        self.productRequestCompletion?(productListings)
    }
}
