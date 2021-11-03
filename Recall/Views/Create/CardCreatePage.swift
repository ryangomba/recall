import SwiftUI

struct CardCreatePage: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var formData = CardFormData()

    var body: some View {
        Page {
            CardForm(formData: formData)
        }
        .interactiveDismissDisabled()
        .navigationTitle("Add cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Exit") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: onSave)
                        .disabled(!formData.isValid)
                }
            }
    }

    func onSave() {
        CardService.createCard(
            front: formData.front,
            back: formData.back,
            tags: formData.isDraft ? ["draft"] : [],
            reversed: formData.reversed
        )
        formData.front = ""
        formData.back = ""
        formData.reversed = false
    }
}

struct CardCreatePage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardCreatePage()
        }
    }
}
