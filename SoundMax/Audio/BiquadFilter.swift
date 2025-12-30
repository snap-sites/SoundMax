import Foundation

/// Biquad filter for parametric EQ
/// Based on Audio EQ Cookbook by Robert Bristow-Johnson
class BiquadFilter {
    private var b0: Float = 1.0
    private var b1: Float = 0.0
    private var b2: Float = 0.0
    private var a1: Float = 0.0
    private var a2: Float = 0.0

    // State variables for filtering (per channel)
    private var x1: [Float] = [0, 0]  // x[n-1] for each channel
    private var x2: [Float] = [0, 0]  // x[n-2] for each channel
    private var y1: [Float] = [0, 0]  // y[n-1] for each channel
    private var y2: [Float] = [0, 0]  // y[n-2] for each channel

    var frequency: Float = 1000
    var gain: Float = 0  // in dB
    var q: Float = 1.0
    var sampleRate: Float = 48000

    init() {}

    /// Calculate coefficients for a peaking EQ filter
    func updateCoefficients() {
        let A = powf(10, gain / 40.0)  // amplitude
        let omega = 2.0 * Float.pi * frequency / sampleRate
        let sinOmega = sin(omega)
        let cosOmega = cos(omega)
        let alpha = sinOmega / (2.0 * q)

        let a0: Float

        if abs(gain) < 0.01 {
            // Bypass - unity gain
            b0 = 1.0
            b1 = 0.0
            b2 = 0.0
            a1 = 0.0
            a2 = 0.0
            return
        }

        // Peaking EQ coefficients
        let b0_raw = 1.0 + alpha * A
        let b1_raw = -2.0 * cosOmega
        let b2_raw = 1.0 - alpha * A
        a0 = 1.0 + alpha / A
        let a1_raw = -2.0 * cosOmega
        let a2_raw = 1.0 - alpha / A

        // Normalize by a0
        b0 = b0_raw / a0
        b1 = b1_raw / a0
        b2 = b2_raw / a0
        a1 = a1_raw / a0
        a2 = a2_raw / a0
    }

    /// Process a single sample for a given channel
    func process(sample: Float, channel: Int) -> Float {
        let ch = min(channel, 1)

        // Direct Form II Transposed
        let output = b0 * sample + b1 * x1[ch] + b2 * x2[ch] - a1 * y1[ch] - a2 * y2[ch]

        // Update state
        x2[ch] = x1[ch]
        x1[ch] = sample
        y2[ch] = y1[ch]
        y1[ch] = output

        return output
    }

    /// Reset filter state
    func reset() {
        x1 = [0, 0]
        x2 = [0, 0]
        y1 = [0, 0]
        y2 = [0, 0]
    }
}

/// 10-band parametric EQ using biquad filters
class ParametricEQ {
    static let frequencies: [Float] = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]

    private var filters: [BiquadFilter] = []
    private var sampleRate: Float = 48000
    var bypass: Bool = false

    init(sampleRate: Double) {
        self.sampleRate = Float(sampleRate)

        // Create a biquad filter for each frequency band
        for freq in Self.frequencies {
            let filter = BiquadFilter()
            filter.frequency = freq
            filter.gain = 0
            filter.q = 1.4  // Good Q for 10-band EQ
            filter.sampleRate = self.sampleRate
            filter.updateCoefficients()
            filters.append(filter)
        }
    }

    func setGain(band: Int, gain: Float) {
        guard band >= 0 && band < 10 else { return }
        filters[band].gain = gain
        filters[band].updateCoefficients()
    }

    func setAllGains(_ gains: [Float]) {
        for (index, gain) in gains.enumerated() where index < 10 {
            filters[index].gain = gain
            filters[index].updateCoefficients()
        }
    }

    /// Process audio buffer in place
    func process(buffer: UnsafeMutablePointer<Float>, frameCount: Int, channel: Int) {
        guard !bypass else { return }

        for frame in 0..<frameCount {
            var sample = buffer[frame]

            // Apply each band's filter in series
            for filter in filters {
                sample = filter.process(sample: sample, channel: channel)
            }

            buffer[frame] = sample
        }
    }

    func reset() {
        for filter in filters {
            filter.reset()
        }
    }
}
