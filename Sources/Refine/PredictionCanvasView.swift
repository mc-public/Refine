//
//  PredictionCanvasView.swift
//
//
//  Created by 孟超 on 2024/2/6.
//

import Foundation
import PencilKit

@MainActor
class PredictionCanvasView: PKCanvasView {
    
    weak var canvasState: PredictionCanvasState?
    
    var predictionDelegate: PredictionCanvasDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.predictionDelegate = PredictionCanvasDelegate(self)
        self.delegate = self.predictionDelegate
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Clean all stokes in canvas and clean prection result.
    @objc func cleanCanvas(cleanResult: Bool = true) {
        self.drawing.strokes = .init()
        self.drawing = .init()
        if cleanResult {
            self.canvasState?.predictionResult = .init()
        }
    }
    
    func setState(for canvasState: PredictionCanvasState) {
        self.canvasState = canvasState
    }
    
}
