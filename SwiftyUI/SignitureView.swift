//
//  SignitureView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/23/25.
//

import SwiftUI
import PencilKit

// TODO: - Sig View
/// PKCanvas Border ColorSource
/// PKCanvas CornerRadius / ClipShape

class SignatureViewModel: ObservableObject {
    
    @Published var drawing: PKDrawing = PKDrawing()
    
    @Published private(set) var inkingTool: PKInkingTool
    @Published private(set) var isDrawingEnabled: Bool
    private var drawingBounds: CGRect = .zero

    init(inkingTool: PKInkingTool = .init(.pen, color: .black, width: 1),
         isDrawingEnabled: Bool = true) {
        
        self.inkingTool = inkingTool
        self.isDrawingEnabled = isDrawingEnabled
        
    }

    func clear() {
        self.drawing = PKDrawing()
    }
    
    func setDrawingBounds(_ bounds: CGRect) {
        self.drawingBounds = bounds
    }
    
    func setInkingTool(_ inkingTool: PKInkingTool) {
        self.inkingTool = inkingTool
    }
    
    func snapshotImage(scale: CGFloat = UIScreen.main.scale) -> UIImage {
        
        return self.drawing.image(
            from: self.drawingBounds,
            scale: scale
        )
        
    }
    
}


struct SignatureView: View {
    
    @ObservedObject private var viewModel: SignatureViewModel
    @Binding private var signatureImage: UIImage?
    private let cornerRadius: CGFloat
    private let borderColor: Color
    private let borderWidth: CGFloat
    
    init(viewModel: SignatureViewModel,
         signatureImage: Binding<UIImage?>,
         cornerRadius: CGFloat = CornerRadius.large.value,
         borderColor: Color = .gray,
         borderWidth: CGFloat = 1) {
        
        self.viewModel = viewModel
        self._signatureImage = signatureImage
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        
    }
    
    var body: some View {
        
        GeometryReader { geo in
            
            CanvasRepresentable(
                drawing: $viewModel.drawing,
                tool: viewModel.inkingTool,
                isDrawingEnabled: viewModel.isDrawingEnabled
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(.rect(cornerRadius: self.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: self.cornerRadius)
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: self.borderWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .foregroundColor(self.borderColor)
            }
            .onAppear {
                self.viewModel.setDrawingBounds(geo.frame(in: .local))
            }
        }
        
    }
    
}

struct CanvasRepresentable: UIViewRepresentable {
    
    @Binding var drawing: PKDrawing
    let tool: PKInkingTool
    let isDrawingEnabled: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        
        let canvas = PKCanvasView()
        
        canvas.delegate = context.coordinator
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isDrawingEnabled = isDrawingEnabled
        canvas.tool = tool
        canvas.drawing = drawing
        
        return canvas
        
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
        // If the model's drawing changed (e.g. via clear()), apply it
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
        
        uiView.tool = tool
        uiView.isDrawingEnabled = isDrawingEnabled
        
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        
        var parent: CanvasRepresentable
        init(_ parent: CanvasRepresentable) { self.parent = parent }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            
            // Push PKCanvasView’s latest strokes back into the model
            parent.drawing = canvasView.drawing
            
        }
        
    }
    
}

#Preview {
    
    @Previewable @StateObject var viewModel = SignatureViewModel()
    @Previewable @State var signatureImage: UIImage?
    
    VStack {
        
        SignatureView(
            viewModel: viewModel,
            signatureImage: $signatureImage
        )
        .frame(height: 300)
        .padding(.horizontal, .large)
        
        HStack {
            Button("Clear") {
                viewModel.clear()
            }
        
            Button("Take Screenshot") {
                signatureImage = viewModel.snapshotImage()
            }
        
            Button("Toggle Pen") {
                
                viewModel
                    .setInkingTool(.init(
                        PKInkingTool.InkType.pen,
                        color: .random(),
                        width: .random(in: 1...1000)
                    ))
                
            }
            
        }
        .frame(height: 32)
        .padding(.vertical, 8)
        .compositingGroup()
        
        if let signatureImage {
            
            Image(uiImage: signatureImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .transition(.move(edge: .bottom).combined(with: .opacity).animation(.snappy))
            
        }
        
    }
    .animation(.snappy, value: signatureImage)
    
}
