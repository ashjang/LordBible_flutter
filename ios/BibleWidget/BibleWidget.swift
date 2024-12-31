//
//  BibleWidget.swift
//  BibleWidget
//
//  Created by 장하림 on 12/31/24.
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.com.Harim.Lordwords"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "말씀을 묵상해보세요", description: "앱 내에서 말씀을 선택할 수 있습니다.")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = UserDefaults.init(suiteName: widgetGroupId)
        let entry = SimpleEntry(date: Date(),
                        title: data?.string(forKey: "title") ?? "말씀을 묵상해보세요",
                        description: data?.string(forKey: "description") ?? "앱 내에서 말씀을 선택할 수 있습니다.")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let description: String
}

struct BibleWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var entry: Provider.Entry

    var body: some View {
        switch self.family {
            
            case .systemSmall:
                VStack {
                    Text("⭐️ \(entry.title)").lineLimit(1).bold().padding(.bottom, 7).frame(alignment: .leading)
                    Text(entry.description).font(.footnote)
                }
                .containerBackground(for: .widget) {
                    Color("lockscreenbackground").opacity(0.9)
                }
            
            case .systemMedium:
                VStack(alignment: .leading) {
                    Text("⭐️ \(entry.title)").lineLimit(1).truncationMode(.tail).bold().padding(.bottom, 9)
                    Text(entry.description).lineLimit(10).truncationMode(.tail).font(.subheadline)
                }
                .containerBackground(for: .widget) {
                    Color("lockscreenbackground").opacity(0.5)
                }.padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3))
                
            case .systemLarge:
                VStack(alignment: .leading) {
                    Text("⭐️ \(entry.title)").lineLimit(1).truncationMode(.tail).bold().padding(.bottom, 9)
                    Text(entry.description).lineLimit(10).truncationMode(.tail).font(.subheadline)
                }
                .containerBackground(for: .widget) {
                    Color("lockscreenbackground").opacity(0.5)
                }.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                
            case .accessoryRectangular:
                VStack(spacing: 5) {
                    Text(entry.title).bold().font(.callout)
                    Text(entry.description).font(.caption)
                }.containerBackground(for: .widget) {
                    Color("lockscreenbackground").opacity(0.5)
                }
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground().edgesIgnoringSafeArea(.all)
                    VStack(spacing: 5) {
                        Text("✝️")
                    }.containerBackground(for: .widget) {
                        Color("lockscreenbackground").opacity(0.5)
                    }
                }

            @unknown default:
              Text("출력이 불가능합니다")
            }
    }
}

struct BibleWidget: Widget {
    let kind: String = "BibleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                BibleWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                BibleWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("말씀 위젯")
        .description("위젯을 추가하여 말씀묵상 해보세요 :)")
    }
}

#Preview(as: .systemSmall) {
    BibleWidget()
} timeline: {
    SimpleEntry(date: .now, title: "말씀묵상", description: "앱 내에서 말씀을 선택할 수 있습니다")
    SimpleEntry(date: .now, title: "말씀묵상", description: "앱 내에서 말씀을 선택할 수 있습니다")
}
