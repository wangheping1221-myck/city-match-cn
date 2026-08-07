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
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }

        let asset = AVURLAsset(url: inputURL)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            throw LivePhotoExportError.videoRenderingFailed
        }

        let reader = try AVAssetReader(asset: asset)
        let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mov)

        let videoReaderSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let videoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        videoOutput.alwaysCopiesSampleData = false
        guard reader.canAdd(videoOutput) else {
            throw LivePhotoExportError.videoRenderingFailed
        }
        reader.add(videoOutput)

        let transformedSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        let width = abs(transformedSize.width)
        let height = abs(transformedSize.height)
        let videoInput = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: Int(width),
                AVVideoHeightKey: Int(height),
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: 6_000_000,
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
                ]
            ]
        )
        videoInput.transform = videoTrack.preferredTransform
        videoInput.expectsMediaDataInRealTime = false
        guard writer.canAdd(videoInput) else {
            throw LivePhotoExportError.videoRenderingFailed
        }
        writer.add(videoInput)

        var audioOutput: AVAssetReaderTrackOutput?
        var audioInput: AVAssetWriterInput?
        if let audioTrack = asset.tracks(withMediaType: .audio).first {
            let output = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            output.alwaysCopiesSampleData = false
            if reader.canAdd(output) {
                reader.add(output)
                audioOutput = output

                let input = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
                input.expectsMediaDataInRealTime = false
                if writer.canAdd(input) {
                    writer.add(input)
                    audioInput = input
                }
            }
        }

        writer.metadata = [metadataForAssetID(assetIdentifier)]
        let stillImageTimeMetadataAdapter = createMetadataAdaptorForStillImageTime()
        if writer.canAdd(stillImageTimeMetadataAdapter.assetWriterInput) {
            writer.add(stillImageTimeMetadataAdapter.assetWriterInput)
        }

        guard writer.startWriting(), reader.startReading() else {
            throw writer.error ?? reader.error ?? LivePhotoExportError.videoRenderingFailed
        }
        writer.startSession(atSourceTime: .zero)

        let stillImageTime = CMTimeRange(
            start: CMTime(seconds: max(0.01, asset.duration.seconds / 2), preferredTimescale: 600),
            duration: CMTime(value: 1, timescale: 600)
        )
        stillImageTimeMetadataAdapter.append(
            AVTimedMetadataGroup(
                items: [metadataItemForStillImageTime()],
                timeRange: stillImageTime
            )
        )

        try await withCheckedThrowingContinuation { continuation in
            let queue = DispatchQueue(label: "rednote-live.metadata-writer")
            var videoFinished = false
            var audioFinished = audioInput == nil || audioOutput == nil
            var didResume = false

            func finishIfReady() {
                guard videoFinished && audioFinished && !didResume else { return }
                didResume = true
                writer.finishWriting {
                    if writer.status == .completed {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: writer.error ?? LivePhotoExportError.videoRenderingFailed)
                    }
                }
            }

            videoInput.requestMediaDataWhenReady(on: queue) {
                while videoInput.isReadyForMoreMediaData {
                    guard let sampleBuffer = videoOutput.copyNextSampleBuffer() else {
                        videoInput.markAsFinished()
                        videoFinished = true
                        finishIfReady()
                        return
                    }

                    if !videoInput.append(sampleBuffer) {
                        reader.cancelReading()
                        videoInput.markAsFinished()
                        videoFinished = true
                        if !didResume {
                            didResume = true
                            continuation.resume(throwing: writer.error ?? LivePhotoExportError.videoRenderingFailed)
                        }
                        return
                    }
                }
            }

            if let audioInput, let audioOutput {
                audioInput.requestMediaDataWhenReady(on: queue) {
                    while audioInput.isReadyForMoreMediaData {
                        guard let sampleBuffer = audioOutput.copyNextSampleBuffer() else {
                            audioInput.markAsFinished()
                            audioFinished = true
                            finishIfReady()
                            return
                        }

                        if !audioInput.append(sampleBuffer) {
                            reader.cancelReading()
                            audioInput.markAsFinished()
                            audioFinished = true
                            if !didResume {
                                didResume = true
                                continuation.resume(throwing: writer.error ?? LivePhotoExportError.videoRenderingFailed)
                            }
                            return
                        }
                    }
                }
            }
        }
    }

    private func metadataForAssetID(_ assetIdentifier: String) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = "com.apple.quicktime.content.identifier" as (NSCopying & NSObjectProtocol)
        item.keySpace = AVMetadataKeySpace(rawValue: "mdta")
        item.value = assetIdentifier as (NSCopying & NSObjectProtocol)
        item.dataType = "com.apple.metadata.datatype.UTF-8"
        return item
    }

    private func createMetadataAdaptorForStillImageTime() -> AVAssetWriterInputMetadataAdaptor {
        let keyStillImageTime = "com.apple.quicktime.still-image-time"
        let keySpaceQuickTimeMetadata = "mdta"
        let spec: NSDictionary = [
            kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as NSString:
                "\(keySpaceQuickTimeMetadata)/\(keyStillImageTime)",
            kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as NSString:
                "com.apple.metadata.datatype.int8"
        ]

        var description: CMFormatDescription?
        CMMetadataFormatDescriptionCreateWithMetadataSpecifications(
            kCFAllocatorDefault,
            kCMMetadataFormatType_Boxed,
            [spec] as CFArray,
            &description
        )

        let input = AVAssetWriterInput(
            mediaType: .metadata,
            outputSettings: nil,
            sourceFormatHint: description
        )
        return AVAssetWriterInputMetadataAdaptor(assetWriterInput: input)
    }

    private func metadataItemForStillImageTime() -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = "com.apple.quicktime.still-image-time" as (NSCopying & NSObjectProtocol)
        item.keySpace = AVMetadataKeySpace(rawValue: "mdta")
        item.value = 0 as (NSCopying & NSObjectProtocol)
        item.dataType = "com.apple.metadata.datatype.int8"
        return item
    }

    private func makeWorkingDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("live-photo-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}

