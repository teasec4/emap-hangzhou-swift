//
//  ServerResponse.swift
//  emap-hangzhou
//
//  Created by Максим Ковалев on 6/23/26.
//

//[
//  {
//    "id": "c9cd4b11-...",
//    "name": "West Lake",
//    "type": "viewpoint",
//    "lat": 30.2374,
//    "lng": 120.1406,
//    "comment": "Beautiful!",
//    "createdAt": "2026-06-22T07:45:48.481Z",
//    "updatedAt": "2026-06-22T07:45:48.481Z"
//  }
//]

struct ServerResponse{
    let id:String
    let name:String
    let type:String
    let lat:Double
    let lng:Double
    let comment:String
    let createdAt:String
    let updatedAt:String
}
