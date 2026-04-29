import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    @EnvironmentObject var onboardingData: OnboardingData
    @EnvironmentObject var supabaseService: SupabaseService
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isUploading = false
    @State private var showQuiz = false
    @State private var errorMessage: String?

    private let maxPhotos = 6
    private let minPhotos = 2

    var body: some View {
        VStack(spacing: 24) {
            Text("Add your photos")
                .font(.title2.bold())

            Text("Add at least \(minPhotos) photos to get started.")
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(0..<maxPhotos, id: \.self) { index in
                    if index < onboardingData.photoImages.count {
                        Image(uiImage: onboardingData.photoImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    onboardingData.photoImages.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.white, .black.opacity(0.5))
                                        .font(.title3)
                                }
                                .padding(4)
                            }
                    } else if index == onboardingData.photoImages.count {
                        PhotosPicker(
                            selection: $selectedItems,
                            maxSelectionCount: maxPhotos - onboardingData.photoImages.count,
                            matching: .images
                        ) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.gray.opacity(0.1))
                                .frame(height: 150)
                                .overlay {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                }
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.05))
                            .frame(height: 150)
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            Button {
                uploadAndContinue()
            } label: {
                if isUploading {
                    HStack {
                        ProgressView()
                        Text("Uploading...")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(canContinue ? Color.accentColor : .gray.opacity(0.3))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(!canContinue || isUploading)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .navigationTitle("Photos")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showQuiz) {
            DateStyleQuizView()
        }
        .onChange(of: selectedItems) { _, newItems in
            loadImages(from: newItems)
        }
        .alert("Upload Error", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var canContinue: Bool {
        onboardingData.photoImages.count >= minPhotos
    }

    private func loadImages(from items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    onboardingData.photoImages.append(image)
                }
            }
            selectedItems = []
        }
    }

    private func uploadAndContinue() {
        guard let userId = supabaseService.session?.user.id.uuidString else {
            showQuiz = true  // Skip upload if no session (preview mode)
            return
        }

        isUploading = true
        Task {
            do {
                var urls: [String] = []
                for (index, image) in onboardingData.photoImages.enumerated() {
                    guard let data = image.jpegData(compressionQuality: 0.7) else { continue }
                    let url = try await supabaseService.uploadPhoto(imageData: data, userId: userId, index: index)
                    urls.append(url)
                }
                onboardingData.photoURLs = urls
                showQuiz = true
            } catch {
                errorMessage = "Failed to upload photos. Please try again."
            }
            isUploading = false
        }
    }
}

#Preview {
    NavigationStack {
        PhotoUploadView()
            .environmentObject(OnboardingData())
            .environmentObject(SupabaseService())
    }
}
