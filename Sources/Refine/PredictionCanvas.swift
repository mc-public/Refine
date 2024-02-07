//
//  PredictionCanvas.swift
//
//
//  Created by 孟超 on 2024/2/6.
//

import Foundation
import SwiftUI
import PencilKit

struct PredictionCanvas_Internal: UIViewRepresentable {
    
    @ObservedObject var currentState: PredictionCanvasState
    
    init(currentState: PredictionCanvasState) {
        self._currentState = .init(wrappedValue: currentState)
        
    }
    
    func makeUIView(context: Context) -> PredictionCanvasView {
        return self.currentState.canvasView
    }
    
    func updateUIView(_ uiView: PredictionCanvasView, context: Context) {}
    
    typealias UIViewType = PredictionCanvasView
    
}

/// View for displaying predictive math character drawing canvas.
@available(iOS 15.0, *)
public struct PredictionCanvas: View {
    
    @ObservedObject private var state: PredictionCanvasState
    private var width: CGFloat
    
    /// Initialize the canvas view
    ///
    /// - Parameter state: Class that manages all states of this view.
    /// - Parameter width: The width of the current view. The width of the current view is always `1.5` times the height.
    /// - Warning: Please note that different canvas views cannot share the same instance of state class, as it will lead to unexpected behavior.
    public init(state: PredictionCanvasState, width: CGFloat = 600) {
        self._state = .init(wrappedValue: state)
        self.width = width
    }
    
    public var body: some View {
        PredictionCanvas_Internal(currentState: self.state)
            .frame(maxWidth: self.width, maxHeight: self.width / 1.5, alignment: .center)
            //.frame(minWidth: 150, idealWidth: 300, maxWidth: 600, minHeight: 100, idealHeight: 200, maxHeight: 400, alignment: .center)
            .aspectRatio(1.5, contentMode: .fit)
            .onDisappear(perform: state.cleanCanvasView)
    }
    
}

