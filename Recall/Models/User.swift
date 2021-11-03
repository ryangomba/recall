import Foundation

class User {
    var id: String
    var email: String?
    var displayName: String?

    init(id: String, email: String?, displayName: String?) {
        self.id = id
        self.email = email
        self.displayName = displayName
    }
}

let testUser = User(
    id: UUID().uuidString,
    email: nil,
    displayName: nil
)
