//
//  Course.swift
//  AssistScraper
//
//  Created by Joshua Kuan on 25/05/2018.
//

import Foundation
final class Course : Codable {//, Hashable {

    var cid: String?
    var cname: String?
    var institution: String?
    var units: Double?
    init() { }
    init(_ institution: String?, cid: String?, cname: String?, units: Double?) {
        self.cid = cid
        self.cname = cname
        self.institution = institution
        self.units = units
    }
}
