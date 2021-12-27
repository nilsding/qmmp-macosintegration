/* qmmp-macosintegration -- better MacOS desktop integration for Qmmp
 * Copyright (C) 2021 Georg Gadinger <nilsding@nilsding.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "macosintegration.h"
#import <MediaPlayer/MediaPlayer.h>

static inline MPNowPlayingPlaybackState mpState(Qmmp::State state)
{
    switch (state)
    {
    case Qmmp::Playing: return MPNowPlayingPlaybackStatePlaying;
    case Qmmp::Paused: return MPNowPlayingPlaybackStatePaused;
    default: return MPNowPlayingPlaybackStateStopped;
    }
}

MacOSIntegration::MacOSIntegration(QObject *parent)
    : QObject(parent)
{
    qDebug(".--==[ MacOSIntegration::MacOSIntegration ]=========--.");
    m_core = SoundCore::instance();
    m_player = MediaPlayer::instance();
    m_pl_manager =  m_player->playListManager();

    connect(m_core, &SoundCore::trackInfoChanged, this, &MacOSIntegration::updateTrackInfo);
    connect(m_core, &SoundCore::stateChanged, this, &MacOSIntegration::stateChanged);

    // initialise the now playing info center once
    MPNowPlayingInfoCenter* infocenter = [MPNowPlayingInfoCenter defaultCenter];
    qDebug(". setting playback state to %lu", mpState(m_core->state()));
    [infocenter setPlaybackState:mpState(m_core->state())];

    // set up the remote
    qDebug(". setting up the remote");
    MPRemoteCommandCenter* commandcenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandcenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        qDebug("-- [ command : pauseCommand ] --");
        if (m_core->state() == Qmmp::Playing)
        {
            m_core->pause();
            return MPRemoteCommandHandlerStatusSuccess;
        }
        return MPRemoteCommandHandlerStatusCommandFailed;
    }];
    [commandcenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        qDebug("-- [ command : playCommand ] --");

        if (m_core->state() == Qmmp::Paused)
        {
            m_core->pause();
        }
        else if (m_core->state() != Qmmp::Playing && m_core->state() != Qmmp::Buffering)
        {
            m_player->play();
        }
        else
        {
            return MPRemoteCommandHandlerStatusCommandFailed;
        }

        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandcenter.stopCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        qDebug("-- [ command : stopCommand ] --");

        m_core->stop();

        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandcenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        qDebug("-- [ command : togglePlayPauseCommand ] --");

        if (m_core->state() == Qmmp::Playing || m_core->state() == Qmmp::Paused)
        {
            m_core->pause();
        }
        else if (m_core->state() != Qmmp::Playing && m_core->state() != Qmmp::Buffering)
        {
            m_player->play();
        }
        else
        {
            return MPRemoteCommandHandlerStatusCommandFailed;
        }

        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandcenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        qDebug("-- [ command : nextTrackCommand ] --");

        m_player->next();

        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandcenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        qDebug("-- [ command : previousTrackCommand ] --");

        m_player->previous();

        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

void MacOSIntegration::updateTrackInfo()
{
    qDebug(".--==[ updateTrackInfo ]=========--.");
    MPNowPlayingInfoCenter* infocenter = [MPNowPlayingInfoCenter defaultCenter];

    qDebug(". setting playback state to %lu", mpState(m_core->state()));
    [infocenter setPlaybackState:mpState(m_core->state())];

    PlayListTrack *track = m_pl_manager->currentPlayList()->currentTrack();
    if (!track || m_core->path().isEmpty())
    {
        qDebug(". empty, setting nowPlayingInfo to nil");
        [infocenter setNowPlayingInfo: nil];
        return;
    }

    TrackInfo info = m_core->trackInfo();

    NSDictionary* nowPlayingInfoBase = @{
        MPNowPlayingInfoPropertyMediaType : @(MPNowPlayingInfoMediaTypeAudio),
        MPMediaItemPropertyPlaybackDuration : @(qMax(m_core->duration() / 1000.0, 0.0)),
        MPNowPlayingInfoPropertyPlaybackRate : @(1.0),
        MPNowPlayingInfoPropertyDefaultPlaybackRate : @(1.0),
        MPNowPlayingInfoPropertyElapsedPlaybackTime : @(qMax(m_core->elapsed() / 1000.0, 0.0))
    };
    NSMutableDictionary* nowPlayingInfo = [nowPlayingInfoBase mutableCopy];

    if (!info.value(Qmmp::TITLE).isEmpty())
    {
        qDebug(". title = %d chars", info.value(Qmmp::TITLE).length());
        [nowPlayingInfo setObject:info.value(Qmmp::TITLE).toNSString() forKey:MPMediaItemPropertyTitle];
    }
    if (!info.value(Qmmp::ARTIST).isEmpty())
    {
        qDebug(". artist = %d chars", info.value(Qmmp::ARTIST).length());
        [nowPlayingInfo setObject:info.value(Qmmp::ARTIST).toNSString() forKey:MPMediaItemPropertyArtist];
    }
    if (!info.value(Qmmp::ALBUM).isEmpty())
    {
        qDebug(". album = %d chars", info.value(Qmmp::ALBUM).length());
        [nowPlayingInfo setObject:info.value(Qmmp::ALBUM).toNSString() forKey:MPMediaItemPropertyAlbumTitle];
    }
    if (!info.value(Qmmp::ALBUMARTIST).isEmpty())
    {
        qDebug(". albumartist = %d chars", info.value(Qmmp::ALBUMARTIST).length());
        [nowPlayingInfo setObject:info.value(Qmmp::ALBUMARTIST).toNSString() forKey:MPMediaItemPropertyAlbumArtist];
    }

    qDebug(". setting nowPlayingInfo to: ");
    NSLog(@"%@", nowPlayingInfo);

    [infocenter setNowPlayingInfo: nowPlayingInfo];
}

void MacOSIntegration::stateChanged(Qmmp::State state)
{
    qDebug(".--==[ stateChanged ]=========--.\n. setting playback state to %lu", mpState(state));
    [[MPNowPlayingInfoCenter defaultCenter] setPlaybackState:mpState(state)];
}
