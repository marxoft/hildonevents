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

#ifndef EVENTFEED_H
#define EVENTFEED_H

#include <QObject>
#include <QStringList>
#include <QVariantMap>

class QProcess;

class EventFeed : public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(bool refreshing READ isRefreshing NOTIFY refreshingChanged)
    
    Q_CLASSINFO("D-Bus Interface", "org.hildon.eventfeed")

public:
    ~EventFeed();
    
    static EventFeed* instance();
    
    bool isRefreshing() const;
        
public Q_SLOTS:
    Q_SCRIPTABLE qlonglong addItem(const QVariantMap &parameters);
    Q_SCRIPTABLE void addRefreshAction(const QString &action);
    Q_SCRIPTABLE void removeItem(qlonglong id);
    Q_SCRIPTABLE void removeItemsBySourceName(const QString &sourceName);
    Q_SCRIPTABLE void removeRefreshAction(const QString &action);
    Q_SCRIPTABLE void updateItem(qlonglong id, const QVariantMap &parameters);
    
    void openItem(qlonglong id);
    
    void refresh();
    void cancelRefresh();
    
Q_SIGNALS:
    Q_SCRIPTABLE void refreshRequested();
    
    void itemAdded(qlonglong id);
    void itemRemoved(qlonglong id);
    void itemsRemoved(const QString &sourceName);
    void itemUpdated(qlonglong id);
    
    void refreshingChanged();

private Q_SLOTS:
    void nextRefreshAction();
    
    void onRefreshFinished();

private:
    EventFeed();
    
    static EventFeed *self;
    
    QProcess *m_refreshProcess;
    
    QStringList m_refreshActions;
};

#endif // EVENTFEED_H
