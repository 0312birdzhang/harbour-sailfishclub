#include <QSettings>
#include "settings.h"


SettingsObject::SettingsObject() {
    settings = new QSettings("club.sailfishos","sailfishclub");
}



void SettingsObject::set_username(const QString &username) {
    settings->setValue(QString("logindata/username"),username);
}

QString SettingsObject::get_username() {
    return settings->value(QString("logindata/username"),QString("")).toString();
}

void SettingsObject::set_password(const QString &password) {
    settings->setValue(QString("logindata/password"),password);
}

QString SettingsObject::get_password() {
    return settings->value(QString("logindata/password"),QString("")).toString();
}

void SettingsObject::set_uid(const int &uid) {
    settings->setValue(QString("logindata/uid"),uid);
}

int SettingsObject::get_uid() {
    return settings->value(QString("logindata/uid"),0).toInt();
}

void SettingsObject::set_token(const QString &token) {
    settings->setValue(QString("logindata/token"),token);
}

QString SettingsObject::get_token() {
    return settings->value(QString("logindata/token"),QString("")).toString();
}

void SettingsObject::set_pagesize(const int &pagesize) {
    settings->setValue(QString("settings/pagesize"),pagesize);
}

int SettingsObject::get_pagesize() {
    return settings->value(QString("settings/pagesize"),20).toInt();
}


void SettingsObject::set_logined(const QString &logined) {
    settings->setValue(QString("logindata/logined"),logined);
}

QString SettingsObject::get_logined() {
    return settings->value(QString("logindata/logined"),QString("false")).toString();
}

void SettingsObject::set_avatar(const QString &avatar) {
    settings->setValue(QString("logindata/avatar"),avatar);
}

QString SettingsObject::get_avatar() {
    return settings->value(QString("logindata/avatar"),QString("")).toString();
}

void SettingsObject::set_savetime(const QString &savetime) {
    settings->setValue(QString("logindata/savetime"),savetime);
}

QString SettingsObject::get_savetime() {
    return settings->value(QString("logindata/savetime"),QString("1548867120")).toString();
}
