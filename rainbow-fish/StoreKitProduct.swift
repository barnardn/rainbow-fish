//
//  StoreKitProduct.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 7/5/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation

struct StoreKitProduct {
    
    fileprivate enum StoreKitPlistKey: String {
        case ProductId = "productID"
        case Name = "name"
        case Summary = "summary"
        case Details = "details"
    }
    
    var productID = ""
    var name = ""
    var summary = ""
    var details: String?
    var displayPrice = ""
    var displayPriceValue: Float = 0.0      // used for sorting!
    var isAvailableForSale = false
    
    static func productsFromFile(_ fileName: String) -> [StoreKitProduct] {
        var results =  [StoreKitProduct]()
        if  let url = Bundle.main.url(forResource: "purchase-options", withExtension: ".plist"),
            let plist = NSDictionary(contentsOf: url) as? Dictionary<String, AnyObject>,
            let options = plist["Options"] as? Array<Dictionary<String,AnyObject>> {

                for option in options {
                    var skProduct = StoreKitProduct()
                    skProduct.productID = option[StoreKitPlistKey.ProductId.rawValue] as! String
                    skProduct.name = option[StoreKitPlistKey.Name.rawValue] as! String
                    skProduct.summary = option[StoreKitPlistKey.Summary.rawValue] as! String
                    skProduct.details = option[StoreKitPlistKey.Details.rawValue] as? String
                    results.append(skProduct)
                }
        }
        return results
    }
    
}

extension StoreKitProduct: CustomStringConvertible {
    var description: String {
        return "\(self.name) @ \(self.displayPrice) available for sale: \(self.isAvailableForSale)"
    }
}
