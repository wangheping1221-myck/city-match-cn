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

        // Implementation target:
        // - Use AVAssetWriter with H.264 QuickTime output.
        // - Render 24 or 30 fps frames from the source image.
        // - Apply Ken Burns-style transforms based on MotionPreset.
        // - Keep the first frame readable because it will also be the key photo.
        //
        // This method is intentionally left as a compile-safe boundary for the
        // first Xcode implementation pass.
        _ = context
        _ = preset
        _ = canvas
        _ = duration
        _ = outputURL
        throw LivePhotoExportError.videoRenderingFailed
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
}

