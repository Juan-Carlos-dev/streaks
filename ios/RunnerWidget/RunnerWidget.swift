import WidgetKit
import SwiftUI

private let appGroupId = "group.com.example.streaks"

struct WidgetData: Decodable {
    let widgetType: String
    let widgetBg: String
    let widgetColor: String
    let gradientStart: String
    let gradientEnd: String
    let streakCount: Int
    let progressCompleted: Int
    let progressTotal: Int
    let starHabitTitle: String
    let starHabitIcon: String
    let starHabitCount: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), data: WidgetData(
            widgetType: "streak",
            widgetBg: "dark",
            widgetColor: "#0052FF",
            gradientStart: "#3D8EF0",
            gradientEnd: "#64B5F6",
            streakCount: 14,
            progressCompleted: 4,
            progressTotal: 6,
            starHabitTitle: "Hacer Ejercicio",
            starHabitIcon: "fitness_center",
            starHabitCount: 12
        ))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), data: loadData())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), data: loadData())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func loadData() -> WidgetData {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        
        let widgetType = userDefaults?.string(forKey: "widgetType") ?? "streak"
        let widgetBg = userDefaults?.string(forKey: "widgetBg") ?? "dark"
        let widgetColor = userDefaults?.string(forKey: "widgetColor") ?? "#0052FF"
        let gradientStart = userDefaults?.string(forKey: "gradientStart") ?? "#3D8EF0"
        let gradientEnd = userDefaults?.string(forKey: "gradientEnd") ?? "#64B5F6"
        let streakCount = userDefaults?.integer(forKey: "streakCount") ?? 14
        let progressCompleted = userDefaults?.integer(forKey: "progressCompleted") ?? 4
        let progressTotal = userDefaults?.integer(forKey: "progressTotal") ?? 6
        let starHabitTitle = userDefaults?.string(forKey: "starHabitTitle") ?? "Hacer Ejercicio"
        let starHabitIcon = userDefaults?.string(forKey: "starHabitIcon") ?? "fitness_center"
        let starHabitCount = userDefaults?.integer(forKey: "starHabitCount") ?? 12

        return WidgetData(
            widgetType: widgetType,
            widgetBg: widgetBg,
            widgetColor: widgetColor,
            gradientStart: gradientStart,
            gradientEnd: gradientEnd,
            streakCount: streakCount,
            progressCompleted: progressCompleted,
            progressTotal: progressTotal,
            starHabitTitle: starHabitTitle,
            starHabitIcon: starHabitIcon,
            starHabitCount: starHabitCount
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct RunnerWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        let data = entry.data
        let accentColor = Color(hex: data.widgetColor)
        let isDarkBg = data.widgetBg == "dark"

        let previewAccentColor = isDarkBg ? accentColor : Color.white
        let previewTextColor = isDarkBg ? Color.white : Color.white.opacity(0.95)
        let previewSubtextColor = isDarkBg ? Color.white.opacity(0.6) : Color.white.opacity(0.7)

        Group {
            if family == .systemMedium {
                // SYSTEM MEDIUM (HORIZONTAL RECTANGULAR WIDGET)
                VStack(alignment: .leading, spacing: 10) {
                    if data.widgetType == "streak" {
                        // STREAK WIDGET (MEDIUM)
                        HStack(alignment: .center, spacing: 16) {
                            // Large Left Icon / Streak Info
                            VStack(alignment: .center, spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(previewAccentColor)
                                Text("\(data.streakCount) Días")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(previewTextColor)
                            }
                            .frame(width: 80)
                            
                            Divider()
                                .background(previewTextColor.opacity(0.15))
                            
                            // Right Details
                            VStack(alignment: .leading, spacing: 4) {
                                Text("RACHA GLOBAL")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(previewSubtextColor)
                                    .tracking(1.0)
                                
                                Text("¡Cada día cuenta!")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(previewTextColor)
                                
                                Text("Mantén encendido el fuego. Completa tus hábitos hoy para no perder el progreso.")
                                    .font(.system(size: 10.5))
                                    .foregroundColor(previewSubtextColor)
                                    .lineLimit(2)
                            }
                        }
                    } else if data.widgetType == "progress" {
                        // PROGRESS WIDGET (MEDIUM)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PROGRESO DIARIO")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(previewSubtextColor)
                                .tracking(1.0)
                            
                            HStack(alignment: .firstTextBaseline) {
                                Text("\(data.progressCompleted) de \(data.progressTotal) completados")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(previewTextColor)
                                
                                Spacer()
                                
                                let percent = data.progressTotal > 0 ? Int((Double(data.progressCompleted) / Double(data.progressTotal)) * 100) : 0
                                Text("\(percent)%")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundColor(previewAccentColor)
                            }
                            
                            // Large Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(previewTextColor.opacity(0.15))
                                        .frame(height: 8)
                                    Capsule()
                                        .fill(previewAccentColor)
                                        .frame(width: geo.size.width * CGFloat(data.progressTotal > 0 ? min(Double(data.progressCompleted) / Double(data.progressTotal), 1.0) : 0.0), height: 8)
                                }
                            }
                            .frame(height: 8)
                            
                            Text("¡Vas por buen camino hoy!")
                                .font(.system(size: 10.5))
                                .foregroundColor(previewSubtextColor)
                        }
                    } else {
                        // STAR HABIT WIDGET (MEDIUM)
                        HStack(spacing: 16) {
                            // Icon Card
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(previewTextColor.opacity(0.1))
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: getSFSymbol(for: data.starHabitIcon))
                                    .font(.system(size: 22))
                                    .foregroundColor(previewAccentColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("HÁBITO ESTRELLA")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(previewSubtextColor)
                                    .tracking(1.0)
                                
                                Text(data.starHabitTitle)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(previewTextColor)
                                    .lineLimit(1)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(previewAccentColor)
                                    Text("\(data.starHabitCount) veces completado")
                                        .font(.system(size: 11))
                                        .foregroundColor(previewSubtextColor)
                                }
                            }
                        }
                    }
                }
                .padding(14)
            } else {
                // SYSTEM SMALL (SQUARE WIDGET) - OPTIMIZED FOR COMPACT SCREEN
                VStack(alignment: .leading, spacing: 8) {
                    if data.widgetType == "streak" {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 18))
                                .foregroundColor(previewAccentColor)
                            Text("RACHA G.")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(previewSubtextColor)
                                .tracking(0.8)
                        }

                        Spacer().frame(height: 2)

                        Text("🔥 \(data.streakCount) Días")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(previewTextColor)

                        Text("Sigue sumando.")
                            .font(.system(size: 9))
                            .foregroundColor(previewSubtextColor)

                    } else if data.widgetType == "progress" {
                        Text("PROGRESO")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(previewSubtextColor)
                            .tracking(0.8)

                        Spacer().frame(height: 2)

                        VStack(alignment: .leading, spacing: 4) {
                            let percent = data.progressTotal > 0 ? Int((Double(data.progressCompleted) / Double(data.progressTotal)) * 100) : 0
                            
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("\(data.progressCompleted)/\(data.progressTotal)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(previewTextColor)
                                Text("hechos")
                                    .font(.system(size: 10))
                                    .foregroundColor(previewSubtextColor)
                                Spacer()
                                Text("\(percent)%")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(previewAccentColor)
                            }

                            // Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(previewTextColor.opacity(0.15))
                                        .frame(height: 6)
                                    Capsule()
                                        .fill(previewAccentColor)
                                        .frame(width: geo.size.width * CGFloat(data.progressTotal > 0 ? min(Double(data.progressCompleted) / Double(data.progressTotal), 1.0) : 0.0), height: 6)
                                }
                            }
                            .frame(height: 6)
                        }

                        Spacer().frame(height: 2)

                        Text("¡Buen ritmo!")
                            .font(.system(size: 9))
                            .foregroundColor(previewSubtextColor)

                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(previewAccentColor)
                            Text("ESTRELLA")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(previewSubtextColor)
                                .tracking(0.8)
                        }

                        Spacer().frame(height: 2)

                        HStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(previewTextColor.opacity(0.1))
                                    .frame(width: 30, height: 30)
                                
                                Image(systemName: getSFSymbol(for: data.starHabitIcon))
                                    .font(.system(size: 14))
                                    .foregroundColor(previewAccentColor)
                            }

                            VStack(alignment: .leading, spacing: 1) {
                                Text(data.starHabitTitle)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(previewTextColor)
                                    .lineLimit(1)
                                Text("\(data.starHabitCount) hechos")
                                    .font(.system(size: 9))
                                    .foregroundColor(previewSubtextColor)
                            }
                        }
                    }
                }
                .padding(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetBackground(
            Group {
                if data.widgetBg == "dark" {
                    Color(red: 30/255, green: 30/255, blue: 30/255)
                } else if data.widgetBg == "gradient" {
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: data.gradientStart), Color(hex: data.gradientEnd)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    accentColor
                }
            }
        )
    }

    private func getSFSymbol(for iconName: String) -> String {
        switch iconName {
        case "fitness_center": return "dumbbell.fill"
        case "school": return "book.closed.fill"
        case "attach_money": return "dollarsign.circle.fill"
        case "local_drink": return "drop.fill"
        case "spa": return "leaf.fill"
        case "directions_run": return "figure.run"
        case "laptop_mac": return "laptopcomputer"
        case "favorite": return "heart.fill"
        case "restaurant": return "fork.knife"
        case "meditation": return "figure.mind.and.body"
        case "bed": return "bed.double.fill"
        case "brush": return "paintpalette.fill"
        case "music_note": return "music.note"
        case "sports_esports": return "gamecontroller.fill"
        default: return "checkmark.circle.fill"
        }
    }
}

// Custom View extension to handle edge-to-edge backgrounds backward-compatibly on iOS 17+
extension View {
    func widgetBackground<T: View>(_ backgroundView: T) -> some View {
        if #available(iOS 17.0, *) {
            return self.containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return self.background(backgroundView)
        }
    }
}

// Safe wrapper to call contentMarginsDisabled only on iOS 17+
extension WidgetConfiguration {
    func disableContentMarginsIfNeeded() -> some WidgetConfiguration {
        #if compiler(>=5.9)
        if #available(iOS 17.0, *) {
            return self.contentMarginsDisabled()
        }
        #endif
        return self
    }
}

struct RunnerWidget: Widget {
    let kind: String = "RunnerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RunnerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Streaks Widget")
        .description("Sigue tus rachas y progreso diario de hábitos directamente en tu pantalla de inicio.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .disableContentMarginsIfNeeded()
    }
}

// Helper to convert Hex to SwiftUI Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8 * 17) & 0xff, (int >> 4 & 0xf) * 17, (int & 0xf) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xff, (int >> 8) & 0xff, (int) & 0xff)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xff, (int >> 16) & 0xff, (int >> 8) & 0xff, (int) & 0xff)
        default:
            (a, r, g, b) = (255, 0, 82, 255) // Default Blue
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
