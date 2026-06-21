//
//  RouteService.swift
//  emap-hangzhou
//

import MapKit
import UIKit

struct RouteService {

    func openInAppleMaps(to place: Place) {
        let mapItem = mapItem(for: place)
        mapItem.name = place.title
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    func openInAMap(to place: Place) {
        let lat = place.latitude
        let lon = place.longitude
        let name = place.title
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "destination"

        let schemeURL = "iosamap://navi?sourceApplication=emap-hangzhou&lat=\(lat)&lon=\(lon)&dev=0&style=2"
        let webURL = "https://uri.amap.com/navigation?to=\(lon),\(lat),\(name)&mode=car"

        if let url = URL(string: schemeURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: webURL) {
            UIApplication.shared.open(url)
        }
    }

    private func mapItem(for place: Place) -> MKMapItem {
        let location = CLLocation(
            latitude: place.latitude,
            longitude: place.longitude
        )

        if #available(iOS 26.0, *) {
            return MKMapItem(location: location, address: nil)
        }

        let placemark = MKPlacemark(coordinate: place.coordinate)
        return MKMapItem(placemark: placemark)
    }
}
