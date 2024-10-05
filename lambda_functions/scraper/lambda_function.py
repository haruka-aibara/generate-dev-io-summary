import json
import logging
import os
import re
from datetime import datetime, timedelta, timezone

import boto3
import requests
from bs4 import BeautifulSoup

# ロガーの設定
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# 環境変数とAWSリソースの設定
queue_url = os.environ["QUEUE_URL"]
sqs = boto3.client("sqs", region_name="ap-northeast-1")
main_url = "https://dev.classmethod.jp"


def clean_url(url):
    # URLから改行とスペースを削除
    url = re.sub(r"\s+", "", url)
    # 先頭と末尾のスラッシュを確認
    if not url.startswith("https://"):
        url = "https://" + url.lstrip("/")
    return url.rstrip("/")


def lambda_handler(event, context):
    try:
        # 昨日の日付をターゲットに設定
        t_delta = timedelta(hours=9)
        JST = timezone(t_delta, "JST")
        yesterday_date = datetime.now(JST) - timedelta(1)
        target_date = yesterday_date.strftime("%Y.%m.%d")

        logger.info({"message": "Starting article search", "target_date": target_date})

        # トップページから記事リンク一覧を取得
        response = requests.get(main_url)
        response.raise_for_status()
        html = response.content
        soup = BeautifulSoup(html, "html.parser")

        # 記事コンテナを見つける
        articles = soup.find_all("div", class_="flex flex-col rounded")
        logger.info({"message": "Articles found on main page", "count": len(articles)})

        articles_found = 0
        for index, article in enumerate(articles, 1):
            # 日付要素を取得
            date_elem = article.find("span", class_="text-xs text-gray-500")
            if not date_elem:
                logger.warning({"message": "Date element not found", "article_index": index})
                continue

            article_date = date_elem.text.strip()
            logger.debug({"message": "Processing article", "article_index": index, "article_date": article_date})

            if article_date != target_date:
                continue

            # リンク要素を取得
            link = article.find("a")
            if not link:
                logger.warning({"message": "Link not found", "article_index": index})
                continue

            article_url = clean_url(main_url + link["href"])
            articles_found += 1
            logger.info({"message": "Matching article found", "article_index": index, "article_url": article_url})

            # SQSへ記事のURLを送信
            message_body = json.dumps({"url": article_url})
            response = sqs.send_message(QueueUrl=queue_url, MessageBody=message_body)
            logger.info(
                {
                    "message": "Message sent to SQS",
                    "article_url": article_url,
                    "sqs_message_id": response.get("MessageId"),
                }
            )

        logger.info({"message": "Article search completed", "articles_found": articles_found})

        return {"statusCode": 200, "body": json.dumps({"message": "Completed", "articles_found": articles_found})}
    except Exception as e:
        logger.error(
            {"message": "An error occurred", "error": str(e), "trace": logging.exception("Exception occurred")}
        )
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
