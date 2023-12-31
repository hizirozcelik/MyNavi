//
//  ContentView.swift
//  NavigationApp
//
//  Created by HIZIR OZCELIK on 2023-10-08.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State var pins: [MKAnnotation] = [] // Annotations from and to
    @State var fromAddress = ""
    @State var toAddress = ""
    @State var routes: [MKRoute] = []
    @State var selectedRoute: MKRoute? // nil at the beginning
    
    var body: some View {
        NavigationStack {
            MapView(locationManager: locationManager, annotations: pins, selectedRoute: $selectedRoute)
                .navigationBarTitle("My Navi")
                .navigationBarTitleDisplayMode(.inline)
                .ignoresSafeArea(edges: [.leading, .bottom, .trailing])
                .toolbar {
                    ToolbarItem {
                        NavigationLink("Route") {
                            RouteSelectionView(locationManager: locationManager, fromAddress: $fromAddress, toAddress: $toAddress, routes: $routes, pins: $pins, selectedRoute: $selectedRoute)
                        }
                    }
                }
                .onAppear {
                    locationManager.startTracking()
                }
        }

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

