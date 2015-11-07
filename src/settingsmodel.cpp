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

#include "settingsmodel.h"
#include <QDir>
#include <QSettings>

static const QString SETTINGS_PATH("/opt/hildonevents/settings");

SettingsModel::SettingsModel(QObject *parent) :
    QStandardItemModel(parent)
{
    m_roles[NameRole] = "name";
    m_roles[IconRole] = "icon";
    m_roles[CategoryRole] = "category";
    m_roles[TypeRole] = "type";
    m_roles[ExecRole] = "exec";
#if QT_VERSION < 0x050000
    setRoleNames(m_roles);
#endif
    setSortRole(CategoryRole);
    
    connect(this, SIGNAL(rowsInserted(QModelIndex, int, int)), this, SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(QModelIndex, int, int)), this, SIGNAL(countChanged()));
}

#if QT_VERSION >= 0x050000
QHash<int, QByteArray> SettingsModel::roleNames() const {
    return m_roles;
}
#endif

QVariant SettingsModel::data(int row, const QByteArray &roleName) const {
    return QStandardItemModel::data(index(row, 0, QModelIndex()), m_roles.key(roleName));
}

void SettingsModel::reload() {
    clear();
    QDir dir(SETTINGS_PATH);
    
    foreach (QString fileName, dir.entryList(QStringList("*.desktop"), QDir::Files, QDir::Name)) {
        QSettings settings(dir.absoluteFilePath(fileName), QSettings::IniFormat);
        settings.beginGroup("Desktop Entry");
        
        if ((settings.contains("Name")) && (settings.contains("Exec"))) {
            QStandardItem *item = new QStandardItem;
            item->setData(settings.value("Name"), NameRole);
            item->setData(settings.value("Icon"), IconRole);
            item->setData(settings.contains("Categories") ? settings.value("Categories").toString().section(',', 0, 0)
                                                          : QString("Feeds"), CategoryRole);
            item->setData(settings.contains("Type") ? settings.value("Type").toString().toLower()
                                                    : QString("qml"), TypeRole);
            item->setData(settings.value("Exec"), ExecRole);
            appendRow(item);
        }
        
        settings.endGroup();
    }
    
    sort(0, Qt::AscendingOrder);
}
