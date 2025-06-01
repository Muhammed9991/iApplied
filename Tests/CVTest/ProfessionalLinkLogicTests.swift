import ComposableArchitecture
@testable import CV
import Foundation
import Models
import Testing

@MainActor
struct ProfessionalLinkLogicTests {
    @Test
    func onButtonTapped_setsTitleErrorIfTitleIsEmpty() async {
        let store = TestStore(initialState: ProfessionalLinkLogic.State(
            viewMode: .add,
            title: "",
            urlString: "https://linkedin.com/in/your-profile"
        )) {
            ProfessionalLinkLogic()
        }

        await store.send(.onButtonTapped) {
            $0.titleTextFieldError = .requiredField
        }
    }

    @Test
    func onButtonTapped_setsLinkErrorIfUrlIsEmpty() async {
        let store = TestStore(initialState: ProfessionalLinkLogic.State(
            viewMode: .add,
            title: "LinkedIn",
            urlString: ""
        )) {
            ProfessionalLinkLogic()
        }

        await store.send(.onButtonTapped) {
            $0.linkFieldError = .requiredField
        }
    }

    @Test
    func onButtonTapped_withValidInput_inAddMode_sendsOnSaveLinkAndDismisses() async {
        let date = Date(timeIntervalSince1970: 1_700_000_000)

        let store = TestStore(initialState: ProfessionalLinkLogic.State(
            viewMode: .add, id: 1,
            createdAt: date,
            title: "LinkedIn",
            urlString: "https://linkedin.com/in/me",
            iconName: "briefcase"
        )) {
            ProfessionalLinkLogic()
        } withDependencies: {
            $0.date.now = date
        }

        await store.send(.onButtonTapped)
        
        #expect(store.state.titleTextFieldError == nil)
        #expect(store.state.linkFieldError == nil)

        await store.receive(.delegate(.onSaveLink(
            ProfessionalLink(
                id: 1,
                createdAt: date,
                title: "LinkedIn",
                link: "https://linkedin.com/in/me",
                image: "briefcase"
            )
        )))
    }

    @Test
    func onButtonTapped_withValidInput_inEditMode_sendsOnEditLinkAndDismisses() async {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let store = TestStore(initialState: ProfessionalLinkLogic.State(
            viewMode: .edit, id: 99,
            createdAt: date,
            title: "GitHub",
            urlString: "https://github.com/me",
            iconName: "terminal"
        )) {
            ProfessionalLinkLogic()
        } withDependencies: {
            $0.date.now = date
        }

        await store.send(.onButtonTapped)
        
        #expect(store.state.titleTextFieldError == nil)
        #expect(store.state.linkFieldError == nil)

        await store.receive(.delegate(.onEditLink(
            ProfessionalLink(
                id: 99,
                createdAt: date,
                title: "GitHub",
                link: "https://github.com/me",
                image: "terminal"
            )
        )))
    }
}
