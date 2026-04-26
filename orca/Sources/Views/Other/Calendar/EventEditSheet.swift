import EventKit
import EventKitUI
import SwiftUI

struct EventEditSheet: UIViewControllerRepresentable {
  let eventStore: EKEventStore
  let event: EKEvent
  var onComplete: (EKEventEditViewController, EKEventEditViewAction) -> Void = { controller, _ in
    controller.dismiss(animated: true)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(onComplete: onComplete)
  }

  func makeUIViewController(context: Context) -> EKEventEditViewController {
    let controller = EKEventEditViewController()
    controller.eventStore = eventStore
    controller.event = event
    controller.editViewDelegate = context.coordinator
    return controller
  }

  func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}

  final class Coordinator: NSObject, EKEventEditViewDelegate {
    let onComplete: (EKEventEditViewController, EKEventEditViewAction) -> Void

    init(onComplete: @escaping (EKEventEditViewController, EKEventEditViewAction) -> Void) {
      self.onComplete = onComplete
    }

    func eventEditViewController(
      _ controller: EKEventEditViewController,
      didCompleteWith action: EKEventEditViewAction
    ) {
      onComplete(controller, action)
    }
  }
}
