import boto3
import json
import os
import requests
from bs4 import BeautifulSoup
import urllib.parse

# キュー情報を設定
queue_url = os.environ["QUEUE_URL"]
topic_arn = os.environ["TOPIC_ARN"]
sqs = boto3.client("sqs", region_name="ap-northeast-1")
sns = boto3.client("sns", region_name="ap-northeast-1")
bedrock_runtime = boto3.client("bedrock-runtime",region_name="ap-northeast-1")

def lambda_handler(event, context):
    try:
        processed_count = 0
        while True:
            res = sqs.receive_message(
                QueueUrl=queue_url,
                AttributeNames=["All"],
                MessageAttributeNames=["All"],
                MaxNumberOfMessages=10,  # 最大10件のメッセージを取得
                VisibilityTimeout=30,
                WaitTimeSeconds=0
            )

            if "Messages" not in res:
                print(f"No more messages in queue. Processed {processed_count} messages.")
                break

            for message in res["Messages"]:
                # メッセージ本文からURLを取得
                message_body = json.loads(message["Body"])
                article_url = message_body["url"]

                print(f"Processing article URL: {article_url}")

                # スクレイピング処理に記事URLを連携
                article_title, article_text = scraping_article(article_url)
                article_summary = generate_summary(article_text)
                publish_message(article_url, article_title, article_summary)

                # メッセージをキューから削除
                receipt_handle = message["ReceiptHandle"]
                sqs.delete_message(
                    QueueUrl=queue_url,
                    ReceiptHandle=receipt_handle
                )

                processed_count += 1

        return {
            "statusCode": 200,
            "body": f"Processed {processed_count} messages"
        }

    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return {
            "statusCode": 500,
            "body": str(e)
        }

# 記事本文のスクレイピング
def scraping_article(article_url):
    try:
        response = requests.get(article_url, timeout=10)
        response.raise_for_status()
        html = response.content
        soup = BeautifulSoup(html, "html.parser")
        
        # 記事のタイトルを取得
        article_title = soup.find("title").get_text() if soup.find("title") else "No title found"
        
        # 記事本文を取得（この部分は実際のウェブサイトの構造に合わせて調整が必要）
        article_text = soup.find("main").get_text() if soup.find("main") else "No content found"
        
        return article_title, article_text
    except Exception as e:
        print(f"Error in scraping article: {str(e)}")
        raise


# 文章要約
def generate_summary(text):
    input_text = (
        "\n\nHuman: あなたはITエンジニアです。"
        "以下の記事を要約し、PREP法（要点、理由、例、まとめ）を使用して構造化してください。"
        "各セクションは1-2文で簡潔にまとめ、全体で最大5文になるようにしてください。"
        "日本語以外の言語が含まれている場合は、日本語に翻訳して出力してください。"
        "\n\narticle_text: {}\n\n"
        "回答例:"
        "要点: [記事の主要なポイントを1文で]\n"
        "理由: [そのポイントが重要である理由を1文で]\n"
        "例: [具体的な例や詳細を1文で]\n"
        "まとめ: [結論や実践的なアドバイスを1-2文で]\n\n"
        "Assistant:"
    ).format(text)
    request_body = json.dumps(
        {
            "prompt": input_text,
            "max_tokens_to_sample": 300,
            "temperature": 0.5,
            "top_k": 250,
            "top_p": 1,
            "anthropic_version": "bedrock-2023-05-31"
        }
    )
    response = bedrock_runtime.invoke_model(
        modelId="anthropic.claude-instant-v1",
        body=request_body,
        accept="*/*",
        contentType="application/json"
    )
    response_body = json.loads(response.get("body").read())

    return response_body


## 要約結果をEメール送信
def publish_message(article_url, article_title, article_summary):
    message = (
        "article_url: {}\narticle_title: {}\narticle_summary: {}"
    ).format(article_url, article_title, article_summary["completion"])
    response = sns.publish(
        TopicArn=topic_arn,
        Message=message,
        Subject="dev-io-summary"
    )

    return response
