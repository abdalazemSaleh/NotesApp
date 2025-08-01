import UIKit

class PhotoPickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    static let shared = PhotoPickerManager()
    private var completion: ((UIImage?) -> Void)?
    private var presentingViewController: UIViewController?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    func presentPhotoPicker(from viewController: UIViewController, removePhoto: (() -> Void)?, isRemoveButtonHidden: Bool, completion: @escaping (UIImage?) -> Void) {
        self.presentingViewController = viewController
        self.completion = completion
        
        let alert = UIAlertController(title: "photo_picker.t".localized(from: .MainApp), message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "camera.t".localized(from: .MainApp), style: .default, handler: { _ in
            self.openPicker(type: .camera)
        }))
        
        alert.addAction(UIAlertAction(title: "gallery.t".localized(from: .MainApp), style: .default, handler: { _ in
            self.openPicker(type: .photoLibrary)
        }))

        if !isRemoveButtonHidden {
            alert.addAction(UIAlertAction(title: "remove.t".localized(from: .MainApp), style: .destructive, handler: { _ in
                removePhoto?()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "cancel.t".localized(from: .MainApp), style: .cancel, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    private func openPicker(type: UIImagePickerController.SourceType) {
        guard let viewController = presentingViewController else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.allowsEditing = false
        picker.delegate = self
        viewController.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        picker.dismiss(animated: true) {
            self.completion?(image)
            self.completion = nil // Clear completion to prevent future calls
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.completion?(nil) // Return nil if canceled
            self.completion = nil
        }
    }
}

import PhotosUI
import UIKit

class PhotosPickerManager: NSObject {
    
    // MARK: - Properties
    static let shared = PhotosPickerManager()
    private var completion: (([UIImage]) -> Void)?
    private var presentingViewController: UIViewController?
    private var photoLimit: Int?
    private var capturedImages: [UIImage] = []
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    func presentPhotoPicker(from viewController: UIViewController, photoLimit: Int, completion: @escaping ([UIImage]) -> Void) {
        self.presentingViewController = viewController
        self.photoLimit = photoLimit
        self.completion = completion
        self.capturedImages = []

        let alert = UIAlertController(
            title: "photo_picker.t".localized(from: .MainApp),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: "camera.t".localized(from: .MainApp),
            style: .default,
            handler: { _ in self.openCamera() }
        ))
        
        alert.addAction(UIAlertAction(
            title: "gallery.t".localized(from: .MainApp),
            style: .default,
            handler: { _ in self.openPhotoLibrary() }
        ))
        
        alert.addAction(UIAlertAction(
            title: "cancel.t".localized(from: .MainApp),
            style: .cancel,
            handler: nil
        ))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func openCamera() {
        guard let viewController = presentingViewController else { return }
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        viewController.present(picker, animated: true, completion: nil)
    }
    
    private func openPhotoLibrary() {
        guard let viewController = presentingViewController else { return }
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = photoLimit ?? 0
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        viewController.present(picker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension PhotosPickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                self.capturedImages.append(image)
            }

            let currentCount = self.capturedImages.count
            let maxCount = self.photoLimit ?? 0

            if currentCount < maxCount {
                // Ask if user wants to take another photo
                let alert = UIAlertController(
                    title: "Take another photo?",
                    message: "You've taken \(currentCount) out of \(maxCount) photos.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                    self.openCamera()
                })
                alert.addAction(UIAlertAction(title: "No", style: .cancel) { _ in
                    self.completion?(self.capturedImages)
                    self.completion = nil
                    self.capturedImages = []
                })
                self.presentingViewController?.present(alert, animated: true, completion: nil)
            } else {
                self.completion?(self.capturedImages)
                self.completion = nil
                self.capturedImages = []
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.completion?(self.capturedImages)
            self.completion = nil
            self.capturedImages = []
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension PhotosPickerManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else {
            completion?([])
            completion = nil
            return
        }
        
        var images: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    defer { dispatchGroup.leave() }
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.completion?(images)
            self.completion = nil
        }
    }
}
