import SwiftUI
import QuickLook

private let previewableExtensions: Set<String> = [
    "pdf", "png", "jpg", "jpeg", "gif", "webp", "heic", "heif",
    "doc", "docx", "xls", "xlsx", "ppt", "pptx",
    "txt", "rtf", "csv", "json", "xml",
    "mp4", "mov", "m4v", "mp3", "m4a", "wav"
]

struct FileAttachmentView: View {
    let fileURLString: String

    @State private var localURL: URL?
    @State private var isDownloading = false
    @State private var showPreview = false
    @State private var showError = false
    @State private var downloadError: String?

    private var remoteURL: URL? {
        APIConfig.resolveFileURL(fileURLString)
    }

    private var fileName: String {
        fileURLString.components(separatedBy: "/").last ?? "Файл"
    }

    private var fileExtension: String {
        fileName.components(separatedBy: ".").last?.lowercased() ?? ""
    }

    private var imageExtensions: Set<String> {
        ["png", "jpg", "jpeg", "gif", "webp", "heic", "heif"]
    }

    private var displayName: String {
        if imageExtensions.contains(fileExtension) {
            return fileExtension.uppercased()
        }
        return fileName
    }

    private var isPreviewable: Bool {
        previewableExtensions.contains(fileExtension)
    }

    private var fileIcon: String {
        switch fileExtension {
        case "pdf": return "doc.richtext.fill"
        case "png", "jpg", "jpeg", "gif", "webp", "heic", "heif": return "photo.fill"
        case "mp4", "mov", "m4v": return "video.fill"
        case "mp3", "m4a", "wav": return "music.note"
        case "doc", "docx": return "doc.fill"
        case "xls", "xlsx": return "tablecells.fill"
        case "ppt", "pptx": return "rectangle.on.rectangle.fill"
        case "zip", "rar", "7z": return "archivebox.fill"
        default: return "doc.fill"
        }
    }

    private var fileIconColor: Color {
        switch fileExtension {
        case "pdf": return .red
        case "png", "jpg", "jpeg", "gif", "webp", "heic", "heif": return .blue
        case "mp4", "mov", "m4v": return .purple
        case "mp3", "m4a", "wav": return .pink
        case "doc", "docx": return .blue
        case "xls", "xlsx": return .green
        case "ppt", "pptx": return .orange
        case "zip", "rar", "7z": return .brown
        default: return .secondary
        }
    }

    var body: some View {
        Button {
            handleTap()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: fileIcon)
                    .font(.subheadline)
                    .foregroundStyle(fileIconColor)
                    .frame(width: 32, height: 32)
                    .background(fileIconColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(displayName)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isDownloading {
                    ProgressView()
                        .controlSize(.small)
                } else if isPreviewable {
                    Image(systemName: "arrow.up.right.circle")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPreview) {
            if let url = localURL {
                NavigationStack {
                    FilePreviewView(url: url)
                        .ignoresSafeArea()
                        .navigationTitle(fileName)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Готово") { showPreview = false }
                            }
                        }
                }
            }
        }
        .alert("Ошибка", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(downloadError ?? "Не удалось загрузить файл")
        }
    }

    private func handleTap() {
        guard let remoteURL else { return }

        if !isPreviewable {
            UIApplication.shared.open(remoteURL)
            return
        }

        if let cached = localURL {
            if FileManager.default.fileExists(atPath: cached.path) {
                showPreview = true
                return
            }
        }

        isDownloading = true
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: remoteURL)
                let tempDir = FileManager.default.temporaryDirectory
                let destination = tempDir.appendingPathComponent(fileName)
                try data.write(to: destination)
                await MainActor.run {
                    localURL = destination
                    isDownloading = false
                    showPreview = true
                }
            } catch {
                await MainActor.run {
                    isDownloading = false
                    downloadError = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        FileAttachmentView(fileURLString: "https://example.com/files/document.pdf")
        FileAttachmentView(fileURLString: "https://example.com/files/photo.jpg")
        FileAttachmentView(fileURLString: "https://example.com/files/archive.zip")
        FileAttachmentView(fileURLString: "https://example.com/files/652dd72a-d0ad-4611-9827-de0f96f2b240.JPG")
    }
    .padding()
}
