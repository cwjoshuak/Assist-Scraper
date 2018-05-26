import Foundation
import SwiftSoup

let DEBUG = true
let welcomeBase = URLComponents(string: "http://web2.assist.org/web-assist/")
// debug

/// origin as ["url" : "Institution Name"]
var origin = [String : String]()

/// destination as ["url" : "Institution Name"]
var destination = [String : String]()

/// majors as ["code" : "Major Name"]
var majors = [String : String]()

// parse first page for origin campuses
do {
    print("Parsing \(welcomeBase!.string!)")
    let html = try String(contentsOf: welcomeBase!.url!, encoding: .ascii) // get html data from url as string
    let els: Elements? = try SwiftSoup.parse(html).select("form")
    //if (try els?.attr("name")) == "ia" {
    if let els = els {
        let elem = try els.select("select").array()
        for options in elem[0].children() {
            let instCode = try options.val()
            //instCode = instCode.replacingOccurrences(of: ".html", with: "")
            if instCode.count != 0 {
                origin[instCode] = try options.text()
            }
        }
    }
    
    if DEBUG {
        for i in origin {
            print(i)
        }
    }
    print("Done!")
} catch let error {
    print("Error: \(error)")
}

// parse second page for destination campuses
// string to be changed
let iKeys = origin.keys
let secondPage = URLComponents(string: welcomeBase!.string! + "prompt.do?ia=FOOTHILL&ay=16-17"/*iKeys.first!*/)

do {
    print("Parsing \(secondPage!.string!)")
    let url = try String(contentsOf: secondPage!.url!, encoding: .ascii) // get second page html in form of string
    let els: Elements? = try SwiftSoup.parse(url).select("form")
    if let els = els {
        let elem = try els.select("select").array()
        for options in elem[2].children() {
            let transferCode = try options.val()
            if transferCode.count != 0 {
                destination[transferCode] = try options.text()
            }
        }
    }
    if DEBUG {
        for i in destination {
            print(i)
        }
    }
    print("Done!")
} catch let error {
    print("Error: \(error)")
}

// parse third page for majors
// string to be changed
let tKeys = destination.keys
let thirdPage = URLComponents(string: welcomeBase!.string! + "articulationAgreement.do?inst1=none&inst2=none&ia=FOOTHILL&ay=16-17&oia=UCB&dir=1"/*tKeys.first!*/)

do {
    print("Parsing \(thirdPage!.string!)")
    let url = try String(contentsOf: thirdPage!.url!, encoding: .ascii) // html of third page
    let els: Elements? = try SwiftSoup.parse(url).select("form") // get all with "form"
    if let els = els {
        let elem = try els.select("select").array()
        for options in elem[3].children() {
            let major = try options.val()
            if major.count != 0 && major != "-1" {
                majors[major] = try options.text()
            }
        }
    }
    if DEBUG {
        for i in majors {
            print(i)
        }
    }
    print("Done!")
} catch let error {
    print("Error: \(error)")
}
print(secondPage!.queryItems)
print()
print(thirdPage!.queryItems)

let report = "http://web2.assist.org/cgi-bin/REPORT_2/Rep2.pl?"
//aay=16-17&oia=UCB&dora=BUS%20ADM&ay=16-17&event=19&agreement=aa&ria=UCB&sia=DAC&ia=DAC&dir=1&&sidebar=false&rinst=left&mver=2&kind=5&dt=2"

let queries = thirdPage!.queryItems!
var params: [URLQueryItem] = [
    URLQueryItem(name: "aay", value: queries[3].value), // aay is year agreement for origin
    URLQueryItem(name: queries[4].name, value: queries[4].value), // oia is same as ria - destination
    URLQueryItem(name: "dora", value: "CIV ENG" /*major*/), // dora is major - destination
    URLQueryItem(name: "ay", value: queries[3].value), // ay is year agreement for destinatoin
    URLQueryItem(name: "event", value: "19"),
    URLQueryItem(name: "agreement", value: "aa"),
    URLQueryItem(name: "ria", value: queries[4].value), // ria is same as oia - destination
    URLQueryItem(name: "sia", value: queries[2].value), // sia is same as ia - origin
    URLQueryItem(name: "ia", value: queries[2].value), // ia is same as sia - origin
    URLQueryItem(name: "dir", value: queries[5].value),
    URLQueryItem(name: "&sidebar", value: "false"),
    URLQueryItem(name: "rinst", value: "left"),
    URLQueryItem(name: "mver", value: "2"),
    URLQueryItem(name: "kind", value: "5"),
    URLQueryItem(name: "dt", value: "2")
]
// ignore all the warnings thanks
var agreementPage = URLComponents(string: report)
agreementPage?.queryItems = params
print(agreementPage!.url)

//        let result = fullLine.matches(in: left, range: NSRange(left.startIndex..., in: left)).map {
//            String(left[Range($0.range, in: left)!])
//        }
func parseCourseSet(lhs: [String], rhs: [String]) -> Equivalency {
    
    let eqSet = Equivalency()
    var leftSet = [Course]()
    var rightSet = [Course]()
    
    var separateLeft = false
    var separateRight = false
    
    //var leftCounter = 0
    //var rightCounter = 0
    /// $0: Full Line
    /// $1: cid
    /// $2: 'spaces'
    /// $3: '&'
    /// $4: course name
    /// $5: (units) where units is a possible double value
    let fullLine = try! NSRegularExpression(pattern: "(\\w+ \\w+)( +)(&)?(.+)(\\(\\d\\.?\\d?\\)$)", options: [.caseInsensitive])
    //(\\w+ \\w+)( +)(&)?([^(0-9)]+)(\\(\\d\\.?\\d?\\)$)
    let alt = try! NSRegularExpression(pattern: "(^\\s+OR\\s+$)", options: [.caseInsensitive])
    let append = try! NSRegularExpression(pattern: "(.[^\\(\\d\\)]+)$", options: [.caseInsensitive, .anchorsMatchLines])
    //(^\\s*\\w*?\\s*&?\\s*\\w+\\s?\\w*\\s*$)
    //let breaker = try! NSRegularExpression(pattern: "-{5}")
    for (left, right) in zip(lhs, rhs) {
        let leftRange = NSRange(left.startIndex..., in: left)
        let rightRange = NSRange(right.startIndex..., in: right)
        let leftCourse = Course()
        let rightCourse = Course()
        // Case 0: Line is a breaker, course separator
        if left.contains("-----") && right.contains("-----"){
            if leftSet.count != 0 && rightSet.count != 0 {
                eqSet.addEquivalency([leftSet, rightSet])
                leftSet = [Course]()
                rightSet = [Course]()
                continue
            }
            continue
        }
        
        // Case 1: Line is OR, sets bool flags for later use
        separateLeft = alt.numberOfMatches(in: left, range: leftRange) == 1
        separateRight = alt.numberOfMatches(in: right, range: rightRange) == 1
        
        //print(fullLine.numberOfMatches(in: left, range: leftRange))
        //print(!left.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        
        // Case 1: this is to append course names to previous course
        if let prevName = append.firstMatch(in: left, range: leftRange) {
            if !separateLeft {
                let appendingcname = String(left[Range(prevName.range(at: 0), in: left)!]).trimmingCharacters(in: .whitespacesAndNewlines)
                if appendingcname.lowercased().range(of:"articulate") != nil {
                    leftCourse.cname = "NO COURSE ARTICULATED"
                    leftSet.append(leftCourse)
                } else {
                    leftSet[leftSet.count-1].cname?.append(" \(appendingcname)")
                }
            }
        } else if !left.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !separateLeft {
            // FOR LEFT SIDE, if line isn't empty
            fullLine.enumerateMatches(in: left, range: leftRange) { matches, flags, stop in
                // set cid
                leftCourse.cid = String(left[Range(matches!.range(at: 1), in: left)!])
                // set cname
                leftCourse.cname = String(left[Range(matches!.range(at: 4), in: left)!]).trimmingCharacters(in: .whitespacesAndNewlines)
                // set units
                leftCourse.units = Double(String(left[Range(matches!.range(at: 5), in: left)!]).trimmingCharacters(in: NSCharacterSet.punctuationCharacters))
            }
            leftSet.append(leftCourse)
            //leftCounter += 1
        }
        
        if let prevName = append.firstMatch(in: right, range: rightRange) {
            if !separateRight {
                let appendingcname = String(right[Range(prevName.range(at: 0), in: left)!]).trimmingCharacters(in: .whitespacesAndNewlines)
                if appendingcname.lowercased().range(of:"articulate") != nil {
                    rightCourse.cname = "NO COURSE ARTICULATED"
                    rightSet.append(rightCourse)
                } else {
                    rightSet[rightSet.count-1].cname?.append(" \(appendingcname)")
                }
                
            }
        } else if !right.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !separateRight {
            // FOR RIGHT SIDE
            fullLine.enumerateMatches(in: right, range: rightRange) { matches, flags, stop in
                // set cid
                rightCourse.cid = String(right[Range(matches!.range(at: 1), in: right)!])
                // set cname
                rightCourse.cname = String(right[Range(matches!.range(at: 4), in: right)!]).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                // set units
                rightCourse.units = Double(String(right[Range(matches!.range(at: 5), in: right)!]).trimmingCharacters(in: NSCharacterSet.punctuationCharacters))
            }
            rightSet.append(rightCourse)
            //rightCounter += 1
        }
        
        //left = fullLine.stringByReplacingMatches(in: left, range: NSRange(left.startIndex..., in: left), withTemplate: "$0, $1, $2, $3, $4, $5, $6")
        //print(x)
        
        
//        // check if current line needs to append next (few) lines
//        appendPrevLeft = fullLine.numberOfMatches(in: left, range: NSRange(left.startIndex..., in: left)) == 1
//        appendPrevRight = fullLine.numberOfMatches(in: right, range: NSRange(right.startIndex..., in: right)) == 1

    }
    return eqSet
}

do {
    let html = try String(contentsOf: agreementPage!.url!, encoding: .ascii)
    let doc: Document = try SwiftSoup.parseBodyFragment(html)
    let body: Element? = doc.body()
    //let x = body?.children()
    let text = try body?.text()
    
    let allLines = text?.components(separatedBy: "\n")
    let splitter = "--------------------------------------------------------------------------------"
    //let arrData = allLines!.split(separator: splitter)
    //let regex = try! NSRegularExpression(pattern: "[^|]+", options: [.caseInsensitive, .anchorsMatchLines])

    var leftArr = [String]()
    var rightArr = [String]()
    for lines in allLines! {
        //print(i)
        if !lines.contains("|") && !lines.contains(splitter) {
            continue
        }
        if lines.contains(splitter) {
            leftArr.append("-----")
            rightArr.append("-----")
        } else {
            let course = lines.split(separator: "|")
            leftArr.append(String(course[0]))
            rightArr.append(String(course[1]))
        }
        
//        for j in lines {
//            if !j.contains("|") {
//                continue
//            }
//            let course = j.split(separator: "|")
        
    }
for (i,j) in zip(leftArr, rightArr) {
    print("\(i) -> \(j)")
}
    var equivalent = [Equivalency]()
    var e = Equivalency()
    let c1 = Course("UCB", cid: "CHEM 1A", cname: "General Chemistry", units: 3.0)
    let c2 = Course("UCB", cid: "CHEM 1AL", cname: "General Chemistry Laboratory", units: 1.0)
    let c3 = Course("UCB", cid: "CHEM 1B", cname: "General Chemistry", units: 4.0)
    let x1 = Course("FOOTHILL", cid: "CHEM 1A", cname: "General Chemistry", units: 5.0)
    let x2 = Course("FOOTHILL", cid: "CHEM 1B", cname: "General Chemistry", units: 5.0)
    
    let courseList = [[c1, c2, c3], [x1,x2], [c1,c2]]
    //let collegeList = [x1, x2]
    
    e.addEquivalency(courseList)
    
    equivalent.append(e)
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    
    let ev = parseCourseSet(lhs: leftArr, rhs: rightArr)
    let data = try! encoder.encode(ev)
    print(String(data: data, encoding: .utf8)!)
    print(ev)
    
    for (i,j) in zip(leftArr, rightArr) {
        print("\(i) -> \(j)")
    }
}

/*
 Transferring from : DAC
 Transferring to : UCB
 Required: [dac -> ucb]
 [MATH 1A & MATH 1B & MATH 1C] : [MATH 6]
 [CIS 1] : [NA]
 
 Optional:
 ...
 */
