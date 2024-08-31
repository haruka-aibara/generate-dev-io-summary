import boto3
import os
import requests
from bs4 import BeautifulSoup
from datetime import datetime, timedelta, timezone


# キュー情報を設定
queue_url = os.environ["QUEUE_URL"]
sqs = boto3.client("sqs", region_name="ap-northeast-1")
main_url = "https://dev.classmethod.jp"


def lambda_handler(event, context):
    # 昨日の日付をターゲットに設定
    t_delta = timedelta(hours=9)
    JST = timezone(t_delta, 'JST')
    yesterday_date = datetime.now(JST) - timedelta(1)
    target_date = yesterday_date.strftime("%Y.%m.%d")

    # トップページから記事リンク一覧を取得
    html = requests.get(main_url).content
    soup = BeautifulSoup(html, "html.parser")
    article_links = soup.find_all("p", class_="date")

    # ターゲット日付に該当する記事のみリンクを取得
    for article_link in article_links:
        article_date = article_link.text.strip()
        if article_date == target_date:
            link = article_link.find_parent("div", class_="post-container").find("a", class_="link")
            if link:
                article_url = main_url + link["href"]

                # sqsへ記事のURLを送信
                response = sqs.send_message(
                    QueueUrl=queue_url,
                    MessageBody=article_url
                )

    return {
        'statusCode': 200,
        'body': "OK"
    }
