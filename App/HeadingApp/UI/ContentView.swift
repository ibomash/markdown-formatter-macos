import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel
    @State private var animateIn = false

    private let accent = Color(red: 0.96, green: 0.56, blue: 0.25)
    private let panelBackground = LinearGradient(
        colors: [Color(red: 0.12, green: 0.13, blue: 0.16), Color(red: 0.18, green: 0.15, blue: 0.12)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            panelBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                header
                histogram
                baseLevelPicker
                clipboardPreview
                    .layoutPriority(1)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .padding(.top, 32)
        }
        .background(
            WindowAccessor { window in
                guard let window else { return }
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                window.isMovableByWindowBackground = true
                window.level = .floating
            }
            .allowsHitTesting(false)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateIn = true
            }
        }
        .frame(minWidth: 520, minHeight: 440)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Heading Palette")
                .font(.custom("Avenir Next", size: 22))
                .foregroundStyle(.white)

            if let minLevel = model.summary.minLevel, let maxLevel = model.summary.maxLevel {
                Text("Detected H\(minLevel) to H\(maxLevel)")
                    .font(.custom("Avenir Next", size: 14))
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                Text("No headings detected")
                    .font(.custom("Avenir Next", size: 14))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 6)
    }

    private var histogram: some View {
        HeadingHistogramView(counts: model.headingCounts, accent: accent)
            .opacity(animateIn ? 1 : 0)
    }

    private var baseLevelPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rebase to")
                .font(.custom("Avenir Next", size: 13))
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: 10) {
                ForEach(1...6, id: \.self) { level in
                    Button(action: {
                        model.baseLevel = level
                    }) {
                        Text("H\(level)")
                            .font(.custom("Avenir Next", size: 13))
                            .foregroundStyle(model.baseLevel == level ? .black : .white)
                            .frame(width: 44, height: 32)
                            .background(model.baseLevel == level ? accent : Color.white.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 12) {
                Button("Copy") {
                    model.copyRebased(to: model.baseLevel)
                }
                .buttonStyle(.plain)
                .font(.custom("Avenir Next", size: 13))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())

                Button("Paste") {
                    model.pasteRebased(to: model.baseLevel)
                }
                .buttonStyle(.plain)
                .font(.custom("Avenir Next", size: 13))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(accent)
                .foregroundStyle(.black)
                .clipShape(Capsule())
            }

            if let statusMessage = model.statusMessage {
                Text(statusMessage)
                    .font(.custom("Avenir Next", size: 12))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 8)
    }

    private var clipboardPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Clipboard preview")
                .font(.custom("Avenir Next", size: 12))
                .foregroundStyle(.white.opacity(0.55))

            ScrollView {
                Text(model.clipboardMonitor.latestText)
                    .font(.custom("Avenir Next", size: 12))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.black.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(minHeight: 140)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 10)
    }
}

struct HeadingHistogramView: View {
    let counts: [Int]
    let accent: Color

    private var maxCount: Int {
        max(counts.max() ?? 0, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(0..<counts.count, id: \.self) { index in
                let level = index + 1
                let count = counts[index]
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(barGradient(level: level))
                        .frame(height: barHeight(for: count))
                        .overlay(alignment: .top) {
                            if count > 0 {
                                Text("\(count)")
                                    .font(.custom("Avenir Next", size: 11))
                                    .foregroundStyle(.white)
                                    .padding(.top, 6)
                            }
                        }
                        .animation(.easeOut(duration: 0.45).delay(Double(index) * 0.05), value: count)

                    Text("H\(level)")
                        .font(.custom("Avenir Next", size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func barHeight(for count: Int) -> CGFloat {
        let minHeight: CGFloat = 14
        let maxHeight: CGFloat = 120
        let ratio = CGFloat(count) / CGFloat(maxCount)
        return minHeight + (maxHeight - minHeight) * ratio
    }

    private func barGradient(level: Int) -> LinearGradient {
        let hue = 0.05 + (Double(level) * 0.03)
        return LinearGradient(
            colors: [accent, Color(hue: hue, saturation: 0.7, brightness: 0.9)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
