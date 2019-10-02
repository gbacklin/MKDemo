//
//  CustomAnnotation.swift
//  MKDemo
//
//  Created by Gene Backlin on 9/17/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var subtitle: String?
    var phoneNumber: String?
    var url: URL?
    var imageName: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
