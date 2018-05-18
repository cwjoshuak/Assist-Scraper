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

do {
    let html = try String(contentsOf: agreementPage!.url!, encoding: .ascii)
    let doc: Document = try SwiftSoup.parseBodyFragment(html)
    let body: Element? = doc.body()
    let x = body?.children()
    let text = try body?.text()
    //print(text)
    var arr = text!.split(separator: "\n")
    var count = 0

    let str = "--------------------------------------------------------------------------------"

    /*
    for i in arr {
        
        if (!i.contains("|")) && (!i.contains(str)) {
            
            arr.remove(at: count)
            count -= 1
        } else {
            print("didn't remove \(i) \(i.count) \(str.count)")
        }
        
        count += 1
    }*/
    /*for i in t {
        print(i)
    }*/
    for i in arr {
        print(i)
    }
    //print(assistAgreement.array().count)
    //print("HTML : \(assistAgreement.array())")
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
