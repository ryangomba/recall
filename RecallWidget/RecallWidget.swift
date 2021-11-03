import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct RecallWidgetSmallView : View {
    var entry: Provider.Entry

    var body: some View {
        Text("SM \(entry.date)")
            .widgetURL(nil)
    }
}

struct RecallWidgetMediumView : View {
    var entry: Provider.Entry

    var body: some View {
        Text("MD \(entry.date)")
            .widgetURL(nil)
    }
}

struct RecallWidgetLargeView : View {
    var entry: Provider.Entry

    var body: some View {
        Text("LG \(entry.date)")
            .widgetURL(nil)
    }
}

struct RecallWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall: RecallWidgetSmallView(entry: entry)
        case .systemMedium: RecallWidgetMediumView(entry: entry)
        case .systemLarge: RecallWidgetLargeView(entry: entry)
        default: Text("Not available")
        }
    }
}

@main
struct RecallWidget: Widget {
    let kind: String = "RecallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RecallWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct RecallWidget_Previews: PreviewProvider {
    static var previews: some View {
        RecallWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
