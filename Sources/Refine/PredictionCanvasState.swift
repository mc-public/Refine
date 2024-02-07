//
//  PredictionCanvasState.swift
//  
//
//  Created by 孟超 on 2024/2/7.
//

import Foundation
import PencilKit

/// Class that manages all states of ``PredictionCanvas`` view.
///
/// - Warning: Please note that different canvas views cannot share the same instance of state class, as it will lead to unexpected behavior.
@MainActor
public class PredictionCanvasState: ObservableObject {
    /// The type of drawing gestures the view permits while the user draws on the canvas view.
    @Published public var inputPolicy: PKCanvasViewDrawingPolicy = .anyInput {
        didSet {
            self.canvasView.drawingPolicy = self.inputPolicy
        }
    }
    /// The drawing characteristics (width, color, pen style) to use when drawing lines on the canvas view.
    @Published public var tool: PKInkingTool = .init(.pen, color: .black, width: 15.0) {
        didSet {
            self.canvasView.tool = self.tool
        }
    }
    
    /// Predictive results of the current user's strokes.
    @Published public internal(set) var predictionResult: [PredictionSymbol] = []
    
    /// Maximum number of predicted results.
    ///
    /// The default value of this property is `20`.
    @Published public var maximumPredictionResultLimit: Int = 20 {
        didSet {
            self._canvasView?.predictionDelegate?.maxScoresItemLimitation = self.maximumPredictionResultLimit
        }
    }
    
    var predictionCalculateUnit = PredictionCalculateUnit()
    
    var canvasView: PredictionCanvasView {
        get {
            let view = self._canvasView ?? .init()
            view.predictionDelegate?.maxScoresItemLimitation = self.maximumPredictionResultLimit
            view.setState(for: self)
            view.drawingPolicy = self.inputPolicy
            view.tool = self.tool
            view.isScrollEnabled = false
            view.isOpaque = true
            self._canvasView = view
            return view
        }
        set {
            self._canvasView = newValue
        }
    }
    private var _canvasView: PredictionCanvasView?
    
    /// Initialize the state class representing the initial prediction state
    public init() {}
    
    
    func cleanCanvasView() {
        self._canvasView = nil
    }
    
    
    /// Clean canvas content.
    ///
    /// This method will clean all stokes in the canvas view.
    /// - Parameter cleanResult: Whether to clear the predicted results for the current class when clearing all strokes, default value is true.
    public func cleanCanvas(cleanResult: Bool = true) {
        _canvasView?.cleanCanvas(cleanResult: cleanResult)
    }
}
