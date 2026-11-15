import Cocoa

// Draws a 1024px app icon: pastel rounded square with an ice cube + candle.
let out = CommandLine.arguments[1]
let S: CGFloat = 1024
let img = NSImage(size: NSSize(width: S, height: S))
img.lockFocus()
let bg = NSBezierPath(roundedRect: NSRect(x: 100, y: 100, width: 824, height: 824), xRadius: 185, yRadius: 185)
NSGradient(starting: NSColor(red: 0.30, green: 0.36, blue: 0.80, alpha: 1),
           ending: NSColor(red: 0.80, green: 0.50, blue: 0.86, alpha: 1))!.draw(in: bg, angle: 90)
func emoji(_ s: String, _ size: CGFloat, _ x: CGFloat, _ y: CGFloat) {
    (s as NSString).draw(at: NSPoint(x: x, y: y), withAttributes: [.font: NSFont.systemFont(ofSize: size)])
}
emoji("🕯️", 360, 470, 230)
emoji("🧊", 340, 170, 300)
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
