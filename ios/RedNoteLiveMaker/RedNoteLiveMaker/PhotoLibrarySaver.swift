import Foundation
import Photos

final class PhotoLibrarySaver {
    func requestAddOnlyAuthorization() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
    }

    func saveLivePhoto(resources: LivePhotoResources) async throws {
        let status = await requestAddOnlyAuthorization()
        guard status == .authorized || status == .limited else {
            throw LivePhotoExportError.photoLibrarySaveFailed(nil)
        }

        try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()

                let photoOptions = PHAssetResourceCreationOptions()
                photoOptions.shouldMoveFile = false

                let videoOptions = PHAssetResourceCreationOptions()
                videoOptions.shouldMoveFile = false

                request.addResource(with: .photo, fileURL: resources.photoURL, options: photoOptions)
                request.addResource(with: .pairedVideo, fileURL: resources.pairedVideoURL, options: videoOptions)
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: LivePhotoExportError.photoLibrarySaveFailed(error))
                }
            }
        }
    }
}

