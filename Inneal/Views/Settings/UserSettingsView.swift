//
//  UserSettingsView.swift
//  Inneal
//
//  Created by Brad Root on 3/25/24.
//

import Foundation
import SwiftData
import SwiftUI
import UIKit

struct UserSettingsView: View {
    @Environment(\.modelContext) var modelContext
    @State var defaultName: String = Preferences.standard.defaultName
    @Query(sort: [SortDescriptor(\Character.name)]) var characters: [Character]
    @Query var userSettings: [UserSettings]
    @Environment(\.dismiss) var dismiss
    @State var currentUserSettings: UserSettings = UserSettings(userCharacter: nil, defaultUserName: "You")
    @State var selectedCharacter: Character?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Your Name (in Chats)"), footer: Text("This is the default name used for you in chats. You can always change it in individual chats if you like, or change it here to affect all existing chats that do not have a name set already.")) {
                    TextField("Wakana Gojou", text: $currentUserSettings.defaultUserName)
                }
                Section(header: Text("Advanced Options"), footer: Text("You can also pick a character to act as your persona, giving you flexibility to add a description and more to yourself in chats.")) {
                    Picker("Persona", selection: $selectedCharacter) {
                        Text("None").tag(nil as Character?)
                        ForEach(characters) { character in
                            Text(character.name).tag(character as Character?)
                        }
                    }
                }
            }
            #if os(iOS)
            .scrollDismissesKeyboard(.immediately)
            #endif
            .navigationTitle("You")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Text("Done") }
                }
            }
            .onChange(of: selectedCharacter) { _, newValue in
                currentUserSettings.userCharacter = newValue
            }
            .onAppear {
                if userSettings.isEmpty {
                    let newUserSettings = UserSettings(userCharacter: nil, defaultUserName: defaultName)
                    modelContext.insert(newUserSettings)
                }
                if let settings = userSettings.first {
                    currentUserSettings = settings
                    selectedCharacter = settings.userCharacter
                }
            }
        }
    }
}

#Preview {
    UserSettingsView()
        .modelContainer(PreviewDataController.previewContainer)
}
