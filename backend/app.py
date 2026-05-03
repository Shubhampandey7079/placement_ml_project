from flask import Flask, render_template, request
import pickle
import pandas as pd
import os

app = Flask(__name__)

model = pickle.load(open("model.pkl", "rb"))
scaler = pickle.load(open("scaler.pkl", "rb"))

@app.route('/')
def home():
    return render_template("index.html")

@app.route('/predict', methods=['POST'])
def predict():
    try:
        cgpa = float(request.form['cgpa'])
        aptitude = float(request.form['aptitude'])

        if not (0 <= cgpa <= 10):
            return render_template("index.html", prediction_text="❌ CGPA must be between 0 and 10")

        if not (0 <= aptitude <= 100):
            return render_template("index.html", prediction_text="❌ Aptitude must be between 0 and 100")

        data = pd.DataFrame([[cgpa, aptitude]], columns=['cgpa','aptitude_score'])
        data = scaler.transform(data)

        prediction = model.predict(data)
        result = "🎉 Placed" if prediction[0] == 1 else "❌ Not Placed"

        return render_template("index.html", prediction_text=result)

    except:
        return render_template("index.html", prediction_text="⚠️ Error")

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host="0.0.0.0", port=port)