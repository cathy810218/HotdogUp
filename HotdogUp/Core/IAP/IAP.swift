//
//  IAP.swift
//  HotdogUp
//
//  Created by Cathy Oun on 9/18/25.
//  Copyright © 2025 Cathy Oun. All rights reserved.
//

import StoreKit


protocol IAP {
    var removeAdsProductID: String { get }
    func products() async throws -> [Product]
    func purchaseRemoveAds() async throws -> Transaction?
    func hasPurchasedRemoveAds() async -> Bool
}


final class StoreKit2Service: IAP {
    let removeAdsProductID = "com.hotdogup.removeads"


    func products() async throws -> [Product] {
        try await Product.products(for: [removeAdsProductID])
    }


    func purchaseRemoveAds() async throws -> Transaction? {
        let items = try await products()
        guard let product = items.first else { return nil }
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let t: Transaction = try checkVerified(verification)
            await t.finish()
            return t
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }


    func hasPurchasedRemoveAds() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, t.productID == removeAdsProductID { return true }
        }
        return false
    }


    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let safe): return safe
        }
    }
}
