import Foundation
import UIKit

@MainActor
final class LivePhotoExporter: ObservableObject {
    @Published private(set) var isExporting = false
    @Published var statusMessage = "Choose a photo or video to begin."

    private let renderer = MotionVideoRenderer()
    private let metadataWriter = LivePhotoMetadataWriter()
    private let saver = PhotoLibrarySaver()

    func exportPhotoAsLivePhoto(
        image: UIImage,
        motionPreset: MotionPreset,
        canvasPreset: SocialCanvasPreset,
        duration: LivePhotoDuration
    ) async {
        isExporting = true
        statusMessage = "Rendering Live Photo..."
        defer { isExporting = false }

        do {
            let workDirectory = try makeWorkingDirectory()
            let keyPhotoURL = workDirectory.appendingPathComponent("key-photo.jpg")
            let motionVideoURL = workDirectory.appendingPathComponent("motion.mov")

            let photoURL = try renderer.renderKeyPhoto(
                from: image,
                canvas: canvasPreset,
                outputURL: keyPhotoURL
            )

            let videoURL = try await renderer.renderMotionVideo(
                from: image,
                preset: motionPreset,
                canvas: canvasPreset,
                duration: duration,
                outputURL: motionVideoURL
            )

            statusMessage = "Pairing Live Photo metadata..."
            let resources = try await metadataWriter.pairResources(
                photoURL: photoURL,
                videoURL: videoURL
            )

            statusMessage = "Saving to Photos..."
            try await saver.saveLivePhoto(resources: resources)
            statusMessage = "Saved. Open Photos and press to preview LIVE."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func makeWorkingDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("rednote-live-export-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}

