# Data KruRoo Blog

Data Science สำหรับการศึกษา - แหล่งเรียนรู้ภาษาไทยสำหรับครูและผู้สนใจ

## การเริ่มต้น

### สร้างบทความใหม่

1. สร้างโฟลเดอร์ใหม่ใน `posts/` เช่น `posts/my-new-post/`
2. คัดลอกเทมเพลตจาก `_templates/post-template.qmd` มาเป็น `posts/my-new-post/index.qmd`
3. แก้ไขข้อมูลในส่วน YAML front matter:
   - `title`: ชื่อบทความ
   - `date`: วันที่เผยแพร่ (YYYY-MM-DD)
   - `categories`: หมวดหมู่ที่เกี่ยวข้อง
   - `description`: คำอธิบายสั้นๆ
   - `draft: false`: เมื่อพร้อมเผยแพร่

### หมวดหมู่ที่แนะนำ

- **📊 Data Analysis** - การวิเคราะห์ข้อมูลเบื้องต้น
- **📈 Visualization** - การสร้างกราฟและแผนภูมิ  
- **📚 R Programming** - การเขียนโปรแกรม R
- **🐍 Python** - การใช้ Python สำหรับ Data Science
- **🔍 Statistics** - สถิติเพื่อการวิจัย
- **🎓 Education Research** - การวิจัยทางการศึกษา
- **🤖 Machine Learning** - การเรียนรู้ของเครื่อง
- **📋 Assessment** - การประเมินผลการเรียนรู้

### การ Build และ Preview

```bash
# Preview ในเครื่อง
quarto preview

# Build site
quarto render

# Publish to GitHub Pages
quarto publish gh-pages
```

### โครงสร้างไฟล์

```
├── _quarto.yml          # การตั้งค่า Quarto
├── index.qmd            # หน้าหลัก
├── about.qmd            # หน้าเกี่ยวกับ
├── posts.qmd            # หน้ารายชื่อบทความ
├── categories.qmd       # หน้าหมวดหมู่
├── custom.scss          # สไตล์ CSS
├── posts/              # โฟลเดอร์บทความ
│   ├── _metadata.yml   # การตั้งค่าเริ่มต้นสำหรับบทความ
│   └── sample-post/    # ตัวอย่างบทความ
└── _templates/         # เทมเพลตสำหรับบทความใหม่
```

## เคล็ดลับการเขียน

1. **ใช้ภาษาไทยผสมอังกฤษ**: เขียนเป็นภาษาไทยหลัก แต่ใช้คำศัพท์ทางเทคนิคภาษาอังกฤษตามความเหมาะสม

2. **รวมโค้ดที่รันได้**: ใส่ตัวอย่างโค้ดที่สามารถรันและทำซ้ำได้จริง

3. **เน้นการประยุกต์ใช้**: เชื่อมโยงเนื้อหากับงานการศึกษาจริง

4. **ใส่ภาพประกอบ**: การแสดงผลกราฟและตารางจะช่วยให้เข้าใจง่ายขึ้น

## การติดตั้งและทดสอบ

ตรวจสอบให้แน่ใจว่าได้ติดตั้ง:
- [Quarto](https://quarto.org/)
- R และ RStudio (ถ้าใช้ R)
- Python (ถ้าใช้ Python)

---

พัฒนาโดย Data KruRoo Team 📊🎓