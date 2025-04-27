//  Created by Muhammed Mahmood on 27/04/2025.

import ComposableArchitecture
import SwiftUI

public struct CVTabView: View {
    let store: StoreOf<CVLogic>

    public init(store: StoreOf<CVLogic>) {
        self.store = store
    }

    public var body: some View {
        Text("Hello World")
    }
}

@Reducer
public struct CVLogic {
    public init() {}
}
