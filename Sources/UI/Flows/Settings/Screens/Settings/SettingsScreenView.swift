import DesignSystem
import PhotosUI
import SwiftUI
import UIKit

struct SettingsScreenView: View {
    @Environment(SettingsModel.self) private var settingsModel
    @Environment(AccountModel.self) private var accountModel
    @Environment(SessionModel.self) private var sessionModel
    @Environment(NotesModel.self) private var notesModel
    @Environment(StorageModel.self) private var storageModel
    @Environment(\.openURL) private var openURL
    @State private var isPhotoSourceShown = false
    @State private var isCameraShown = false
    @State private var isLibraryShown = false
    @State private var libraryItem: PhotosPickerItem?
    @State private var isDeleteConfirmationShown = false
    let version: String
    let build: String
    let buildType: String
    let apiHost: String

    private static let studioURL = URL(string: "https://mkdigital.sk")!

    var body: some View {
        List {
            Section(String(localized: .settingsProfileSection)) {
                Button {
                    isPhotoSourceShown = true
                } label: {
                    HStack(spacing: Spacing.m) {
                        ProfilePhoto(data: settingsModel.profilePhoto)
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(.settingsProfilePhoto)
                                .foregroundStyle(Color.dsTextPrimary)
                            Text(.settingsProfilePhotoHint)
                                .font(.dsCaption)
                                .foregroundStyle(Color.dsTextSecondary)
                        }
                    }
                }
                if let user = accountModel.user {
                    LabeledContent(String(localized: .settingsEmail), value: user.email)
                }
            }
            Section(String(localized: .settingsAppearanceSection)) {
                Picker(String(localized: .settingsTheme), selection: appearance) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.text)
                    }
                }
                Button(String(localized: .settingsLanguage), action: openAppSettings)
            }
            Section(String(localized: .settingsAboutSection)) {
                LabeledContent(String(localized: .settingsVersion), value: "\(version) (\(build))")
                LabeledContent(String(localized: .settingsBuildType), value: buildType)
                LabeledContent(String(localized: .settingsApiHost), value: apiHost)
                Link(destination: Self.studioURL) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(.settingsAboutTagline)
                            .foregroundStyle(Color.dsTextPrimary)
                        Text(verbatim: Self.studioURL.host() ?? "")
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsAccent)
                    }
                }
            }
            #if DEBUG
            Section(String(localized: .settingsDebugSection)) {
                Button(role: .destructive) {
                    settingsModel.triggerTestCrash()
                } label: {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(.settingsTestCrashTitle)
                        Text(.settingsTestCrashSubtitle)
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsTextSecondary)
                    }
                }
            }
            #endif
            Section(String(localized: .settingsAccountSection)) {
                Button(String(localized: .settingsSignOut), action: signOut)
                Button(String(localized: .settingsDeleteAccount), role: .destructive) {
                    isDeleteConfirmationShown = true
                }
                .disabled(accountModel.user?.isDemo ?? true || accountModel.isDeleting)
                if accountModel.user?.isDemo == true {
                    Text(.settingsDeleteAccountDemo)
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsTextSecondary)
                }
                if accountModel.deleteFailed {
                    Text(.settingsDeleteAccountError)
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsError)
                }
            }
        }
        .navigationTitle(Text(.settingsTitle))
        .task {
            await accountModel.load()
        }
        .confirmationDialog(Text(.settingsPhotoSourceTitle), isPresented: $isPhotoSourceShown, titleVisibility: .visible) {
            if CameraPicker.isAvailable {
                Button(String(localized: .settingsPhotoSourceCamera)) { isCameraShown = true }
            }
            Button(String(localized: .settingsPhotoSourceLibrary)) { isLibraryShown = true }
            if settingsModel.profilePhoto != nil {
                Button(String(localized: .settingsPhotoRemove), role: .destructive) {
                    Task { await settingsModel.setProfilePhoto(nil) }
                }
            }
        }
        .fullScreenCover(isPresented: $isCameraShown) {
            CameraPicker { data in
                isCameraShown = false
                guard let data else { return }
                Task { await settingsModel.setProfilePhoto(data) }
            }
            .ignoresSafeArea()
        }
        .photosPicker(isPresented: $isLibraryShown, selection: $libraryItem, matching: .images)
        .onChange(of: libraryItem) { _, item in
            guard let item else { return }
            Task {
                let data = try? await item.loadTransferable(type: Data.self)
                libraryItem = nil
                guard let photo = data.flatMap(UIImage.init)?.profilePhotoData else { return }
                await settingsModel.setProfilePhoto(photo)
            }
        }
        .confirmationDialog(Text(.settingsDeleteAccountTitle), isPresented: $isDeleteConfirmationShown, titleVisibility: .visible) {
            Button(String(localized: .settingsDeleteAccountConfirm), role: .destructive, action: deleteAccount)
        } message: {
            Text(.settingsDeleteAccountText)
        }
    }

    private var appearance: Binding<AppearanceMode> {
        Binding(get: { settingsModel.appearance }) { mode in
            Task { await settingsModel.setAppearance(mode) }
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }

    /// The token authorizes the call, so the account goes first and the device is cleared after.
    private func deleteAccount() {
        Task {
            guard await accountModel.deleteAccount() else { return }
            await clearDeviceAndSignOut()
        }
    }

    private func signOut() {
        Task {
            await clearDeviceAndSignOut()
        }
    }

    /// Each store clears on its own, and the session ends whatever they answer — a store that will not
    /// clear must never leave the person signed in on a device that half-erased itself.
    private func clearDeviceAndSignOut() async {
        await notesModel.deleteAll()
        try? await storageModel.reset()
        await sessionModel.signOut()
    }
}

private struct ProfilePhoto: View {
    let data: Data?

    var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(Color.dsTextSecondary)
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(.circle)
    }
}

#Preview(traits: .modifier(SessionPreviewModifier()), .modifier(SettingsPreviewModifier()), .modifier(AccountPreviewModifier()), .modifier(NotesPreviewModifier()), .modifier(StoragePreviewModifier())) {
    NavigationStack {
        SettingsScreenView(version: "1.0", build: "1", buildType: "debug", apiHost: "api.showcase.mkdigital.sk")
    }
}
