//
//  ViewController.swift
//  MKDemo
//
//  Created by Gene Backlin on 9/17/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//

import UIKit
import MapKit

enum MapType: Int {
    case standard = 0
    case satellite = 1
    case hybrid = 2
}

protocol MapKitDirectionsDelegate {
    func getDirections(to destination: CLLocationCoordinate2D)
}

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var locationManager = CLLocationManager()
    var isLocationManagerProvidingUpdates = true
    var currentLocation: CLLocationCoordinate2D?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView?.showsUserLocation = true
        requestLocationAccess()
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: false)
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = false
    }
    
    @IBAction func setMapType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case MapType.standard.rawValue:
            mapView.mapType = .standard
        case MapType.satellite.rawValue:
            mapView.mapType = .satellite
        case MapType.hybrid.rawValue:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard
        }
    }
    
    
    @IBAction func startStopLocationUpdates(_ sender: UIButton) {
        if isLocationManagerProvidingUpdates == true {
            isLocationManagerProvidingUpdates = false
            mapView.showsUserLocation = false
            locationManager.stopUpdatingLocation()
            sender.setTitle("Start", for: .normal)
        } else {
            isLocationManagerProvidingUpdates = true
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            sender.setTitle("Stop", for: .normal)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAnnotationDetail" {
            let annotationView: MKAnnotationView? = sender as? MKAnnotationView
            
            if let annotation: CustomAnnotation = annotationView!.annotation as? CustomAnnotation {
                let controller: CustomAnnotationCalloutViewController = segue.destination as! CustomAnnotationCalloutViewController
                controller.popoverPresentationController!.delegate = self
                controller.popoverPresentationController?.sourceView = sender as? UIView
                controller.preferredContentSize = CGSize(width: 250, height: 200)

                controller.annotation = annotation
                controller.delegate = self
            }
        }
    }
    
    // MARK: - Utility
    
    func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
            
        case .denied, .restricted:
            print("location access denied")
            
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {[weak self] (response, error) in
            if let results = response {
                if let err = error {
                    print("Error occurred in search: \(err.localizedDescription)")
                } else if results.mapItems.count == 0 {
                    print("No matches found")
                } else {
                    print("Matches found")
                    
                    for item in results.mapItems {
                        print("Name = \(item.name ?? "No match")")
                        print("Phone = \(item.phoneNumber ?? "No Match")")
                        
                        self!.matchingItems.append(item as MKMapItem)
                        print("Matching items = \(self!.matchingItems.count)")
                        
                        //let annotation = MKPointAnnotation()
                        let annotation = CustomAnnotation(coordinate: item.placemark.coordinate)
                        //annotation.coordinate = item.placemark.coordinate
                        annotation.title = item.name
                        annotation.url = item.url
                        if let phoneNumber = item.phoneNumber {
                            annotation.subtitle = "\(phoneNumber)"
                            annotation.phoneNumber = phoneNumber
                        } else {
                            annotation.subtitle = ""
                        }
                        self!.mapView.addAnnotation(annotation)
                    }
                    self!.mapView.showAnnotations(self!.mapView.annotations, animated: true)
                }
            }
        })
    }
    
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        debugPrint("popoverPresentationControllerDidDismissPopover")
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        mapView.removeAnnotations(mapView.annotations)
        performSearch()
        return true
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
        -> MKAnnotationView? {
            
            let identifier = "marker"
            var view: MKMarkerAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            let rightButton = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = rightButton
            view.canShowCallout = true
            
            return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let _: CustomAnnotation = view.annotation as? CustomAnnotation {
            performSegue(withIdentifier: "ShowAnnotationDetail", sender: view)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }

}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location!.coordinate
    }
}

extension ViewController: MapKitDirectionsDelegate {
    func getDirections(to destination: CLLocationCoordinate2D) {
        let source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation!))
        source.name = "Source"
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        destination.name = "Destination"
        
        MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
