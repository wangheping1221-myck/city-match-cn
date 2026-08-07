import Foundation
import CoreGraphics

enum SocialCanvasPreset: String, CaseIterable, Identifiable {
    case rednotePortrait = "3:4 RedNote"
    case square = "1:1 Square"
    case story = "9:16 Story"

    var id: String { rawValue }

    var size: CGSize {
        switch self {
        case .rednotePortrait:
            return CGSize(width: 1080, height: 1440)
        case .square:
            return CGSize(width: 1080, height: 1080)
        case .story:
            return CGSize(width: 1080, height: 1920)
        }
    }
}

enum MotionPreset: String, CaseIterable, Identifiable {
    case slowZoomIn = "Slow zoom in"
    case slowZoomOut = "Slow zoom out"
    case panLeft = "Pan left"
    case panRight = "Pan right"
    case breath = "Breath"

    var id: String { rawValue }
}

enum LivePhotoDuration: Double, CaseIterable, Identifiable {
    case onePointFive = 1.5
    case two = 2.0
    case three = 3.0
    case five = 5.0

    var id: Double { rawValue }

    var label: String {
        switch self {
        case .onePointFive:
            return "1.5s"
        case .two:
            return "2s"
        case .three:
            return "3s"
        case .five:
            return "5s"
        }
    }
}

struct LivePhotoResources {
    let photoURL: URL
    let pairedVideoURL: URL
    let assetIdentifier: String
}

enum LivePhotoExportError: LocalizedError {
    case imageDataUnavailable
    case metadataWritingNotImplemented
    case videoRenderingFailed
    case photoLibrarySaveFailed(Error?)

    var errorDescription: String? {
        switch self {
        case .imageDataUnavailable:
            return "Could not read the selected image."
        case .metadataWritingNotImplemented:
            return "Live Photo metadata writing is not implemented yet."
        case .videoRenderingFailed:
            return "Could not render the motion video."
        case .photoLibrarySaveFailed(let error):
            return error?.localizedDescription ?? "Could not save the Live Photo."
        }
    }
}

