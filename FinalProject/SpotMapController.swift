
//
//  SpotMapController.swift
//  FinalProject
//
//  Created by Labuser on 7/27/16.
//  Copyright © 2016 wustl. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import AddressBookUI

class SkateSpotController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSearch: UISearchBar!
    
    @IBAction func currentButton(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
    
    
    @IBAction func changeMap(_ sender: AnyObject) {
        
        print(sender.selectedSegmentIndex.description)
        
        if(sender.selectedSegmentIndex.description == "1") {
            mapView.mapType = MKMapType.satellite
        } else {
            mapView.mapType = MKMapType.standard
        }
        
    }
    
    let locationManager = CLLocationManager()
    var regionChange = false
    var address = ""
    var geocoder = CLGeocoder()
    var selectedAnnotation: MKPointAnnotation!
    var spotArray:[Spot] = []
    var searching = false
    var tempCoordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var pinAddress = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapSearch.showsScopeBar = true
        mapSearch.delegate = self
        mapSearch.showsCancelButton = true
        
        mapView.delegate = self
        
        loadSpots()
        addPin()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
    
    //allow the map to move around
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let tempView = mapView.subviews.first
        let listOfGestures = tempView!.gestureRecognizers
        for recognizer in listOfGestures! {
            if recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended {
                self.regionChange = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.regionChange {
            self.regionChange = false
            locationManager.stopUpdatingLocation()
        }
    }
    
    //add annotation
    func addPin() {
        
        let pinLocationRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        pinLocationRecognizer.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(pinLocationRecognizer)
    }
    
    //finds coordinate of long press
    func handleLongPress(_ locationRecognizer:UIGestureRecognizer) {
        if locationRecognizer.state != .began{
            return
        }
        locationManager.stopUpdatingLocation()
        
        let point: CGPoint = locationRecognizer.location(in: mapView)
        let coordinate:CLLocationCoordinate2D = mapView.convert(point, toCoordinateFrom: mapView)
        
        tempCoordinates = coordinate
        
        let pin:MKPointAnnotation = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "Add spot?"
        
        mapView.addAnnotation(pin)
        centerAtPoint(coordinate)
    }
    
    //add buttons to annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view?.canShowCallout = true
            
            //add spot
            view?.rightCalloutAccessoryView = UIButton(type: .contactAdd)
            
            //delete button
//            let button = UIButton(frame: CGRectMake(0, 0, 70, 30))
//            button.backgroundColor = UIColor.redColor()
//            button.layer.cornerRadius = 10
//            button.clipsToBounds = true
//            view?.leftCalloutAccessoryView = button
            
            //info button
            view?.leftCalloutAccessoryView = UIButton(type: .infoLight)
        }
        else {
            view?.annotation = annotation
        }
        return view
    }
    
    //annotation is tapped
    func mapView(_ mapView: MKMapView, annotationView view:MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            selectedAnnotation = view.annotation as? MKPointAnnotation
            reverseGeoCode(tempCoordinates)
            

        }
        if control == view.leftCalloutAccessoryView {
            selectedAnnotation = view.annotation as? MKPointAnnotation
        }
    }
    
    //segue for adding new spot
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "addSpot" == segue.identifier {
            
            let destinationVC = segue.destination as! NewSpotViewController
            destinationVC.addressFromCoord = pinAddress
        }
        if "viewSpot" == segue.identifier {
            
            
            
            
        }
    }
    
    //move map view region around a coordinate point as the center
    func centerAtPoint(_ center: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    //set mapview as current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
    }
    
    //search bar implementation
    func searchBarSearchButtonClicked(_ mapSearch: UISearchBar) {
        searching = true
        mapSearch.resignFirstResponder()
        if mapSearch.text != nil{
            address = mapSearch.text!
        }
        locationManager.stopUpdatingLocation()
        
        forwardGeocode(address)
        
    }
    
    func searchBarCancelButtonClicked(_ mapSearch: UISearchBar) {
        mapSearch.text = ""
        mapSearch.resignFirstResponder()
    }
    
    //forward geocoding
    func forwardGeocode(_ anAddress: String){
        
        geocoder.geocodeAddressString(anAddress, completionHandler: {(placemarks, error) ->  Void in
            if((error) != nil){
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coord = placemark.location!.coordinate
                if (self.searching == true) {
                    self.centerAtPoint(coord)
                    self.searching = false
                }
                else {
                    self.passCoordinates(coord)
                }
            }
        })
        
    }
    
    //reverse geocoding
    func reverseGeoCode(_ coordinate: CLLocationCoordinate2D) {
        
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error \(error!.localizedDescription)")
                return
            }
            
            if (placemarks!.count > 0) {
                let pm = placemarks![0]
                let address = ABCreateStringWithAddressDictionary(pm.addressDictionary!, false)
            
                self.pinAddress = address
                self.performSegue(withIdentifier: "addSpot", sender: self)
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    
    
    //load in all spots from database
    func loadSpots() {
        let id = UserDefaults.standard.value(forKey: "userID_session") as! String
        
        let ref = FIRDatabase.database().reference().child("Spots")
        
        ref.observe(FIRDataEventType.value, with: {(snapshot) in
            if let info = snapshot.value as? [String: NSDictionary]{
            
            self.spotArray = []
            for entry in info{
                let creator = entry.1.value(forKey: "Creator") as! String
                let theName = entry.1.value(forKey: "Name") as? String
                
                let theTotalScore = entry.1.value(forKey: "TotalScore") as? Double
                let theTotalRatings = entry.1.value(forKey: "TotalRatings") as? Int
                
                var type1 = ""
                if let types = entry.1.value(forKey: "Type") as? String{
                    type1 = types
                }else{
                    type1 = ""
                }
                
                var add = ""
                if let address = entry.1.value(forKey: "Address") as? String{
                    add = address
                }else{
                    add = ""
                }
                
                
                let theRating = theTotalScore! / Double (theTotalRatings!)
                
                
                let spot1 = Spot(name: theName!, rating: theRating, distance: 0.5, type: type1, totalRatings: theTotalRatings!, totalScore: theTotalScore!, address: add)
                
                self.spotArray.append(spot1)
                
                self.forwardGeocode(spot1.address)
                print(spot1.name)
            }
            }
        })
        
      
    }
    
    //pass coordinates
    func passCoordinates(_ coord: CLLocationCoordinate2D) {
        addSkateSpots(coord)
    }
    
    //add pin without press
    func addSkateSpots(_ coordinates: CLLocationCoordinate2D) {
        let skateSpot:MKPointAnnotation = MKPointAnnotation()
        skateSpot.coordinate = coordinates
        skateSpot.title = "SkateSpot"
        
        mapView.addAnnotation(skateSpot)
    }
    
    
    
    
}
