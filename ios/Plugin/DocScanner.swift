import UIKit
import VisionKit

/**
 This class uses VisonKit to start a document scan. It either returns the cropped images in base64 or as file paths
 depending on the configuration.
 */
@available(iOS 13.0, *)
public class DocScanner: NSObject, VNDocumentCameraViewControllerDelegate {
    
    /** @property  viewController the document scanner gets called from this view controller */
    private var viewController: UIViewController?
    
    /** @property  successHandler a callback triggered when the user completes the document scan successfully */
    private var successHandler: ([String]) -> Void
    
    /** @property  errorHandler a callback triggered when there's an error */
    private var errorHandler: (String) -> Void
    
    /** @property  cancelHandler a callback triggered when the user cancels the document scan */
    private var cancelHandler: () -> Void
    
    /** @property  responseType determines the format response (base64 or file paths) */
    private var responseType: String

    /** @property  croppedImageQuality the 0 - 100 quality of the cropped image */
    private var croppedImageQuality: Int

    /** @property  maxNumDocuments the maximum number of documents to scan */
    private var maxNumDocuments: Int

    /** @property  scannedDocumentsCount tracks the number of documents already scanned */
    private var scannedDocumentsCount: Int = 0

    /** @property  allScannedResults stores all scanned results across multiple scans */
    private var allScannedResults: [String] = []

    /** @property  documentCameraViewController reference to the document scanner for manual dismissal */
    private var documentCameraViewController: VNDocumentCameraViewController?

    /** @property  toastLabel reference to the toast message label */
    private var toastLabel: UILabel?

    /**
     constructor for DocScanner

     @param     viewController      the ViewController that starts the document scan
     @param     successHandler      a callback triggered when the user completes the document scan successfully
     @param     errorHandler        a callback triggered when there's an error
     @param     cancelHandler       a callback triggered when the user cancels the document scan
     @param     responseType        determines the format response (base64 or file paths)
     @param     croppedImageQuality the 0 - 100 quality of the cropped image
     @param     maxNumDocuments     the maximum number of documents to scan

     @return    Returns a DocScanner
     */
    public init(
        _ viewController: UIViewController? = nil,
        successHandler: @escaping ([String]) -> Void = {_ in },
        errorHandler: @escaping (String) -> Void = {_ in },
        cancelHandler: @escaping () -> Void = {},
        responseType: String = ResponseType.imageFilePath,
        croppedImageQuality: Int = 100,
        maxNumDocuments: Int = Int.max
    ) {
        self.viewController = viewController
        self.successHandler = successHandler
        self.errorHandler = errorHandler
        self.cancelHandler = cancelHandler
        self.responseType = responseType
        self.croppedImageQuality = croppedImageQuality
        self.maxNumDocuments = maxNumDocuments
    }
    
    /**
     constructor for DocScanner
     
     @return    Returns a DocScanner
     */
    public convenience override init() {
        self.init(nil)
    }
    
    /**
     opens the camera, and starts the document scan
     */
    public func startScan() {
        // Reset counters for new scan session
        self.scannedDocumentsCount = 0
        self.allScannedResults = []

        // make sure device has the ability to scan documents
        if (!VNDocumentCameraViewController.isSupported) {
            self.errorHandler("Document scanning is not supported on this device")
            return
        }
        
        DispatchQueue.main.async {
            // launch the document scanner
            let documentCameraViewController = VNDocumentCameraViewController()
            documentCameraViewController.delegate = self
            self.documentCameraViewController = documentCameraViewController
            self.viewController?.present(documentCameraViewController, animated: true)
        }
    }
    
    /**
     opens the camera, and starts the document scan

     @param     viewController      the ViewController that starts the document scan
     @param     successHandler      a callback triggered when the user completes the document scan successfully
     @param     errorHandler        a callback triggered when there's an error
     @param     cancelHandler       a callback triggered when the user cancels the document scan
     @param     responseType        determines the format response (base64 or file paths)
     @param     croppedImageQuality the 0 - 100 quality of the cropped image
     @param     maxNumDocuments     the maximum number of documents to scan
     */
    public func startScan(
        _ viewController: UIViewController? = nil,
        successHandler: @escaping ([String]) -> Void = {_ in },
        errorHandler: @escaping (String) -> Void = {_ in },
        cancelHandler: @escaping () -> Void = {},
        responseType: String? = ResponseType.imageFilePath,
        croppedImageQuality: Int? = 100,
        maxNumDocuments: Int? = Int.max
    ) {
        self.viewController = viewController
        self.successHandler = successHandler
        self.errorHandler = errorHandler
        self.cancelHandler = cancelHandler
        self.responseType = responseType ?? ResponseType.imageFilePath
        self.croppedImageQuality = croppedImageQuality ?? 100
        self.maxNumDocuments = maxNumDocuments ?? Int.max

        self.startScan()
    }
    
    /**
     This gets called on document scan success. Either return an array with cropped images in base64 format, or save the cropped
     images and return an array with image file paths
     
     @param controller  the ViewController that starts the document scan
     @param scan        contains details like number of pages scanned and UIImages for all scanned pages
     */
    public func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFinishWith scan: VNDocumentCameraScan
    ) {
        // Check if we've already reached the maximum number of documents
        if self.scannedDocumentsCount >= self.maxNumDocuments {
            // Show toast that limit has been reached
            self.showToast("Limite raggiunto: hai già scansionato \(self.maxNumDocuments) documento/i")
            return
        }

        var results: [String] = []
        
        // Process only one page per scan session (since we're accumulating across multiple scans)
        for pageNumber in 0..<scan.pageCount {
            // If we've already processed enough documents, stop
            if self.scannedDocumentsCount >= self.maxNumDocuments {
                break
            }

            // convert scan UIImage to jpeg data
            guard let scannedDocumentImage: Data = scan
                .imageOfPage(at: pageNumber)
                .jpegData(compressionQuality: CGFloat(self.croppedImageQuality) / CGFloat(100)) else {
                goBackToPreviousView(controller)
                self.errorHandler("Unable to get scanned document in jpeg format")
                return
            }
            
            switch responseType {
                case ResponseType.base64:
                    // convert scan jpeg data to base64
                    let base64EncodedImage: String = scannedDocumentImage.base64EncodedString()
                    results.append(base64EncodedImage)
                case ResponseType.imageFilePath:
                    do {
                        // save scan jpeg
                        let croppedImageFilePath = FileUtil().createImageFile(self.scannedDocumentsCount)
                        try scannedDocumentImage.write(to: croppedImageFilePath)
                        
                        // store image file path
                        results.append(croppedImageFilePath.absoluteString)
                    } catch {
                        goBackToPreviousView(controller)
                        self.errorHandler("Unable to save scanned image: \(error.localizedDescription)")
                        return
                    }
                default:
                    self.errorHandler(
                        "responseType must be \(ResponseType.base64) or \(ResponseType.imageFilePath)"
                    )
            }
            
            // Increment counter after successfully processing a document
            self.scannedDocumentsCount += 1
        }
        
        // Add results to accumulated results
        self.allScannedResults.append(contentsOf: results)

        // Don't close the scanner - let user decide when to close
        // Show a toast message if limit has been reached
        if self.scannedDocumentsCount >= self.maxNumDocuments {
            self.showToast("Limite raggiunto! Hai scansionato \(self.scannedDocumentsCount)/\(self.maxNumDocuments) documenti", duration: 3.0)
        }
    }
    
    /**
     This gets called if the user cancels the document scan
     
     @param controller  the ViewController that starts the document scan
     */
    public func documentCameraViewControllerDidCancel(
        _ controller: VNDocumentCameraViewController
    ) {
        // exit document scanner
        goBackToPreviousView(controller)

        // If user has scanned some documents, return them instead of canceling
        if self.allScannedResults.count > 0 {
            self.successHandler(self.allScannedResults)
        } else {
            self.cancelHandler()
        }
    }

    /**
     This gets called if there's an error during the document scan
     
     @param controller      the ViewController that starts the document scan
     @param error           the error
     */
    public func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFailWithError error: Error
    ) {
        // exit document scanner
        goBackToPreviousView(controller)
        
        // return the error message
        self.errorHandler(error.localizedDescription)
    }
    
    /**
     returns the user back to the ViewController that starts the document scan
     
     @param controller      the ViewController that starts the document scan
     */
    private func goBackToPreviousView(_ controller: VNDocumentCameraViewController) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true)
        }
    }

    /**
     Shows a toast message on the screen that disappears automatically

     @param message    the message to display
     @param duration   the duration in seconds to show the toast (default 2 seconds)
     */
    private func showToast(_ message: String, duration: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            // Remove existing toast if present
            self.toastLabel?.removeFromSuperview()

            // Create toast label
            let toastLabel = UILabel()
            toastLabel.text = message
            toastLabel.textColor = .white
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            toastLabel.numberOfLines = 0
            toastLabel.clipsToBounds = true
            toastLabel.layer.cornerRadius = 8

            // Add padding
            toastLabel.translatesAutoresizingMaskIntoConstraints = false

            // Get the key window
            guard let keyWindow = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .filter({ $0.isKeyWindow })
                .first else {
                return
            }

            keyWindow.addSubview(toastLabel)
            self.toastLabel = toastLabel

            // Set constraints
            NSLayoutConstraint.activate([
                toastLabel.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor),
                toastLabel.bottomAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                toastLabel.leadingAnchor.constraint(greaterThanOrEqualTo: keyWindow.leadingAnchor, constant: 20),
                toastLabel.trailingAnchor.constraint(lessThanOrEqualTo: keyWindow.trailingAnchor, constant: -20)
            ])

            // Animate in
            toastLabel.alpha = 0
            UIView.animate(withDuration: 0.3) {
                toastLabel.alpha = 1
            }

            // Remove after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                UIView.animate(
                    withDuration: 0.3,
                    animations: {
                        toastLabel.alpha = 0
                    },
                    completion: { _ in
                        toastLabel.removeFromSuperview()
                    }
                )
            }
        }
    }
}

