//
//  ContentView.swift
//  TaskManager
//
//  Created by 長橋和敏 on 2025/01/27.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // @Environmentプロパティラッパーを使って、**Core Dataの管理対象コンテキスト（managed object context）**を取得する
    // プロパティラッパーはプロパティを効率的に管理・制御するためのツール
    // このviewContextを通じて、データベース操作（例: オブジェクトの保存や削除）を行う
    @Environment(\.managedObjectContext) private var viewContext

    // Core Dataのエンティティ（データ）を取得するためのリクエストを定義する
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MyTask.timestamp, ascending: true)],
        animation: .default)
    
    // このitems変数に、指定した条件でCore Dataから取得したデータがリアルタイムに反映される
    private var tasks: FetchedResults<MyTask>
    
    @State private var isAddingTask = false
    
    var body: some View {
        // 以下のコードは、Core Dataで取得したデータをリスト形式で表示し、項目の追加や削除ができるシンプルなUIを構築している
        // 複数の画面を階層的に表示できるナビゲーションインターフェイスを提供するコンテナ
        // ？なぜここはNavigationLinkではないのか？
        NavigationStack {
            List {
                // 取得したitemsの各要素を反復処理し、リストに表示
                ForEach(tasks) { task in
                    // なぜここもHStackである必要があるのか？
                    HStack {
                        Text(task.title ?? "Untitled Task")
                        Spacer()
                        Button(action: {
                            toggleTaskCompletion(task)
                        }) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle").foregroundColor(task.isCompleted ? .green : .gray)
                        }
                    }
                }
                .onDelete(perform: deleteTask)
            }
            .navigationTitle("タスク一覧")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddingTask = true
                    }) {
                        Label("新規タスク", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingTask) {
                AddTaskView()
            }
        }
    }
            
    // タスクの完了状態を切り替え
    private func toggleTaskCompletion(_ task: MyTask) {
        task.isCompleted.toggle()
        saveContext()
    }
            
    //タスクを削除
    private func deleteTask(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
            
    // コンテキストを保存
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }


    // このコードは、プレビューでCore Dataが使える状態にするための設定を行っている
    // SwiftUIのプレビューを管理するための構造体を定義
    struct ContentView_Previews: PreviewProvider {
        // プレビューとして表示するビューを定義
        static var previews: some View {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
