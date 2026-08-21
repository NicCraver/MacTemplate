 

extension CGSize {
    /// Scales up a point-size CGSize into its pixel representation.
    /// 
    var pixelSize: CGSize {
        #if os(iOS)
        let scale = UIScreen.cc_active.scale
        #elseif os(macOS)
        let scale = NSScreen.main?.backingScaleFactor ?? 2
        #else
        let scale: CGFloat = 2
        #endif
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}
