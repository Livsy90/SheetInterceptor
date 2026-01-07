# SheetInterceptor

<img src="https://github.com/Livsy90/SheetInterceptor/blob/main/SheetInterceptorDemo.gif" height="450">

A SwiftUI sheet dismissal interceptor using `presentationDetents`. It prevents interactive sheet dismissal when the user drags to a configured “threshold” detent and lets you run custom logic (for example, showing a confirmation about unsaved changes).

## Features
- Configurable sheet detents (including threshold and default)
- Tracks the selected detent via `selection`
- Intercepts dismissal when reaching the threshold detent and restores the previous detent
- `onIntercept` callback to show an alert or run custom logic
- Disables interactive dismissal (`interactiveDismissDisabled`) until the user confirms explicitly

## Requirements
- iOS 16+

## Installation via Swift Package Manager

Add the package to your project using one of the following methods:

- Xcode: File → Add Packages… → paste the repository URL

```
https://github.com/Livsy90/SheetInterceptor.git
```
## Example:

 ```swift
 import SwiftUI

 struct DismissInterceptorExampleView: View {
     @State private var isSheetPresented = false
     @State private var isAlertPresented = false

     var body: some View {
         VStack {
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
 }
 ```
