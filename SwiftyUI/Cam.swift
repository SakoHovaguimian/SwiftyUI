//
//  CustomCameraView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/29/25.
//

import SwiftUI
import AVFoundation
import Photos

// **************************************
// MARK: - Capture Mode Enum
// **************************************

public enum CameraCaptureMode {
    case single(UIImage?)
    case multiple([UIImage])
    
    mutating func addPhoto(_ image: UIImage) {
        switch self {
        case .single:
            self = .single(image)
        case .multiple(var images):
            images.append(image)
            self = .multiple(images)
        }
    }
    
    var latestPhoto: UIImage? {
        switch self {
        case .single(let img): return img
        case .multiple(let imgs): return imgs.last
        }
    }
    
    var allPhotos: [UIImage] {
        switch self {
        case .single(let img): return img.map { [$0] } ?? []
        case .multiple(let imgs): return imgs
        }
    }
}

// **************************************
// MARK: - Service Protocol
// **************************************

public protocol NewCameraService: AnyObject {
    var session: AVCaptureSession { get }
    func configure() throws
    func start()
    func stop()
    func capturePhoto(_ completion: @escaping (Result<UIImage, Error>) -> Void)
}

// **************************************
// MARK: - Service Impl
// **************************************

public final class NewAVCameraService: NSObject, NewCameraService {
    
    public let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var captureCompletion: ((Result<UIImage, Error>) -> Void)?
    
    public func configure() throws {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back)
        else {
            session.commitConfiguration()
            throw CameraError.deviceUnavailable
        }
        
        let input = try AVCaptureDeviceInput(device: device)
        if session.canAddInput(input) {
            session.addInput(input)
            videoDeviceInput = input
        } else {
            session.commitConfiguration()
            throw CameraError.inputAddFailed
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        } else {
            session.commitConfiguration()
            throw CameraError.outputAddFailed
        }
        
        session.commitConfiguration()
    }
    
    public func start() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    public func stop() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    public func capturePhoto(_ completion: @escaping (Result<UIImage, Error>) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.isHighResolutionPhotoEnabled = true
        captureCompletion = completion
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// **************************************
// MARK: - AVCapturePhotoCaptureDelegate
// **************************************

extension NewAVCameraService: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput,
                            didFinishProcessingPhoto photo: AVCapturePhoto,
                            error: Error?) {
        
        if let error {
            captureCompletion?(.failure(error))
            captureCompletion = nil
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data)
        else {
            captureCompletion?(.failure(CameraError.imageCreationFailed))
            captureCompletion = nil
            return
        }
        
        captureCompletion?(.success(image))
        captureCompletion = nil
    }
}

// **************************************
// MARK: - Errors
// **************************************

public enum CameraError: LocalizedError {
    case permissionDenied
    case deviceUnavailable
    case inputAddFailed
    case outputAddFailed
    case imageCreationFailed
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied: return "Camera permission denied."
        case .deviceUnavailable: return "Back camera unavailable."
        case .inputAddFailed: return "Could not add camera input."
        case .outputAddFailed: return "Could not add photo output."
        case .imageCreationFailed: return "Failed to create image."
        }
    }
}

// **************************************
// MARK: - ViewModel
// **************************************

@MainActor
public final class CameraViewModel: ObservableObject {
    
    private let cameraService: NewCameraService
    
    @Published public var captureMode: CameraCaptureMode
    @Published public var errorMessage: String?
    @Published public var isShutterDisabled: Bool = false
    
    public init(mode: CameraCaptureMode = .single(nil),
                cameraService: NewCameraService = NewAVCameraService()) {
        self.captureMode = mode
        self.cameraService = cameraService
    }
    
    public var session: AVCaptureSession {
        cameraService.session
    }
    
    public func setup() {
        Task {
            let status = await AVCaptureDevice.requestAccess(for: .video)
            if !status {
                errorMessage = CameraError.permissionDenied.localizedDescription
                return
            }
            
            do {
                try cameraService.configure()
                cameraService.start()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    public func teardown() {
        cameraService.stop()
    }
    
    public func shutter() {
        isShutterDisabled = true
        cameraService.capturePhoto { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let image):
                    self.captureMode.addPhoto(image)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
                self.isShutterDisabled = false
            }
        }
    }
}

// **************************************
// MARK: - Preview Layer Host
// **************************************

public struct CameraPreviewView: UIViewRepresentable {
    public let session: AVCaptureSession
    
    public func makeUIView(context: Context) -> Preview {
        let view = Preview()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    public func updateUIView(_ uiView: Preview, context: Context) {}
    
    public final class Preview: UIView {
        override public class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        public var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

// **************************************
// MARK: - Shutter Button
// **************************************

public struct ShutterButton: View {
    let size: CGFloat
    let action: () -> Void
    let disabled: Bool
    
    public init(size: CGFloat = 78,
                disabled: Bool,
                action: @escaping () -> Void) {
        self.size = size
        self.disabled = disabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .strokeBorder(.white.opacity(0.9), lineWidth: 4)
                    .frame(width: size, height: size)
                Circle()
                    .fill(.white)
                    .frame(width: size - 14, height: size - 14)
            }
        }
        .buttonStyle(.plain)
        .opacity(disabled ? 0.6 : 1)
        .scaleEffect(disabled ? 0.98 : 1)
        .disabled(disabled)
    }
}

// **************************************
// MARK: - Camera View
// **************************************

public struct CustomCameraView: View {
    
    @StateObject var viewModel = CameraViewModel(mode: .multiple([])) // change to .single(nil) if you want single mode
    
    public init() {}
    
    public var body: some View {
        ZStack {
            CameraPreviewView(session: viewModel.session)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.bottom, 8)
                }
                
                HStack {
                    Spacer()
                    ShutterButton(disabled: viewModel.isShutterDisabled) {
                        viewModel.shutter()
                    }
                    Spacer()
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear { viewModel.setup() }
        .onDisappear { viewModel.teardown() }
        .overlay(alignment: .topTrailing) {
            if let img = viewModel.captureMode.latestPhoto {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(.white.opacity(0.8), lineWidth: 1)
                    )
                    .padding(.top, 18)
                    .padding(.trailing, 18)
                    .shadow(radius: 6)
            }
        }
    }
}

#Preview {
    
    CustomCameraView()
    
}
