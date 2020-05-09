//
//  IconDrawableTests.swift
//  Iconic
//
//  Copyright © 2019 The Home Assistant Authors
//  Licensed under the Apache 2.0 license
//  For more information see https://github.com/home-assistant/Iconic

import XCTest
@testable import Iconic

enum TestIcon: Int {
    case icon1
    case icon2
    case icon3
    case icon4
    case icon5
}

extension TestIcon : IconDrawable {

    static var count: Int { return 5 }

    static var familyName: String {
        return "FontAwesome"
    }

    init(named iconName: String) {
        switch iconName.lowercased() {
        case "icon1": self = .icon1
        case "icon2": self = .icon2
        case "icon3": self = .icon3
        case "icon4": self = .icon4
        case "icon5": self = .icon5
        default: self = .icon1
        }
    }

    var name: String {
        switch self {
        case .icon1: return "icon1"
        case .icon2: return "icon2"
        case .icon3: return "icon3"
        case .icon4: return "icon4"
        case .icon5: return "icon5"
        }
    }

    var unicode: String {
        switch self {
        case .icon1: return "\u{F129}"
        case .icon2: return "\u{F12D}"
        case .icon3: return "\u{F143}"
        case .icon4: return "\u{F14C}"
        case .icon5: return "\u{F152}"
        }
    }
}

class IconDrawableTests: XCTestCase {

    override func setUp() {

        super.setUp()

        FontAwesomeIcon.register()
    }

    override func tearDown() {

        FontAwesomeIcon.unregister()

        super.tearDown()
    }

    func testFundamentals() {

        let iconA = TestIcon(rawValue: 4)
        let iconB = TestIcon(named: "icon5")
        let iconC = TestIcon(named: "")

        XCTAssertNotNil(iconA?.name)
        XCTAssertNotNil(iconA?.unicode)
        XCTAssertNotNil(TestIcon.familyName)

        XCTAssertEqual(iconA, iconB)
        XCTAssertEqual(iconA?.name, "icon5")
        XCTAssertEqual(iconA?.unicode, "\u{F152}")

        XCTAssertNotEqual(iconC, iconA)
        XCTAssertEqual(iconC.rawValue, 0)

        XCTAssertEqual(TestIcon.count, 5)
    }

    func testUnicodeConstructor() {

        measure() {
            let str = TestIcon.icon1.unicode

            XCTAssertNotNil(str)
            XCTAssertEqual(str, "\u{F129}")
        }
    }

    func testFontConstructor() {

        measure() {
            let font = TestIcon.font(ofSize: 20)

            XCTAssertNotNil(font)
            XCTAssertEqual(font.familyName, TestIcon.familyName)
        }
    }

    func testFontSizeZero() {

        measure() {
            // Fonts with zero point size, default to 10, to avoid returning a system font.
            let font = TestIcon.font(ofSize: 0)

            XCTAssertNotNil(font)
            XCTAssertEqual(font.pointSize, 10.0)
            XCTAssertEqual(font.familyName, TestIcon.familyName)
        }
    }

    func testAttributedStringConstructor() {

        measure() {
            let string = TestIcon.icon1.attributedString(ofSize: 20, color: nil)
            let range = NSRange(location: 0, length: string.length)

            XCTAssertNotNil(string)
            
            string.enumerateAttribute(NSAttributedString.Key.font, in: range, options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (value, range, stop) -> Void in
                if let font = value as? UIFont {
                    XCTAssertEqual(font.familyName, TestIcon.familyName)
                }
            }
        }
    }

    func testImageConstructor() {

        measure() {
            let size = CGSize(width: 20, height: 20)

            let image = TestIcon.icon1.image(ofSize: size, color: nil)

            XCTAssertNotNil(image)
            XCTAssertEqual(image.size, size)
        }
    }

    func testImageInsetsConstructor() {

        measure() {
            let insets = UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5)
            let size = CGSize(width: 20, height: 20)

            let image = TestIcon.icon1.image(ofSize: size, color: nil, edgeInsets: insets)

            XCTAssertNotNil(image)
            XCTAssertEqual(image.size, CGSize(width: 30, height: 30))
        }
    }
}
