//
//  Equivalency.swift
//  AssistScraper
//
//  Created by Joshua Kuan on 26/05/2018.
//

import Foundation
final class Equivalency : Codable {
    var courseList = [Int : [[Course]]]()
    
    func addEquivalency(_ courses: [[Course]]) {
        courseList[courseList.count+1] = courses
    }
}
