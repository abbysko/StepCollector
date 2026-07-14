//
//  HomeView.swift
//  Step Collector
//
//  Created by Abigail Skofield on 4/13/26.
//
import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedGroup: WalkGroup?
    var isTrackingActive: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WalkGroup.name) private var walkGroups: [WalkGroup]
    
    @State private var editorMode: GroupEditorMode? = nil
    @State private var groupName = ""
    @State private var groupError = ""
    
    enum GroupEditorMode: Identifiable {
        case add
        case rename(WalkGroup)

        var id: String {
            switch self {
            case .add: return "add"
            case .rename(let group): return "rename-\(group.persistentModelID)"
            }
        }

        var title: String {
            switch self {
            case .add: return "Add Group"
            case .rename: return "Rename Group"
            }
        }

        var confirmLabel: String {
            switch self {
            case .add: return "Add"
            case .rename: return "Save"
            }
        }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(walkGroups) { group in
                    displayWalkGroupRow(group)
                }
            } header: {
                listHeader
            }
        }
        .task {
            if walkGroups.isEmpty {
                let defaultGroup = WalkGroup(name: "Demo Walks")
                let sampleSessions: [(daysAgo: Int, duration: TimeInterval, steps: Int)] = [
                    (1,  2700, 2843),
                    (2,  3960, 4102),
                    (3,  1800, 2011),
                    (5,  4500, 4987),
                    (7,  2340, 2556),
                    (8,  3120, 3401),
                    (10, 1980, 2200),
                    (12, 4200, 4631),
                    (14, 2520, 2788),
                    (15, 3780, 3953),
                ]
                let now = Date()
                for entry in sampleSessions {
                    let start = Calendar.current.date(byAdding: .day, value: -entry.daysAgo, to: now) ?? now
                    defaultGroup.sessions.append(WalkSession(start: start, duration: entry.duration, stepCount: entry.steps))
                }
                modelContext.insert(defaultGroup)
                selectedGroup = defaultGroup
            } else if selectedGroup == nil {
                selectedGroup = walkGroups.first
            }
        }
        .sheet(item: $editorMode) { mode in
            addRenameDialog(for: mode)
        }
    }

    private var listHeader: some View {
        HStack {
            Text("Select Group")
            Spacer()
            Button("Add Group") {
                groupName = ""
                groupError = ""
                editorMode = .add
            }
            .disabled(walkGroups.count >= 5 || isTrackingActive)
            .textCase(nil)
        }
    }

    private func displayWalkGroupRow(_ group: WalkGroup) -> some View {
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
        .disabled(isTrackingActive)
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
                    selectedGroup = walkGroups.first(where: { $0.persistentModelID != group.persistentModelID })
                }
                modelContext.delete(group)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func addRenameDialog(for mode: GroupEditorMode) -> some View {
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
            .navigationTitle(mode.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { editorMode = nil }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode.confirmLabel) { saveGroup(mode) }
                }
            }
        }
    }
    
    private func saveGroup(_ mode: GroupEditorMode) {
        let trimmed = groupName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            groupError = "Name cannot be empty."
        } else if trimmed.count > 100 {
            groupError = "Name must be 100 characters or fewer."
        } else if walkGroups.contains(where: {
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

#Preview("5 saved") {
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
