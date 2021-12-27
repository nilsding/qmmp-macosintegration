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

#pragma once

#include <QObject>
#include <qmmp/qmmp.h>
#include <qmmp/soundcore.h>
#include <qmmpui/mediaplayer.h>
#include <qmmpui/playlistmanager.h>

class MacOSIntegration : public QObject
{
    Q_OBJECT
public:
    explicit MacOSIntegration(QObject *parent = nullptr);

signals:

private slots:
    void updateTrackInfo(void);
    void stateChanged(Qmmp::State state);

private:
    SoundCore *m_core = nullptr;
    MediaPlayer *m_player = nullptr;
    PlayListManager *m_pl_manager = nullptr;
};
