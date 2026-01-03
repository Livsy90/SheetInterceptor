import SwiftUI

public extension View {
    /// Adds a sheet dismissal interceptor using presentation detents.
    ///
    /// Use this modifier on content presented in a sheet to prevent interactive dismissal
    /// when the user drags the sheet to a specific "threshold" detent. When the sheet
    /// reaches that detent, the modifier restores the previous detent and invokes
    /// `onIntercept` so you can present a confirmation alert or perform custom logic
    /// (for example, asking the user to confirm closing with unsaved changes).
    ///
    /// The modifier configures the sheet's available detents and tracks the current
    /// selection. If the selection changes to the configured threshold detent, the
    /// change is intercepted and reverted.
    ///
    /// - Parameters:
    ///   - config: A configuration describing the available detents, the default detent
    ///     to start at, and the detent that should act as the interception threshold.
    ///   - onIntercept: A closure invoked whenever the user attempts to dismiss by
    ///     dragging the sheet to the threshold detent.
    /// - Returns: A view that intercepts dismissal attempts at the threshold detent.
    ///
    /// - Example:
    /// ```swift
    /// import SwiftUI
    ///
    /// struct DismissInterceptorExampleView: View {
    ///     @State private var isSheetPresented = false
    ///     @State private var isAlertPresented = false
    ///
    ///     var body: some View {
    ///         VStack(spacing: 16) {
    ///             Button("Present Sheet") {
    ///                 isSheetPresented = true
    ///             }
    ///         }
    ///         .sheet(isPresented: $isSheetPresented) {
    ///             Text("Pull me down to intercept")
    ///                 .dismissInterceptor(
    ///                     config: DismissInterceptorConfig(
    ///                         tresholdDetent: .height(300),
    ///                         defaultDetent: .large,
    ///                         other: [.medium]
    ///                     )
    ///                 ) {
    ///                     isAlertPresented.toggle()
    ///                 }
    ///                 .alert("Are you sure?", isPresented: $isAlertPresented) {
    ///                     Button("Cancel") {}
    ///                     Button("OK") {
    ///                         isSheetPresented.toggle()
    ///                     }
    ///                 }
    ///         }
    ///     }
    /// }
    /// ```
    func dismissInterceptor(
        config: DismissInterceptorConfig,
        onIntercept: @escaping () -> Void
    ) -> some View {
        modifier(
            DismissInterceptorModifier(
                config: config,
                onIntercept: onIntercept
            )
        )
    }
}

/// Configuration for the sheet dismissal interceptor.
///
/// Use this type to declare which presentation detents are available to the sheet,
/// which detent should be selected by default when the sheet appears, and which
/// detent should be treated as the dismissal threshold (the detent that, when
/// reached by a drag gesture, will trigger interception instead of allowing the
/// sheet to dismiss).
///
/// The initializer ensures that both the `tresholdDetent` and `defaultDetent` are
/// included in the set of available `detents`.
public struct DismissInterceptorConfig {
    /// The full set of detents available to the sheet, including the threshold and default detents.
    let detents: Set<PresentationDetent>
    /// The detent the sheet should start at when presented.
    let defaultDetent: PresentationDetent
    /// The detent that acts as the dismissal threshold to intercept at.
    let tresholdDetent: PresentationDetent
    
    /// Creates a new configuration.
    ///
    /// - Parameters:
    ///   - tresholdDetent: The detent that acts as the interception threshold. When the
    ///     sheet is dragged to this detent, the attempt is intercepted and `onIntercept`
    ///     is invoked.
    ///   - defaultDetent: The detent that should be selected by default when the sheet appears.
    ///   - other: Additional detents to make available alongside the threshold and default detents.
    public init(
        tresholdDetent: PresentationDetent,
        defaultDetent: PresentationDetent,
        other: Set<PresentationDetent>
    ) {
        self.detents = other.union(Set([tresholdDetent, defaultDetent]))
        self.defaultDetent = defaultDetent
        self.tresholdDetent = tresholdDetent
    }
}

struct DismissInterceptorModifier: ViewModifier {
    
    @State private var currentDetent = PresentationDetent.large
    private let treshold: PresentationDetent
    private let detents: Set<PresentationDetent>
    private let onIntercept: () -> Void
    
    init(
        config: DismissInterceptorConfig,
        onIntercept: @escaping () -> Void
    ) {
        self.currentDetent = config.defaultDetent
        self.treshold = config.tresholdDetent
        self.detents = config.detents
        self.onIntercept = onIntercept
    }
    
    func body(content: Content) -> some View {
        content
            .presentationDetents(detents, selection: $currentDetent)
            .onChangeCompat(of: currentDetent) { oldValue, newValue in
                if newValue == treshold {
                    currentDetent = oldValue
                    Task {
                        onIntercept()
                    }
                }
            }
            .interactiveDismissDisabled()
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var isSheetPresented = false
    @Previewable @State var isAlertPresented = false
    
    VStack(spacing: 16) {
        Button("Present Sheet") {
            isSheetPresented = true
        }
    }
    .sheet(isPresented: $isSheetPresented) {
        Text("Pull me down to intercept")
            .dismissInterceptor(
                config: DismissInterceptorConfig(
                    tresholdDetent: .height(300),
                    defaultDetent: .large,
                    other: [.medium]
                )
            ) {
                isAlertPresented.toggle()
            }
            .alert("Are you sure?", isPresented: $isAlertPresented) {
                Button("Cancel") {}
                Button("OK") {
                    isSheetPresented.toggle()
                }
            }
    }
}

