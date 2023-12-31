//
//  MapView.swift
//  NavigationApp
//
//  Created by HIZIR OZCELIK on 2023-10-08.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    var annotations: [MKAnnotation]
    var selectedRoute: Binding<MKRoute?>
    var spanKm = 1.0
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsUserLocation = true
        mapView.mapType = .hybrid
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context)
    {
        print("updateUIView called")
        updateMap(uiView)
    }
    
    func updateMap(_ uiView: MKMapView) {
        
        print("update Map called")
        
        // Remove existing overlays and annotations
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        
        // display the current user location
        if locationManager.userTracking {
            let coord = locationManager.location.coordinate
            let center = CLLocationCoordinate2D(latitude: coord.latitude,
                                                longitude: coord.longitude)
            let span = MKCoordinateSpan(latitudeDelta: spanKm/111.111,
                                        longitudeDelta: spanKm/111.111)
            let region = MKCoordinateRegion(center: center, span: span)
            uiView.setRegion(region, animated: true)
        }
        
        // display the route
        if let selectedRoute = selectedRoute.wrappedValue {
            
            print("after update MAP function if let block")
            uiView.showsUserLocation = false
            
            let polyline = selectedRoute.polyline
            uiView.addOverlay(polyline)
            
            let startAnnotation = MKPointAnnotation()
            startAnnotation.coordinate = selectedRoute.polyline.coordinates.first ?? CLLocationCoordinate2D()
            startAnnotation.title = "Start"
            
            let endAnnotation = MKPointAnnotation()
            endAnnotation.coordinate = selectedRoute.polyline.coordinates.last ?? CLLocationCoordinate2D()
            endAnnotation.title = "End"
            
            uiView.addAnnotations([startAnnotation, endAnnotation])
            uiView.addOverlay(selectedRoute.polyline)
            
            // Set the map view to show the entire route
            let padding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
            uiView.setVisibleMapRect(selectedRoute.polyline.boundingMapRect, edgePadding: padding, animated: true)
        }
    }
    
    
    
    func makeCoordinator() -> MapViewCoordinator
    {
        return MapViewCoordinator(self)
    }
}

// coordinator (delegate) to communicate with SwiftUI
class MapViewCoordinator: NSObject, MKMapViewDelegate
{
    // properties
    let mapView: MapView
    init(_ mapView: MapView) {
        self.mapView = mapView
    }
    // delegates for MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .red
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

// Extension to create a bounding map rect from an array of annotations
extension MKMapRect {
    static func forAnnotations(_ annotations: [MKAnnotation]) -> MKMapRect {
        let mapPoints = annotations.map { MKMapPoint($0.coordinate) }
        let rects = mapPoints.map { MKMapRect(origin: $0, size: MKMapSize(width: 0, height: 0)) }
        return rects.reduce(MKMapRect.null) { $0.union($1) }
    }
    
    
}

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}


