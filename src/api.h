#ifndef NODEBB_API_H
#define NODEBB_API_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkCookieJar>
#include <QNetworkReply>
#include <QNetworkProxy>
#include <QVariant>
#include <QString>
#include <QHash>
#include <QJsonObject>

class Api : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString siteUrl READ siteUrl WRITE setSiteUrl NOTIFY siteUrlChanged)
    Q_PROPERTY(QString proxy READ proxy WRITE setProxy NOTIFY proxyChanged)
    Q_PROPERTY(QString csrf READ csrf NOTIFY csrfChanged)

public:
    explicit Api(QObject *parent = nullptr);

    QString siteUrl() const;
    void setSiteUrl(const QString &url);

    QString proxy() const;
    void setProxy(const QString &proxy);

    QString csrf() const;

    // Session
    Q_INVOKABLE void initCookie(const QString &savedCookie);
    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void logout(int uid, const QString &token);
    Q_INVOKABLE void getOtherParam(const QString &username);
    Q_INVOKABLE QString getSecretKey();

    // Read APIs
    Q_INVOKABLE void getRecent(const QString &slug);
    Q_INVOKABLE void getPopular(const QString &slug);
    Q_INVOKABLE void getCategories();
    Q_INVOKABLE void getTopic(int tid, const QString &slug);
    Q_INVOKABLE void getUnread();
    Q_INVOKABLE void search(const QString &term, const QString &slug);
    Q_INVOKABLE void getUserInfo(const QString &username, bool isUsername);

    // Write APIs
    Q_INVOKABLE void createTopic(int cid, const QString &title, const QString &content);
    Q_INVOKABLE void replyToTopic(int tid, const QString &content, int pid);

    // Utilities
    Q_INVOKABLE void previewMd(const QString &text);
    Q_INVOKABLE void uploadImage(const QString &path, const QString &desc);
    Q_INVOKABLE void downloadFile(const QString &url, const QString &filename);

    // Cache (sync, non-network)
    Q_INVOKABLE QVariant getQueryListData(const QString &key);
    Q_INVOKABLE bool setQueryListData(const QString &key, const QVariant &result, int expire);

signals:
    void siteUrlChanged();
    void proxyChanged();
    void csrfChanged(const QString &csrf);
    void loadStarted();
    void loadFinished();
    void loadFailed(const QString &error);
    void loginSuccess(const QVariant &result);
    void loginFailed(const QString &message);
    void recentReady(const QVariant &result);
    void categoriesReady(const QVariant &result);
    void topicReady(const QVariant &result);
    void replayFloorReady(const QVariant &result);
    void unreadReady(const QVariant &result);
    void searchReady(const QVariant &result);
    void userInfoReady(const QVariant &result);
    void previewReady(const QVariant &result);
    void uploadImageReady(const QVariant &result, const QVariant &desc);
    void downloadReady(bool success);
    void otherParamReady(const QVariant &result);

private:
    enum Kind {
        KLogin, KRecent, KPopular, KCategories, KTopic, KCreate,
        KReply, KUnread, KSearch, KUserInfo, KUpload, KOtherParam
    };

    void get(const QString &url, Kind kind, bool withCsrf = false);
    void post(const QString &url, const QByteArray &body, const QString &contentType, Kind kind);
    QNetworkRequest makeRequest(const QString &url, bool withCsrf = false);
    void handleReply(QNetworkReply *reply, Kind kind);
    void performLogin(const QByteArray &body);
    QVariant parseBody(const QByteArray &body);
    QString cacheDir() const;
    QString md5(const QString &text) const;

    QString siteUrl_;
    QString proxy_;
    QString csrf_;
    bool csrfFetched_;
    QNetworkAccessManager *nam_;
    QNetworkCookieJar *cookieJar_;
    QString pendingDesc_;
};

#endif // NODEBB_API_H