import SnapshotTesting
import SwiftUI
import UIKit

struct Snapshot<Content>: View where Content: View {
    let content: () -> Content
    @State var image: Image?
    let snapshotting: Snapshotting<AnyView, UIImage>

    init(
        _ snapshotting: Snapshotting<AnyView, UIImage>,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.content = content
        self.snapshotting = snapshotting
    }

    var body: some View {
        ZStack {
            image?
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .onAppear {
            snapshotting
                .snapshot(AnyView(content()))
                .run { image = Image(uiImage: $0) }
        }
    }
}
