/*
 * Copyright (C) 2016 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>

class Settings : public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(bool enableAutomaticScrollingInWidget READ enableAutomaticScrollingInWidget
               WRITE setEnableAutomaticScrollingInWidget NOTIFY enableAutomaticScrollingInWidgetChanged)
    Q_PROPERTY(int screenOrientation READ screenOrientation WRITE setScreenOrientation
               NOTIFY screenOrientationChanged)

public:
    ~Settings();

    static Settings* instance();
    
    static bool enableAutomaticScrollingInWidget();
    static int screenOrientation();

public Q_SLOTS:
    static void setEnableAutomaticScrollingInWidget(bool enabled);
    static void setScreenOrientation(int orientation);
    
Q_SIGNALS:
    void enableAutomaticScrollingInWidgetChanged(bool enabled);
    void screenOrientationChanged(int orientation);

private:
    Settings();

    static Settings *self;
};

#endif // SETTINGS_H
