//
//  PredictionCalculateUnit.swift
//
//
//  Created by 孟超 on 2024/2/7.
//

import Foundation
import CoreML
import UIKit

actor PredictionCalculateUnit {
    var atomicValue: Int = 0
    var isPredicting: Bool = false
    private let trainedImageSize = CGSize(width: 300, height: 200)
    
    private let model: deTeX? = {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all /* 配置计算单元 */
            return try deTeX(configuration: config)
        }
        catch {
            #if DEBUG
            print(error)
            fatalError("[Refine][FatalError] Couldn't create ML model.")
            #else
            return nil
            #endif
        }
    }()
    
    func increaseAtomicValue() {
        self.atomicValue += 1
    }
    
    func setPredictionState(_ value: Bool) {
        self.isPredicting = value
    }
    
    func predictImage(image: UIImage, maxScoresItemLimitation: Int) async -> [PredictionSymbol]?  {
        await Symbols.share.loadAllSymbols()
        let currentAtomicValue = self.atomicValue
        let result: [PredictionSymbol]? = await withCheckedContinuation { continuation in
            Task.detached {
                if await self.atomicValue != currentAtomicValue {
                    continuation.resume(returning: nil)
                    return
                }
                await self.setPredictionState(true)
                await self.increaseAtomicValue()
                guard let resizedImage = image.resize(newSize: self.trainedImageSize), let pixelBuffer = resizedImage.toCVPixelBuffer() else {
                    await self.setPredictionState(false)
                    continuation.resume(returning: [])
                    return
                }
                guard let result = try? self.model?.prediction(drawing: pixelBuffer) else {
                    print("[Refine][Warning][\(#function)] error in prediction image.")
                    await self.setPredictionState(false)
                    continuation.resume(returning: [])
                    return
                }
                let list = Array(result.classLabelProbs.sorted { $0.value > $1.value } [..<maxScoresItemLimitation])
                Task { @MainActor in
                    var usedID: [String] = []
                    let newList: [PredictionSymbol] = list.compactMap { (id: String, value: Double) in
                        if usedID.contains(id) {
                            return nil
                        }
                        usedID.append(id)
                        guard let symbol = Symbols.share.allSymbols[id] else {
                            return nil
                        }
                        return .init(symbol: symbol, confidence: value)
                    }
                    await self.setPredictionState(false)
                    continuation.resume(returning: newList)
                }
            }
        }
        return result
    }
}
