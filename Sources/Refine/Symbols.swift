//
//  File.swift
//  
//
//  Created by 孟超 on 2024/2/6.
//

import Foundation
import SwiftUI

/// Structure representing the predicted results of mathematical symbols.
public struct PredictionSymbol: Identifiable {
    private var symbol: Symbol
    /// The confidence level of the current prediction result.
    public var confidence: Double
    /// The identity of the current prediction result.
    public var id: String {
        symbol.id
    }
    /// The LaTeX command of the current prediction result.
    public var command: String {
        symbol.command
    }
    /// The Unicode Scalar of the current prediction result.
    ///
    /// This value of `nil` indicates that the current prediction result does not have a valid Unicode character corresponding to it.
    public var unicode: String? {
        symbol.unicode
    }
    private var css_class: String {
        symbol.css_class
    }
    /// Whether the LaTeX command corresponding to the current prediction result is available in math mode.
    public var isMathMode: Bool {
        symbol.mathmode
    }
    /// Whether the LaTeX command corresponding to the current prediction result is available in text mode.
    public var isTextMode: Bool {
        symbol.textmode
    }
    /// The LaTeX package name that defines LaTeX commands corresponding to the current prediction result.
    ///
    /// This value of `nil` means that the LaTeX command corresponding to the current prediction result can be used without any LaTeX package.
    public var package: String? {
        symbol.package
    }
    /// The `Image` result corresponding to the current prediction result.
    public var image: Image {
        Image(css_class, bundle: Bundle.module)
    }
    
    init(symbol: Symbol, confidence: Double) {
        self.symbol = symbol
        self.confidence = confidence
    }
}

struct Symbol: Codable, Identifiable {
    let id: String
    let command: String
    let unicode: String?
    let css_class: String
    let mathmode: Bool
    let textmode: Bool
    let package: String?
    var image: Image {
        Image(css_class, bundle: Bundle.module)
    }
}


@MainActor
class Symbols: ObservableObject {
    
    var allSymbols: [String: Symbol] = [:]
    var isFetchedAllSymbols = false
    
    static let share = Symbols()
    
    private init() {}
    
    func loadAllSymbols() async {
        guard !isFetchedAllSymbols else {
            return
        }
        await withCheckedContinuation { continuation in
            Task.detached {
                let symbols = await self.decode("symbols.json")
                Task { @MainActor in
                    self.allSymbols = symbols
                    self.isFetchedAllSymbols = true
                    continuation.resume()
                }
            }
        }
        
    }
    
    private func decode(_ file: String) -> [String: Symbol] {
        guard let url = Bundle.module.url(forResource: file, withExtension: nil) else {
            #if DEBUG
            fatalError("[Refine] Failed to locate \(file) in bundle.")
            #else
            return [:]
            #endif
        }
        guard let data = try? Data(contentsOf: url) else {
            #if DEBUG
            fatalError("[Refine] Failed to load \(file) from bundle.")
            #else
            return [:]
            #endif
        }
        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode([Symbol].self, from: data) else {
            #if DEBUG
            fatalError("[Refine] Failed to decode \(file) from bundle.")
            #else
            return [:]
            #endif
        }
        var result: [String: Symbol] = [:]
        for symbol in loaded {
            result[symbol.id] = symbol
        }
        return result
    }
    
}
