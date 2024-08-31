import boto3
import json
import os
import requests
from bs4 import BeautifulSoup
from datetime import datetime, timedelta, timezone
import re

# キュー情報を設定
queue_url = os.environ["QUEUE_URL"]
sqs = boto3.client("sqs", region_name="ap-northeast-1")
main_url = "https://dev.classmethod.jp"

def clean_url(url):
    # URLから改行とスペースを削除
    url = re.sub(r'\s+', '', url)
    # 先頭と末尾のスラッシュを確認
    if not url.startswith('https://'):
        url = 'https://' + url.lstrip('/')
    return url.rstrip('/')

def lambda_handler(event, context):
    try:
        # 昨日の日付をターゲットに設定
        t_delta = timedelta(hours=9)
        JST = timezone(t_delta, 'JST')
        yesterday_date = datetime.now(JST) - timedelta(1)
        target_date = yesterday_date.strftime("%Y.%m.%d")

        print(f"Target date: {target_date}")

        # トップページから記事リンク一覧を取得
        response = requests.get(main_url)
        response.raise_for_status()
        html = response.content
        soup = BeautifulSoup(html, "html.parser")
        
        # 記事コンテナを見つける
        articles = soup.find_all("div", class_="flex flex-col bg-white rounded")
        
        print(f"Number of articles found: {len(articles)}")

        articles_found = 0
        for article in articles:
            # 日付要素を取得
            date_elem = article.find("span", class_="text-xs text-gray-500")
            if date_elem:
                article_date = date_elem.text.strip()
                print(f"Article date: {article_date}")
                if article_date == target_date:
                    # リンク要素を取得
                    link = article.find("a")
                    if link:
                        article_url = clean_url(main_url + link["href"])
                        print(f"Found matching article: {article_url}")
                        articles_found += 1

                        # SQSへ記事のURLを送信
                        message_body = json.dumps({"url": article_url})
                        response = sqs.send_message(
                            QueueUrl=queue_url,
                            MessageBody=message_body
                        )
                        print(f"Sent message to SQS: {response}")
                    else:
                        print("Link not found in the article")
                else:
                    print("Date did not match target date")
            else:
                print("Date element not found in article")

        print(f"Total articles found: {articles_found}")

        return {
            'statusCode': 200,
            'body': f"Completed. Found {articles_found} articles.",
        }
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return {
            'statusCode': 500,
            'body': str(e),
        }
