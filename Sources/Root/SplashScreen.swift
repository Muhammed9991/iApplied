import Settings
import Sharing
import SwiftUI
import Theme

struct SplashScreen<Content: View>: View {
    @Shared(.preferredColorScheme) var preferredColorScheme
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    private var resolvedColorScheme: ColorScheme {
        switch preferredColorScheme {
        case 1: .light
        case 2: .dark
        default: .light // System default
        }
    }
    
    var body: some View {
        Group {
            if isActive {
                content()
                    .transition(.opacity)
            } else {
                splashContent
            }
        }
    }

    @ViewBuilder
    private var splashContent: some View {
        ZStack {
            AppColors.background(for: resolvedColorScheme)
                .ignoresSafeArea()
            
            VStack {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.accent(for: resolvedColorScheme))
                    .accessibilityLabel("App icon")
                
                Text("iApplied")
                    .font(.largeTitle)
                    .foregroundColor(AppColors.textPrimary(for: resolvedColorScheme))
                    .padding(.top, 10)
                    .accessibilityAddTraits(.isHeader)
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear(perform: animateSplash)
        }
    }

    private func animateSplash() {
        withAnimation(.easeIn(duration: 1.2)) {
            size = 0.9
            opacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                isActive = true
            }
        }
    }
}
