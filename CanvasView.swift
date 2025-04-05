import SwiftUI

struct CanvasView: UIViewRepresentable {
    @Binding var drawnImage: UIImage?
    @Binding var brushColor: Color
    @Binding var brushSize: CGFloat
    
    class Coordinator: NSObject {
        var parent: CanvasView
        var canvasView: CanvasUIView
        
        init(parent: CanvasView, canvasView: CanvasUIView) {
            self.parent = parent
            self.canvasView = canvasView
        }
        
        @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
            let point = sender.location(in: canvasView)
            
            let canvasBounds = canvasView.bounds
            guard canvasBounds.contains(point) else { return }
            
            switch sender.state {
            case .began:
                canvasView.startNewPath(at: point, color: parent.brushColor.uiColor, size: parent.brushSize)
            case .changed:
                canvasView.addPointToCurrentPath(point)
            case .ended:
                canvasView.finishCurrentPath()
                parent.drawnImage = canvasView.createImage()
            default:
                break
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        let canvasView = CanvasUIView()
        return Coordinator(parent: self, canvasView: canvasView)
    }
    
    func makeUIView(context: Context) -> CanvasUIView {
        let view = context.coordinator.canvasView
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
        return view
    }
    
    func updateUIView(_ uiView: CanvasUIView, context: Context) {
        uiView.setNeedsDisplay()
    }
}

class CanvasUIView: UIView {
    private var shapeLayer: CAShapeLayer?
    private var currentPath: UIBezierPath?
    private var currentColor: UIColor = .black
    private var currentSize: CGFloat = 5.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
    }
    
    func startNewPath(at point: CGPoint, color: UIColor, size: CGFloat) {
        currentPath = UIBezierPath()
        currentPath?.lineWidth = size
        currentPath?.move(to: point)
        
        currentColor = color
        currentSize = size
        
        let newShapeLayer = CAShapeLayer()
        newShapeLayer.strokeColor = color.cgColor
        newShapeLayer.fillColor = nil
        newShapeLayer.lineWidth = size
        newShapeLayer.lineCap = .round
        
        layer.addSublayer(newShapeLayer)
        shapeLayer = newShapeLayer
    }
    
    func addPointToCurrentPath(_ point: CGPoint) {
        guard let currentPath = currentPath else { return }
        currentPath.addLine(to: point)
        
        shapeLayer?.path = currentPath.cgPath
        setNeedsDisplay()
    }
    
    func finishCurrentPath() {
        currentPath = nil
    }
    
    func createImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

extension Color {
    var uiColor: UIColor {
        return UIColor(self)
    }
}
