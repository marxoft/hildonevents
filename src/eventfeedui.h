/*
 * Copyright (C) 2015 Stuart Howarth <showarth@marxoft.co.uk>
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

#ifndef EVENTFEEDUI_H
#define EVENTFEEDUI_H

#include <QObject>
#include <QPointer>

class QDeclarativeEngine;

class EventFeedUi : public QObject
{
    Q_OBJECT
    
    Q_CLASSINFO("D-Bus Interface", "org.hildon.eventfeed.ui")
    
public:
    ~EventFeedUi();
    
    static EventFeedUi* instance();
    
public Q_SLOTS:
    Q_SCRIPTABLE void showWidget();
    Q_SCRIPTABLE void showWindow();
    
private:
    EventFeedUi();
    
    void initEngine();
    QObject* createQmlObject(const QString &fileName);
    
    static EventFeedUi *self;

    QDeclarativeEngine *m_engine;
    QPointer<QObject> m_widget;
    QPointer<QObject> m_window;
};

#endif // EVENTFEEDUI_H
