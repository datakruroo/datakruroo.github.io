# Changelog

## [1.0.0] - 2025-09-11

### Added
- ✨ ระบบวิเคราะห์การเชื่อมโยง Course Learning Outcomes (CLO) กับ Program Learning Outcomes (PLO)
- 📊 ตัวชี้วัด 5 ประเภทหลัก: Coverage, Alignment Strength, Balance, Concentration, Strategic Importance
- 🎨 ระบบ Visualization ครบถ้วน: Sankey Diagram, Heatmap, Keywords Analysis, Balance Chart, Strategic Dashboard
- 📄 เอกสารประกอบครบถ้วน: README, Methodology, Interpretation Guide, Examples
- 🔧 ฟังก์ชันการวิเคราะห์ 6 ชุดหลัก
- 📈 ระบบรายงานอัตโนมัติสำหรับผู้บริหารและอาจารย์
- 🏗️ โครงสร้างโปรเจคที่เป็นระบบและครบถ้วน

### Features
- **Coverage Analysis**: วิเคราะห์การครอบคลุม PLO และ sub-PLO
- **Alignment Strength**: วัดความแข็งแกรงของการเชื่อมโยง CLO-PLO
- **Balance Assessment**: ประเมินความสมดุลการกระจาย PLO
- **Concentration Index**: วิเคราะห์ความเข้มข้นแบบ HHI
- **Strategic Importance**: ประเมินคุณค่าเชิงกลยุทธ์ของรายวิชา
- **Gap Analysis**: ระบุ sub-PLO ที่ยังไม่ครอบคลุม
- **Interactive Visualizations**: กราฟเชิงโต้ตอบด้วย plotly และ networkD3
- **Automated Reporting**: รายงานอัตโนมัติในรูปแบบต่างๆ

### Technical Stack
- **R**: ภาษาหลักสำหรับการวิเคราะห์
- **tidyverse**: การจัดการและแปลงข้อมูล
- **plotly**: กราฟเชิงโต้ตอบ
- **networkD3**: Sankey Diagram
- **ggplot2**: กราฟสถิติคุณภาพสูง

### Documentation
- `README.md`: เอกสารหลักของโปรเจค
- `docs/methodology.md`: อธิบายวิธีการและทฤษฎี
- `docs/interpretation.md`: คู่มือการตีความผล
- `docs/examples.md`: ตัวอย่างการใช้งานครบถ้วน

### Project Structure
```
plo_course_res/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── data/
│   └── generate_dataset.R
├── analysis/
│   ├── coverage_analysis.R
│   └── visualization.R
├── outputs/
│   ├── reports/
│   └── charts/
├── docs/
│   ├── methodology.md
│   ├── interpretation.md
│   └── examples.md
└── sankey.r
```

### Initial Data
- 5 รายวิชาหลัก (208 ชั่วโมงรวม)
- 4 PLOs หลัก
- 12 sub-PLOs
- 24 CLOs รวม  
- 55 keywords พร้อมคะแนนความสำคัญ
- 160+ การ mapping CLO-subPLO

### Metrics Implemented
1. **PLO Coverage**: 100% (4/4 PLOs)
2. **Sub-PLO Coverage**: 91.7% (11/12 sub-PLOs)
3. **Balance Score**: 0.95 (Well Balanced)
4. **Critical Courses**: 2 รายวิชา
5. **High-Impact Keywords**: 10+ keywords

---

## Future Releases

### [1.1.0] - Planned
- 🔄 การเปรียบเทียบระหว่างภาคเรียน
- 📱 Responsive dashboard
- 🌐 Web interface
- 📤 Export ข้อมูลเป็น Excel/PDF

### [1.2.0] - Planned  
- 🤖 Machine Learning สำหรับคาดการณ์แนวโน้ม
- 🎯 Recommendation system
- 🔗 API integration
- 📊 Advanced analytics

### [2.0.0] - Future
- 🏫 Multi-department support
- 👥 Collaborative features
- 🔐 User management
- ☁️ Cloud deployment

---

## Contributors

- **Lead Developer**: ภาควิชาวิจัยและจิตวิทยาการศึกษา
- **Data Analysis**: R Core Team
- **Visualization**: plotly + networkD3 communities  
- **Documentation**: Internal team

---

## Acknowledgments

- ขขอบคุณชุมชน R และ tidyverse สำหรับเครื่องมือที่ยอดเยี่ยม
- ขอบคุณทฤษฎีจาก Educational Assessment และ Curriculum Evaluation
- ขอบคุณ feedback จากอาจารย์และผู้บริหารหลักสูตร

---

## License

MIT License - ดู [LICENSE](LICENSE) สำหรับรายละเอียด
