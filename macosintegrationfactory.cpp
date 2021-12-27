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

#include "macosintegrationfactory.h"

#include <QMessageBox>
#include "macosintegration.h"

GeneralProperties MacOSIntegrationFactory::properties() const
{
    GeneralProperties properties;
    properties.name = tr("MacOS Integration");
    properties.shortName = "macosintegration";
    properties.hasAbout = true;
    properties.hasSettings = false;
    properties.visibilityControl = false;
    return properties;
}

QObject* MacOSIntegrationFactory::create(QObject* parent)
{
    return new MacOSIntegration(parent);
}

QDialog* MacOSIntegrationFactory::createConfigDialog(QWidget* parent)
{
    return nullptr;
}

void MacOSIntegrationFactory::showAbout(QWidget* parent)
{
    QMessageBox::about(
        parent, tr("About MacOS Integration"),
        tr("Qmmp MacOS integration plug-in") + "\n" +
            tr("This plug-in provides better integration with MacOS.") + "\n" +
            tr("Written by: Georg Gadinger <nilsding@nilsding.org>"));
}

QString MacOSIntegrationFactory::translation() const
{
    return QLatin1String(":/macosintegration_plugin_");
}
