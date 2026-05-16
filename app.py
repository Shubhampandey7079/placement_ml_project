from flask import Flask, render_template, request, jsonify, send_file
import pickle
import pandas as pd
import os
import io
import re
from dotenv import load_dotenv
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from groq import Groq

# ==========================================
# INIT & CONFIG
# ==========================================
app = Flask(__name__)
load_dotenv()

# ==========================================
# GROQ SETUP
# ==========================================
GROQ_API_KEY = os.getenv("GROQ_API_KEY")

client = None
if GROQ_API_KEY:
    client = Groq(api_key=GROQ_API_KEY)
    print("✅ Groq Connected")
else:
    print("❌ No API Key found in .env")

# ==========================================
# LOAD MODEL
# ==========================================
try:
    model = pickle.load(open("model.pkl", "rb"))
    scaler = pickle.load(open("scaler.pkl", "rb"))
    print("✅ Model Loaded")
except FileNotFoundError:
    print("⚠️ Model files not found. Using dummy prediction logic.")
    model = None
    scaler = None

FEATURE_COLUMNS = [
    'cgpa', 'aptitude_score', 'coding_skills',
    'internships', 'certifications',
    'communication_skills', 'projects'
]

# ==========================================
# AI REPORT FUNCTION (UPDATED PROMPT)
# ==========================================
def generate_ai_report(data, prediction):
    # Map dictionary keys to the prompt variables
    prompt = f"""
You are an AI Placement Analyst.

========================
STRICT RULES (MUST FOLLOW)
========================
1. Use ONLY the given input data.
2. DO NOT assume anything.
3. DO NOT exaggerate scores.
4. DO NOT contradict the prediction.
5. DO NOT misinterpret values.
6. Be logical, consistent, and data-driven.

========================
SCORING SYSTEM
========================
CGPA: 0–10
Projects / Internships / Certifications: 0–10
Aptitude / Coding / Communication: 0–100

Interpretation:
For /100 scale:
0–40 = Poor
40–70 = Average
70–100 = Strong

For /10 scale:
0–3 = Poor
4–6 = Average
7–10 = Strong

========================
STUDENT DATA
========================
CGPA: {data['cgpa']}/10
Aptitude: {data['aptitude_score']}/100
Coding: {data['coding_skills']}/10
Communication: {data['communication_skills']}/100
Projects: {data['projects']}/10
Internships: {data['internships']}/5
Certifications: {data['certifications']}/10

Prediction:
Placement Status: {prediction}

========================
LOGIC ALIGNMENT RULE
========================
IF prediction = "Placed":
- Focus mainly on strengths
- Justify WHY the student is job-ready
- Mention only minor improvements

IF prediction = "Not Placed":
- Focus mainly on weaknesses
- Clearly explain skill gaps
- Explain why the student is not job-ready

========================
TASK
========================
Generate a structured report including:
1. Student Summary (based strictly on actual scores)
2. Strengths (only if scores are strong)
3. Weaknesses (only if scores are poor/average)
4. Reason for Prediction (must match prediction)
5. Skills to Improve (based only on weak areas)
6. Roadmap:
   - 0–3 months
   - 3–6 months
   - 6–12 months
7. Suitable Job Roles (based on CURRENT level)
8. Project Suggestions (based on skill level)
9. Interview Strategy
10. Final Conclusion (aligned with prediction)

========================
OUTPUT STYLE
========================
- Use simple professional English
- No fake praise
- No contradictions
- No assumptions
- Keep it structured for PDF
- Use bullet points and short paragraphs
"""

    try:
        response = client.chat.completions.create(
            messages=[{"role": "user", "content": prompt}],
            model="llama-3.1-8b-instant", 
            temperature=0.3
        )
        return response.choices[0].message.content
    except Exception as e:
        return f"AI Generation Error: {str(e)}"

# ==========================================
# PDF GENERATOR (UPDATED FORMATTING)
# ==========================================
def parse_markdown_to_rml(text):
    """
    Converts raw text with \n and **bold** tags into ReportLab XML tags.
    """
    # 1. Handle newlines first: replace \n with <br/>
    processed_text = text.replace('\n', '<br/>')
    
    # 2. Handle Bold text: **text** -> <b>text</b>
    # We use regex to replace all occurrences
    processed_text = re.sub(r'\*\*(.*?)\*\*', r'<b>\1</b>', processed_text)
    
    return processed_text

def create_resume_style_pdf(buffer, data):
    doc = SimpleDocTemplate(
        buffer,
        pagesize=A4,
        rightMargin=72,
        leftMargin=72,
        topMargin=72,
        bottomMargin=40
    )

    styles = getSampleStyleSheet()
    
    # Custom Styles
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=colors.HexColor("#0056b3"),
        spaceAfter=20,
        fontName='Helvetica-Bold',
        alignment=TA_CENTER
    )
    heading_style = ParagraphStyle(
        'SectionHeader',
        parent=styles['Heading2'],
        fontSize=14,
        textColor=colors.HexColor("#333333"),
        spaceBefore=15,
        spaceAfter=8,
        fontName='Helvetica-Bold',
        borderLeft=True,
        borderPaddingLeft=10,
        borderColor=colors.HexColor("#0056b3")
    )
    normal_style = ParagraphStyle(
        'BodyText',
        parent=styles['BodyText'],
        fontSize=10,
        textColor=colors.HexColor("#444444"),
        leading=14, # Line height
        alignment=TA_LEFT,
        allowWidows=1,
        allowOrphans=1,
        wordWrap='CJK' 
    )
    
    # Header/Footer Function
    def header_footer(canvas, doc):
        canvas.saveState()
        # Header
        canvas.setFont('Helvetica-Bold', 12)
        canvas.setFillColor(colors.HexColor("#0056b3"))
        canvas.drawString(inch, A4[1] - 40, "AI PLACEMENT ROADMAP REPORT")
        
        # Footer
        canvas.setFont('Helvetica', 9)
        canvas.setFillColor(colors.grey)
        canvas.drawCentredString(A4[0] / 2, 20, f"Page {doc.page}")
        
        # Lines
        canvas.setStrokeColor(colors.lightgrey)
        canvas.setLineWidth(0.5)
        canvas.line(40, A4[1] - 50, A4[0] - 40, A4[1] - 50)
        canvas.line(40, 40, A4[0] - 40, 40)
        canvas.restoreState()

    # Content List
    story = []
    
    # 1. Title
    story.append(Paragraph("AI PLACEMENT ANALYSIS", title_style))
    story.append(Spacer(1, 0.2 * inch))

    # 2. Prediction Box
    pred_color = "#2ecc71" if "Placed" in data['prediction'] else "#e74c3c"
    result_data = [
        ["Prediction Status:", f"{data['prediction']}"],
        ["Confidence Score:", f"{data['confidence']}"]
    ]
    result_table = Table(result_data, colWidths=[2*inch, 3.5*inch], hAlign='LEFT')
    result_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), colors.HexColor("#f0f2f5")),
        ('TEXTCOLOR', (0, 0), (0, -1), colors.grey),
        ('TEXTCOLOR', (1, 0), (1, -1), colors.HexColor(pred_color)),
        ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
        ('FONTSSIZE', (0, 0), (-1, -1), 11),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.lightgrey),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(result_table)
    story.append(Spacer(1, 0.3 * inch))

    # 3. Input Data Table
    story.append(Paragraph("Student Profile Snapshot", heading_style))
    input_rows = [["Metric", "Value"]]
    for k, v in data["input_data"].items():
        label = k.replace("_", " ").title()
        input_rows.append([label, str(v)])
    
    profile_table = Table(input_rows, colWidths=[2.5*inch, 3*inch], hAlign='LEFT')
    profile_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#333333")),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.lightgrey),
    ]))
    story.append(profile_table)
    story.append(Spacer(1, 0.3 * inch))

    # 4. AI Analysis (UPDATED LOGIC)
    story.append(Paragraph("AI Roadmap & Strategy", heading_style))
    raw_text = data.get('ai_report', "No analysis generated.")
    
    # Parse the text to handle newlines and bold tags
    formatted_text = parse_markdown_to_rml(raw_text)
    
    # Pass formatted text to Paragraph
    report_para = Paragraph(formatted_text, normal_style)
    story.append(report_para)

    # 5. Footer Note
    story.append(Spacer(1, 1 * inch))
    story.append(Paragraph(
        "<i>Generated by AI Placement Engine. Results are based on historical data patterns.</i>", 
        ParagraphStyle('Footer', parent=styles['Normal'], fontSize=8, textColor=colors.grey, alignment=TA_CENTER)
    ))

    # Build
    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)

# ==========================================
# ROUTES
# ==========================================

@app.route('/')
def home():
    return render_template("index.html")


@app.route('/predict', methods=['POST'])
def predict():
    input_data = {}
    for col in FEATURE_COLUMNS:
        val = request.form.get(col)
        input_data[col] = float(val)

    # Use Real Model or Dummy Logic
    if model and scaler:
        df = pd.DataFrame([input_data])
        scaled = scaler.transform(df)
        pred = model.predict(scaled)[0]
        prob = model.predict_proba(scaled)[0][1]
    
    result = "Placed" if pred == 1 else "Not Placed"

    return jsonify({
        "prediction": result,
        "confidence": f"{prob*100:.2f}%",
        "input_data": input_data
    })


@app.route('/generate-report', methods=['POST'])
def generate_report():
    data = request.json
    ai_text = generate_ai_report(data["input_data"], data["prediction"])
    return jsonify({"ai_report": ai_text})


@app.route('/download_report', methods=['POST'])
def download_report():
    data = request.json
    buffer = io.BytesIO()
    
    create_resume_style_pdf(buffer, data)
    
    buffer.seek(0)
    return send_file(
        buffer,
        as_attachment=True,
        download_name="Placement_Analysis_Report.pdf",
        mimetype="application/pdf"
    )


if __name__ == "__main__":
    app.run(debug=True, port=5000)
