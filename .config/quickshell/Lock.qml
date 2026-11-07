import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import QtQuick

// Lock screen (SUPER + L, or the power menu), on every monitor. The password
// is checked by PAM with pam/password.conf
Scope {
    id: root

    property bool failed: false
    readonly property bool checking: pam.active

    // The password fields clear when this is emitted
    signal cleared()

    function lock() {
        failed = false;
        sessionLock.locked = true;
    }

    function unlock(password) {
        if (pam.active || password === "")
            return;
        pam.password = password;
        pam.start();
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            root.lock();
        }
    }

    PamContext {
        id: pam

        property string password

        configDirectory: Quickshell.shellDir + "/pam"
        config: "password.conf"

        onPamMessage: {
            if (responseRequired)
                respond(password);
        }

        onCompleted: result => {
            password = "";
            root.failed = result !== PamResult.Success;
            if (!root.failed)
                sessionLock.locked = false;
            root.cleared();
        }
    }

    WlSessionLock {
        id: sessionLock

        LockSurface {
            lock: root
        }
    }
}
