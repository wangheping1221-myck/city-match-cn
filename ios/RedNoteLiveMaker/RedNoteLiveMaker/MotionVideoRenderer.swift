import AVFoundation
import CoreImage
import UIKit

final class MotionVideoRenderer {
    private let context = CIContext()

    func renderMotionVideo(
        from image: UIImage,
        preset: MotionPreset,
        canvas: SocialCanvasPreset,
        duration: LivePhotoDuration,
        outputURL: URL
    ) async throws -> URL {
        guard image.cgImage != nil else {
            throw LivePhotoExportError.imageDataUnavailable
        }

        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }

        let targetSize = canvas.size
        let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(targetSize.width),
            AVVideoHeightKey: Int(targetSize.height),
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 6_000_000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]

        let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        input.expectsMediaDataInRealTime = false

        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: Int(targetSize.width),
            kCVPixelBufferHeightKey as String: Int(targetSize.height),
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]

        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: pixelBufferAttributes
        )

        guard writer.canAdd(input) else {
            throw LivePhotoExportError.videoRenderingFailed
        }

        writer.add(input)
        guard writer.startWriting() else {
            throw writer.error ?? LivePhotoExportError.videoRenderingFailed
        }

        let fps: Int32 = 24
        let frameCount = max(1, Int(duration.rawValue * Double(fps)))
        writer.startSession(atSourceTime: .zero)

        try await withCheckedThrowingContinuation { continuation in
            let queue = DispatchQueue(label: "rednote-live.motion-renderer")
            var frameIndex = 0
            var didResume = false

            func finish(_ result: Result<URL, Error>) {
                guard !didResume else { return }
                didResume = true
                switch result {
                case .success(let url):
                    continuation.resume(returning: url)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            input.requestMediaDataWhenReady(on: queue) {
                while input.isReadyForMoreMediaData && frameIndex < frameCount {
                    let time = CMTime(value: CMTimeValue(frameIndex), timescale: fps)
                    let progress = frameCount <= 1 ? 0 : CGFloat(frameIndex) / CGFloat(frameCount - 1)

                    guard let pixelBuffer = self.makePixelBuffer(
                        image: image,
                        canvasSize: targetSize,
                        preset: preset,
                        progress: progress,
                        attributes: pixelBufferAttributes
                    ) else {
                        input.markAsFinished()
                        writer.cancelWriting()
                        finish(.failure(LivePhotoExportError.videoRenderingFailed))
                        return
                    }

                    if !adaptor.append(pixelBuffer, withPresentationTime: time) {
                        input.markAsFinished()
                        writer.cancelWriting()
                        finish(.failure(writer.error ?? LivePhotoExportError.videoRenderingFailed))
                        return
                    }

                    frameIndex += 1
                }

                if frameIndex >= frameCount {
                    input.markAsFinished()
                    writer.finishWriting {
                        if writer.status == .completed {
                            finish(.success(outputURL))
                        } else {
                            finish(.failure(writer.error ?? LivePhotoExportError.videoRenderingFailed))
                        }
                    }
                }
            }
        }

        _ = context
        return outputURL
    }

    func renderKeyPhoto(
        from image: UIImage,
        canvas: SocialCanvasPreset,
        outputURL: URL
    ) throws -> URL {
        let targetSize = canvas.size
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let rendered = renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))

            let rect = aspectFillRect(
                imageSize: image.size,
                canvasSize: targetSize
            )
            image.draw(in: rect)
        }

        guard let data = rendered.jpegData(compressionQuality: 0.94) else {
            throw LivePhotoExportError.imageDataUnavailable
        }

        try data.write(to: outputURL, options: [.atomic])
        return outputURL
    }

    private func aspectFillRect(imageSize: CGSize, canvasSize: CGSize) -> CGRect {
        let imageRatio = imageSize.width / max(imageSize.height, 1)
        let canvasRatio = canvasSize.width / max(canvasSize.height, 1)

        let drawSize: CGSize
        if imageRatio > canvasRatio {
            drawSize = CGSize(width: canvasSize.height * imageRatio, height: canvasSize.height)
        } else {
            drawSize = CGSize(width: canvasSize.width, height: canvasSize.width / imageRatio)
        }

        return CGRect(
            x: (canvasSize.width - drawSize.width) / 2,
            y: (canvasSize.height - drawSize.height) / 2,
            width: drawSize.width,
            height: drawSize.height
        )
    }

    private func makePixelBuffer(
        image: UIImage,
        canvasSize: CGSize,
        preset: MotionPreset,
        progress: CGFloat,
        attributes: [String: Any]
    ) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(canvasSize.width),
            Int(canvasSize.height),
            kCVPixelFormatType_32ARGB,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

        guard
            let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer),
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
            let context = CGContext(
                data: baseAddress,
                width: Int(canvasSize.width),
                height: Int(canvasSize.height),
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
            )
        else {
            return nil
        }

        UIGraphicsPushContext(context)
        UIColor.black.setFill()
        UIRectFill(CGRect(origin: .zero, size: canvasSize))

        let motion = motionTransform(for: preset, progress: progress)
        var rect = aspectFillRect(imageSize: image.size, canvasSize: canvasSize)
        let originalCenter = CGPoint(x: rect.midX, y: rect.midY)
        rect.size.width *= motion.scale
        rect.size.height *= motion.scale
        rect.origin.x = originalCenter.x - rect.width / 2 + motion.offset.width * canvasSize.width
        rect.origin.y = originalCenter.y - rect.height / 2 + motion.offset.height * canvasSize.height
        image.draw(in: rect)
        UIGraphicsPopContext()

        return pixelBuffer
    }

    private func motionTransform(
        for preset: MotionPreset,
        progress: CGFloat
    ) -> (scale: CGFloat, offset: CGSize) {
        let u = sin(max(0, min(1, progress)) * .pi)

        switch preset {
        case .slowZoomIn:
            return (1.02 + 0.08 * u, .zero)
        case .slowZoomOut:
            return (1.10 - 0.08 * u, .zero)
        case .panLeft:
            return (1.08, CGSize(width: 0.025 - 0.05 * u, height: 0))
        case .panRight:
            return (1.08, CGSize(width: -0.025 + 0.05 * u, height: 0))
        case .breath:
            return (1.02 + 0.06 * u, .zero)
        }
    }
}

