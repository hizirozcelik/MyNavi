//
//  RouteSelectionView.swift
//  NavigationApp
//
//  Created by HIZIR OZCELIK on 2023-10-08.
//

import SwiftUI
import MapKit

struct RouteSelectionView: View {
    
    @ObservedObject var locationManager: LocationManager
    @Binding var fromAddress: String
    @Binding var toAddress: String
    @Binding var routes: [MKRoute]
    @Binding var pins: [MKAnnotation]
    @Binding var selectedRoute: MKRoute?
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("From", text: $fromAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .padding(.top, 50)
            
            TextField("To", text: $toAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Fetch Routes") {
                // Stop updating user location when fetching routes
                locationManager.stopTracking()
                geocode(address: fromAddress) { (sourcePlacemark) in
                    geocode(address: toAddress) { (destinationPlacemark) in
                        guard let source = sourcePlacemark, let destination = destinationPlacemark else {
                            // Handle geocoding failure here
                            print("Failed to geocode addresses.")
                            return
                        }
                        fetchRoutes(from: source, to: destination) { fetchedRoutes in
                            self.routes = fetchedRoutes
                        }
                    }
                }
            }
            .padding()
            
            List(routes, id: \.name) { route in
                HStack {
                    Text(route.name)
                    Spacer()
                    Text("\(route.formattedDistance), \(route.formattedExpectedTravelTime)")
                }
                .onTapGesture {
                    self.selectedRoute = route
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
}

struct RouteSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RouteSelectionView(locationManager: LocationManager(),
                           fromAddress: .constant(""),
                           toAddress: .constant(""),
                           routes: .constant([]),
                           pins: .constant([]),
                           selectedRoute: .constant(MKRoute()))
    }
}

func fetchRoutes(from source: MKPlacemark, to destination: MKPlacemark, completion: @escaping ([MKRoute]) -> Void) {
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: source)
    request.destination = MKMapItem(placemark: destination)
    request.transportType = .automobile // This fetches routes for automobiles; can be changed to .walking or .transit
    
    let directions = MKDirections(request: request)
    directions.calculate { (response, error) in
        if let error = error {
            print("Failed to fetch routes: \(error)")
            completion([])
            return
        }
        
        completion(response?.routes ?? [])
    }
}

func geocode(address: String, completion: @escaping (MKPlacemark?) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) { (placemarks, error) in
        if let error = error {
            print("Failed to geocode address: \(error)")
            completion(nil)
            return
        }
        if let firstPlacemark = placemarks?.first {
            completion(MKPlacemark(placemark: firstPlacemark))
        } else {
            completion(nil)
        }
    }
}

extension MKRoute {
    var formattedDistance: String {
        let distanceInKm = self.distance / 1000 // Convert to kilometers
        return String(format: "%.1f Km", distanceInKm)
    }
    
    var formattedExpectedTravelTime: String {
        let hours = Int(self.expectedTravelTime) / 3600
        let minutes = Int(self.expectedTravelTime) / 60 % 60
        let seconds = Int(self.expectedTravelTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}


