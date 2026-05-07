//
//  HomeView.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/13/26.
//
import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedGroup: WalkGroup?
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WalkGroup.name) private var groups: [WalkGroup]
    
    @State private var editorMode: GroupEditorMode? = nil
    @State private var groupName = ""
    @State private var groupError = ""
    
    enum GroupEditorMode: Identifiable {
        case add
        case rename(WalkGroup)

        var id: String {
            switch self {
            case .add:
                return "add"
            case .rename(let group):
                return "rename-\(group.persistentModelID)"
            }
        }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(groups) { group in
                    Button {
                        selectedGroup = group
                    } label: {
                        HStack {
                            Text(group.name)
                            Spacer()
                            if selectedGroup?.persistentModelID == group.persistentModelID {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            groupName = group.name
                            groupError = ""
                            editorMode = .rename(group)
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if selectedGroup?.persistentModelID == group.persistentModelID {
                                selectedGroup = groups.first(where: { $0.persistentModelID != group.persistentModelID })
                            }
                            modelContext.delete(group)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Select Group")
                    Spacer()
                    Button("Add Group") {
                        groupName = ""
                        groupError = ""
                        editorMode = .add
                    }
                    .disabled(groups.count >= 5)
                    .textCase(nil)
                }
            }
        }
        .task {
            if groups.isEmpty {
                let defaultGroup = WalkGroup(name: "My Walks")
                modelContext.insert(defaultGroup)
                selectedGroup = defaultGroup
            } else if selectedGroup == nil {
                selectedGroup = groups.first
            }
        }
        .sheet(item: $editorMode) { mode in
            NavigationStack {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Group name", text: $groupName)
                        .textFieldStyle(.roundedBorder)

                    if !groupError.isEmpty {
                        Text(groupError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle(modeTitle(mode))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            editorMode = nil
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button(confirmButtonTitle(mode)) {
                            saveGroup(mode)
                        }
                    }
                }
            }
        }
    }
    
    private func modeTitle(_ mode: GroupEditorMode) -> String {
        switch mode {
        case .add: return "Add Group"
        case .rename: return "Rename Group"
        }
    }

    private func confirmButtonTitle(_ mode: GroupEditorMode) -> String {
        switch mode {
        case .add: return "Add"
        case .rename: return "Save"
        }
    }
    
    private func saveGroup(_ mode: GroupEditorMode) {
        let trimmed = groupName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            groupError = "Name cannot be empty."
        } else if trimmed.count > 100 {
            groupError = "Name must be 100 characters or fewer."
        } else if groups.contains(where: {
            switch mode {
            case .add:
                return $0.name.caseInsensitiveCompare(trimmed) == .orderedSame
            case .rename(let group):
                return $0.persistentModelID != group.persistentModelID &&
                       $0.name.caseInsensitiveCompare(trimmed) == .orderedSame
            }
        }) {
            groupError = "Name must be unique."
        } else {
            switch mode {
            case .add:
                let newGroup = WalkGroup(name: trimmed)
                modelContext.insert(newGroup)
                selectedGroup = newGroup

            case .rename(let group):
                group.name = trimmed
            }

            groupError = ""
            editorMode = nil
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: WalkGroup.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    
    let group1 = WalkGroup(name: "My Walks")
    let group2 = WalkGroup(name: "Training Runs")
    
    context.insert(group1)
    context.insert(group2)
    
    return HomeView(selectedGroup: .constant(group1))
        .modelContainer(container)
}

#Preview ("5 saved"){
    let container = try! ModelContainer(
        for: WalkGroup.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    
    let group1 = WalkGroup(name: "My Walks")
    let group2 = WalkGroup(name: "Training Runs")
    let group3 = WalkGroup(name: "three")
    let group4 = WalkGroup(name: "four")
    let group5 = WalkGroup(name: "five")
    
    context.insert(group1)
    context.insert(group2)
    context.insert(group3)
    context.insert(group4)
    context.insert(group5)
    
    return HomeView(selectedGroup: .constant(group1))
        .modelContainer(container)
}
