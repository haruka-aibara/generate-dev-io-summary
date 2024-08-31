import boto3
import json
import os
import requests
from bs4 import BeautifulSoup


# キュー情報を設定
queue_url = os.environ["QUEUE_URL"]
topic_arn = os.environ["TOPIC_ARN"]
sqs = boto3.client("sqs", region_name="ap-northeast-1")
sns = boto3.client("sns", region_name="ap-northeast-1")
bedrock_runtime = boto3.client("bedrock-runtime",region_name="ap-northeast-1")


# メイン処理
def lambda_handler(event, context):
    res = sqs.receive_message(
        QueueUrl=queue_url,
        AttributeNames=["All"],
        MessageAttributeNames=["All"],
        MaxNumberOfMessages=1,
        VisibilityTimeout=30,
        WaitTimeSeconds=0
    )

    if "Messages" in res:
        message = res["Messages"][0]
        article_url = message["Body"]
        # メッサージをキューから削除
        receipt_handle = message["ReceiptHandle"]
        sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )
        # スクレイピング処理に記事URLを連携
        article_title, article_text = scraping_article(article_url)
        article_summary = generate_summary(article_text)
        response = publish_message(article_url, article_title, article_summary)

        return {
            "statusCode": 200,
            "body": "OK"
        }


# 記事本文のスクレイピング
def scraping_article(article_url):
    html = requests.get(article_url).content
    soup = BeautifulSoup(html, "html.parser")
    # 記事のタイトルを取得
    article_title = soup.find("title").get_text()
    # 不要な文章をクラスで指定
    exclude_classes = [
        "blocks", "copyright", "events", "posts", "post-content",
        "related", "share-navigation", "sub-content"
    ]
    exclude_divs = soup.find_all("div", class_=exclude_classes)
    if exclude_divs:
        for exclude_div in exclude_divs:
            exclude_div.extract()
    article_text = soup.body.get_text()

    return article_title, article_text


# 文章要約
def generate_summary(text):
    input_text = (
        "\n\nHuman: You are an IT engineer."
        "Summarize the following article_text and write up to 5 sentences in the form of a response example."
        "In addition, please translate language other than Japanese to Japanese and output."
        "\n\narticle_text: {}\n\nresponse example:"
        "- first sentence\n- second sentence\n- third sentence\n- forth sentense\n- fifth sentence\n\nAssistant:"
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


# 要約結果をEメール送信
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