//
//  TaskManagerApp.swift
//  TaskManager
//
//  Created by 長橋和敏 on 2025/01/27.
//

import SwiftUI

@main
struct MyTaskManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
