import SwiftUI

struct DateStyleChart: View {
    let card: DateStyleCard

    private let axes: [(label: String, keyPath: KeyPath<DateStyleCard, Int>)] = [
        ("Adventurous", \.adventurous),
        ("Planner", \.planner),
        ("Talker", \.talker),
        ("Foodie", \.foodie),
    ]

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 24

            ZStack {
                // Grid circles
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { scale in
                    Circle()
                        .stroke(.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: radius * 2 * scale, height: radius * 2 * scale)
                }

                // Axis lines and labels
                ForEach(0..<axes.count, id: \.self) { index in
                    let angle = angleForIndex(index)
                    let endpoint = point(at: angle, radius: radius, center: center)
                    let labelPoint = point(at: angle, radius: radius + 20, center: center)

                    Path { path in
                        path.move(to: center)
                        path.addLine(to: endpoint)
                    }
                    .stroke(.gray.opacity(0.3), lineWidth: 1)

                    Text(axes[index].label)
                        .font(.caption2.weight(.medium))
                        .position(labelPoint)
                }

                // Data polygon
                Path { path in
                    for (index, axis) in axes.enumerated() {
                        let value = CGFloat(card[keyPath: axis.keyPath]) / 100.0
                        let angle = angleForIndex(index)
                        let pt = point(at: angle, radius: radius * value, center: center)
                        if index == 0 {
                            path.move(to: pt)
                        } else {
                            path.addLine(to: pt)
                        }
                    }
                    path.closeSubpath()
                }
                .fill(Color.accentColor.opacity(0.2))
                .overlay(
                    Path { path in
                        for (index, axis) in axes.enumerated() {
                            let value = CGFloat(card[keyPath: axis.keyPath]) / 100.0
                            let angle = angleForIndex(index)
                            let pt = point(at: angle, radius: radius * value, center: center)
                            if index == 0 {
                                path.move(to: pt)
                            } else {
                                path.addLine(to: pt)
                            }
                        }
                        path.closeSubpath()
                    }
                    .stroke(Color.accentColor, lineWidth: 2)
                )

                // Data points
                ForEach(0..<axes.count, id: \.self) { index in
                    let value = CGFloat(card[keyPath: axes[index].keyPath]) / 100.0
                    let angle = angleForIndex(index)
                    let pt = point(at: angle, radius: radius * value, center: center)
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 8, height: 8)
                        .position(pt)
                }
            }
        }
    }

    private func angleForIndex(_ index: Int) -> Double {
        let slice = (2 * .pi) / Double(axes.count)
        return slice * Double(index) - .pi / 2
    }

    private func point(at angle: Double, radius: CGFloat, center: CGPoint) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }
}

#Preview {
    DateStyleChart(card: DateStyleCard(
        adventurous: 75,
        planner: 60,
        talker: 80,
        foodie: 90
    ))
    .frame(height: 250)
    .padding()
}
