import SwiftUI
import SwiftUIX

class CardFormData: ObservableObject {
    @Published var front: String
    @Published var back: String
    @Published var reversed: Bool
    var isValid: Bool {
        !front.isEmpty
    }
    var isDraft: Bool {
        back.isEmpty
    }
    init() {
        front = ""
        back = ""
        reversed = false
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
                TextEditor(text: $formData.front)
                    .focused($focusedField, equals: .front)
                    .border(.secondary)
                    .maxHeight(100)
            }
            VStack(alignment: .leading) {
                Text("Back")
                TextEditor(text: $formData.back)
                    .focused($focusedField, equals: .back)
                    .border(.secondary)
                    .maxHeight(100)
            }
            HStack {
                Button("Flip fields", action: onFlipFields)
                    .disabled(!formData.isValid)
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

