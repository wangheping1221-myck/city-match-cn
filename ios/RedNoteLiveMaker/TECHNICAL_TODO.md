# Technical TODO

## Must validate before TestFlight

### 1. MotionVideoRenderer

`renderMotionVideo(...)` now has an initial AVAssetWriter implementation. Validate it on device with:

- `AVAssetWriter` output type `.mov`.
- H.264 video codec.
- 1080-based canvas sizes from `SocialCanvasPreset`.
- 24 or 30 fps.
- `CVPixelBufferPool` for frame rendering.
- `CIContext.render(_:to:)` or Core Graphics drawing into pixel buffers.
- Motion transforms for:
  - slow zoom in
  - slow zoom out
  - pan left
  - pan right
  - breath

Acceptance:

- The output MOV plays in Photos/QuickTime.
- First and last frames do not flash black.
- The first frame is a valid static card.

### 2. LivePhotoMetadataWriter

`writeVideoContentIdentifier(...)` now has an initial AVAssetReader/Writer implementation. Validate that it writes:

- Top-level QuickTime metadata:
  - `com.apple.quicktime.content.identifier`
- Timed metadata track:
  - `com.apple.quicktime.still-image-time`
  - payload byte `0xFF`
  - timestamp should match the key photo moment, usually frame 0 or the chosen cover frame

Acceptance:

- `PHAssetCreationRequest` saves one Live Photo asset, not separate photo/video assets.
- Photos shows the LIVE badge.
- Press-and-hold plays motion.
- The Live Photo can be selected in RedNote/Xiaohongshu from the iPhone album.

### 3. Video input path

Add a separate path for video input:

- Pick video from Photos/Files.
- Trim with `AVAssetExportSession` or `AVAssetReader`/`AVAssetWriter`.
- Extract key photo with `AVAssetImageGenerator`.
- Rewrap/export MOV with required Live Photo metadata.
- Save with `PhotoLibrarySaver`.

### 4. App Store readiness

- Add icons.
- Add screenshots:
  - choose photo
  - choose motion preset
  - save as Live Photo
  - Photos LIVE badge
  - RedNote publish flow
- Add privacy policy.
- Add Terms of Use if monetization is enabled.
- Add StoreKit purchase flow only after export path is stable.

## Suggested first test case

Use one vertical product photo:

1. Select `3:4 RedNote`.
2. Select `Slow zoom in`.
3. Select `2s`.
4. Save to Photos.
5. Verify LIVE badge.
6. Publish in RedNote/Xiaohongshu.

