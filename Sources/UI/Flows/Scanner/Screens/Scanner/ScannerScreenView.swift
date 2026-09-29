import AVFoundation
import DesignSystem
import SwiftUI

struct ScannerScreenView: View {
    @State private var viewModel: ScannerViewModel

    init(viewModel: ScannerViewModel = ScannerViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text(.scannerSubtitle)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextSecondary)
                Picker(String(localized: .scannerMode), selection: $viewModel.mode) {
                    Text(.scannerModeGenerate).tag(ScannerViewModel.Mode.generate)
                    Text(.scannerModeScan).tag(ScannerViewModel.Mode.scan)
                }
                .pickerStyle(.segmented)
                switch viewModel.mode {
                case .generate:
                    GeneratePane(viewModel: viewModel)
                case .scan:
                    ScanPane(scanned: viewModel.scanned, onScan: viewModel.codeScanned, onScanAgain: viewModel.scanAgain)
                }
            }
            .screenPadding()
        }
        .background(Color.dsBackground)
        .navigationTitle(Text(.scannerTitle))
        .onChange(of: viewModel.mode) { viewModel.modeChanged() }
    }
}

private struct GeneratePane: View {
    @Bindable var viewModel: ScannerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Picker(String(localized: .scannerFormat), selection: $viewModel.format) {
                Text(.scannerFormatQr).tag(CodeFormat.qr)
                Text(.scannerFormatBarcode).tag(CodeFormat.barcode)
            }
            .pickerStyle(.segmented)
            FormField(label: Text(.scannerInputLabel), error: nil) {
                TextField(String(localized: .scannerInputHint), text: $viewModel.text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            Button(String(localized: .scannerGenerate), action: viewModel.generate)
                .buttonStyle(.dsPrimary)
                .disabled(viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            if let generated = viewModel.generated {
                VStack(spacing: Spacing.s) {
                    Text(.scannerResultTitle)
                        .font(.dsBodyEmphasis)
                        .foregroundStyle(Color.dsTextPrimary)
                    Image(decorative: generated, scale: 1)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 260)
                        .padding(Spacing.m)
                        .background(.white, in: .rect(cornerRadius: 12))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onChange(of: viewModel.text) { viewModel.inputChanged() }
        .onChange(of: viewModel.format) { viewModel.inputChanged() }
    }
}

private struct ScanPane: View {
    let scanned: String?
    let onScan: (String) -> Void
    let onScanAgain: () -> Void
    @State private var cameraGranted: Bool?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            if let scanned {
                Text(.scannerScannedResult)
                    .font(.dsBodyEmphasis)
                    .foregroundStyle(Color.dsTextPrimary)
                Text(scanned)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextPrimary)
                    .textSelection(.enabled)
                Button(String(localized: .scannerScanAgain), action: onScanAgain)
                    .buttonStyle(.dsSecondary)
            } else if !CodeScannerView.isSupported {
                Text(.scannerUnsupported)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextSecondary)
            } else if cameraGranted == false {
                Text(.scannerCameraDenied)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsError)
            } else if cameraGranted == true {
                CodeScannerView(onScan: onScan)
                    .frame(height: 320)
                    .clipShape(.rect(cornerRadius: 12))
                Text(.scannerHint)
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsTextSecondary)
            }
        }
        .task {
            guard CodeScannerView.isSupported, cameraGranted == nil else { return }
            cameraGranted = await AVCaptureDevice.requestAccess(for: .video)
        }
    }
}

#Preview("Generated") {
    let viewModel = ScannerViewModel(text: "https://mkdigital.sk")
    viewModel.generate()
    return NavigationStack {
        ScannerScreenView(viewModel: viewModel)
    }
}
