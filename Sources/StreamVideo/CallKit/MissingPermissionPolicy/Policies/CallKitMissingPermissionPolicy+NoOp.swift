//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

#if os(iOS) // SPIKE macOS: CallKit (CXProvider) and PushKit VoIP are iOS-only

import Foundation

extension CallKitMissingPermissionPolicy {
    
    /// No-op policy. Always allows reporting, regardless of permissions or
    /// app state.
    final class NoOp: CallKitMissingPermissionPolicyProtocol {
        
        /// Always allow.
        func reportCall() throws { /* No-op */ }
    }
}
#endif
