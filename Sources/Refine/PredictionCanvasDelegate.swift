//
//  PredictionCanvasDelegate.swift
//
//
//  Created by 孟超 on 2024/2/6.
//

import Foundation
import PencilKit
import CoreML

class PredictionCanvasDelegate: NSObject, PKCanvasViewDelegate, Sendable {
    
    var maxScoresItemLimitation: Int = 20
    weak private var pkCanvas: PredictionCanvasView?
    
    init(_ pkCanvas: PredictionCanvasView) {
        self.pkCanvas = pkCanvas
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        // if canvasView is empty escape gracefully
        guard !canvasView.drawing.bounds.isEmpty else {
            return
        }
        
#if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
#endif
        
        // Find the scaling factor for drawings and appropriate pointsize
        let scaleH = canvasView.drawing.bounds.size.width / canvasView.frame.width
        let scaleW = canvasView.drawing.bounds.size.height / canvasView.frame.height
        let scale = max(scaleH, scaleW)
        let pointSize = CGSize(width: 2.5 + scale * 5.5, height: 2.5 + scale * 5.5)
        
        //create new drawing with default width of 10 and white strokes
        var newDrawingStrokes = [PKStroke]()
        for stroke in canvasView.drawing.strokes {
            var newPoints = [PKStrokePoint]()
            for point in stroke.path {
                let newPoint = PKStrokePoint(location: point.location, timeOffset: point.timeOffset, size: pointSize, opacity: CGFloat(2), force: point.force, azimuth: CGFloat.zero, altitude: CGFloat.pi/2)
                newPoints.append(newPoint)
            }
            let newPath = PKStrokePath(controlPoints: newPoints, creationDate: Date())
            newDrawingStrokes.append(PKStroke(ink: PKInk(.pen, color: UIColor.white), path: newPath))
        }
        let newDrawing = PKDrawing(strokes: newDrawingStrokes)
        var image = newDrawing.image(from: newDrawing.bounds, scale: 5.0)
        //flip color from black to white in dark mode
        if image.averageColor?.cgColor.components?[0] == 0 {
            image = invertColors(image: image)
        }
        // overlay image on a black background
        let processed_image = overlayBlackBg(image: image)
        Task {
            self.pkCanvas?.canvasState?.predictionResult = (await  self.pkCanvas?.canvasState?.predictionCalculateUnit.predictImage(image: processed_image, maxScoresItemLimitation: self.maxScoresItemLimitation) ?? [])
        }
    }
    
   
}
