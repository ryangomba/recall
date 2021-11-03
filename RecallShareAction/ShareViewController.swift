import UIKit
import SwiftUI
import MobileCoreServices

@objc(ShareViewController)
class ShareViewController: UIViewController {
    let controller = UIHostingController(rootView: ShareView())

    override func viewDidLoad() {
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)

        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controller.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            controller.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            controller.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controller.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        handleSharedText()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func handleSharedText() {
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        let contentType = "public.plain-text"
        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(contentType) {
                provider.loadItem(forTypeIdentifier: contentType,
                                  options: nil) { [unowned self] (data, error) in
                    guard error == nil else { return }
                    if let text = data as? String {
                        self.saveTextAsDraft(text)
                    }
                }}
        }
    }

    private func saveTextAsDraft(_ text: String) {
        let appGroupName = "group.com.ryangomba.Recall"
        let userDefaults = UserDefaults(suiteName: appGroupName)!
        var drafts = userDefaults.object(forKey: "drafts") as? [String] ?? []
        drafts.append(text)
        userDefaults.set(drafts, forKey: "drafts")
    }

}
