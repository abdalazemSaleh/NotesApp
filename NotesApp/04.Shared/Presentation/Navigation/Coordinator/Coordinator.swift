import UIKit

protocol Coordinator: AnyObject {
    var router: Router { get }
    var currentViewController: UIViewController { get }
    
    func start()
}

extension Coordinator {
    var currentViewController: UIViewController {
        return router.navigationController.visibleViewController!
    }
    
    func dismiss(completion: @escaping () -> Void = {} ) {
        router.dismiss(animated: true, completion: completion)
    }
    
    func popToRoot(completion: @escaping () -> Void = { }) {
        router.popToRoot(animated: false, completion: completion)
    }
    
    func pop() {
        router.pop(animated: true, completion: {})
    }
    
    func showAlert(alert: UIAlertController) {
        router.present(alert)
    }
    
    func showImagePicker(isRemoveButtonHidden: Bool, removePhoto: @escaping () -> Void = { }, completion: @escaping (UIImage) -> Void) {
        PhotoPickerManager.shared.presentPhotoPicker(from: currentViewController, removePhoto: removePhoto, isRemoveButtonHidden: isRemoveButtonHidden) { image in
            if let selectedImage = image {
                completion(selectedImage)
            }
        }
    }
    
    func showImagesPicker(photoLimit: Int = 0, completion: @escaping ([UIImage]) -> Void) {
        PhotosPickerManager.shared.presentPhotoPicker(from: currentViewController, photoLimit: photoLimit) { images in
            completion(images)
        }
    }
    
    func presentFullScreenFromPresnset(_ viewController: UIViewController, animated: Bool = false, completion: @escaping () -> Void = {}) {
        viewController.modalPresentationStyle = .custom
        currentViewController.present(viewController, animated: animated, completion: completion)
    }
    
    func popToViewController<T: UIViewController>(ofType type: T.Type, animated: Bool = true) {
        if let viewController = router.navigationController.viewControllers.first(where: { $0 is T }) {
            router.navigationController.popToViewController(viewController, animated: animated)
        }
    }
    
    func openAppLanguageSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    func openURLInSafari(_ urlString: String) {
        guard let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else {
            print("Invalid or unsupported URL")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
