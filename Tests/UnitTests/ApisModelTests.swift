@testable import TemplateIOS
import Testing

@MainActor
struct ApisModelTests {
    @Test
    func `load reads which biometric the device offers`() {
        let model = ApisModel(locationClient: StubLocationClient(), biometricClient: StubBiometricClient(kind: .touchID))

        model.load()

        #expect(model.biometricKind == .touchID)
    }

    @Test
    func `locate shows the fix, or the failure`() async {
        let model = ApisModel(locationClient: StubLocationClient(), biometricClient: StubBiometricClient())
        await model.locate()
        #expect(model.location == .stub)
        #expect(!model.locationFailed)

        let denied = ApisModel(locationClient: StubLocationClient(failure: .denied), biometricClient: StubBiometricClient())
        await denied.locate()
        #expect(denied.location == nil)
        #expect(denied.locationFailed)
    }

    @Test
    func `tracking follows the stream and ends with it`() async {
        let model = ApisModel(locationClient: StubLocationClient(), biometricClient: StubBiometricClient())

        model.startTracking()
        #expect(model.isTracking)
        await Task.yield()
        for _ in 0 ..< 20 where model.isTracking {
            await Task.yield()
        }

        #expect(model.trackedLocation == [Location].stubTrack.last)
        #expect(!model.isTracking)
    }

    @Test
    func `stop cancels tracking`() {
        let model = ApisModel(locationClient: StubLocationClient(), biometricClient: StubBiometricClient())
        model.startTracking()

        model.stopTracking()

        #expect(!model.isTracking)
    }

    @Test
    func `the biometric outcome is what the client answered`() async {
        let model = ApisModel(locationClient: StubLocationClient(), biometricClient: StubBiometricClient(outcome: .cancelled))

        await model.authenticate(reason: "test")

        #expect(model.biometricOutcome == .cancelled)
        #expect(!model.isAuthenticating)
    }

    @Test
    func `an app that refused a URL is shown until it opens one`() {
        let model = ApisModel(locationClient: StubLocationClient(), biometricClient: StubBiometricClient())

        model.externalAppOpened(.dialer, accepted: false)
        #expect(model.unavailableApps == [.dialer])

        model.externalAppOpened(.dialer, accepted: true)
        #expect(model.unavailableApps.isEmpty)
    }
}
