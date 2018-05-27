import Foundation

let DEBUG = true
let welcomeBase = "http://web2.assist.org/web-assist/"
let report = "http://web2.assist.org/cgi-bin/REPORT_2/Rep2.pl?"
// debug
let parser = Parser(welcomeBase, report, DEBUG)

// needs for loops
parser.getOrigins()

let origin = parser.origin.reversed()
parser.getDestinations(key: origin.first!.key)

let destination = parser.destination.reversed()
parser.getMajors(destination: destination.first!.key)

let majors = parser.majors
parser.getAgreements(major: majors.first!.key)
