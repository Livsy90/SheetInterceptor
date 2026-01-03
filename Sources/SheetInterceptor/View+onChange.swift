import SwiftUI

extension View {
    @ViewBuilder
    func onChangeCompat<V>(
        of value: V,
        _ action: @escaping (_ previous: V, _ current: V) -> Void
    ) -> some View where V: Equatable {
        if #available(iOS 17, *) {
            onChange(of: value, action)
        } else {
            onChange(of: value) { [value] newValue in
                action(value, newValue)
            }
        }
    }
}
