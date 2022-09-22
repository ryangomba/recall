import SwiftUI
import SwiftUIX
import UniformTypeIdentifiers

class CardFormData: ObservableObject {
    @Published var front: CardFace
    @Published var back: CardFace
    @Published var reversed: Bool
    var isValid: Bool {
        !front.text.isEmpty || front.attachment != nil
    }
    var isDraft: Bool {
        back.text.isEmpty && back.attachment == nil
    }
    init() {
        front = CardFace(text: "")
        back = CardFace(text: "")
        reversed = false
    }
}

struct CardAttachmentSelectionView: View {
    var attachment: CardAttachment?
    var action: (CardAttachment?) -> Void
    @State var isDropArea: Bool = false
    @State var isLoading: Bool = false

    var body: some View {
        if let attachment = attachment {
            Button(action: onRemoveAttachment) {
                AsyncImage(url: URL(string: attachment.src)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .width(40)
                .height(40)
                .border(isDropArea ? Color.red : Color.clear, width: 2)
                .clipped()
            }
            .buttonStyle(.plain) // for Mac
            .onDrop(of: [UTType.image, UTType.url], isTargeted: $isDropArea) { providers, location in
                // TODO
                if let provider = providers.first {
                    if provider.hasRepresentationConforming(toTypeIdentifier: UTType.url.identifier) {
                        provider.loadDataRepresentation(forTypeIdentifier: UTType.url.identifier) { data, error in
                            if let data = data {
                                let url = URL(dataRepresentation: data, relativeTo: nil)
                                print(url?.absoluteString)
                            }
                        }
//                        provider.loadItem(forTypeIdentifier: UTType.url, options: nil) { value, error in
//                            <#code#>
//                        }
                    }
                    if provider.hasRepresentationConforming(toTypeIdentifier: UTType.image.identifier) {
                        provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                            if let data = data {
                                isLoading = true
                                FileService.uploadJPEGImageData(data: data) { attachment in
                                    isLoading = false
                                    action(attachment)
                                }
                            }
                        }
                    }
                }
                return true
            }
        } else {
            Button("Attach", action: onAddAttachment)
        }
    }

    private func onRemoveAttachment() {
        action(nil)
    }

    private func onAddAttachment() {
        let attachment = CardAttachment(
            type: "image/jpeg",
            src: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/San_Diego_Paramylodon.jpg/2880px-San_Diego_Paramylodon.jpg",
            aspectRatio: 1.81316826
        )
        action(attachment)
    }
}

struct CardForm: View {
    enum Field: Hashable {
        case front
        case back
    }
    @ObservedObject var formData: CardFormData
    @FocusState private var focusedField: Field?

    init(formData: CardFormData) {
        self.formData = formData
        UITextView.appearance().textContainerInset = UIEdgeInsets(top: 16, left: 10, bottom: 16, right: 10)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading) {
                Text("Front")
                TextEditor(text: $formData.front.text)
                    .focused($focusedField, equals: .front)
                    .border(.secondary)
                    .maxHeight(100)
                CardAttachmentSelectionView(attachment: formData.front.attachment) { attachment in
                    formData.front.attachment = attachment
                }
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("Back")
                    Spacer()
                    Button(systemImage: .arrowUpArrowDown, action: onFlipFields)
                        .disabled(!formData.isValid)
                }
                TextEditor(text: $formData.back.text)
                    .focused($focusedField, equals: .back)
                    .border(.secondary)
                    .maxHeight(100)
                CardAttachmentSelectionView(attachment: formData.back.attachment) { attachment in
                    formData.back.attachment = attachment
                }
            }
            HStack {
                Spacer()
                Text("Reverse")
                Toggle("Reverse", isOn: $formData.reversed)
                    .labelsHidden()
            }
            Spacer()
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + DISMISSAL_DURATION) {
                focusedField = .front
            }
        }
    }

    func onFlipFields() {
        let oldFront = formData.front
        formData.front = formData.back
        formData.back = oldFront
    }
}

struct CardForm_Previews: PreviewProvider {
    static var previews: some View {
        CardForm(formData: CardFormData())
    }
}

