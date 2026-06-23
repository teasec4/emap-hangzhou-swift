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
        guard let appURL = amapAppURL(for: place) else { return }

        UIApplication.shared.open(appURL) { isOpened in
            guard !isOpened, let webURL = amapWebURL(for: place) else { return }
            UIApplication.shared.open(webURL)
        }
    }

    private func amapAppURL(for place: Place) -> URL? {
        var components = URLComponents()
        components.scheme = "iosamap"
        components.host = "navi"
        components.queryItems = [
            URLQueryItem(name: "sourceApplication", value: "emap-hangzhou"),
            URLQueryItem(name: "poiname", value: place.title),
            URLQueryItem(name: "lat", value: String(place.latitude)),
            URLQueryItem(name: "lon", value: String(place.longitude)),
            URLQueryItem(name: "dev", value: "0"),
            URLQueryItem(name: "style", value: "2")
        ]

        return components.url
    }

    private func amapWebURL(for place: Place) -> URL? {
        var components = URLComponents(string: "https://uri.amap.com/navigation")
        components?.queryItems = [
            URLQueryItem(
                name: "to",
                value: "\(place.longitude),\(place.latitude),\(place.title)"
            ),
            URLQueryItem(name: "mode", value: "car"),
            URLQueryItem(name: "src", value: "emap-hangzhou")
        ]

        return components?.url
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
