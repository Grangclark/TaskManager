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
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    
    // このitems変数に、指定した条件でCore Dataから取得したデータがリアルタイムに反映される
    private var items: FetchedResults<Item>

    var body: some View {
        // 以下のコードは、Core Dataで取得したデータをリスト形式で表示し、項目の追加や削除ができるシンプルなUIを構築している
        // 複数の画面を階層的に表示できるナビゲーションインターフェイスを提供するコンテナ
        NavigationView {
            List {
                // 取得したitemsの各要素を反復処理し、リストに表示
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                // ユーザーがリストの項目をスワイプして削除する際に呼び出される関数
                .onDelete(perform: deleteItems)
            }
            // ツールバーにボタンを追加
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    // この関数は、Core Dataを利用して新しい項目（Itemエンティティ）を作成し、
    // データベースに保存する処理を行っている
    private func addItem() {
        // SwiftUIのアニメーションを適用するスコープ。
        // この中のUI変更（リストへの新規項目追加など）はアニメーション付きで更新される
        withAnimation {
            // Core DataのItemエンティティの新しいインスタンスを作成し、
            // 指定されたviewContextに関連付ける
            let newItem = Item(context: viewContext)
            // Itemエンティティのtimestampプロパティに現在日時を設定
            newItem.timestamp = Date()

            // コンテキスト内の変更を永続化（保存）
            // 実際のデータベースファイル（SQLiteなど）に変更が反映される
            // 保存中にエラーが発生した場合（例: データベースが書き込み禁止）、catchブロックが実行される
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                // スローされたエラー（error）をNSError型にキャスト
                let nsError = error as NSError
                // エラー内容を出力し、アプリケーションをクラッシュさせる
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // このコードは、Core Dataを利用してデータを削除する処理を実行している
    // 具体的には、リストのアイテムをスワイプで削除したときに呼び出される
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            // 削除対象の取得と削除処理
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// このコードは、日時をフォーマットするための DateFormatter を定義している
private let itemFormatter: DateFormatter = {
    // クロージャ内部
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

// このコードは、プレビューでCore Dataが使える状態にするための設定を行っている
// SwiftUIのプレビューを管理するための構造体を定義
struct ContentView_Previews: PreviewProvider {
    // プレビューとして表示するビューを定義
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
