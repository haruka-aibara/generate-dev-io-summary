import json
import logging
import os
import urllib.parse

import boto3
import requests
from bs4 import BeautifulSoup

# ロガーの設定
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# 環境変数とAWSリソースの設定
queue_url = os.environ["QUEUE_URL"]
topic_arn = os.environ["TOPIC_ARN"]
sqs = boto3.client("sqs", region_name="ap-northeast-1")
sns = boto3.client("sns", region_name="ap-northeast-1")
bedrock_runtime = boto3.client("bedrock-runtime", region_name="ap-northeast-1")


def lambda_handler(event, context):
    try:
        processed_count = 0
        while True:
            res = sqs.receive_message(
                QueueUrl=queue_url,
                AttributeNames=["All"],
                MessageAttributeNames=["All"],
                MaxNumberOfMessages=10,
                VisibilityTimeout=30,
                WaitTimeSeconds=0,
            )

            if "Messages" not in res:
                logger.info({"message": "No more messages in queue", "processed_count": processed_count})
                break

            for message in res["Messages"]:
                # メッセージ本文からURLを取得
                message_body = json.loads(message["Body"])
                article_url = message_body["url"]

                logger.info({"message": "Processing article", "article_url": article_url})

                # スクレイピング処理に記事URLを連携
                article_title, article_text = scraping_article(article_url)
                article_summary = generate_summary(article_text)
                publish_message(article_url, article_title, article_summary)

                # メッセージをキューから削除
                receipt_handle = message["ReceiptHandle"]
                sqs.delete_message(QueueUrl=queue_url, ReceiptHandle=receipt_handle)

                processed_count += 1
                logger.info(
                    {"message": "Article processed", "article_url": article_url, "processed_count": processed_count}
                )

        logger.info({"message": "Lambda execution completed", "total_processed": processed_count})
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Execution completed", "processed_count": processed_count}),
        }

    except Exception as e:
        logger.error({"message": "An error occurred", "error": str(e)}, exc_info=True)
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}


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

        logger.info(
            {
                "message": "Article scraped successfully",
                "article_url": article_url,
                "title_length": len(article_title),
                "content_length": len(article_text),
            }
        )
        return article_title, article_text
    except Exception as e:
        logger.error(
            {"message": "Error in scraping article", "article_url": article_url, "error": str(e)}, exc_info=True
        )
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
            "anthropic_version": "bedrock-2023-05-31",
        }
    )
    try:
        response = bedrock_runtime.invoke_model(
            modelId="anthropic.claude-instant-v1", body=request_body, accept="*/*", contentType="application/json"
        )
        response_body = json.loads(response.get("body").read())
        logger.info({"message": "Summary generated successfully", "summary_length": len(response_body["completion"])})
        return response_body
    except Exception as e:
        logger.error({"message": "Error in generating summary", "error": str(e)}, exc_info=True)
        raise


# 要約結果をEメール送信
def publish_message(article_url, article_title, article_summary):
    message = {
        "version": "1.0",
        "source": "custom",
        "content": {
            "description": f":newspaper: *昨日 Developers.io に投稿された記事の要約をお届けします*\n\n"
            f":link: *記事URL:* {article_url}\n"
            f":book: *タイトル:* {article_title}\n\n"
            f":memo: *要約:*\n{article_summary['completion']}\n\n"
            f"---\nこの要約は自動生成されました。詳細は元の記事をご確認ください。"
        },
    }

    try:
        response = sns.publish(TopicArn=topic_arn, Message=json.dumps(message))
        logger.info(
            {"message": "Message published to SNS", "article_url": article_url, "message_id": response["MessageId"]}
        )
        return response
    except Exception as e:
        logger.error(
            {"message": "Error in publishing message", "article_url": article_url, "error": str(e)}, exc_info=True
        )
        raise
