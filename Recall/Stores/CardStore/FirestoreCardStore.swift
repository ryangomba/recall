import Foundation
import FirebaseFirestore
import Combine

class FirestoreCardStore: CardStore {
    private var store: Firestore
    private let path: String = "cards"

    init() {
        store = Firestore.firestore()
    }

    func get(id: String, onRecordReceived: @escaping (Card) -> Void) -> AnyCancellable {
        let reg = store.collection(path).document(id)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                let card = self.cardFromDocument(document)
                onRecordReceived(card)
            }
        return AnyCancellable {
            reg.remove()
        }
    }

    func query(_ params: CardQueryParams, onRecordsReceived: @escaping ([Card]) -> Void) -> AnyCancellable {
        let query = store.collection(path)
            .whereField("userID", isEqualTo: params.userID)
        let reg = query.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error getting cards: \(error.localizedDescription)")
                return
            }
            var cards: [Card] = querySnapshot?.documents.compactMap { document in
                return self.cardFromDocument(document)
            } ?? []
            cards = queryCardArray(cards: cards, params: params)
            onRecordsReceived(cards)
        }
        return AnyCancellable {
            reg.remove()
        }
    }

    func create(_ card: Card) {
        store.collection(path).addDocument(data: documentDataFromCard(card))
    }

    func update(_ card: Card) {
        store.collection(path).document(card.id).setData(documentDataFromCard(card))
    }

    private func delete(id: String) {
        store.collection(path).document(id).delete { error in
            if let error = error {
                print("Unable to remove card: \(error.localizedDescription)")
            }
        }
    }

    func delete(ids: Set<String>) {
        ids.forEach { id in
            delete(id: id)
        }
    }

    private func attachmentFromData(_ data: [String: Any]) -> CardAttachment {
        return CardAttachment(
            type: data["type"] as! String,
            src: data["src"] as! String,
            aspectRatio: data["aspectRatio"] as! Float?
        )
    }

    private func cardFaceFromData(_ data: Any) -> CardFace {
        if let text = data as? String {
            return CardFace(text: text)
        }
        let map = data as! [String: Any]
        let text = map["text"] as! String
        var attachment: CardAttachment?
        if let attachmentData = map["attachment"] as? [String: Any] {
            attachment = attachmentFromData(attachmentData)
        }
        return CardFace(text: text, attachment: attachment)
    }

    private func cardFromDocument(_ document: DocumentSnapshot) -> Card {
        guard let data = document.data() else {
            fatalError("No data for document")
        }
        let userID = data["userID"] as! String
        let createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
        let front = cardFaceFromData(data["front"]!)
        let back = cardFaceFromData(data["back"]!)
        let nextReviewAt = data["nextReviewAt"] as! Timestamp
        let tags = data["tags"] as? [String] ?? []
        let reviewDatas = data["reviews"] as? [[String: Any]] ?? []
        let reviews = reviewDatas.map { data -> Review in
            let createdAt = data["createdAt"] as! Timestamp
            let result = data["result"] as! Bool
            return Review(createdAt: createdAt.dateValue(), result: result)
        }
        let reversedCardID = data["reversedCardID"] as! String?
        return Card(
            id: document.documentID,
            userID: userID,
            createdAt: createdAt.dateValue(),
            front: front,
            back: back,
            nextReviewAt: nextReviewAt.dateValue(),
            tags: Set(tags),
            reviews: reviews,
            reversedCardID: reversedCardID
        )
    }

    private func documentDataFromCardAttachment(_ attachment: CardAttachment) -> [String: Any] {
        var data: [String: Any] = [
            "type": attachment.type,
            "src": attachment.src,
        ]
        if let aspectRatio = attachment.aspectRatio {
            data["aspectRatio"] = aspectRatio
        }
        return data
    }

    private func documentDataFromCardFace(_ cardFace: CardFace) -> [String: Any] {
        var data: [String: Any] = [
            "text": cardFace.text,
        ]
        if let attachment = cardFace.attachment {
            data["attachment"] = documentDataFromCardAttachment(attachment)
        }
        return data
    }

    private func documentDataFromCard(_ card: Card) -> [String: Any] {
        var data: [String: Any] = [
            "userID": card.userID,
            "createdAt": Timestamp(date: card.createdAt),
            "front": documentDataFromCardFace(card.front),
            "back": documentDataFromCardFace(card.back),
            "nextReviewAt": Timestamp(date: card.nextReviewAt),
            "tags": card.tags.sorted(),
            "reviews": card.reviews.map({ review in
                return [
                    "createdAt": Timestamp(date: card.createdAt),
                    "result": review.result,
                ]
            }),
        ]
        if let reversedCardID = card.reversedCardID {
            data["reversedCardID"] = reversedCardID
        }
        return data
    }
}
