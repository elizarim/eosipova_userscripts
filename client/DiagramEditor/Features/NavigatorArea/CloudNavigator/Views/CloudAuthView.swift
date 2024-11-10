import SwiftUI

struct CloudAuthView: View {
    enum Mode {
        case signUp
        case signIn
    }

    var mode: Mode
    var client: CloudClient
    var dismiss: () -> Void

    @State var server = ""
    @State var username = ""
    @State var password = ""
    @State var passwordConfirmation = ""

    @State var isSendingRequest: Bool = false
    @State var authErrorAlertIsPresented: Bool = false
    @State var authErrorDetail: String = ""

    private var isSignUpMode: Bool {
        switch mode {
        case .signIn: return false
        case .signUp: return true
        }
    }
    private let keychain = AppKeychain()

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(
                    content: {
                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Server")
                                    .font(.caption3)
                                    .foregroundColor(.secondary)
                                TextField("", text: $server, prompt: Text("http://127.0.0.1:8080"))
                                    .labelsHidden()
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Username")
                                    .font(.caption3)
                                    .foregroundColor(.secondary)
                                TextField("", text: $username)
                                    .labelsHidden()
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Password")
                                    .font(.caption3)
                                    .foregroundColor(.secondary)
                                SecureField("", text: $password)
                                    .labelsHidden()
                            }
                            if isSignUpMode {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Password Confirmation")
                                        .font(.caption3)
                                        .foregroundColor(.secondary)
                                    SecureField("", text: $passwordConfirmation)
                                        .labelsHidden()
                                }
                            }
                        }
                        .disabled(isSendingRequest)
                    },
                    header: {
                        VStack(alignment: .center, spacing: 10) {
                            Text(isSignUpMode ? "Sign Up" : "Sign In")
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    },
                    footer: {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Text("Cancel")
                                    .frame(maxWidth: .infinity)
                            }
                            .disabled(isSendingRequest)
                            .controlSize(.large)
                            .frame(maxWidth: .infinity)

                            Button {
                                authenticate()
                            } label: {
                                Text(isSignUpMode ? "Sign Up" : "Sign In")
                                    .frame(maxWidth: .infinity)
                            }
                            .disabled(username.isEmpty || password.isEmpty || (isSignUpMode && passwordConfirmation.isEmpty) || isSendingRequest)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .alert(
                                Text("Unable to add account"),
                                isPresented: $authErrorAlertIsPresented
                            ) {
                                Button("OK") {
                                    authErrorAlertIsPresented.toggle()
                                }
                            } message: {
                                Text(authErrorDetail)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                )
            }
            .formStyle(.grouped)
            .background(Color.green)
            .scrollDisabled(true)
            .onSubmit {
                authenticate()
            }
        }
        .frame(width: 300)
    }

    @MainActor
    private func authenticate() {
        guard let serverURL = URL(string: server), serverURL.host() != nil else {
            authErrorDetail = "Invalid server URL"
            authErrorAlertIsPresented.toggle()
            return
        }
        if let account = client.account, account.serverURL == serverURL, account.name.lowercased() == username.lowercased() {
            authErrorDetail = "Account with the same username and provider already exists"
            authErrorAlertIsPresented.toggle()
            return
        }
        if isSignUpMode && password.count < 8 {
            authErrorDetail = "Password is less than minimum of 8 characters"
            authErrorAlertIsPresented.toggle()
            return
        }
        if isSignUpMode && password != passwordConfirmation {
            authErrorDetail = "Passwords did not match"
            authErrorAlertIsPresented.toggle()
            return
        }
        isSendingRequest = true
        Task { @MainActor in
            do {
                if isSignUpMode {
                    try await client.signUp(serverURL, username, password, passwordConfirmation)
                }
                try await client.signIn(serverURL, username, password)
                dismiss()
            } catch {
                handleRequestError(error)
            }
            isSendingRequest = false
        }
    }

    private func handleRequestError(_ error: Error) {
        if let apiError = error as? CloudClient.APIError {
            authErrorDetail = apiError.reason
        } else {
            authErrorDetail = error.localizedDescription
        }
        authErrorAlertIsPresented.toggle()
    }
}

extension Font {
    static var caption3: Font { .system(size: 11, weight: .medium) }
}
