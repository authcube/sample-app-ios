//
//  DashboardView.swift
//  AppSample
//
//  Created by Alex Eduardo Chiaranda on 27/12/24.
//
import AVFoundation
import SwiftUI

struct DashboardView: View {
    // parameters
    @ObservedObject var viewModel: AppSampleViewModel
    var changeAuthenticationState: (Bool) -> Void
    
    @AppStorage("url_idp") private var urlIdp: String = ""
    
    @State private var selectedTab = 0
    @State private var isShowingQrScanner = false
    
    @State private var isLoading = false
    @State private var feedbackMessage: String?

    
    private let tabBarHeight: CGFloat = 49
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                
                HomeTabView(viewModel: viewModel, changeAuthenticationState: changeAuthenticationState)
                    .tabItem{
                        Label("Home", systemImage: "house.fill")
                    }.tag(0)
                
                RiskTabView(viewModel: viewModel)
                    .tabItem{
                        Label("Risk", systemImage: "exclamationmark.triangle.fill")
                    }.tag(1)
                
                StrongTabView(viewModel: viewModel)
                    .tabItem{
                        Label("Strong", systemImage: "key.fill")
                    }.tag(2)
                
                ConnectTabView(viewModel: viewModel)
                    .tabItem{
                        Label("Connect", systemImage: "person.fill")
                    }.tag(3)
                
            } // -- tab
            .accentColor(Color(hex: "#333333")) // Set the tab bar's accent color
            .navigationBarBackButtonHidden(true)
            .padding(.vertical, 20)
            
            cameraButton()
            
            
        } // -- ZStack
        
        .sheet(isPresented: $isShowingQrScanner) {
            QRCodeScannerView(isPresented: $isShowingQrScanner) { result in

                switch result {
                case .success(let code):
                    let urlString = code.string
                    print("QR Code found: \(urlString)")

                    // 1. Valida se é uma URL válida
                    guard let url = URL(string: urlString) else {
                        print("QR Code string is not a valid URL: \(urlString)")
                        self.feedbackMessage = "QR Code does not contain a valid URL."
                        return
                    }
                    
//                    self.isShowingQrScanner = false

                    // 2. Call the function to make the request in the background
                    performBackgroundRequest(url: url)

                case .failure(let error):
                    print("Error scanning: \(error.localizedDescription)")
                }
            }
        } // -- sheet
        .alert("Result", isPresented: .constant(feedbackMessage != nil), actions: {
            Button("OK") { feedbackMessage = nil }
        }, message: {
            Text(feedbackMessage ?? "Unknown message.")
        }) // -- alert
        .overlay {
            if isLoading {
                ProgressView("Sending ...")
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
            }
        } // -- overlay
        
        
    } // -- body
    
    
    @ViewBuilder
    private func cameraButton() -> some View {
        Button {
            // Action: Activate the presentation of the QR code scanner
            print("Camera Button Pressed")
            self.isShowingQrScanner = true
        } label: {
            Image(systemName: "camera.fill") // Camera Icon
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25) // Icon Size
                .padding(15) // Internal spacing to increase touch area and background size
                .background(Color(hex: "#333333")) // Button background color
                .foregroundColor(.white) // Icon color
                .clipShape(Circle()) // Make the button round
                .shadow(radius: 5) // Adds a shadow to highlight
        }
        // Positioning: Move the button up to overlay the TabView
        // Adjust the Y value (-30 is a starting point) as needed
        // to obtain the desired visual effect.
        .offset(y: -tabBarHeight / 2 - 5) // Center vertically on the top edge and shift a little higher
    } // -- cameraButton
    
    // Mark: - Perform Background Request
    // Function to perform the request in the background
    func performBackgroundRequest(url: URL) {
        isLoading = true // show loading indicator during request
        feedbackMessage = nil
        
        viewModel.appDelegate.getAuthState()!.performAction() { (accessToken, idToken, error) in
            
            if error != nil  {
                print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            guard let accessToken = accessToken else {
                return
            }
            
            guard let urlIDP = URL(string :urlIdp) else {
                print("IDP URL is invalid") // should never happen
                feedbackMessage = "Error converting IDP url to an URL Object"
                isLoading = false
                return
            }
            
            
            if !url.hasSameBase(as: urlIDP) {
                print("QRCode URL does not match with IDP URL FQDN")
                self.feedbackMessage = "QRCode URL does not match with IDP URL FQDN"
                isLoading = false
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET" // Exemplo: GET request
            request.allHTTPHeaderFields = ["Authorization": "Bearer \(accessToken)"]
            // request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // GO BACK TO MAIN THREAD to update the UI (isLoading, feedbackMessage)
                DispatchQueue.main.async {
                    self.isLoading = false // Esconde indicador
                    
                    // 1. Check network error
                    if let error = error {
                        print("Request error: \(error.localizedDescription)")
                        self.feedbackMessage = "Network error: \(error.localizedDescription)"
                        return
                    }
                    
                    // 2. Check the HTTP response
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("Invalid response.")
                        self.feedbackMessage = "Invalid response from server."
                        return
                    }
                    
                    // 3. Check the status code of the response
                    print("Status Code: \(httpResponse.statusCode)")
                    if (200...299).contains(httpResponse.statusCode) {
                        print("Request successful!")
                        self.feedbackMessage = "Request sent successfully!"
                    } else {
                        print("Server error: Status \(httpResponse.statusCode)")
                        self.feedbackMessage = "Server error (Status: \(httpResponse.statusCode))."
                    }
                }
            }
            // Inicia a tarefa de rede
            task.resume()
            
        }
        
        
    } // -- performBackgroundRequest
 
}



struct DashboardView_Previews: PreviewProvider {
    
    static var previews: some View {
        let _appDelegate = AppDelegate()
        DashboardView(viewModel: AppSampleViewModel(appDelegate: _appDelegate), changeAuthenticationState: {_ in })
    }
}




// MARK: - Scanner's View

struct QRCodeScannerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var completion: (Result<ScanResult, ScanError>) -> Void
    
    func makeUIViewController(context: Context) -> QRCodeScannerViewController {
        let controller = QRCodeScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRCodeScannerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator to handle UIKit ViewController delegate
    class Coordinator: NSObject, QRCodeScannerViewControllerDelegate {
        var parent: QRCodeScannerView
        
        init(_ parent: QRCodeScannerView) {
            self.parent = parent
        }
        
        func qrScanningDidFail() {
            parent.completion(.failure(.badInput))
            parent.isPresented = false
        }
        
        func qrScanningSucceededWithCode(_ code: String?) {
            guard let code = code else {
                parent.completion(.failure(.badOutput)) // no code found
                parent.isPresented = false
                return
            }
            // Cria um objeto ScanResult simulado
            let result = ScanResult(string: code, type: .qr)
            parent.completion(.success(result)) // completion already closes the sheet in MainTabView
        }
        
        func qrScanningDidStop() {
            parent.isPresented = false
        }
    }
}


// MARK: -- Scanner Types
struct ScanResult {
    let string: String
    let type: AVMetadataObject.ObjectType // using AVFoundation directly
}

enum ScanError: Error {
    case badInput
    case badOutput
    case permissionDenied
}

// MARK: --- Scanner's ViewController UIKit
protocol QRCodeScannerViewControllerDelegate: AnyObject {
    func qrScanningDidFail()
    func qrScanningSucceededWithCode(_ code: String?)
    func qrScanningDidStop()
}

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: QRCodeScannerViewControllerDelegate?
    
    // draw square around qrcode
    private var qrCodeHighlightLayer: CAShapeLayer?
    
    // flag to signalize to scanning is stopping
    private var isStopping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        checkCameraPermissions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset a flag to allow new scans
        isStopping = false
        
        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }
    
    func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { self?.setupCamera() }
                } else {
                    self?.scanningFailed()
                }
            }
        default:
            scanningFailed() // Permission denied or restricted
        }
    }
    
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            // the simulator does not have access to the camera
            print("Failed to get camera - simulator ?")
            scanningFailed()
            return
        }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to create input: \(error)")
            scanningFailed()
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            print("Cannot add input")
            scanningFailed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr] // Especifica QR Code
        } else {
            print("Cannot add output")
            scanningFailed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // draw square
        setupQRCodeHighlightLayer()
        
        // Starts the session in the background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            print("Starting AV session")
            self?.captureSession.startRunning()
        }
        
        // Adds the Cancel Button
        addCancelButton()
    }
    
    func setupQRCodeHighlightLayer() {
        let highlightLayer = CAShapeLayer()
        
        // line color
//        highlightLayer.strokeColor = UIColor.green.cgColor
        highlightLayer.strokeColor = UIColor(hex: "#DA291C")!.cgColor
        
        // Line thickness
        highlightLayer.lineWidth = 5
        
        // transparent box
        highlightLayer.fillColor = UIColor.clear.cgColor
        
        // add this layer to view layer
        // Make sure it is ABOVE the previewLayer
        view.layer.addSublayer(highlightLayer)
        self.qrCodeHighlightLayer = highlightLayer // Save the reference
    }
    
    func addCancelButton() {
        let cancelButton = UIButton(type: .system)
        cancelButton.frame = CGRect(x: 20, y: 40, width: 100, height: 50) // top right corner
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.layer.cornerRadius = 5
        view.addSubview(cancelButton)
        view.bringSubviewToFront(cancelButton)
    }
    
    @objc func cancelTapped() {
        print("Scanner canceled by user")
        stopScanningAndDismiss(withCode: nil, failure: true)
    }
    
    func scanningFailed() {
        print("Scan failed (permission or setup)")
        delegate?.qrScanningDidFail()
        // There is no need to call dismiss here, as the delegate takes care of this via binding.
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Remove qualquer destaque anterior (limpa a caixa)
        // Fazemos isso no início de cada chamada do delegate
        DispatchQueue.main.async { // Garante execução na main thread para UI updates
            self.qrCodeHighlightLayer?.path = nil
        }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            
            
            // --- START DRAW BOX ---
            // Transforms the coordinates of the detected object to the coordinate system of the preview layer
            guard let transformedObject = previewLayer?.transformedMetadataObject(for: readableObject) as? AVMetadataMachineReadableCodeObject else { return }
            
            // Creates the path for the box using the detected corners
            let qrCodePath = UIBezierPath()
            if !transformedObject.corners.isEmpty {
                // Move to the first corner
                qrCodePath.move(to: transformedObject.corners[0])
                // Draw lines to the other corners
                for i in 1..<transformedObject.corners.count {
                    qrCodePath.addLine(to: transformedObject.corners[i])
                }
                // Close the path by returning to the first corner
                qrCodePath.close()
                
                // Updates the highlight layer with the new path (in the main thread)
                DispatchQueue.main.async {
                    self.qrCodeHighlightLayer?.path = qrCodePath.cgPath
                }
            }
            // --- END OF BOX ---
            
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) // Feedback
            stopScanningAndDismiss(withCode: stringValue)
        }
    }
    
    func stopScanningAndDismiss(withCode code: String?, failure: Bool = false) {
        
        guard !isStopping else {
            print("Already read a qrcode, dismiss multipe attemps")
            return
        }
        // flag the scanning is STOPPING, to prevent multiple readings
        isStopping = true
        
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                print("Stoping AV session")
                self?.captureSession.stopRunning()
                // Calls delegate in main thread after stopping
                DispatchQueue.main.async {
                    if failure {
                        self?.delegate?.qrScanningDidFail()
                    } else {
                        self?.delegate?.qrScanningSucceededWithCode(code)
                    }
                }
            }
        } else {
            // If the session was not running but we need to call the delegate (e.g. cancel before starting)
            DispatchQueue.main.async {
                if failure {
                    self.delegate?.qrScanningDidFail()
                } else {
                    self.delegate?.qrScanningSucceededWithCode(code)
                }
            }
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true //hide status bar in camera view
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait // lock in portrait mode
    }
}
