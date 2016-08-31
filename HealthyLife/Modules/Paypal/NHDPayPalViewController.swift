//
//  NHDPayPalViewController.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 28/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

class NHDPayPalViewController: BaseViewController {

    var id: String?
    var name: String!
    var price = "0"
    var payPalConfig = PayPalConfiguration() // default
    
    @IBOutlet weak var successView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: - Enter your credentials
        PayPalMobile.initializeWithClientIdsForEnvironments([
            PayPalEnvironmentProduction: "AX8p3N-96A-O7vQ1RcbgGBJEY658IQRRSq4JQXWtdd6tnF5dJsOoKVA41KJ_cxAkId_dlcJtO66GDFrC",
            PayPalEnvironmentSandbox: "AYSLFRcRD3krd7Zp4uFyUkihz9izLDezjKwkQpxSjvndhf0u-p2kCrkcGNk3I7Xfe-BhWsdGKwaSzHfs"
            ])
        
        PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentSandbox)
        
        setupUIs()
        setupPaypal()
    }
    
    func setupUIs() {
        self.successView.hidden = true
        title = "Connect with Paypal"
    }

    func setupPaypal() {
        
        showLoading()
        
        // Optional: include multiple items
        let item1 = PayPalItem(name: name, withQuantity: 1, withPrice: NSDecimalNumber(string: price), withCurrency: "USD", withSku: "")
        
        let items = [item1]
        let subtotal = PayPalItem.totalPriceForItems(items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "0.00")
        let tax = NSDecimalNumber(string: "0.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.decimalNumberByAdding(shipping).decimalNumberByAdding(tax)
        
        let shortDescription = "Buy " + name
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: shortDescription, intent: .Sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            
            navigationController?.presentViewController(paymentViewController!, animated: true, completion: nil)
        }
        else {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn't be processable, and you'd want
            // to handle that here.
            print("Payment not processalbe: \(payment)")
            hideLoading()
            navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @IBAction func onBack(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension NHDPayPalViewController: PayPalPaymentDelegate {
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController, didCompletePayment completedPayment: PayPalPayment) {
        
        print("PayPal Payment Success !")
        paymentViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            self.successView.hidden = false
            self.hideLoading()
        })
    }
    
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController) {
        
        showLoading()
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
