//
//  Course.swift
//  AssistScraper
//
//  Created by Joshua Kuan on 25/05/2018.
//

import Foundation
final class Course : Codable {//, Hashable {

    var cid: String?
    var name: String?
    var institution: String?
    var units: Double?
    init() { }
    init(_ institution: String?, cid: String?, name: String?, units: Double?) {
        self.cid = cid
        self.name = name
        self.institution = institution
        self.units = units
    }
}
