import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
pragma Singleton
pragma ComponentBehavior: Bound

/**
 * A nice wrapper for default Pipewire audio sink and source.
 */
Singleton {
    id: root

    property bool ready: Pipewire.defaultAudioSink?.ready ?? false
    property PwNode sink: Pipewire.defaultAudioSink
    property PwNode source: Pipewire.defaultAudioSource

    signal sinkProtectionTriggered(string reason);

    PwObjectTracker {
        objects: [sink, source]
    }

    Connections { // Protection against sudden volume changes
        target: sink?.audio ?? null
        property bool lastReady: false
        property real lastVolume: 0
        property bool isAdjusting: false
        function onVolumeChanged() {
            // Prevent recursive calls when we modify the volume ourselves
            if (isAdjusting) {
                return;
            }

            if (!lastReady) {
                lastVolume = sink.audio.volume;
                lastReady = true;
                return;
            }
            // read the new volume reported by Pipewire
            var newVolume = sink.audio.volume;

            // Absolute hard-cap at 100% to prevent any external command (e.g. wpctl/hypr keywords)
            // from setting the sink above 1.0. This always runs regardless of the protection
            // toggle so keyboard/compositor commands can't bypass the 100% ceiling.
            if (newVolume > 1.0) {
                // Silently clamp to exactly 100% without triggering recursive handler
                isAdjusting = true;
                sink.audio.volume = 1.0;
                isAdjusting = false;
                lastVolume = 1.0;
                return;
            }

            // If protection is disabled, skip configurable protections but keep the hard-cap above.
            if (!Config.options.audio.protection.enable) {
                // ensure sink.audio.volume is valid
                if (sink.ready && (isNaN(sink.audio.volume) || sink.audio.volume === undefined || sink.audio.volume === null)) {
                    isAdjusting = true;
                    sink.audio.volume = 0;
                    isAdjusting = false;
                }
                lastVolume = sink.audio.volume;
                return;
            }

            const maxAllowedIncrease = Config.options.audio.protection.maxAllowedIncrease / 100; 
            const maxAllowed = Config.options.audio.protection.maxAllowed / 100;

            if (newVolume - lastVolume > maxAllowedIncrease) {
                isAdjusting = true;
                sink.audio.volume = lastVolume;
                isAdjusting = false;
                root.sinkProtectionTriggered("Illegal increment");
            } else if (newVolume > maxAllowed) {
                root.sinkProtectionTriggered("Exceeded max allowed");
                isAdjusting = true;
                sink.audio.volume = Math.min(lastVolume, maxAllowed);
                isAdjusting = false;
            }
            if (sink.ready && (isNaN(sink.audio.volume) || sink.audio.volume === undefined || sink.audio.volume === null)) {
                isAdjusting = true;
                sink.audio.volume = 0;
                isAdjusting = false;
            }
            lastVolume = sink.audio.volume;
        }
        
    }

}
