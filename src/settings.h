#ifndef SETTINGS
#define SETTINGS

#include<QSettings>
#include<QString>

class SettingsObject: public QObject {
    Q_OBJECT
private:
    QSettings* settings;
public:
    explicit SettingsObject();
    Q_INVOKABLE void set_username(const QString &username);
    Q_INVOKABLE QString get_username();
    Q_INVOKABLE void set_password(const QString &password);
    Q_INVOKABLE QString get_password();
    Q_INVOKABLE void set_uid(const int &uid);
    Q_INVOKABLE int get_uid();
    Q_INVOKABLE QString get_token();
    Q_INVOKABLE void set_token(const QString &token);
    Q_INVOKABLE void set_pagesize(const int &pagesize);
    Q_INVOKABLE int get_pagesize();
    Q_INVOKABLE QString get_logined();
    Q_INVOKABLE void set_logined(const QString &logined);
    Q_INVOKABLE QString get_avatar();
    Q_INVOKABLE void set_avatar(const QString &avatar);
    Q_INVOKABLE QString get_savetime();
    Q_INVOKABLE void set_savetime(const QString &savetime);

};

#endif // SETTINGS
