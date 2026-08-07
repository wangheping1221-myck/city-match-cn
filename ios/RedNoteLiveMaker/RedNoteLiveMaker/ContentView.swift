import PhotosUI
import SwiftUI

struct ContentView: View {
    @StateObject private var exporter = LivePhotoExporter()

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var canvasPreset: SocialCanvasPreset = .rednotePortrait
    @State private var motionPreset: MotionPreset = .slowZoomIn
    @State private var duration: LivePhotoDuration = .two

    var body: some View {
        NavigationStack {
            Form {
                Section("Input") {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Choose photo", systemImage: "photo")
                    }

                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                Section("Preset") {
                    Picker("Canvas", selection: $canvasPreset) {
                        ForEach(SocialCanvasPreset.allCases) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }

                    Picker("Motion", selection: $motionPreset) {
                        ForEach(MotionPreset.allCases) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }

                    Picker("Duration", selection: $duration) {
                        ForEach(LivePhotoDuration.allCases) { option in
                            Text(option.label).tag(option)
                        }
                    }
                }

                Section {
                    Button {
                        guard let selectedImage else { return }
                        Task {
                            await exporter.exportPhotoAsLivePhoto(
                                image: selectedImage,
                                motionPreset: motionPreset,
                                canvasPreset: canvasPreset,
                                duration: duration
                            )
                        }
                    } label: {
                        if exporter.isExporting {
                            ProgressView()
                        } else {
                            Label("Save as Live Photo", systemImage: "livephoto")
                        }
                    }
                    .disabled(selectedImage == nil || exporter.isExporting)
                }

                Section("Status") {
                    Text(exporter.statusMessage)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("LivePost Maker")
            .task(id: selectedItem) {
                await loadSelectedImage()
            }
        }
    }

    private func loadSelectedImage() async {
        guard let selectedItem else { return }
        do {
            if let data = try await selectedItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        } catch {
            exporter.statusMessage = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}

