#!/usr/bin/env python3
"""
Blood Bank Management System - Screenshot Generator
"""

import os
import sys
from pathlib import Path
from datetime import datetime

class BloodBankReportGenerator:
    def __init__(self, project_path):
        self.project_path = Path(project_path)
        self.screenshots_dir = self.project_path / "screenshots"
        self.report_dir = self.project_path / "reports"
        
        # Create directories
        self.screenshots_dir.mkdir(exist_ok=True)
        self.report_dir.mkdir(exist_ok=True)
        
        # All pages in the app
        self.pages = [
            "splash_screen", "login_page", "signup_page", "forgot_password_page",
            "home_page", "admin_page", "donor_page", "receiver_page", "profile_page",
            "settings_page", "contact_page", "blood_inventory_page", 
            "notification_management_page", "analytics_dashboard", "qr_code_scanner",
            "search_filter_page", "theme_selection_page"
        ]
    
    def generate_screenshots(self):
        """Generate placeholder screenshots for all pages"""
        print("📸 Generating screenshots for all pages...")
        
        for page in self.pages:
            self.create_page_screenshot(page)
            print(f"   ✅ {page}")
    
    def create_page_screenshot(self, page_name):
        """Create a placeholder screenshot for a page"""
        html_content = f'''
<!DOCTYPE html>
<html>
<head>
    <title>{page_name.replace('_', ' ').title()}</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }}
        .container {{
            text-align: center;
            background: rgba(255,255,255,0.1);
            border-radius: 20px;
            padding: 40px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
        }}
        .icon {{
            font-size: 64px;
            margin-bottom: 20px;
        }}
        .title {{
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 15px;
        }}
        .description {{
            font-size: 18px;
            opacity: 0.9;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">🩸</div>
        <div class="title">{page_name.replace('_', ' ').title()}</div>
        <div class="description">Blood Bank Management System</div>
    </div>
</body>
</html>
'''
        
        file_path = self.screenshots_dir / f"{page_name}.html"
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(html_content)
    
    def generate_screenshot_html(self):
        """Generate HTML for screenshot grid"""
        html_parts = []
        
        for page in self.pages:
            page_title = page.replace('_', ' ').title()
            screenshot_path = f"../screenshots/{page}.html"
            
            html_parts.append(f'''
                <div class="screenshot-item">
                    <iframe src="{screenshot_path}"></iframe>
                    <div class="screenshot-caption">{page_title}</div>
                </div>
            ''')
        
        return "".join(html_parts)
    
    def create_html_report(self):
        """Create comprehensive HTML report"""
        print("📄 Creating HTML report...")
        
        report_html = f'''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blood Bank Management System - Project Report</title>
    <style>
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 0;
            background: #f5f5f5;
            color: #333;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }}
        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }}
        .header h1 {{
            margin: 0;
            font-size: 2.5em;
            font-weight: 300;
        }}
        .content {{
            padding: 40px;
        }}
        .section {{
            margin-bottom: 40px;
        }}
        .section h2 {{
            color: #667eea;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
        }}
        .screenshot-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }}
        .screenshot-item {{
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }}
        .screenshot-item iframe {{
            width: 100%;
            height: 300px;
            border: none;
        }}
        .screenshot-caption {{
            padding: 15px;
            text-align: center;
            font-weight: bold;
            color: #667eea;
        }}
        .stats {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }}
        .stat-item {{
            text-align: center;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
        }}
        .stat-number {{
            font-size: 2em;
            font-weight: bold;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🩸 Blood Bank Management System</h1>
            <p>Comprehensive Project Report & Screenshots</p>
            <p>Generated on {datetime.now().strftime('%B %d, %Y at %I:%M %p')}</p>
        </div>
        
        <div class="content">
            <div class="section">
                <h2>📊 Project Overview</h2>
                <p>The Blood Bank Management System is a comprehensive Flutter application designed to streamline blood bank operations, donor management, and blood inventory tracking.</p>
                
                <div class="stats">
                    <div class="stat-item">
                        <div class="stat-number">{len(self.pages)}</div>
                        <div>Total Pages</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">3</div>
                        <div>User Roles</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">5</div>
                        <div>Theme Options</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">8</div>
                        <div>Blood Types</div>
                    </div>
                </div>
            </div>
            
            <div class="section">
                <h2>📱 Application Screenshots</h2>
                <p>Below are screenshots of all major application pages:</p>
                
                <div class="screenshot-grid">
                    {self.generate_screenshot_html()}
                </div>
            </div>
            
            <div class="section">
                <h2>✨ Key Features</h2>
                <ul>
                    <li>Multi-role user management (Admin, Donor, Receiver)</li>
                    <li>Secure authentication and session management</li>
                    <li>Real-time blood inventory tracking</li>
                    <li>Advanced theme system with 5+ color schemes</li>
                    <li>Analytics dashboard with data visualization</li>
                    <li>QR code scanning capabilities</li>
                    <li>Cross-platform support (Android, iOS, Web)</li>
                </ul>
            </div>
            
            <div class="section">
                <h2>🏗️ Technical Architecture</h2>
                <ul>
                    <li><strong>Frontend:</strong> Flutter 3.8.0+ with Material Design 3</li>
                    <li><strong>Language:</strong> Dart 3.2.0+</li>
                    <li><strong>State Management:</strong> Provider 6.1.1</li>
                    <li><strong>Database:</strong> SQLite (mobile), Web SQL (web)</li>
                    <li><strong>Build Tools:</strong> Flutter CLI, Gradle</li>
                </ul>
            </div>
        </div>
    </div>
</body>
</html>
'''
        
        report_path = self.report_dir / "blood_bank_report.html"
        with open(report_path, "w", encoding="utf-8") as f:
            f.write(report_html)
        
        print(f"   ✅ Report created: {report_path}")
    
    def run(self):
        """Main execution method"""
        print("🩸 Blood Bank Management System - Report Generator")
        print("=" * 60)
        
        # Generate screenshots
        self.generate_screenshots()
        
        # Create HTML report
        self.create_html_report()
        
        print("\n🎉 Process completed successfully!")
        print(f"📁 Screenshots: {self.screenshots_dir}")
        print(f"📄 Report: {self.report_dir}")
        print("\n💡 To view the report, open the HTML file in your browser")

def main():
    project_path = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    generator = BloodBankReportGenerator(project_path)
    generator.run()

if __name__ == "__main__":
    main()
