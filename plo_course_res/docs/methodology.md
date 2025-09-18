# วิธีการวิเคราะห์และการคำนวณ Metrics

## ภาพรวมการวิเคราะห์

โปรเจคนี้ใช้หลักการวิเคราะห์เชิงปริมาณ (Quantitative Analysis) ในการประเมินคุณภาพการเชื่อมโยงระหว่าง Course Learning Outcomes (CLO) และ Program Learning Outcomes (PLO) โดยอาศัยทฤษฎีจากด้าน Educational Assessment และ Curriculum Evaluation

## กระบวนการวิเคราะห์

### 1. Data Preparation
```r
# การเตรียมข้อมูลพื้นฐาน
complete_dataset <- create_complete_dataset()

# โครงสร้างข้อมูล:
# - Courses (5 รายวิชา)
# - CLOs (24 CLOs รวม)  
# - Sub-PLOs (12 sub-PLOs)
# - PLOs (4 PLOs หลัก)
# - Keywords (55 keywords พร้อมคะแนน)
```

### 2. Coverage Analysis (การวิเคราะห์การครอบคลุม)

#### หลักการ
Coverage Analysis วัดระดับการครอบคลุมของ PLO และ sub-PLO ในหลักสูตร เป็นตัวชี้วัดพื้นฐานที่สำคัญที่สุดในการประเมินความสมบูรณ์ของหลักสูตร

#### สูตรการคำนวณ
```r
# PLO Coverage Percentage
plo_coverage_pct = (จำนวน PLO ที่มี CLO เชื่อมโยง / จำนวน PLO ทั้งหมด) × 100

# Sub-PLO Coverage Percentage  
subplo_coverage_pct = (จำนวน sub-PLO ที่มี CLO เชื่อมโยง / จำนวน sub-PLO ทั้งหมด) × 100

# Course Coverage Score
course_coverage_score = (covered_subplo / 12) × 100
```

#### การตีความผล
- **90-100%**: Excellence - ครอบคลุมเยี่ยม
- **80-89%**: Good - ครอบคลุมดี  
- **70-79%**: Satisfactory - ครอบคลุมพอใช้
- **60-69%**: Need Improvement - ต้องปรับปรุง
- **<60%**: Poor - ต้องปรับปรุงอย่างเร่งด่วน

### 3. Alignment Strength Analysis (การวิเคราะห์ความแข็งแกรงของการเชื่อมโยง)

#### หลักการ
Alignment Strength วัดคุณภาพและความลึกของการเชื่อมโยง ไม่ใช่แค่มีหรือไม่มี แต่วัดว่าแข็งแกรงเพียงใด

#### สูตรการคำนวณ
```r
# Course-PLO Alignment Score
alignment_score = connection_count + (keyword_intensity / 10) + unique_subplo

# ส่วนประกอบ:
# - connection_count: จำนวนการเชื่อมโยง CLO-subPLO
# - keyword_intensity: ผลรวมคะแนน keywords ที่เกี่ยวข้อง  
# - unique_subplo: จำนวน sub-PLO ที่เชื่อมโยงผ่านรายวิชา
```

#### หมวดหมู่ความแข็งแกรง
- **Very Strong (≥15)**: การเชื่อมโยงแข็งแกรงมาก - มี CLO หลากหลาย keywords คุณภาพสูง
- **Strong (10-14)**: การเชื่อมโยงแข็งแกรง - มีการเชื่อมโยงที่ดี
- **Moderate (5-9)**: การเชื่อมโยงปานกลาง - เพียงพอแต่อาจพัฒนาได้
- **Weak (<5)**: การเชื่อมโยงอ่อน - ต้องปรับปรุงเร่งด่วน

### 4. Concentration Index (ดัชนีความเข้มข้น)

#### หลักการ
ใช้หลักการคล้าย Herfindahl-Hirschman Index จากเศรษฐศาสตร์ เพื่อวัดการกระจายตัวของความสนใจในแต่ละ PLO

#### สูตรการคำนวณ
```r
# Concentration Index
CI = Σ(proportion_i²)

# โดยที่ proportion_i = จำนวน mappings ของ PLO_i / จำนวน mappings ทั้งหมด
```

#### การตีความ
- **CI ≥ 0.5**: Highly Concentrated - เน้นหนักบาง PLO อาจทำให้ไม่สมดุล
- **0.25 ≤ CI < 0.5**: Moderately Concentrated - กระจายตัวปานกลาง
- **CI < 0.25**: Well Distributed - กระจายตัวดีมีความสมดุล

### 5. Balance Assessment (การประเมินความสมดุล)

#### หลักการ
วัดความสมดุลในการกระจายการเรียนรู้ระหว่าง PLO ต่างๆ โดยเปรียบเทียบกับการกระจายที่เท่าเทียมกัน

#### สูตรการคำนวณ
```r
# Balance Score สำหรับแต่ละ PLO
balance_score_i = 1 - |actual_proportion_i - expected_proportion_i|

# Expected Proportion = 1/4 = 0.25 (สำหรับ 4 PLOs)

# Overall Balance Score
overall_balance = mean(balance_score_i)
```

#### ระดับความสมดุล
- **Well Balanced (≥0.8)**: สมดุลดีมาก
- **Moderately Balanced (0.6-0.79)**: สมดุลปานกลาง
- **Imbalanced (<0.6)**: ไม่สมดุล ต้องปรับปรุง

### 6. Strategic Importance Analysis (การวิเคราะห์ความสำคัญเชิงกลยุทธ์)

#### หลักการ
ประเมินคุณค่าเชิงกลยุทธ์ของรายวิชาโดยรวมปัจจัยหลายด้าน รวมถึง keyword quality, PLO coverage, และ resource utilization

#### สูตรการคำนวณ
```r
# Strategic Score
strategic_score = (total_keyword_score × 0.4) +      # คุณภาพเนื้อหา (40%)
                 (high_value_keywords × 5) +          # Keywords สำคัญ 
                 (plo_coverage × 10) +                # การครอบคลุม PLO
                 (subplo_coverage × 2) +              # การครอบคลุม sub-PLO  
                 (hours × 0.1)                        # ปริมาณชั่วโมงเรียน

# Score per Hour (ประสิทธิภาพ)
efficiency_score = strategic_score / hours
```

#### หมวดหมู่ความสำคัญ
- **Critical (≥100)**: รายวิชาสำคัญสูงสุด - core courses
- **High Priority (70-99)**: ความสำคัญสูง - major courses  
- **Important (40-69)**: รายวิชาสำคัญ - supporting courses
- **Supporting (<40)**: รายวิชาสนับสนุน - elective/supplementary

## การประยุกต์ใช้ผลการวิเคราะห์

### สำหรับการพัฒนาหลักสูตร
1. **Gap Analysis**: ใช้ Coverage metrics หา gaps ที่ต้องเติมเต็ม
2. **Resource Allocation**: ใช้ Strategic Importance จัดสรรทรัพยากร
3. **Course Redesign**: ใช้ Alignment Strength ปรับปรุงรายวิชา

### สำหรับการประกันคุณภาพ
1. **Accreditation**: ใช้ Coverage และ Balance เป็นหลักฐาน
2. **Continuous Improvement**: ใช้ทุก metrics ในการติดตาม
3. **Benchmarking**: เปรียบเทียบกับมาตรฐานสากล

### สำหรับการบริหารหลักสูตร
1. **Faculty Development**: ใช้ Alignment Strength วางแผนพัฒนาอาจารย์
2. **Curriculum Review**: ใช้ Balance Assessment ในการทบทวน
3. **Strategic Planning**: ใช้ Strategic Importance วางแผนระยะยาว

## ข้อจำกัดและข้อควรระวัง

### ข้อจำกัดของวิธีการ
1. **ขึ้นอยู่กับคุณภาพของข้อมูล mapping**: ถ้า mapping ไม่ถูกต้อง ผลการวิเคราะห์จะคลาดเคลื่อน
2. **น้ำหนักในสูตรเป็น assumption**: อาจต้องปรับตาม context ของแต่ละสถาบัน
3. **ไม่รวมปัจจัยเชิงคุณภาพ**: เช่น teaching quality, student satisfaction

### ข้อแนะนำในการใช้งาน
1. **Validate mapping อย่างสม่ำเสมอ**: ให้อาจารย์ทบทวน CLO-PLO mapping
2. **ปรับน้ำหนักตาม context**: แต่ละสถาบันอาจมีความสำคัญที่แตกต่าง
3. **ใช้ร่วมกับข้อมูลเชิงคุณภาพ**: เช่น feedback จากนักศึกษาและผู้ใช้บัณฑิต

## อ้างอิง

1. Biggs, J., & Tang, C. (2011). Teaching for Quality Learning at University. McGraw-Hill Education.
2. Anderson, L. W., & Krathwohl, D. R. (2001). A Taxonomy for Learning, Teaching, and Assessing: A Revision of Bloom's Taxonomy of Educational Objectives. Allyn & Bacon.
3. Wiggins, G., & McTighe, J. (2005). Understanding by Design. Association for Supervision and Curriculum Development.
