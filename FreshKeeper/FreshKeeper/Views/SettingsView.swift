//
//  SettingsView.swift
//  FreshKeeper
//
//  Settings view for managing app configuration including OpenAI API key
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey = ""
    @State private var showAPIKey = false
    @State private var isEditingAPIKey = false
    @State private var showDeleteConfirmation = false
    @State private var showSuccessMessage = false
    @State private var errorMessage: String?
    @State private var selectedVisionModelId: String = ""
    @State private var selectedReasoningModelId: String = ""
    @State private var showVisionModelPicker = false
    @State private var showReasoningModelPicker = false

    private let openAIService = OpenAIService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F9FA")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // AI Integration Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                    .foregroundColor(Color(hex: "9C27B0"))
                                    .font(.title2)
                                Text("AI Food Identification")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "1A1A1A"))
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Configure OpenAI API Key")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                Text("Enable AI-powered food identification by adding your OpenAI API key. This allows the app to automatically identify food items from photos.")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(Color(hex: "666666"))
                                    .fixedSize(horizontal: false, vertical: true)

                                if openAIService.hasAPIKey {
                                    // API Key is configured
                                    VStack(spacing: 12) {
                                        HStack {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(Color(hex: "4CAF50"))
                                            Text("Configuration Active")
                                                .font(.system(.subheadline, design: .rounded))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(hex: "4CAF50"))
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color(hex: "E8F5E9"))
                                        .cornerRadius(12)

                                        // Vision Model Selection
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Vision Model (Food Identification)")
                                                .font(.system(.caption, design: .rounded))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(hex: "666666"))

                                            Button {
                                                showVisionModelPicker = true
                                            } label: {
                                                HStack {
                                                    Image(systemName: "camera.fill")
                                                        .font(.caption)
                                                        .foregroundColor(Color(hex: "9C27B0"))
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        if let currentModel = OpenAIModel.visionModels.first(where: { $0.id == selectedVisionModelId }) {
                                                            Text(currentModel.name)
                                                                .font(.system(.subheadline, design: .rounded))
                                                                .fontWeight(.semibold)
                                                                .foregroundColor(Color(hex: "1A1A1A"))
                                                            Text(currentModel.costEstimate)
                                                                .font(.system(.caption, design: .rounded))
                                                                .foregroundColor(Color(hex: "666666"))
                                                        }
                                                    }
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                        .font(.caption)
                                                        .foregroundColor(Color(hex: "999999"))
                                                }
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(8)
                                            }
                                        }

                                        // Reasoning Model Selection
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Reasoning Model (Recommendations)")
                                                .font(.system(.caption, design: .rounded))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(hex: "666666"))

                                            Button {
                                                showReasoningModelPicker = true
                                            } label: {
                                                HStack {
                                                    Image(systemName: "brain")
                                                        .font(.caption)
                                                        .foregroundColor(Color(hex: "2196F3"))
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        if let currentModel = OpenAIModel.reasoningModels.first(where: { $0.id == selectedReasoningModelId }) {
                                                            Text(currentModel.name)
                                                                .font(.system(.subheadline, design: .rounded))
                                                                .fontWeight(.semibold)
                                                                .foregroundColor(Color(hex: "1A1A1A"))
                                                            Text(currentModel.costEstimate)
                                                                .font(.system(.caption, design: .rounded))
                                                                .foregroundColor(Color(hex: "666666"))
                                                        }
                                                    }
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                        .font(.caption)
                                                        .foregroundColor(Color(hex: "999999"))
                                                }
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(8)
                                            }
                                        }

                                        HStack(spacing: 12) {
                                            if showAPIKey {
                                                Text(openAIService.getAPIKey() ?? "")
                                                    .font(.system(.caption, design: .monospaced))
                                                    .foregroundColor(Color(hex: "1A1A1A"))
                                                    .lineLimit(1)
                                                    .truncationMode(.middle)
                                            } else {
                                                Text("••••••••••••••••••••")
                                                    .font(.system(.caption, design: .monospaced))
                                                    .foregroundColor(Color(hex: "666666"))
                                            }

                                            Button {
                                                showAPIKey.toggle()
                                            } label: {
                                                Image(systemName: showAPIKey ? "eye.slash" : "eye")
                                                    .font(.caption)
                                                    .foregroundColor(Color(hex: "2196F3"))
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(8)

                                        HStack(spacing: 12) {
                                            Button {
                                                isEditingAPIKey = true
                                            } label: {
                                                Label("Update Config", systemImage: "pencil")
                                                    .font(.system(.subheadline, design: .rounded))
                                                    .fontWeight(.semibold)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 12)
                                                    .background(Color(hex: "2196F3"))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(8)
                                            }

                                            Button {
                                                showDeleteConfirmation = true
                                            } label: {
                                                Label("Delete All", systemImage: "trash")
                                                    .font(.system(.subheadline, design: .rounded))
                                                    .fontWeight(.semibold)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 12)
                                                    .background(Color(hex: "FF5722"))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                } else {
                                    // No API Key configured
                                    Button {
                                        isEditingAPIKey = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Add API Key")
                                                .fontWeight(.semibold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            LinearGradient(
                                                colors: [Color(hex: "9C27B0"), Color(hex: "7B1FA2")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                        }


                        // How to get API Key section
                        VStack(alignment: .leading, spacing: 12) {
                            Label("How to get an API Key", systemImage: "questionmark.circle")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "1A1A1A"))

                            VStack(alignment: .leading, spacing: 8) {
                                StepRow(step: 1, text: "Visit platform.openai.com")
                                StepRow(step: 2, text: "Sign up or log in to your account")
                                StepRow(step: 3, text: "Go to API Keys section")
                                StepRow(step: 4, text: "Click 'Create new secret key'")
                                StepRow(step: 5, text: "Copy the key and paste it here")
                            }
                            .padding()
                            .background(Color(hex: "F0F7FF"))
                            .cornerRadius(12)

                            Text("Note: You'll need to add billing to your OpenAI account. The cost is very low (~$0.01 per identification).")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color(hex: "666666"))
                                .italic()
                        }

                        // App Info Section
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(Color(hex: "2196F3"))
                                Text("About FreshKeeper")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                Spacer()
                            }

                            HStack {
                                Text("Version")
                                    .foregroundColor(Color(hex: "666666"))
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                            }
                            .font(.system(.subheadline, design: .rounded))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isEditingAPIKey) {
                APIKeyEditSheet(
                    apiKey: $apiKey,
                    selectedVisionModelId: $selectedVisionModelId,
                    selectedReasoningModelId: $selectedReasoningModelId,
                    onSave: {
                        if openAIService.saveAPIKey(apiKey) {
                            _ = openAIService.saveSelectedModel(selectedVisionModelId, for: .vision)
                            _ = openAIService.saveSelectedModel(selectedReasoningModelId, for: .reasoning)
                            showSuccessMessage = true
                            apiKey = ""
                            isEditingAPIKey = false
                        } else {
                            errorMessage = "Failed to save configuration"
                        }
                    }
                )
                .onAppear {
                    if openAIService.hasAPIKey {
                        apiKey = openAIService.getAPIKey() ?? ""
                    }
                    selectedVisionModelId = openAIService.getSelectedModel(for: .vision)
                    selectedReasoningModelId = openAIService.getSelectedModel(for: .reasoning)
                }
            }
            .sheet(isPresented: $showVisionModelPicker) {
                ModelPickerSheet(
                    selectedModelId: $selectedVisionModelId,
                    models: OpenAIModel.visionModels,
                    title: "Select Vision Model"
                ) {
                    _ = openAIService.saveSelectedModel(selectedVisionModelId, for: .vision)
                    showVisionModelPicker = false
                }
            }
            .sheet(isPresented: $showReasoningModelPicker) {
                ModelPickerSheet(
                    selectedModelId: $selectedReasoningModelId,
                    models: OpenAIModel.reasoningModels,
                    title: "Select Reasoning Model"
                ) {
                    _ = openAIService.saveSelectedModel(selectedReasoningModelId, for: .reasoning)
                    showReasoningModelPicker = false
                }
            }
            .onAppear {
                selectedVisionModelId = openAIService.getSelectedModel(for: .vision)
                selectedReasoningModelId = openAIService.getSelectedModel(for: .reasoning)
            }
            .alert("Delete All Configuration?", isPresented: $showDeleteConfirmation) {
                Button("Delete All", role: .destructive) {
                    _ = openAIService.deleteAllConfiguration()
                    selectedVisionModelId = ""
                    selectedReasoningModelId = ""
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove your OpenAI API key and selected model, disabling AI food identification.")
            }
            .alert("Success", isPresented: $showSuccessMessage) {
                Button("OK") {}
            } message: {
                Text("API Key has been saved successfully")
            }
        }
    }
}

struct StepRow: View {
    let step: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(step).")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color(hex: "2196F3")))

            Text(text)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Color(hex: "1A1A1A"))

            Spacer()
        }
    }
}

struct APIKeyEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var apiKey: String
    @Binding var selectedVisionModelId: String
    @Binding var selectedReasoningModelId: String
    let onSave: () -> Void
    @State private var isValidKey = false
    @State private var showKey = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        if showKey {
                            TextField("sk-...", text: $apiKey)
                                .font(.system(.body, design: .monospaced))
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        } else {
                            SecureField("sk-...", text: $apiKey)
                                .font(.system(.body, design: .monospaced))
                        }

                        Button {
                            showKey.toggle()
                        } label: {
                            Image(systemName: showKey ? "eye.slash" : "eye")
                                .foregroundColor(Color(hex: "666666"))
                        }
                    }
                    .onChange(of: apiKey) { _, newValue in
                        // Basic validation
                        isValidKey = newValue.hasPrefix("sk-") && newValue.count > 20
                    }
                } header: {
                    Text("OpenAI API Key")
                } footer: {
                    Text("Your API key starts with 'sk-' and is kept secure in your device's keychain. Tap the eye icon to show/hide the key.")
                        .font(.caption)
                }

                Section {
                    Picker("Vision Model", selection: $selectedVisionModelId) {
                        ForEach(OpenAIModel.visionModels, id: \.id) { model in
                            VStack(alignment: .leading) {
                                Text(model.name)
                                Text(model.costEstimate)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(model.id)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Reasoning Model", selection: $selectedReasoningModelId) {
                        ForEach(OpenAIModel.reasoningModels, id: \.id) { model in
                            VStack(alignment: .leading) {
                                Text(model.name)
                                Text(model.costEstimate)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(model.id)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("AI Models")
                } footer: {
                    Text("Vision model is used for food identification from photos. Reasoning model will be used for meal recommendations (coming soon).")
                        .font(.caption)
                }

                if !apiKey.isEmpty && !isValidKey {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("API key should start with 'sk-'")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("OpenAI Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(!isValidKey)
                }
            }
        }
    }
}

struct ModelPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedModelId: String
    let models: [OpenAIModel]
    let title: String
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(models, id: \.id) { model in
                    Button {
                        selectedModelId = model.id
                        onSave()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(model.name)
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                Text(model.description)
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(Color(hex: "666666"))
                                Text(model.costEstimate)
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: "2196F3"))
                            }
                            Spacer()
                            if model.id == selectedModelId {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "4CAF50"))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}