//
//  RouteService.swift
//  emap-hangzhou
//

import MapKit
import UIKit

struct RouteService {

    func openInAppleMaps(to place: Place) {
        // Direct deep link: opens Apple Maps immediately
        let urlString = "maps://?daddr=\(place.latitude),\(place.longitude)&dirflg=d"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    func openInAMap(to place: Place) {
        // Direct deep link via iosamap:// scheme
        guard let appURL = amapAppURL(for: place) else { return }
        UIApplication.shared.open(appURL) { isOpened in
            // Fallback: if AMap not installed, open in browser
            guard !isOpened, let webURL = amapWebURL(for: place) else { return }
            UIApplication.shared.open(webURL)
        }
    }

    // MARK: - AMap URL builders

    private func amapAppURL(for place: Place) -> URL? {
        // iosamap://path?sourceApplication=...&dlat=...&dlon=...&dname=...&dev=0&t=0
        var components = URLComponents()
        components.scheme = "iosamap"
        components.host = "path"
        components.queryItems = [
            URLQueryItem(name: "sourceApplication", value: "emap-hangzhou"),
            URLQueryItem(name: "dlat", value: String(place.latitude)),
            URLQueryItem(name: "dlon", value: String(place.longitude)),
            URLQueryItem(name: "dname", value: place.title),
            URLQueryItem(name: "dev", value: "0"),
            URLQueryItem(name: "t", value: "0")
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
}
