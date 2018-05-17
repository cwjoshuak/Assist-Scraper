import Foundation
import SwiftSoup
/*
let base = "http://web2.assist.org/web-assist/"
let part = "articulationAgreement.do?inst1=none&inst2=none&ia=DAC&ay=17-18&oia=CSUMA&dir=1"
*/
let DEBUG = true
let welcomeBase = URLComponents(string: "http://web2.assist.org/web-assist/")
// debug

/// institution as ["url" : "Institution Name"]
var institution = [String : String]()

/// agreements as ["url" : "Institution Name"]
var transfers = [String : String]()

/// majors as ["url" : "Major Name"]
var majors = [String : String]()

// parse first page for campuses
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
let secondPage = URLComponents(string: welcomeBase!.string! + iKeys.first!)

do {
    print("Parsing \(secondPage!.string!)")
    let url = try String(contentsOf: secondPage!.url!, encoding: .ascii) // get second page html in form of string
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
let thirdPage = URLComponents(string: welcomeBase!.string! + tKeys.first!)

do {
    print("Parsing \(thirdPage!.string!)")
    let url = try String(contentsOf: thirdPage!.url!, encoding: .ascii)
    let els: Elements? = try SwiftSoup.parse(url).select("form")
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
