import os
import requests
from flask import Flask, request, jsonify

app = Flask(__name__)

OPENAI_ENDPOINT = "https://nba-openai-d481f.openai.azure.com/"
OPENAI_DEPLOYMENT = "nba-gpt4-mini"
SEARCH_ENDPOINT = "https://nba-ai-search.search.windows.net"
SEARCH_INDEX = "rag-1779756830276"

def get_secret(secret_name):
    key = os.environ.get(secret_name)
    if not key:
        raise ValueError(f"Missing: {secret_name}")
    return key

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy", "service": "NBA AI Analytics"})

@app.route("/ask", methods=["POST"])
def ask():
    data = request.get_json()
    question = data.get("question", "")
    if not question:
        return jsonify({"error": "No question provided"}), 400

    try:
        OPENAI_KEY = get_secret("OPENAI_KEY")
        SEARCH_KEY = get_secret("SEARCH_KEY")

        search_url = f"{SEARCH_ENDPOINT}/indexes/{SEARCH_INDEX}/docs/search?api-version=2023-11-01"
        search_headers = {"Content-Type": "application/json", "api-key": SEARCH_KEY}
        search_body = {"search": "*", "top": 11, "select": "chunk"}
        search_results = requests.post(search_url, headers=search_headers, json=search_body).json()

        context = "\n".join([doc.get("chunk", "") for doc in search_results.get("value", [])])

        if not context:
            return jsonify({"error": "No NBA data found in index"}), 500

        openai_url = f"{OPENAI_ENDPOINT}openai/deployments/{OPENAI_DEPLOYMENT}/chat/completions?api-version=2024-12-01-preview"
        openai_headers = {"Content-Type": "application/json", "api-key": OPENAI_KEY}
        openai_body = {
            "messages": [
                {"role": "system", "content": f"You are an NBA analytics assistant. Use ONLY this data to answer questions:\n{context}"},
                {"role": "user", "content": question}
            ]
        }

        response = requests.post(openai_url, headers=openai_headers, json=openai_body).json()
        answer = response["choices"][0]["message"]["content"]

        return jsonify({
            "question": question,
            "answer": answer,
            "source": "NBA CSV data via Azure AI Search"
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
