import Cocoa
import WebKit

// A transparent strip over the top of the window that lets you drag it around.
final class DragBar: NSView {
    override var mouseDownCanMoveWindow: Bool { true }
    override func mouseDown(with event: NSEvent) { window?.performDrag(with: event) }
}

final class Bridge: NSObject, WKScriptMessageHandler {
    weak var window: NSWindow?
    func userContentController(_ c: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any], let type = body["type"] as? String else { return }
        switch type {
        case "pin":
            window?.level = (body["on"] as? Bool ?? true) ? .floating : .normal
        case "done":
            NSSound(named: "Glass")?.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { NSSound(named: "Glass")?.play() }
            NSApp.requestUserAttention(.informationalRequest)
            window?.orderFrontRegardless()
        default: break
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSPanel!
    let bridge = Bridge()

    func applicationDidFinishLaunching(_ n: Notification) {
        buildMenu()
        let size = NSSize(width: 280, height: 420)
        window = NSPanel(contentRect: NSRect(origin: .zero, size: size),
                         styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                         backing: .buffered, defer: false)
        window.title = "Melt & Study"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isFloatingPanel = true
        window.level = .floating
        window.hidesOnDeactivate = false
        window.becomesKeyOnlyIfNeeded = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.setFrameAutosaveName("MeltStudyWindow")
        if !window.setFrameUsingName("MeltStudyWindow"), let screen = NSScreen.main {
            let v = screen.visibleFrame
            window.setFrameOrigin(NSPoint(x: v.maxX - size.width - 24, y: v.maxY - size.height - 24))
        }

        let config = WKWebViewConfiguration()
        config.userContentController.add(bridge, name: "app")
        if #available(macOS 14.0, *) { config.preferences.inactiveSchedulingPolicy = .none }
        let web = WKWebView(frame: NSRect(origin: .zero, size: size), configuration: config)
        web.autoresizingMask = [.width, .height]
        web.setValue(false, forKey: "drawsBackground")
        bridge.window = window

        // frosted-glass background that blurs whatever is behind the window
        let content = NSVisualEffectView(frame: NSRect(origin: .zero, size: size))
        content.material = .hudWindow
        content.blendingMode = .behindWindow
        content.state = .active
        content.addSubview(web)
        // drag strip: top 34px, leaving the pin button on the right clickable
        let drag = DragBar(frame: NSRect(x: 0, y: size.height - 34, width: size.width - 40, height: 34))
        drag.autoresizingMask = [.width, .minYMargin]
        content.addSubview(drag)
        window.contentView = content

        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { true }

    func buildMenu() {
        let main = NSMenu()
        let appItem = NSMenuItem()
        main.addItem(appItem)
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Hide Melt & Study", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit Melt & Study", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu
        let winItem = NSMenuItem()
        main.addItem(winItem)
        let winMenu = NSMenu(title: "Window")
        winMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        winMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        winItem.submenu = winMenu
        NSApp.mainMenu = main
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
