import AVFoundation
import Foundation
import ImageIO
import MobileCoreServices
import UniformTypeIdentifiers

final class LivePhotoMetadataWriter {
    func pairResources(photoURL: URL, videoURL: URL) async throws -> LivePhotoResources {
        let assetIdentifier = UUID().uuidString
        let workingDirectory = try makeWorkingDirectory()

        let pairedPhotoURL = workingDirectory.appendingPathComponent("IMG_LIVE.JPG")
        let pairedVideoURL = workingDirectory.appendingPathComponent("IMG_LIVE.MOV")

        try writeImageContentIdentifier(
            inputURL: photoURL,
            outputURL: pairedPhotoURL,
            assetIdentifier: assetIdentifier
        )

        try await writeVideoContentIdentifier(
            inputURL: videoURL,
            outputURL: pairedVideoURL,
            assetIdentifier: assetIdentifier
        )

        return LivePhotoResources(
            photoURL: pairedPhotoURL,
            pairedVideoURL: pairedVideoURL,
            assetIdentifier: assetIdentifier
        )
    }

    private func writeImageContentIdentifier(
        inputURL: URL,
        outputURL: URL,
        assetIdentifier: String
    ) throws {
        guard
            let source = CGImageSourceCreateWithURL(inputURL as CFURL, nil),
            let imageType = CGImageSourceGetType(source),
            let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, imageType, 1, nil)
        else {
            throw LivePhotoExportError.imageDataUnavailable
        }

        let metadata = (CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]) ?? [:]
        var mutableMetadata = metadata

        var makerApple = (mutableMetadata[kCGImagePropertyMakerAppleDictionary as String] as? [String: Any]) ?? [:]
        makerApple["17"] = assetIdentifier
        mutableMetadata[kCGImagePropertyMakerAppleDictionary as String] = makerApple

        CGImageDestinationAddImageFromSource(destination, source, 0, mutableMetadata as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            throw LivePhotoExportError.imageDataUnavailable
        }
    }

    private func writeVideoContentIdentifier(
        inputURL: URL,
        outputURL: URL,
        assetIdentifier: String
    ) async throws {
        // Implementation target:
        // - Re-export as a QuickTime .mov.
        // - Add top-level QuickTime metadata:
        //   com.apple.quicktime.content.identifier = assetIdentifier.
        // - Add a timed metadata track:
        //   com.apple.quicktime.still-image-time = 0xFF.
        //
        // AVAssetExportSession can attach the top-level QuickTime metadata, but
        // the still-image-time timed metadata track usually requires an
        // AVAssetWriter metadata adaptor or a proven helper implementation.
        //
        // Keep this explicit so we do not ship a fake Live Photo that saves as a
        // normal photo/video pair.
        _ = inputURL
        _ = outputURL
        _ = assetIdentifier
        throw LivePhotoExportError.metadataWritingNotImplemented
    }

    private func makeWorkingDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("live-photo-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}

