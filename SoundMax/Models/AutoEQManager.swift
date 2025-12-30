import Foundation

// MARK: - AutoEQ Integration
// Fetches headphone correction curves from the AutoEQ project
// https://github.com/jaakkopasanen/AutoEq

class AutoEQManager: ObservableObject {
    static let shared = AutoEQManager()

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchResults: [AutoEQHeadphone] = []

    // Our 10 fixed frequency bands
    static let targetFrequencies: [Double] = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]

    // Popular headphones index (curated list for quick access)
    static let popularHeadphones: [AutoEQHeadphone] = [
        // === OVER-EAR === //

        // Sennheiser
        AutoEQHeadphone(name: "Sennheiser HD 560S", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sennheiser HD 600", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sennheiser HD 650", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sennheiser HD 660S", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sennheiser HD 800", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sennheiser HD 800 S", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sennheiser HD 820", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sennheiser HD 599", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sennheiser HD 569", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sennheiser HD 450BT", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sennheiser Momentum 3 Wireless", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sennheiser Momentum 4 Wireless", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sennheiser PXC 550-II", source: "oratory1990", type: "over-ear"),

        // Beyerdynamic
        AutoEQHeadphone(name: "Beyerdynamic DT 770 Pro", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Beyerdynamic DT 880", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Beyerdynamic DT 990 Pro", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Beyerdynamic DT 1770 Pro", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Beyerdynamic DT 1990 Pro", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Beyerdynamic Amiron Home", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Beyerdynamic T1 2nd Generation", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Beyerdynamic T5p 2nd Generation", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Beyerdynamic Lagoon ANC", source: "oratory1990", type: "over-ear"),

        // Audio-Technica
        AutoEQHeadphone(name: "Audio-Technica ATH-M50x", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Audio-Technica ATH-M40x", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Audio-Technica ATH-M70x", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Audio-Technica ATH-R70x", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Audio-Technica ATH-AD700X", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Audio-Technica ATH-AD900X", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Audio-Technica ATH-A990Z", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Audio-Technica ATH-MSR7b", source: "oratory1990", type: "over-ear"),

        // Sony
        AutoEQHeadphone(name: "Sony WH-1000XM3", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sony WH-1000XM4", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sony WH-1000XM5", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sony MDR-Z7M2", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sony MDR-1AM2", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sony MDR-7506", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Sony MDR-V6", source: "oratory1990", type: "over-ear"),

        // Bose
        AutoEQHeadphone(name: "Bose QuietComfort 35 II", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Bose QuietComfort 45", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Bose 700", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Bose QuietComfort Ultra", source: "oratory1990", type: "over-ear"),

        // AKG
        AutoEQHeadphone(name: "AKG K240 Studio", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "AKG K371", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "AKG K553 MKII", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "AKG K612 Pro", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "AKG K701", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "AKG K702", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "AKG K712 Pro", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "AKG K812", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "AKG N700NC M2", source: "oratory1990", type: "over-ear"),

        // HiFiMAN
        AutoEQHeadphone(name: "HiFiMAN Sundara", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "HiFiMAN Ananda", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "HiFiMAN Arya", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "HiFiMAN Edition XS", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "HiFiMAN HE400i 2020", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "HiFiMAN HE400se", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "HiFiMAN HE5XX", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "HiFiMAN HE6se", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "HiFiMAN Deva", source: "oratory1990", type: "over-ear"),

        // Focal
        AutoEQHeadphone(name: "Focal Clear", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Focal Elex", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Focal Elegia", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Focal Utopia", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Focal Stellia", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Focal Celestee", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Focal Bathys", source: "oratory1990", type: "over-ear"),

        // Other Over-ear
        AutoEQHeadphone(name: "Meze 99 Classics", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Meze 99 Neo", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Meze Empyrean", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Meze Liric", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Philips SHP9500", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Philips Fidelio X2HR", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Philips Fidelio X3", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Dan Clark Audio Aeon 2", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Audeze LCD-2 Classic", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Audeze LCD-X", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Audeze Mobius", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Audeze Penrose", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "SIVGA SV021", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Shure SRH840", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Shure SRH1540", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Shure SRH1840", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "V-Moda Crossfade M-100", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Monoprice M1060", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Monoprice M570", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Status Audio CB-1", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "RODE NTH-100", source: "oratory1990", type: "over-ear"),

        // Gaming Headsets
        AutoEQHeadphone(name: "SteelSeries Arctis Nova Pro", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "SteelSeries Arctis 7", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "HyperX Cloud II", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "HyperX Cloud Alpha", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Logitech G Pro X", source: "oratory1990", type: "over-ear"),
        AutoEQHeadphone(name: "Razer BlackShark V2", source: "oratory1990", type: "over-ear"),

        // Apple
        AutoEQHeadphone(name: "Apple AirPods Max", source: "oratory1990", type: "over-ear"),

        // === IN-EAR / IEMs === //

        // Apple
        AutoEQHeadphone(name: "Apple AirPods Pro", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Apple AirPods Pro 2", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Apple AirPods (3rd generation)", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Apple AirPods (2nd generation)", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Apple EarPods", source: "oratory1990", type: "in-ear"),

        // Sony IEMs
        AutoEQHeadphone(name: "Sony WF-1000XM3", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Sony WF-1000XM4", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Sony WF-1000XM5", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Sony IER-M7", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Sony IER-M9", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Sony MDR-EX800ST", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Sony LinkBuds S", source: "oratory1990", type: "in-ear"),

        // Samsung
        AutoEQHeadphone(name: "Samsung Galaxy Buds Pro", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Samsung Galaxy Buds2 Pro", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Samsung Galaxy Buds2", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Samsung Galaxy Buds Plus", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Samsung Galaxy Buds Live", source: "oratory1990", type: "in-ear"),

        // Shure IEMs
        AutoEQHeadphone(name: "Shure SE215", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Shure SE315", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Shure SE425", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Shure SE535", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Shure SE846", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Shure Aonic 3", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Shure Aonic 4", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Shure Aonic 5", source: "oratory1990", type: "in-ear"),

        // Moondrop
        AutoEQHeadphone(name: "Moondrop Blessing 2", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Moondrop Blessing 2 Dusk", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Moondrop Starfield", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Moondrop Aria", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Moondrop Kato", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Moondrop Variations", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Moondrop Chu", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Moondrop Quarks", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Moondrop KXXS", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Moondrop S8", source: "crinacle", type: "in-ear"),

        // Etymotic
        AutoEQHeadphone(name: "Etymotic ER2XR", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Etymotic ER2SE", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Etymotic ER3XR", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Etymotic ER3SE", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Etymotic ER4XR", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Etymotic ER4SR", source: "oratory1990", type: "in-ear"),

        // Other IEMs
        AutoEQHeadphone(name: "7Hz Timeless", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "7Hz Salnotes Zero", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Tin HiFi T2", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Tin HiFi T3", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Tin HiFi P1", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "KZ ZS10 Pro", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "KZ ZSN Pro", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "CCA CRA", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Tripowin Lea", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "BLON BL-03", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Shuoer S12", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Truthear Zero", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Truthear Hexa", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Dunu Titan S", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Final Audio E3000", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Final Audio E5000", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Final Audio A4000", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Campfire Audio Andromeda", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Campfire Audio Solaris", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Westone W40", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Fiio FH3", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Fiio FH5", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Fiio FD5", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "ThieAudio Legacy 3", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "ThieAudio Monarch MKII", source: "crinacle", type: "in-ear"),
        AutoEQHeadphone(name: "Sennheiser IE 300", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Sennheiser IE 600", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Sennheiser IE 900", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Sennheiser Momentum True Wireless 3", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Jabra Elite 75t", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Jabra Elite 85t", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Google Pixel Buds Pro", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Nothing Ear (1)", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Nothing Ear (2)", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "Anker Soundcore Liberty 3 Pro", source: "oratory1990", type: "in-ear"),
        AutoEQHeadphone(name: "1More Triple Driver", source: "oratory1990", type: "in-ear"),

        // === ON-EAR === //
        AutoEQHeadphone(name: "Koss Porta Pro", source: "oratory1990", type: "on-ear"),
        AutoEQHeadphone(name: "Koss KSC75", source: "oratory1990", type: "on-ear"),
        AutoEQHeadphone(name: "Koss KPH30i", source: "oratory1990", type: "on-ear"),
        AutoEQHeadphone(name: "Grado SR60e", source: "oratory1990", type: "on-ear"),
        AutoEQHeadphone(name: "Grado SR80e", source: "oratory1990", type: "on-ear"),
        AutoEQHeadphone(name: "Grado SR125e", source: "oratory1990", type: "on-ear"),
        AutoEQHeadphone(name: "Grado SR225e", source: "oratory1990", type: "on-ear"),
        AutoEQHeadphone(name: "Grado SR325e", source: "oratory1990", type: "on-ear"),
        AutoEQHeadphone(name: "Beats Solo3 Wireless", source: "oratory1990", type: "on-ear"),
        AutoEQHeadphone(name: "Beats Solo Pro", source: "oratory1990", type: "on-ear"),
        AutoEQHeadphone(name: "Marshall Major IV", source: "oratory1990", type: "on-ear"),
        AutoEQHeadphone(name: "Bowers & Wilkins PX5", source: "oratory1990", type: "on-ear"),
    ]

    // MARK: - Search

    func search(query: String) {
        let lowercaseQuery = query.lowercased()
        searchResults = Self.popularHeadphones.filter { headphone in
            headphone.name.lowercased().contains(lowercaseQuery)
        }
    }

    // MARK: - Fetch EQ Data

    func fetchEQ(for headphone: AutoEQHeadphone, completion: @escaping (Result<[Float], Error>) -> Void) {
        isLoading = true
        errorMessage = nil

        let urlString = headphone.graphicEQURL
        guard let url = URL(string: urlString) else {
            isLoading = false
            errorMessage = "Invalid URL"
            completion(.failure(AutoEQError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }

                guard let data = data, let content = String(data: data, encoding: .utf8) else {
                    self?.errorMessage = "Could not read response"
                    completion(.failure(AutoEQError.invalidResponse))
                    return
                }

                // Check for 404
                if content.contains("404") || content.contains("Not Found") {
                    self?.errorMessage = "EQ data not found for this headphone"
                    completion(.failure(AutoEQError.notFound))
                    return
                }

                // Parse the GraphicEQ format
                do {
                    let bands = try self?.parseGraphicEQ(content) ?? []
                    completion(.success(bands))
                } catch {
                    self?.errorMessage = "Could not parse EQ data"
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Parse GraphicEQ Format

    private func parseGraphicEQ(_ content: String) throws -> [Float] {
        // Format: GraphicEQ: 20 -3.5; 22 -3.5; 23 -3.4; ...
        guard let eqLine = content.components(separatedBy: "\n").first(where: { $0.hasPrefix("GraphicEQ:") }) else {
            throw AutoEQError.parseError
        }

        let dataString = eqLine.replacingOccurrences(of: "GraphicEQ:", with: "").trimmingCharacters(in: .whitespaces)
        let pairs = dataString.components(separatedBy: ";")

        var frequencyGainMap: [(Double, Double)] = []

        for pair in pairs {
            let trimmed = pair.trimmingCharacters(in: .whitespaces)
            let components = trimmed.split(separator: " ")
            if components.count >= 2,
               let freq = Double(components[0]),
               let gain = Double(components[1]) {
                frequencyGainMap.append((freq, gain))
            }
        }

        guard !frequencyGainMap.isEmpty else {
            throw AutoEQError.parseError
        }

        // Interpolate to our 10 target frequencies
        return interpolateToTargetBands(frequencyGainMap)
    }

    // MARK: - Interpolation

    private func interpolateToTargetBands(_ data: [(Double, Double)]) -> [Float] {
        var result: [Float] = []

        for targetFreq in Self.targetFrequencies {
            // Find surrounding points for interpolation
            var lowerIndex = 0
            var upperIndex = data.count - 1

            for (i, point) in data.enumerated() {
                if point.0 <= targetFreq {
                    lowerIndex = i
                }
                if point.0 >= targetFreq && upperIndex == data.count - 1 {
                    upperIndex = i
                    break
                }
            }

            // Linear interpolation
            let lower = data[lowerIndex]
            let upper = data[upperIndex]

            let gain: Double
            if lower.0 == upper.0 {
                gain = lower.1
            } else {
                // Interpolate in log frequency space
                let logLower = log10(lower.0)
                let logUpper = log10(upper.0)
                let logTarget = log10(targetFreq)
                let t = (logTarget - logLower) / (logUpper - logLower)
                gain = lower.1 + t * (upper.1 - lower.1)
            }

            // Clamp to our ±12dB range
            result.append(Float(max(-12, min(12, gain))))
        }

        return result
    }
}

// MARK: - Models

struct AutoEQHeadphone: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let source: String  // oratory1990, crinacle, etc.
    let type: String    // over-ear, in-ear, on-ear

    var graphicEQURL: String {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        return "https://raw.githubusercontent.com/jaakkopasanen/AutoEq/master/results/\(source)/\(type)/\(encodedName)/\(encodedName)%20GraphicEQ.txt"
    }

    var displayType: String {
        switch type {
        case "over-ear": return "Over-ear"
        case "in-ear": return "In-ear"
        case "on-ear": return "On-ear"
        default: return type.capitalized
        }
    }
}

// MARK: - Errors

enum AutoEQError: LocalizedError {
    case invalidURL
    case invalidResponse
    case notFound
    case parseError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .notFound: return "EQ data not found for this headphone"
        case .parseError: return "Could not parse EQ data"
        }
    }
}
