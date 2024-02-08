//
//  PredictionCalculateUnit.swift
//
//
//  Created by 孟超 on 2024/2/7.
//

import Foundation
import CoreML
import UIKit

/// 保证在主线程上访问
class PredictionCalculateUnit {
    @AtomicProperty
    private var atomicValue: Int = 0
    @AtomicProperty
    var isPredicting: Bool = false
    private let trainedImageSize = CGSize(width: 300, height: 200)
    private let queue: DispatchQueue = .init(label: "\(PredictionCalculateUnit.Type.self)_\(UUID().uuidString)_SerialQueue")
    private var model: deTeX? = { /*accessed at queue*/
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
        await Symbols.share.waitFetchedResult()
        let currentAtomicValue = self.atomicValue
        let result: [PredictionSymbol]? = await withCheckedContinuation { continuation in
            self.queue.async {
                if self.atomicValue != currentAtomicValue {
                    continuation.resume(returning: nil)
                    return
                }
                self.setPredictionState(true)
                self.increaseAtomicValue()
                guard let resizedImage = image.resize(newSize: self.trainedImageSize), let pixelBuffer = resizedImage.toCVPixelBuffer() else {
                    self.setPredictionState(false)
                    continuation.resume(returning: [])
                    return
                }
                guard let result = try? self.model?.prediction(drawing: pixelBuffer) else {
                    print("[Refine][Warning][\(#function)] error in prediction image.")
                    self.setPredictionState(false)
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
                        guard let symbol = Symbols.share.fetchSymbol(id: id) else {
                            return nil
                        }
                        return .init(symbol: symbol, confidence: value)
                    }
                    self.setPredictionState(false)
                    continuation.resume(returning: newList)
                }
            }
        }
        return result
    }
}
