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

#include "eventfeedui.h"
#include "eventfeed.h"
#include "eventmodel.h"
#include "settingsmodel.h"
#include <QDBusConnection>
#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QDeclarativeComponent>
#include <qdeclarative.h>
#include <QDebug>

static const QString WIDGET_FILENAME("/opt/hildonevents/qml/Widget.qml");
static const QString WINDOW_FILENAME("/opt/hildonevents/qml/MainWindow.qml");

EventFeedUi* EventFeedUi::self = 0;

EventFeedUi::EventFeedUi() :
    QObject()
{
    self = this;
    
    QDBusConnection connection = QDBusConnection::sessionBus();
    connection.registerService("org.hildon.eventfeed.ui");
    connection.registerObject("/org/hildon/eventfeed/ui", this, QDBusConnection::ExportScriptableSlots);
}

EventFeedUi::~EventFeedUi() {
    self = 0;
}

EventFeedUi* EventFeedUi::instance() {
    return self ? self : self = new EventFeedUi;
}

void EventFeedUi::showWidget() {
    if (m_widget.isNull()) {
        if (QObject *obj = createQmlObject(WIDGET_FILENAME)) {
            m_widget = obj;
        }
    }
}

void EventFeedUi::showWindow() {
    if (m_window.isNull()) {
        m_window = createQmlObject(WINDOW_FILENAME);
    }
    
    if (!m_window.isNull()) {
        QMetaObject::invokeMethod(m_window, "activate");
    }
}

void EventFeedUi::initEngine() {
    if (m_engine) {
        return;
    }
    
    qmlRegisterType<EventModel>("org.hildon.eventfeed", 1, 0, "EventModel");
    qmlRegisterType<SettingsModel>("org.hildon.eventfeed", 1, 0, "SettingsModel");
    
    m_engine = new QDeclarativeEngine(this);
    m_engine->rootContext()->setContextProperty("feed", EventFeed::instance());
    m_engine->rootContext()->setContextProperty("ui", this);
}

QObject* EventFeedUi::createQmlObject(const QString &fileName) {
    initEngine();
    QDeclarativeContext *context = new QDeclarativeContext(m_engine->rootContext());
    QDeclarativeComponent *component = new QDeclarativeComponent(m_engine, fileName, this);
    
    if (QObject *obj = component->create(context)) {
        context->setParent(obj);
        return obj;
    }

    if (component->isError()) {
        foreach (QDeclarativeError error, component->errors()) {
            qDebug() << error.toString();
        }        
    }

    delete component;
    delete context;
    return 0;
}
