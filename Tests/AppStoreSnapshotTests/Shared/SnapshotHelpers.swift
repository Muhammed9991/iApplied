import SnapshotTesting
import SwiftUI
import UIKit

@MainActor
func assertAppStoreDevicePreviewSnapshots(
    for view: some View,
    @ViewBuilder description: @escaping () -> some View,
    backgroundColor: Color,
    colorScheme: ColorScheme,
    precision: Float = 0.98,
    perceptualPrecision: Float = 0.98,
    record recording: Bool? = nil,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    for (name, config) in appStoreViewConfigs {
        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            assertSnapshots(
                of: AppStoreDevicePreview(
                    .image(layout: .device(config: config)),
                    description: description,
                    backgroundColor: backgroundColor
                ) {
                    view
                        .environment(\.colorScheme, colorScheme)
                }
                .environment(\.colorScheme, colorScheme),
                as: [
                    .image(
                        precision: precision,
                        perceptualPrecision: perceptualPrecision,
                        layout: .device(config: config)
                    )

                ],
                record: recording,
                fileID: fileID,
                file: filePath,
                testName: "\(testName)\(name)",
                line: line,
                column: column
            )
        }
    }
}

@MainActor
func assertDeviceBottomSheetSnapshots(
    for view: some View,
    @ViewBuilder description: @escaping () -> some View,
    backgroundColor: Color,
    colorScheme: ColorScheme,
    precision: Float = 0.98,
    perceptualPrecision: Float = 0.98,
    record recording: Bool? = nil,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    for (name, config) in appStoreViewConfigs {
        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            assertSnapshots(
                of: DeviceBottomSheetPreview(
                    .image(layout: .device(config: config)),
                    description: description,
                    backgroundColor: backgroundColor
                ) {
                    view
                        .environment(\.colorScheme, colorScheme)
                }
                .environment(\.colorScheme, colorScheme),
                as: [
                    .image(
                        precision: precision,
                        perceptualPrecision: perceptualPrecision,
                        layout: .device(config: config)
                    )

                ],
                record: recording,
                fileID: fileID,
                file: filePath,
                testName: "\(testName)\(name)",
                line: line,
                column: column
            )
        }
    }
}
