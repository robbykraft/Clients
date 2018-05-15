//
//  ExposureQueryView.swift
//  Allergy
//
//  Created by Robby Kraft on 5/15/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ExposureQueryView: UIView {
	let mapView = MKMapView()
	let regionRadius: CLLocationDistance = 200

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
		self.addSubview(mapView)

//		mapView.showsUserLocation = true
		let austinCenter = CLLocation(latitude: 30.2674869, longitude: -97.742351)
		self.centerMapOnLocation(location: austinCenter, animated:false)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let mapW:CGFloat = self.bounds.size.height - 80
		mapView.frame = CGRect(x: 0, y: 0, width: mapW, height: mapW)
		mapView.center = CGPoint(x: mapW*0.5+20, y: self.bounds.size.height*0.5)
	}

	func centerMapOnLocation(location: CLLocation, animated:Bool) {
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
		mapView.setRegion(coordinateRegion, animated: animated)
	}

}
