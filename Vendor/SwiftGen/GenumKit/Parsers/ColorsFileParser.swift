//
// GenumKit
// Copyright (c) 2015 Olivier Halligon
// MIT Licence
//

import Foundation
import AppKit.NSColor

public protocol ColorsFileParser {
  var colors: [String: UInt32] { get }
}

// MARK: - Private Helpers

private func parseHexString(hexString: String) -> UInt32 {
  let scanner = NSScanner(string: hexString)
  let prefixLen: Int
  if scanner.scanString("#", intoString: nil) {
    prefixLen = 1
  } else if scanner.scanString("0x", intoString: nil) {
    prefixLen = 2
  } else {
    prefixLen = 0
  }

  var value: UInt32 = 0
  scanner.scanHexInt(&value)

  let len = hexString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - prefixLen
  if len == 6 {
    // There were no alpha component, assume 0xff
    value = (value << 8) | 0xff
  }

  return value
}

// MARK: - Text File Parser

public final class ColorsTextFileParser: ColorsFileParser {
  public private(set) var colors = [String:UInt32]()

  public init() {}

  public func addColorWithName(name: String, value: String) {
    addColorWithName(name, value: parseHexString(value))
  }

  public func addColorWithName(name: String, value: UInt32) {
    colors[name] = value
  }

  // Text file expected to be:
  //  - One line per entry
  //  - Each line composed by the color name, then ":", then the color hex representation
  //  - Extra spaces will be skipped
  public func parseFile(path: String, separator: String = ":") throws {
    let content = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
    let lines = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    let ws = NSCharacterSet.whitespaceCharacterSet()
    for line in lines {
      let scanner = NSScanner(string: line)
      scanner.charactersToBeSkipped = ws
      var key: NSString?
      if scanner.scanUpToString(":", intoString: &key) {
        scanner.scanString(":", intoString: nil)
        var value: NSString?
        if scanner.scanUpToCharactersFromSet(ws, intoString: &value) {
          addColorWithName(key! as String, value: value! as String)
        }
      }
    }
  }
}

// MARK: - CLR File Parser

public final class ColorsCLRFileParser: ColorsFileParser {
  public private(set) var colors = [String: UInt32]()

  public init() {}

  public func parseFile(path: String) {
    if let colorsList = NSColorList(name: "UserColors", fromFile: path) {
      for colorName in colorsList.allKeys {
        colors[colorName] = colorsList.colorWithKey(colorName)?.rgbColor?.hexValue
      }
    }
  }

}

extension NSColor {

  private var rgbColor: NSColor? {
    return colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
  }

  private var hexValue: UInt32 {
    let hexRed   = UInt32(redComponent   * 0xFF) << 24
    let hexGreen = UInt32(greenComponent * 0xFF) << 16
    let hexBlue  = UInt32(blueComponent  * 0xFF) << 8
    let hexAlpha = UInt32(alphaComponent * 0xFF)
    return hexRed | hexGreen | hexBlue | hexAlpha
  }

}


// MARK: - Android colors.xml File Parser

public final class ColorsXMLFileParser: ColorsFileParser {
  static let colorTagName = "color"
  static let colorNameAttribute = "name"

  public private(set) var colors = [String: UInt32]()

  public init() {}

  public func parseFile(path: String) throws {
    class ParserDelegate: NSObject, NSXMLParserDelegate {
      var parsedColors = [String: UInt32]()
      var currentColorName: String? = nil
      var currentColorValue: String? = nil

      @objc func parser(parser: NSXMLParser, didStartElement elementName: String,
        namespaceURI: String?, qualifiedName qName: String?,
        attributes attributeDict: [String: String])
      {
        guard elementName == ColorsXMLFileParser.colorTagName else { return }
        currentColorName = attributeDict[ColorsXMLFileParser.colorNameAttribute]
        currentColorValue = nil
      }

      @objc func parser(parser: NSXMLParser, foundCharacters string: String) {
        currentColorValue = (currentColorValue ?? "") + string
      }

      @objc func parser(parser: NSXMLParser, didEndElement elementName: String,
        namespaceURI: String?, qualifiedName qName: String?)
      {
        guard elementName == ColorsXMLFileParser.colorTagName else { return }
        guard let colorName = currentColorName, let colorValue = currentColorValue else { return }
        parsedColors[colorName] = parseHexString(colorValue)
        currentColorName = nil
        currentColorValue = nil
      }
    }

    guard let parser = NSXMLParser(contentsOfURL: NSURL.fileURLWithPath(path)) else {
      throw NSError(domain: NSXMLParserErrorDomain, code: NSXMLParserError.InternalError.rawValue, userInfo: nil)
    }
    let delegate = ParserDelegate()
    parser.delegate = delegate
    parser.parse()
    colors = delegate.parsedColors
  }

}

// MARK: - JSON File Parser

public final class ColorsJSONFileParser: ColorsFileParser {
  public private(set) var colors = [String: UInt32]()

  public init() {}

  public func parseFile(path: String) throws {
    if let JSONdata = NSData(contentsOfFile: path),
      let json = try? NSJSONSerialization.JSONObjectWithData(JSONdata, options: []),
      let dict = json as? [String: String] {
        for (key, value) in dict {
          colors[key] = parseHexString(value)
        }
    }
  }
}
