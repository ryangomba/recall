import SwiftUI
import SwiftUIX
import Firebase
import BackgroundTasks

@main
struct RecallApp: App {
    let badgeManager: BadgeManager
    init() {
        FirebaseApp.configure()
        badgeManager = BadgeManager()
        badgeManager.start()
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.ryangomba.Recall.refresh", using: nil) { [self] task in
             self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    func handleAppRefresh(task: BGAppRefreshTask) {
        let request = BGAppRefreshTaskRequest(identifier: "com.example.apple-samplecode.ColorFeed.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
//        task.expirationHandler = {}
//        task.setTaskCompleted(success: !operation.isCancelled)
    }
    func onForeground() {
        importDrafts()
    }
    func importDrafts() {
        let appGroupName = "group.com.ryangomba.Recall"
        let userDefaults = UserDefaults(suiteName: appGroupName)!
        let drafts = userDefaults.object(forKey: "drafts") as? [String] ?? []
        for draft in drafts {
            CardService.createDraft(text: draft)
        }
        userDefaults.set([], forKey: "drafts")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(env.sessionStore)
                .titleBarHidden(true)
                .onAppear(perform: {
                    onForeground()
                })
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    onForeground()
                }
        }
        .commands {
            SidebarCommands()
        }
    }
}
