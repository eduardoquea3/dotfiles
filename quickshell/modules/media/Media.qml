import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Item {
    id: mediaService

    property bool playbackObserved: false
    property bool wasPlaying: false
    property var activePlayer: null

    function players() {
        return Mpris.players.values !== undefined ? Mpris.players.values : Mpris.players;
    }

    function resolvePlayingPlayer() {
        const availablePlayers = players();
        if (!availablePlayers || availablePlayers.length === 0)
            return null;

        for (let index = 0; index < availablePlayers.length; index++) {
            if (availablePlayers[index].playbackState === MprisPlaybackState.Playing)
                return availablePlayers[index];

        }
        return null;
    }

    function pollPlayback() {
        const player = resolvePlayingPlayer();
        const playing = player !== null;
        root.mediaPlayer = player;
        if (playing && (!playbackObserved || !wasPlaying || activePlayer !== player)) {
            root.showMedia(player);
            mediaPresentationTimer.restart();
        }
        activePlayer = player;
        wasPlaying = playing;
        playbackObserved = true;
    }

    Timer {
        interval: 250
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: mediaService.pollPlayback()
    }

    Timer {
        id: mediaPresentationTimer

        interval: 5000
        repeat: false
        onTriggered: {
            root.closeMedia();
        }
    }

}
