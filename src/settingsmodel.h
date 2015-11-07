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

#ifndef SETTINGSMODEL_H
#define SETTINGSMODEL_H

#include <QStandardItemModel>

class SettingsModel : public QStandardItemModel
{
    Q_OBJECT
    
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    
public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        IconRole,
        CategoryRole,
        TypeRole,
        ExecRole
    };
    
    explicit SettingsModel(QObject *parent = 0);
    
#if QT_VERSION >= 0x050000
    QHash<int, QByteArray> roleNames() const;
#endif

public Q_SLOTS:
    QVariant data(int row, const QByteArray &roleName) const;
    
    void reload();

Q_SIGNALS:
    void countChanged();

private:
    QHash<int, QByteArray> m_roles;
};

#endif // SETTINGSMODEL_H
