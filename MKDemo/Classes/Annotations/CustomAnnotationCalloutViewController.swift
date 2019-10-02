//
//  CustomAnnotationCalloutViewController.swift
//  MKDemo
//
//  Created by Gene Backlin on 9/17/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotationCalloutViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneNumberTextView: UITextView!
    
    var annotation: CustomAnnotation?
    var url: URL?
    var delegate: MapKitDirectionsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let phoneNumber = annotation!.phoneNumber {
            phoneNumberTextView.insertText(phoneNumber)
        }
        titleLabel.text = annotation?.title
        url = annotation!.url
    }
    
    @IBAction func visitWebSite(_ sender: UIButton) {
        if let webURL = url {
            websiteButton.isEnabled = true
            if let link = URL(string: webURL.absoluteString) {
              UIApplication.shared.open(link)
            }
        } else {
            websiteButton.isEnabled = false
        }
    }

    @IBAction func getDirections(_ sender: UIButton) {
        delegate?.getDirections(to: annotation!.coordinate)
        dismiss(animated: true, completion: nil)
    }
}
