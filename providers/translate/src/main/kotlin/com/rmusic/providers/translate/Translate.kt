package com.rmusic.providers.translate

import io.ktor.client.HttpClient
import io.ktor.client.engine.cio.CIO
import io.ktor.client.plugins.HttpRequestRetry
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.UserAgent
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.defaultRequest
import io.ktor.client.request.accept
import io.ktor.http.ContentType
import io.ktor.http.contentType
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json

object Translate {
    internal val client by lazy {
        HttpClient(CIO) {
            install(ContentNegotiation) {
                json(
                    Json {
                        isLenient = true
                        ignoreUnknownKeys = true
                    }
                )
            }

            install(HttpRequestRetry) {
                exponentialDelay()
                maxRetries = 2
            }

            install(HttpTimeout) {
                connectTimeoutMillis = 1000L
                requestTimeoutMillis = 5000L
            }

            expectSuccess = true

            defaultRequest {
                accept(ContentType.Application.Json)
                contentType(ContentType.Application.Json)
            }

            install(UserAgent) {
                agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
            }
        }
    }

    internal val dt = listOf("at", "bd", "ex", "ld", "md", "qca", "rw", "rm", "ss", "t")

    @Suppress("unused")
    val hostNames by lazy {
        listOf(
            "translate.google.ac", "translate.google.ad", "translate.google.ae",
            "translate.google.al", "translate.google.am", "translate.google.as",
            "translate.google.at", "translate.google.az", "translate.google.ba",
            "translate.google.be", "translate.google.bf", "translate.google.bg",
            "translate.google.bi", "translate.google.bj", "translate.google.bs",
            "translate.google.bt", "translate.google.by", "translate.google.ca",
            "translate.google.cat", "translate.google.cc", "translate.google.cd",
            "translate.google.cf", "translate.google.cg", "translate.google.ch",
            "translate.google.ci", "translate.google.cl", "translate.google.cm",
            "translate.google.cn", "translate.google.co.ao", "translate.google.co.bw",
            "translate.google.co.ck", "translate.google.co.cr", "translate.google.co.id",
            "translate.google.co.il", "translate.google.co.in", "translate.google.co.jp",
            "translate.google.co.ke", "translate.google.co.kr", "translate.google.co.ls",
            "translate.google.co.ma", "translate.google.co.mz", "translate.google.co.nz",
            "translate.google.co.th", "translate.google.co.tz", "translate.google.co.ug",
            "translate.google.co.uk", "translate.google.co.uz", "translate.google.co.ve",
            "translate.google.co.vi", "translate.google.co.za", "translate.google.co.zm",
            "translate.google.co.zw", "translate.google.com.af", "translate.google.com.ag",
            "translate.google.com.ai", "translate.google.com.ar", "translate.google.com.au",
            "translate.google.com.bd", "translate.google.com.bh", "translate.google.com.bn",
            "translate.google.com.bo", "translate.google.com.br", "translate.google.com.bz",
            "translate.google.com.co", "translate.google.com.cu", "translate.google.com.cy",
            "translate.google.com.do", "translate.google.com.ec", "translate.google.com.eg",
            "translate.google.com.et", "translate.google.com.fj", "translate.google.com.gh",
            "translate.google.com.gi", "translate.google.com.gt", "translate.google.com.hk",
            "translate.google.com.jm", "translate.google.com.kh", "translate.google.com.kw",
            "translate.google.com.lb", "translate.google.com.ly", "translate.google.com.mm",
            "translate.google.com.mt", "translate.google.com.mx", "translate.google.com.my",
            "translate.google.com.na", "translate.google.com.ng", "translate.google.com.ni",
            "translate.google.com.np", "translate.google.com.om", "translate.google.com.pa",
            "translate.google.com.pe", "translate.google.com.pg", "translate.google.com.ph",
            "translate.google.com.pk", "translate.google.com.pr", "translate.google.com.py",
            "translate.google.com.qa", "translate.google.com.sa", "translate.google.com.sb",
            "translate.google.com.sg", "translate.google.com.sl", "translate.google.com.sv",
            "translate.google.com.tj", "translate.google.com.tr", "translate.google.com.tw",
            "translate.google.com.ua", "translate.google.com.uy", "translate.google.com.vc",
            "translate.google.com.vn", "translate.google.com", "translate.google.cv",
            "translate.google.cz", "translate.google.de", "translate.google.dj",
            "translate.google.dk", "translate.google.dm", "translate.google.dz",
            "translate.google.ee", "translate.google.es", "translate.google.eu",
            "translate.google.fi", "translate.google.fm", "translate.google.fr",
            "translate.google.ga", "translate.google.ge", "translate.google.gf",
            "translate.google.gg", "translate.google.gl", "translate.google.gm",
            "translate.google.gp", "translate.google.gr", "translate.google.gy",
            "translate.google.hn", "translate.google.hr", "translate.google.ht",
            "translate.google.hu", "translate.google.ie", "translate.google.im",
            "translate.google.io", "translate.google.iq", "translate.google.is",
            "translate.google.it", "translate.google.je", "translate.google.jo",
            "translate.google.kg", "translate.google.ki", "translate.google.kz",
            "translate.google.la", "translate.google.li", "translate.google.lk",
            "translate.google.lt", "translate.google.lu", "translate.google.lv",
            "translate.google.md", "translate.google.me", "translate.google.mg",
            "translate.google.mk", "translate.google.ml", "translate.google.mn",
            "translate.google.ms", "translate.google.mu", "translate.google.mv",
            "translate.google.mw", "translate.google.ne", "translate.google.nf",
            "translate.google.nl", "translate.google.no", "translate.google.nr",
            "translate.google.nu", "translate.google.pl", "translate.google.pn",
            "translate.google.ps", "translate.google.pt", "translate.google.ro",
            "translate.google.rs", "translate.google.ru", "translate.google.rw",
            "translate.google.sc", "translate.google.se", "translate.google.sh",
            "translate.google.si", "translate.google.sk", "translate.google.sm",
            "translate.google.sn", "translate.google.so", "translate.google.sr",
            "translate.google.st", "translate.google.td", "translate.google.tg",
            "translate.google.tk", "translate.google.tl", "translate.google.tm",
            "translate.google.tn", "translate.google.to", "translate.google.tt",
            "translate.google.us", "translate.google.vg", "translate.google.vu",
            "translate.google.ws"
        )
    }
}
