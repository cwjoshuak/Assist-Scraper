import Foundation
import SwiftSoup
/*
let base = "http://web2.assist.org/web-assist/"
let part = "articulationAgreement.do?inst1=none&inst2=none&ia=DAC&ay=17-18&oia=CSUMA&dir=1"
*/
let DEBUG = true
let welcomeBase = URL(string: "http://web2.assist.org/web-assist/")

/// institution as ["url" : "Institution Name"]
var institution = [String : String]()

/// agreements as ["url" : "Institution Name"]
var transfers = [String : String]()

/// majors as ["url" : "Major Name"]
var majors = [String : String]()

// parse first page for campuses
do {
    print("Parsing \(welcomeBase!.absoluteString)")
    let url = try String(contentsOf: welcomeBase!, encoding: .ascii)
    let els: Elements? = try SwiftSoup.parse(url).select("form")
    //if (try els?.attr("name")) == "ia" {
    if let els = els {
        let elem = try els.select("select").array()
        for options in elem[0].children() {
            let instCode = try options.val()
            //instCode = instCode.replacingOccurrences(of: ".html", with: "")
            if instCode.count != 0 {
                institution[instCode] = try options.text()
            }
        }
    }
    
    if DEBUG {
        for i in institution {
            print(i)
        }
    }
    print("Done!")
} catch let error {
    print("Error: \(error)")
}

// parse second page for transfer campuses
// string to be changed
let iKeys = institution.keys
let spurl = (welcomeBase!.absoluteString + iKeys.first!).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
let secondPage = URL(string: spurl)

do {
    print("Parsing \(secondPage!.absoluteString)")
    let url = try String(contentsOf: secondPage!, encoding: .ascii)
    let els: Elements? = try SwiftSoup.parse(url).select("form")
    if let els = els {
        let elem = try els.select("select").array()
        for options in elem[2].children() {
            let transferCode = try options.val()
            if transferCode.count != 0 {
                transfers[transferCode] = try options.text()
            }
        }
    }
    if DEBUG {
        for i in transfers {
            print(i)
        }
    }
    print("Done!")
} catch let error {
    print("Error: \(error)")
}

// parse third page for majors
// string to be changed
let tKeys = transfers.keys
let tpurl = (welcomeBase!.absoluteString + tKeys.first!).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
let thirdPage = URL(string: tpurl)

do {
    print("Parsing \(thirdPage!.absoluteString)")
    let url = try String(contentsOf: thirdPage!, encoding: .ascii)
    let els: Elements? = try SwiftSoup.parse(url).select("form")
    if let els = els {
        let elem = try els.select("select").array()
        print(elem.count)
        
        for options in elem[3].children() {
            
            //print(options)
            let major = try options.val()
            //instCode = instCode.replacingOccurrences(of: ".html", with: "")
            if major.count != 0 {
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


var report = "http://web2.assist.org/cgi-bin/REPORT_2/Rep2.pl?"
//aay=16-17&oia=UCB&dora=BUS%20ADM&ay=16-17&event=19&agreement=aa&ria=UCB&sia=DAC&ia=DAC&dir=1&&sidebar=false&rinst=left&mver=2&kind=5&dt=2"
var params = [
    ["aay" : ""],
    ["oia" : ""],
    ["dora" : "" ],
    ["ay" : ""],
    ["event" : ""],
    ["agreement" : ""],
    ["ria" : ""],
    ["sia" : ""],
    ["ia" : ""],
    ["dir": ""],
    ["&sidebar" : "false"],
    ["rinst" : "left"],
    ["mver" : "2"],
    ["kind" : "5"],
    ["dt" : "2"]]

/*
print(baseURL)
do {
    
    let myHTMLString = try String(contentsOf: baseURL!, encoding: .ascii)
    let doc: Document = try SwiftSoup.parseBodyFragment(myHTMLString)
    let body: Element? = doc.body()
    let text = try body?.text()
    //print(text)
    var arr = text!.split(separator: "\n")
    var count = 0

    for i in arr {
        if !arr[count].contains("|") || !arr[count].contains("|") {
            arr.remove(at: count)
            count -= 1
        }
        count += 1
    }
    for i in arr {
        print(i)
    }
    //print(assistAgreement.array().count)
    //print("HTML : \(assistAgreement.array())")
}

*/
