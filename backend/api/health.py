# Vercel Serverless Function
# API 路径: /api/health

from http.server import BaseHTTPRequestHandler
import json

class handler(BaseHTTPRequestHandler):
    """健康检查接口"""
    
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        
        response = {
            "status": "healthy",
            "service": "Gayish API",
            "platform": "Vercel"
        }
        
        self.wfile.write(json.dumps(response).encode('utf-8'))
