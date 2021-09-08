import SwiftUI

#if os(macOS)

struct DocumentPicker: View {
    
    @Binding var isPresented: Bool
    var documentTypes: [String] // [kUTTypeFolder as String]
    var onCancel: () -> ()
    var onDocumentsPicked: (_: [URL]) -> ()
    
    init(
        isPresented: Binding<Bool>,
        documentTypes: [String],
        onCancel: @escaping () -> (),
        onDocumentsPicked: @escaping (_: [URL]) -> ()
    ) {
        self._isPresented = isPresented
        self.documentTypes = documentTypes
        self.onCancel = onCancel
        self.onDocumentsPicked = onDocumentsPicked
    }
    
    var body: some View {
        Color.clear.frame(width: 0, height: 0)
            .id(isPresented)
            .onAppear {
                if self.isPresented {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = true
                    panel.canChooseDirectories = true
                    panel.allowedFileTypes = self.documentTypes
                    panel.resolvesAliases = true
                    panel.isAccessoryViewDisclosed = false
                    
                    // panel.allowsMultipleSelection = true
                    // panel.directoryURL = URL()
                    
                    let result = panel.runModal()
                    guard result == .OK else {
                        self.isPresented.toggle()
                        self.onCancel()
                        return
                    }
                    self.isPresented.toggle()
                    self.onDocumentsPicked(panel.urls)
                }
            }
    }
}

#else
import UIKit

struct DocumentPicker: UIViewControllerRepresentable {
    
    class Coordinator: NSObject {
        
        var parent: DocumentPicker
        var pickerController: UIDocumentPickerViewController
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
            self.pickerController = UIDocumentPickerViewController(documentTypes: parent.documentTypes,
                in: .open)
            
            super.init()
            pickerController.delegate = self
        }
    }
    
    @Binding var isPresented: Bool
    var documentTypes: [String] // [kUTTypeFolder as String]
    var onCancel: () -> ()
    var onDocumentsPicked: (_: [URL]) -> ()
    
    init(
        isPresented: Binding<Bool>,
        documentTypes: [String],
        onCancel: @escaping () -> (),
        onDocumentsPicked: @escaping (_: [URL]) -> ()
    ) {
        self._isPresented = isPresented
        self.documentTypes = documentTypes
        self.onCancel = onCancel
        self.onDocumentsPicked = onDocumentsPicked
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ presentingController: UIViewController, context: Context) {
        let pickerController = context.coordinator.pickerController
        pickerController.presentationController?.delegate = context.coordinator
        
        if isPresented && !pickerController.isBeingPresented {
            DispatchQueue.main.async {
                isPresented = false
            }
            pickerController.allowsMultipleSelection = true
            presentingController.present(pickerController, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension DocumentPicker.Coordinator: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        parent.onDocumentsPicked(urls)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        parent.onCancel()
    }
}

extension DocumentPicker.Coordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        parent.onCancel()
    }
}
#endif


struct MSCDocumentPicker: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: false)
        controller.allowsMultipleSelection = true
        controller.delegate = context.coordinator
        controller.presentationController?.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    typealias UIViewControllerType = UIDocumentPickerViewController
    
    func makeCoordinator() -> MSCDocumentPickerCoordinator {
        MSCDocumentPickerCoordinator()
    }
}

class MSCDocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UIAdaptivePresentationControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            print(url)
        }
    }
}
