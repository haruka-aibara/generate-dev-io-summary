# generate-dev-io-summary
Developers.io に投稿された新規記事を要約して Slack 通知する

当プロジェクトを Terraform Apply すると、下記の通り variables で指定した Slack Workspace,Channel に毎朝 6:30 頃に前日に投稿された記事の要約が届きます。

![image](https://github.com/user-attachments/assets/1aa0052e-ce90-41da-be98-f320f598cadb)

こちらの記事を参考に作成させていただき、メール送信ではなく Slack 通知に変更し、形式を PREP 法でまとめてもらうようにしています。

また、事前に Chatbot と WorkSpace の設定が必要です。

Terraform で即時 Apply できるようにしています。

https://dev.classmethod.jp/articles/generate-dev-io-summary/
