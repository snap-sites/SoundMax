import SwiftUI

struct EQSliderView: View {
    @Binding var value: Float
    let label: String

    private let range: ClosedRange<Float> = -12...12
    private let sliderHeight: CGFloat = 120

    var body: some View {
        VStack(spacing: 4) {
            // Value display
            Text(formattedValue)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(valueColor)
                .frame(width: 32)

            // Slider track
            ZStack {
                // Background track
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 8, height: sliderHeight)

                // Center line (0 dB mark)
                Rectangle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 16, height: 2)

                // Fill from center
                VStack(spacing: 0) {
                    if value >= 0 {
                        // Positive: fill goes up from center
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.orange)
                            .frame(width: 6, height: fillHeight)
                        Spacer()
                            .frame(height: sliderHeight / 2)
                    } else {
                        // Negative: fill goes down from center
                        Spacer()
                            .frame(height: sliderHeight / 2)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: 6, height: fillHeight)
                        Spacer()
                    }
                }
                .frame(height: sliderHeight)

                // Thumb
                Circle()
                    .fill(Color.white)
                    .shadow(radius: 2)
                    .frame(width: 16, height: 16)
                    .offset(y: thumbOffset)
            }
            .frame(width: 24, height: sliderHeight)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        updateValue(from: gesture.location.y)
                    }
            )

            // Frequency label
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
    }

    private var formattedValue: String {
        if abs(value) < 0.5 {
            return "0"
        } else if value > 0 {
            return String(format: "+%.0f", value)
        } else {
            return String(format: "%.0f", value)
        }
    }

    private var valueColor: Color {
        if value > 0.5 {
            return .orange
        } else if value < -0.5 {
            return .blue
        } else {
            return .secondary
        }
    }

    private var fillHeight: CGFloat {
        let normalized = CGFloat(abs(value) / 12.0)
        return normalized * (sliderHeight / 2)
    }

    private var thumbOffset: CGFloat {
        // Map value (-12 to +12) to offset (top to bottom)
        // +12 = top = -sliderHeight/2
        // 0 = center = 0
        // -12 = bottom = +sliderHeight/2
        let normalized = CGFloat(value / 12.0)
        return -normalized * (sliderHeight / 2)
    }

    private func updateValue(from locationY: CGFloat) {
        // Map y position to value
        // Top (y=0) = +12
        // Center (y=sliderHeight/2) = 0
        // Bottom (y=sliderHeight) = -12
        let center = sliderHeight / 2
        let offset = center - locationY
        let normalized = offset / center
        let newValue = Float(normalized) * 12
        value = min(max(newValue, range.lowerBound), range.upperBound)
    }
}

#Preview {
    HStack(spacing: 12) {
        EQSliderView(value: .constant(-6), label: "32")
        EQSliderView(value: .constant(0), label: "250")
        EQSliderView(value: .constant(6), label: "1K")
        EQSliderView(value: .constant(12), label: "8K")
    }
    .padding()
    .background(Color.black.opacity(0.1))
}
