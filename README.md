# Recall

A spaced repetition app for iOS and macOS ([Spaced repetition memory systems make memory a choice](https://notes.andymatuschak.org/Spaced_repetition_memory_systems_make_memory_a_choice)). The primary goal for this project was to play with new-ish technologies like SwiftUI, Combine, Catalyst, WidgetKit, and Firebase.

### Login

- You can log in via Apple (to review, create, and edit cards associated with your Apple ID), or you can log in anonymously (useful for testing).

### Data model

- `Card` is the base model. It has a `front` and a `back`. For now, these are just text.
- Each card has an embedded set of `Review`s. Based on recent reviews, I calculate `Card.nextReviewAt`. This algorithm is very basic right now.
- Cards have `tags`. The only currently used tag is `"draft"`. A draft is a card that needs to be edited before it enters the review set. You can select text in another app and use the iOS share sheet to create a draft, which you can later turn into a reviewable card.

### Architecture

- A `CardStore` persists a list of cards.
- A `CardQuery` queries cards with a set of filters and updates automatically whenever the `CardStore` changes.
- The `CardService` abstracts away the details for the UX.

### Syncing

- Cards are synced via Firebase. Why Firebase? It works and it has good offline support.
- Note: you'll need to add a `GoogleService-Info.plist` to the `Recall` directory, or a `GOOGLE_SERVICE_PLIST` environment variable with the contents of this file, to run the app.

