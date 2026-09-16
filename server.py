"""
server.py - SolidWorks 2D Drawing to STEP AP203 Automation Web Server
Full-stack REST API providing automated drawing analysis, CAD generation, and SolidWorks integration.
"""

import os
import json
from flask import Flask, request, jsonify, send_from_directory, send_file
from drawing_analyzer import DrawingAnalyzer
from cad_generator import CADGenerator

app = Flask(__name__, static_folder='static', static_url_path='/static')

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_DIR = os.path.join(BASE_DIR, "uploads")
OUTPUT_DIR = os.path.join(BASE_DIR, "outputs")
PREVIEW_DIR = os.path.join(BASE_DIR, "static", "previews")

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(PREVIEW_DIR, exist_ok=True)

analyzer = DrawingAnalyzer(upload_dir=UPLOAD_DIR, preview_dir=PREVIEW_DIR)
cad_gen = CADGenerator(output_dir=OUTPUT_DIR)

@app.route('/')
def index():
    return send_from_directory('static', 'index.html')

@app.route('/api/upload', methods=['POST'])
def upload_and_analyze():
    if 'file' not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "Empty filename"}), 400

    filepath = os.path.join(UPLOAD_DIR, file.filename)
    file.save(filepath)

    try:
        # 1. Analyze 2D Drawing
        spec = analyzer.process_file(filepath)

        # 2. Automatically Generate 3D STEP AP203 & SolidWorks Macro
        cad_res = cad_gen.generate_model(spec)

        # Combine results
        result = {
            "success": True,
            "drawing": spec,
            "cad": cad_res
        }
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": f"Analysis failed: {str(e)}"}), 500

@app.route('/api/sample', methods=['GET'])
def load_sample_drawing():
    """
    Loads verified sample engineering drawing (AA-14 from IDA-007 DRAWING.pdf)
    """
    sample_pdf = "C:/Users/jittr/Downloads/26-0585 - JIGIDA-007/IDA-007 DRAWING.pdf"
    if not os.path.exists(sample_pdf):
        sample_pdf = os.path.join(BASE_DIR, "ida_drawing_upright.png")

    try:
        spec = analyzer.process_file(sample_pdf)
        cad_res = cad_gen.generate_model(spec)
        return jsonify({
            "success": True,
            "drawing": spec,
            "cad": cad_res
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/regenerate', methods=['POST'])
def regenerate_cad():
    """
    Regenerates 3D STEP AP203 and SolidWorks Macro when user modifies dimensions in UI.
    """
    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing specification data"}), 400

    try:
        cad_res = cad_gen.generate_model(data)
        return jsonify({
            "success": True,
            "cad": cad_res
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/download/<path:filename>')
def download_output(filename):
    file_path = os.path.join(OUTPUT_DIR, filename)
    if os.path.exists(file_path):
        return send_file(file_path, as_attachment=True)
    return jsonify({"error": "File not found"}), 404

@app.route('/api/stl/<path:filename>')
def serve_stl(filename):
    file_path = os.path.join(OUTPUT_DIR, filename)
    if os.path.exists(file_path):
        return send_file(file_path, mimetype='model/stl')
    return jsonify({"error": "STL not found"}), 404

if __name__ == '__main__':
    port = 5000
    print(f"==================================================")
    print(f" SolidWorks 2D Drawing to STEP AP203 Web Server")
    print(f" Running at: http://127.0.0.1:{port}")
    print(f"==================================================")
    app.run(host='0.0.0.0', port=port, debug=False)
