#include "api.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QNetworkCookie>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonParseError>
#include <QUrlQuery>
#include <QRegularExpression>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QCryptographicHash>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDateTime>
#include <QDebug>

namespace {
const char kUserAgent[] = "Mozilla/5.0 (Mobile Linux; U; like Android 4.4.3; Sailfish OS/2.0) AppleWebKit/535.19 (KHTML, like Gecko) Version/4.0 Mobile Safari/535.19";
const char kSessionCookieName[] = "express.sid";
const char kCsrfHeader[] = "X-CSRF-Token";
}

Api::Api(QObject *parent)
    : QObject(parent)
    , siteUrl_(QStringLiteral("https://sailfishos.club"))
    , proxy_(QString())
    , csrfFetched_(false)
    , nam_(new QNetworkAccessManager(this))
    , cookieJar_(new QNetworkCookieJar(this))
{
    nam_->setCookieJar(cookieJar_);
}

QString Api::siteUrl() const
{
    return siteUrl_;
}

void Api::setSiteUrl(const QString &url)
{
    if (siteUrl_ != url) {
        siteUrl_ = url;
        emit siteUrlChanged();
    }
}

QString Api::proxy() const
{
    return proxy_;
}

void Api::setProxy(const QString &proxy)
{
    proxy_ = proxy;
    QUrl p(proxy_);
    if (p.isValid() && !p.host().isEmpty()) {
        QNetworkProxy netProxy;
        netProxy.setType(QNetworkProxy::HttpProxy);
        netProxy.setHostName(p.host());
        netProxy.setPort(p.port(8080));
        nam_->setProxy(netProxy);
    } else {
        nam_->setProxy(QNetworkProxy::NoProxy);
    }
    emit proxyChanged();
}

QString Api::csrf() const
{
    return csrf_;
}

QNetworkRequest Api::makeRequest(const QString &url, bool withCsrf)
{
    QNetworkRequest req{ QUrl(url) };
    req.setHeader(QNetworkRequest::UserAgentHeader, QLatin1String(kUserAgent));
    req.setRawHeader("Accept", "application/json, text/plain, */*");
    if (withCsrf && !csrf_.isEmpty()) {
        req.setRawHeader(kCsrfHeader, csrf_.toUtf8());
    }
    return req;
}

void Api::get(const QString &url, Kind kind, bool withCsrf)
{
    emit loadStarted();
    QNetworkRequest req = makeRequest(url, withCsrf);
    QNetworkReply *reply = nam_->get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply, kind]() {
        handleReply(reply, kind);
    });
}

void Api::post(const QString &url, const QByteArray &body, const QString &contentType, Kind kind)
{
    emit loadStarted();
    QNetworkRequest req = makeRequest(url, true);
    if (!contentType.isEmpty()) {
        req.setHeader(QNetworkRequest::ContentTypeHeader, contentType);
    }
    req.setHeader(QNetworkRequest::ContentLengthHeader, QVariant::fromValue(body.size()));
    QNetworkReply *reply = nam_->post(req, body);
    connect(reply, &QNetworkReply::finished, this, [this, reply, kind]() {
        handleReply(reply, kind);
    });
}

QVariant Api::parseBody(const QByteArray &body)
{
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(body, &err);
    if (err.error != QJsonParseError::NoError || doc.isNull()) {
        return QVariant(body);
    }
    if (doc.isObject()) {
        return QVariant(doc.object().toVariantMap());
    }
    if (doc.isArray()) {
        return QVariant(doc.array().toVariantList());
    }
    return QVariant(doc.toVariant());
}

void Api::initCookie(const QString &savedCookie)
{
    if (savedCookie.isEmpty()) {
        return;
    }
    QUrl url(siteUrl_);
    QNetworkCookie cookie;
    cookie.setName(kSessionCookieName);
    cookie.setValue(savedCookie.toUtf8());
    cookie.setDomain(url.host());
    cookie.setPath(QStringLiteral("/"));
    QList<QNetworkCookie> cookies = cookieJar_->cookiesForUrl(url);
    cookies << cookie;
    cookieJar_->setCookiesFromUrl(cookies, url);
    // refresh csrf with restored session
    QNetworkRequest req = makeRequest(siteUrl_ + QStringLiteral("/api/config"));
    QNetworkReply *reply = nam_->get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            QJsonParseError err;
            QJsonDocument doc = QJsonDocument::fromJson(reply->readAll(), &err);
            if (err.error == QJsonParseError::NoError && doc.isObject()) {
                csrf_ = doc.object().value(QStringLiteral("csrf_token")).toString();
                csrfFetched_ = true;
                emit csrfChanged(csrf_);
            }
        }
        reply->deleteLater();
    });
}

void Api::performLogin(const QByteArray &body)
{
    post(siteUrl_ + QStringLiteral("/api/v3/utilities/login"), body,
         QStringLiteral("application/x-www-form-urlencoded"), KLogin);
}

void Api::login(const QString &username, const QString &password)
{
    QUrlQuery query;
    query.addQueryItem(QStringLiteral("username"), username);
    query.addQueryItem(QStringLiteral("password"), password);
    QByteArray body = query.toString(QUrl::FullyEncoded).toUtf8();

    if (csrfFetched_ && !csrf_.isEmpty()) {
        performLogin(body);
        return;
    }
    // fetch csrf first, then login
    QNetworkRequest req = makeRequest(siteUrl_ + QStringLiteral("/api/config"));
    QNetworkReply *reply = nam_->get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply, body]() {
        if (reply->error() == QNetworkReply::NoError) {
            QByteArray data = reply->readAll();
            QJsonParseError err;
            QJsonDocument doc = QJsonDocument::fromJson(data, &err);
            if (err.error == QJsonParseError::NoError && doc.isObject()) {
                csrf_ = doc.object().value(QStringLiteral("csrf_token")).toString();
                csrfFetched_ = true;
                emit csrfChanged(csrf_);
            }
        }
        reply->deleteLater();
        performLogin(body);
    });
}

void Api::logout(int uid, const QString &token)
{
    Q_UNUSED(uid)
    Q_UNUSED(token)
    // cookie-based session: clearing local cookies is sufficient.
    // the server-side session expires naturally.
    cookieJar_->setCookiesFromUrl(QList<QNetworkCookie>(), QUrl(siteUrl_));
    csrf_.clear();
    csrfFetched_ = false;
}

void Api::getOtherParam(const QString &username)
{
    Q_UNUSED(username)
    QVariantMap result;
    QString dbPath = QDir::homePath() + QStringLiteral("/.local/share/harbour-sailfishclub/harbour-sailfishclub/.QtWebKit/cookies.db");
    if (QFile::exists(dbPath) && QSqlDatabase::isDriverAvailable("QSQLITE")) {
        {
            QSqlDatabase db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), QStringLiteral("cookieConn"));
            db.setDatabaseName(dbPath);
            if (db.open()) {
                QSqlQuery query(db);
                query.prepare(QStringLiteral("SELECT * FROM cookies WHERE cookieId LIKE '%express.sid'"));
                if (query.exec() && query.next()) {
                    QString value = query.value(1).toString();
                    int idx = value.indexOf(QStringLiteral("express.sid="));
                    if (idx >= 0) {
                        QString sid = value.mid(idx + 12).split(QLatin1Char(';')).first();
                        result.insert(QStringLiteral("sid"), sid);
                    }
                    int ex = value.indexOf(QStringLiteral("expires="));
                    if (ex >= 0) {
                        result.insert(QStringLiteral("expires"), value.mid(ex + 8).split(QLatin1Char(';')).first());
                    }
                }
                db.close();
            }
        }
        QSqlDatabase::removeDatabase(QStringLiteral("cookieConn"));
    }
    emit otherParamReady(result);
}

QString Api::getSecretKey()
{
    return QStringLiteral("keyskeyskeyskeys");
}

void Api::getRecent(const QString &slug)
{
    get(siteUrl_ + QStringLiteral("/api/recent?") + slug, KRecent);
}

void Api::getPopular(const QString &slug)
{
    get(siteUrl_ + QStringLiteral("/api/popular?") + slug, KPopular);
}

void Api::getCategories()
{
    get(siteUrl_ + QStringLiteral("/api/v3/categories"), KCategories, true);
}

void Api::getTopic(int tid, const QString &slug)
{
    get(siteUrl_ + QStringLiteral("/api/topic/") + (slug.isEmpty() ? QString::number(tid) : slug), KTopic);
}

void Api::getUnread()
{
    get(siteUrl_ + QStringLiteral("/api/notifications"), KUnread, true);
}

void Api::search(const QString &term, const QString &slug)
{
    QString url = siteUrl_ + QStringLiteral("/api/search?term=") + QString::fromUtf8(QUrl::toPercentEncoding(term))
                  + QStringLiteral("&in=titlesposts&") + slug;
    get(url, KSearch);
}

void Api::getUserInfo(const QString &username, bool isUsername)
{
    QString uri;
    if (isUsername) {
        uri = username.contains(QLatin1Char('@')) ? QStringLiteral("/api/user/email/") : QStringLiteral("/api/user/");
    } else {
        uri = QStringLiteral("/api/user/uid/");
    }
    get(siteUrl_ + uri + username, KUserInfo);
}

void Api::createTopic(int cid, const QString &title, const QString &content)
{
    QJsonObject payload;
    payload.insert(QStringLiteral("cid"), cid);
    payload.insert(QStringLiteral("title"), title);
    payload.insert(QStringLiteral("content"), content);
    QByteArray body = QJsonDocument(payload).toJson(QJsonDocument::Compact);
    post(siteUrl_ + QStringLiteral("/api/v3/topics"), body, QStringLiteral("application/json"), KCreate);
}

void Api::replyToTopic(int tid, const QString &content, int pid)
{
    QJsonObject payload;
    payload.insert(QStringLiteral("content"), content);
    if (pid > 0) {
        payload.insert(QStringLiteral("toPid"), pid);
    }
    QByteArray body = QJsonDocument(payload).toJson(QJsonDocument::Compact);
    post(siteUrl_ + QStringLiteral("/api/v3/topics/") + QString::number(tid), body,
         QStringLiteral("application/json"), KReply);
}

// ---- markdown to html ----
static QString escapeHtml(QString text)
{
    return text.replace(QLatin1Char('&'), QStringLiteral("&amp;"))
               .replace(QLatin1Char('<'), QStringLiteral("&lt;"))
               .replace(QLatin1Char('>'), QStringLiteral("&gt;"));
}

static QString inlineMd(QString text)
{
    text.replace(QRegularExpression(QStringLiteral("!\\[([^\\]]*)\\]\\(([^)]+)\\)")),
                 QStringLiteral("<img src=\"\\2\" alt=\"\\1\"/>"));
    text.replace(QRegularExpression(QStringLiteral("\\[([^\\]]+)\\]\\(([^)]+)\\)")),
                 QStringLiteral("<a href=\"\\2\">\\1</a>"));
    text.replace(QRegularExpression(QStringLiteral("\\*\\*(.+?)\\*\\*")), QStringLiteral("<b>\\1</b>"));
    text.replace(QRegularExpression(QStringLiteral("__(.+?)__")), QStringLiteral("<b>\\1</b>"));
    text.replace(QRegularExpression(QStringLiteral("\\*(.+?)\\*")), QStringLiteral("<i>\\1</i>"));
    text.replace(QRegularExpression(QStringLiteral("_(.+?)_")), QStringLiteral("<i>\\1</i>"));
    text.replace(QRegularExpression(QStringLiteral("`([^`]+)`")), QStringLiteral("<code>\\1</code>"));
    return text;
}

void Api::previewMd(const QString &text)
{
    const QStringList lines = text.split(QLatin1Char('\n'));
    QString html;
    bool inCode = false;
    QString codeBuf;
    for (const QString &raw : lines) {
        QString line = raw;
        if (line.startsWith(QStringLiteral("```"))) {
            if (!inCode) {
                inCode = true;
                codeBuf.clear();
            } else {
                inCode = false;
                html += QStringLiteral("<pre><code>") + escapeHtml(codeBuf.trimmed()) + QStringLiteral("</code></pre>");
            }
            continue;
        }
        if (inCode) {
            codeBuf += line + QLatin1Char('\n');
            continue;
        }
        if (line.trimmed().isEmpty()) {
            html += QStringLiteral("<p></p>");
            continue;
        }
        if (line.startsWith(QStringLiteral("### "))) {
            html += QStringLiteral("<h3>") + inlineMd(line.mid(4)) + QStringLiteral("</h3>");
        } else if (line.startsWith(QStringLiteral("## "))) {
            html += QStringLiteral("<h2>") + inlineMd(line.mid(3)) + QStringLiteral("</h2>");
        } else if (line.startsWith(QLatin1Char('#'))) {
            html += QStringLiteral("<h1>") + inlineMd(line.mid(2)) + QStringLiteral("</h1>");
        } else if (line.startsWith(QStringLiteral("> "))) {
            html += QStringLiteral("<blockquote>") + inlineMd(line.mid(2)) + QStringLiteral("</blockquote>");
        } else if (line.startsWith(QStringLiteral("- ")) || line.startsWith(QStringLiteral("* "))) {
            html += QStringLiteral("<li>") + inlineMd(line.mid(2)) + QStringLiteral("</li>");
        } else if (line.contains(QRegularExpression(QStringLiteral("^\\d+\\.")))) {
            int dot = line.indexOf(QLatin1Char('.'));
            html += QStringLiteral("<li>") + inlineMd(line.mid(dot + 1).trimmed()) + QStringLiteral("</li>");
        } else {
            html += QStringLiteral("<p>") + inlineMd(line) + QStringLiteral("</p>");
        }
    }
    if (inCode) {
        html += QStringLiteral("<pre><code>") + escapeHtml(codeBuf.trimmed()) + QStringLiteral("</code></pre>");
    }
    emit previewReady(html);
}

// ---- upload to catbox.moe ----
void Api::uploadImage(const QString &path, const QString &desc)
{
    pendingDesc_ = desc;
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        emit loadFailed(QStringLiteral("Cannot open image file"));
        emit loadFinished();
        return;
    }
    QByteArray fileData = file.readAll();
    file.close();

    QString boundary = QStringLiteral("----harbour") + QString::number(QDateTime::currentMSecsSinceEpoch());
    QByteArray body;
    body += QStringLiteral("--%1\r\n").arg(boundary).toUtf8();
    body += QStringLiteral("Content-Disposition: form-data; name=\"reqtype\"\r\n\r\nfileupload\r\n").toUtf8();
    body += QStringLiteral("--%1\r\n").arg(boundary).toUtf8();
    body += QStringLiteral("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"file\"\r\n").toUtf8();
    body += QStringLiteral("Content-Type: application/octet-stream\r\n\r\n").toUtf8();
    body += fileData;
    body += QStringLiteral("\r\n--%1--\r\n").arg(boundary).toUtf8();

    QNetworkRequest req{ QUrl(QStringLiteral("https://catbox.moe/user/api.php")) };
    req.setHeader(QNetworkRequest::ContentTypeHeader,
                  QStringLiteral("multipart/form-data; boundary=%1").arg(boundary));
    req.setHeader(QNetworkRequest::UserAgentHeader,
                  QStringLiteral("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"));
    emit loadStarted();
    QNetworkReply *reply = nam_->post(req, body);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        bool ok = reply->error() == QNetworkReply::NoError;
        QString result;
        if (ok) {
            result = QString::fromUtf8(reply->readAll()).trimmed();
            result.replace(QStringLiteral("\\"), QString());
        } else {
            result = QString();
        }
        reply->deleteLater();
        emit uploadImageReady(result, pendingDesc_);
        emit loadFinished();
    });
}

// ---- download to Pictures/SailfishClub ----
void Api::downloadFile(const QString &url, const QString &filename)
{
    QString dir = QDir::homePath() + QStringLiteral("/Pictures/SailfishClub");
    QDir().mkpath(dir);
    QString target = dir + QLatin1Char('/') + (filename.isEmpty() ? url.section(QLatin1Char('/'), -1) : filename);

    QNetworkRequest req = makeRequest(url);
    emit loadStarted();
    QNetworkReply *reply = nam_->get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply, target]() {
        bool ok = reply->error() == QNetworkReply::NoError;
        if (ok) {
            QFile f(target);
            if (f.open(QIODevice::WriteOnly)) {
                f.write(reply->readAll());
                f.close();
            } else {
                ok = false;
            }
        }
        reply->deleteLater();
        emit downloadReady(ok);
        emit loadFinished();
    });
}

// ---- cache ----
QString Api::cacheDir() const
{
    QString dir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    dir += QStringLiteral("/query_cache");
    QDir().mkpath(dir);
    return dir;
}

QString Api::md5(const QString &text) const
{
    return QString::fromLatin1(QCryptographicHash::hash(text.toUtf8(), QCryptographicHash::Md5).toHex());
}

QVariant Api::getQueryListData(const QString &key)
{
    QString path = cacheDir() + QLatin1Char('/') + md5(key) + QStringLiteral(".json");
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly)) {
        return QVariant();
    }
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll(), &err);
    f.close();
    if (err.error != QJsonParseError::NoError || !doc.isObject()) {
        return QVariant();
    }
    QVariantMap map = doc.object().toVariantMap();
    if (map.contains(QStringLiteral("__expire"))) {
        bool ok = false;
        qint64 expire = map.value(QStringLiteral("__expire")).toLongLong(&ok);
        if (ok && QDateTime::currentMSecsSinceEpoch() > expire) {
            QFile::remove(path);
            return QVariant();
        }
    }
    return map.value(QStringLiteral("__data"));
}

bool Api::setQueryListData(const QString &key, const QVariant &result, int expire)
{
    if (result.isNull() || result.toString() == QLatin1String("Forbidden")) {
        return false;
    }
    QVariantMap map;
    map.insert(QStringLiteral("__data"), result);
    map.insert(QStringLiteral("__expire"), QDateTime::currentMSecsSinceEpoch() + qint64(expire) * 1000);
    QString path = cacheDir() + QLatin1Char('/') + md5(key) + QStringLiteral(".json");
    QFile f(path);
    if (!f.open(QIODevice::WriteOnly)) {
        return false;
    }
    f.write(QJsonDocument(QJsonObject::fromVariantMap(map)).toJson());
    f.close();
    return true;
}

void Api::handleReply(QNetworkReply *reply, Kind kind)
{
    if (reply->error() != QNetworkReply::NoError) {
        emit loadFailed(reply->errorString());
        emit loadFinished();
        reply->deleteLater();
        return;
    }
    // capture Set-Cookie header before consuming the body
    QByteArray setCookieHeader = reply->rawHeader("Set-Cookie");
    QByteArray data = reply->readAll();
    QVariant result = parseBody(data);
    reply->deleteLater();

    switch (kind) {
    case KLogin: {
        QVariantMap map = result.toMap();
        QVariantMap status = map.value(QStringLiteral("status")).toMap();
        if (status.value(QStringLiteral("code")).toString() == QLatin1String("ok")) {
            QString sid;
            // 1) look up from cookie jar (applied by HTTPCookieProcessor)
            QList<QNetworkCookie> cookies = cookieJar_->cookiesForUrl(QUrl(siteUrl_));
            for (const QNetworkCookie &c : cookies) {
                if (c.name() == kSessionCookieName) {
                    sid = QString::fromUtf8(c.value());
                    break;
                }
            }
            // 2) fallback: parse raw Set-Cookie header
            if (sid.isEmpty() && !setCookieHeader.isEmpty()) {
                QList<QNetworkCookie> raw = QNetworkCookie::parseCookies(setCookieHeader);
                for (const QNetworkCookie &c : raw) {
                    if (c.name() == kSessionCookieName) {
                        sid = QString::fromUtf8(c.value());
                        break;
                    }
                }
            }
            // 3) make sure the session cookie is in the jar for later requests
            if (!sid.isEmpty()) {
                QUrl url(siteUrl_);
                QList<QNetworkCookie> existing = cookieJar_->cookiesForUrl(url);
                bool found = false;
                for (const QNetworkCookie &c : existing) {
                    if (c.name() == kSessionCookieName) { found = true; break; }
                }
                if (!found) {
                    QNetworkCookie cookie;
                    cookie.setName(kSessionCookieName);
                    cookie.setValue(sid.toUtf8());
                    cookie.setDomain(url.host());
                    cookie.setPath(QStringLiteral("/"));
                    cookieJar_->setCookiesFromUrl(existing << cookie, url);
                }
            }
            map.insert(QStringLiteral("cookies"), sid);
            emit loginSuccess(map);
        } else {
            emit loginFailed(status.value(QStringLiteral("message")).toString());
        }
        break;
    }
    case KRecent:
    case KPopular:
        emit recentReady(result);
        break;
    case KCategories: {
        // Write API wraps payload under "response": {categories: [...]}
        QVariantMap map = result.toMap();
        emit categoriesReady(map.value(QStringLiteral("response"), result));
        break;
    }
    case KTopic:
        emit topicReady(result);
        break;
    case KCreate:
    case KReply:
        emit replayFloorReady(result);
        break;
    case KUnread:
    case KSearch: {
        // v4.15 wraps these under {status, response}
        QVariantMap map = result.toMap();
        emit kind == KUnread ? unreadReady(map.value(QStringLiteral("response"), result))
                             : searchReady(map.value(QStringLiteral("response"), result));
        break;
    }
    case KUserInfo:
        emit userInfoReady(result);
        break;
    case KOtherParam:
        emit otherParamReady(result);
        break;
    case KUpload:
        break;
    }
    emit loadFinished();
}