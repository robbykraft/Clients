//
//  ExposureQueryView.swift
//  Allergy
//
//  Created by Robby Kraft on 5/15/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit
//import MapKit
//import CoreLocation

class ExposureQueryView: UIView {
//class ExposureQueryView: UIView, MKMapViewDelegate {
//	let mapView = MKMapView()
//	let locationManager = CLLocationManager.init()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initUI()
	}
	convenience init() {
		self.init(frame: CGRect.zero)
	}
	required init(coder aDecoder: NSCoder) {
		fatalError("This class does not support NSCoding")
	}
	
	func initUI(){
//		locationManager.requestWhenInUseAuthorization()
//		mapView.delegate = self
//		mapView.mapType = .satellite
//		mapView.showsUserLocation = true
//		mapView.showsScale = true
//		mapView.showsCompass = true
//		self.addSubview(mapView)

//		mapView.setCenter(CLLocationCoordinate2DMake(40.6877609761811, -73.989780480111), animated: true)
	}
	override func layoutSubviews() {
		super.layoutSubviews()
//		let mapW:CGFloat = self.bounds.size.height - 20
//		mapView.frame = CGRect(x: 0, y: 0, width: mapW, height: mapW)
//		mapView.center = CGPoint(x: mapW*0.5+20, y: self.bounds.size.height*0.5)
	}

//	func zoomToCurrentLocation() {
//		let span = MKCoordinateSpan.init(latitudeDelta: 0.0075, longitudeDelta: 0.0075)
////		print(locationManager.location?.coordinate)
//		let region = MKCoordinateRegion.init(center: (locationManager.location?.coordinate)!, span: span)
//		mapView.setRegion(region, animated: true)
//	}
//
//	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//		print("didUpdate  \(userLocation.coordinate.latitude) \(userLocation.coordinate.longitude)")
//		mapView.setCenter(userLocation.coordinate, animated: true)
//	}
//
//	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//		print("regionDidChangeAnimated")
//	}





}
