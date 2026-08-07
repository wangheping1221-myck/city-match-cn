# RedNoteLiveMaker iOS MVP Skeleton

This folder contains a lightweight SwiftUI/PhotoKit skeleton for the proposed iOS MVP.

It is not a complete Xcode project because this repository currently hosts static web assets and the current environment is Linux-based. To continue implementation on macOS:

1. Open Xcode.
2. Create a new iOS App project named `RedNoteLiveMaker`.
3. Set interface to SwiftUI.
4. Add the Swift files from `RedNoteLiveMaker/`.
5. Add the Info.plist permission strings listed below.
6. Fill in the `LivePhotoMetadataWriter` implementation using AVFoundation/ImageIO.

## Required capabilities

- Photos add-only permission.
- Photo picker access via `PhotosUI`.

## Required Info.plist keys

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save generated Live Photos to your photo library.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Select photos and videos to turn them into Live Photos.</string>
```

## Live Photo pipeline

```text
User selects photo/video
  -> Normalize to selected format (3:4, 1:1, or 9:16)
  -> Render a short H.264 .mov
  -> Generate key photo .jpg
  -> Write matching Live Photo identifiers into photo and movie metadata
  -> Save resources with PHAssetCreationRequest:
       .photo + .pairedVideo
  -> Photos app shows a real LIVE asset
```

## Implementation notes

Apple Photos recognizes a Live Photo when:

1. The still image has Apple MakerNote key `17` set to a UUID content identifier.
2. The movie has QuickTime metadata `com.apple.quicktime.content.identifier` set to the same UUID.
3. The movie includes the still-image-time timed metadata track.
4. The app saves both resources in one `PHAssetCreationRequest`.

The skeleton separates this into:

- `MotionVideoRenderer`: static photo -> subtle motion MOV.
- `LivePhotoMetadataWriter`: image/video metadata pairing.
- `PhotoLibrarySaver`: PhotoKit save request.
- `LivePhotoExporter`: high-level orchestration.

## First build target

Implement and test one path first:

1. Pick a static photo.
2. Render a 2-second slow zoom-in MOV.
3. Write metadata.
4. Save as Live Photo.
5. Confirm the output has the LIVE badge in Photos and can be selected in RedNote/Xiaohongshu.

After that path is proven, add video input and trimming.

