---
format: 
 revealjs:
    theme: ["theme/q-theme.scss"]
    slide-number: c/t
    logo: "https://github.com/ssiwacho/picture/blob/main/datakruroo.png?raw=true"
    center-title-slide: false
    code-link: true
    code-overflow: wrap
    highlight-style: a11y
    height: 900
    width: 1600
    keep-md: true
    incremental: false 
    scrollable: true
    footer: ผศ.ดร.สิวะโชติ ศรีสุทธิยากร
---



# Data-Driven Decisions: <br> Crafting Educational Dashboards

<div style = "position: relative; left: 770px;"> ผศ.ดร.สิวะโชติ ศรีสุทธิยากร</div>

![](<https://b1538966.smushcdn.com/1538966/wp-content/uploads/2018/07/identify-what-makes-a-good-dashboard-by-analyzing-a-bad-one.png?lossy=1&strip=1&webp=1>)

## Data-Driven Decisions

การตัดสินใจที่ขับเคลื่อนด้วยข้อมูล หรือการตัดสินใจที่ใช้ข้อมูลเป็นฐานไม่เพียงแต่เป็นสิ่งจำเป็นในการดำเนินงานขององค์กรในปัจจุบัน แต่ยังเป็นกุญแจสำคัญในการสร้างอนาคตที่ยั่งยืนและมีประสิทธิภาพในวงการศึกษา

<hr>


- สร้างความมั่นใจและความน่าเชื่อถือในการตัดสินใจ

- สนับสนุน/พัฒนาผลลัพธ์การเรียนรู้ของนักเรียน และการจัดการเรียนรู้ของครู

- สนับสนุนการออกแบบและกำกับติดตามการดำเนินงานตามนโยบายอย่างเหมาะสม

- ช่วยสร้างความได้เปรียบในการแข่งขัน

- เป็นเครื่องมือที่ช่วยให้องค์กรตอบสนองต่อการเปลี่ยนแปลงต่าง ๆ ได้อย่างทันท่วงที

## (Educational) Dashboard

Dashboard เป็นเครื่องมือที่ใช้สำหรับการแสดงข้อมูลหรือคุณลักษณะที่สำคัญในรูปแบบที่สามารถอ่านและเข้าใจได้ง่าย

<hr>

- สนับสนุน data-driven decision

- ช่วยให้การวิเคราะห์/ตีความหมายจากข้อมูลง่ายขึ้นสำหรับ user ที่ไม่ได้เชี่ยวชาญเกี่ยวกับ data

- เป็นเครื่องมือที่มีประสิทธิภาพในการสื่อสารข้อมูลกับผู้มีส่วนได้ส่วนเสีย เช่น นักเรียน ครู ผู้ปกครอง หรือชุมชนที่จะมีส่วนช่วยเหลือในการพัฒนาการเรียนรู้ของนักเรียน

- ส่งเสริมการกำกับติดตาม/ประเมินผลที่เป็นปัจจุบันและต่อเนื่อง

- ช่วยสร้างมาตรฐานในการวัดและประเมินผลการดำเนินงานต่าง ๆ ทางการศึกษา

## ประเภทของ Dashboard ทางการศึกษา

การแบ่งประเภทของ Dashboard ทางการศึกษาสามารถแบ่งได้หลายลักษณะ ลักษณะแรกเป็นการแบ่งแบบทั่วไป

- Descriptive Dashboard

- Diagnostic Dashboard

- Predictive Dashboard

- Presciptive Dashboard

<center>
![](https://media.springernature.com/full/springer-static/image/art%3A10.1186%2Fs41239-021-00313-7/MediaObjects/41239_2021_313_Fig3_HTML.png?as=webp)
</center>

## ประเภทของ Dashboard ทางการศึกษา

ลักษณะที่สองเป็นการแบ่งตามวัตถุประสงค์หลักของการใช้งาน dashboard

- Operational Dashboards

- Analytical Dashbaords

- Strategic Dashboards

- Tactical Dashboards

- Individual Dashboards

- ...

## หลักการออกแบบ Dashboard


:::: columns

::: {.column width="60%"}


![](https://github.com/ssiwacho/picture/blob/main/design.,png.png?raw=true)

:::

::: {.column width="40%"}


-   Accessible

-   Trustworthy

-   Elegant
:::
::::

## กระบวนการพัฒนา Dashboard

- กำหนดวัตถุประสงค์และกลุ่มเป้าหมาย

- ศึกษาหรือเก็บรวบรวมข้อมูลความต้องการของผู้ใช้
  
  - กลุ่มเป้าหมายต้องการตัดสินใจหรือดำเนินงานอะไร
  
  - ข้อมูลที่เกี่ยวข้อง/จำเป็น หรือ KPI ที่สำคัญต่อการตัดสินใจหรือดำเนินงานมีอะไรบ้าง
  
  - จากข้อมูลต้องทำการวิเคราะห์/สร้างสารสนเทศอะไรบ้างเพื่อสนับสนุนการตัดสินใจดังกล่าว
  
  - พิจารณาความเป็นไปได้ในการเก็บรวบรวมข้อมูลดังกล่าว
  
  - ทดลองวิเคราะห์ข้อมูลจริงเพื่อดูว่าสารสนเทศที่ได้ตอบโจทย์ได้จริงหรือไม่
  
- สร้าง prototype ของ dashboard (ร่างแบบยังไม่ต้องทำจริง)

  - ออกแบบ layout และการจัดเรียงสารสนเทศต่าง ๆ บน dashboard

  - ออกแบบ data visualization ที่ใช้ใน dashboard
  
  - dashboard ต้องการ interactive feature หรือไม่
  
  - dashboard ต้องการโมเดลหรือ machine learning เพื่อประมวลผลหรือไม่
  
- พัฒนา Dashboard (ฉบับทดลองใช้) 

- ทดลองใช้กับกลุ่มเป้าหมายหรือผู้ใช้เพื่อขอ feedback ในขั้นตอนนี้ควรมีการกำหนดตัวชี้วัดประสิทธิภาพของ dashboard ให้ชัดเจน โดยอาจยึดตามกรอบของ Dieter Rams ในข้างต้นหรือกรอบการประเมินอื่นที่เหมาะสมก็ได้ ปกติมักเรียกขั้นตอนนี้ว่า Usability testing 

- ปรับปรุง dashboard 

- เผยแพร่และฝึกอบรมให้ผู้ใช้

- ตรวจสอบ บำรุงรักษา และปรับปรุงอย่างต่อเนื่อง

## กิจกรรม 1: dashboard prototype

- [แผนการศึกษาแห่งชาติ](https://cbethailand.com/wp-content/uploads/2021/10/2-%E0%B9%81%E0%B8%9C%E0%B8%99%E0%B8%81%E0%B8%B2%E0%B8%A3%E0%B8%A8%E0%B8%B6%E0%B8%81%E0%B8%A9%E0%B8%B2%E0%B9%81%E0%B8%AB%E0%B9%88%E0%B8%87%E0%B8%8A%E0%B8%B2%E0%B8%95%E0%B8%B4.pdf)




## การพัฒนา Dashboard ด้วย R

### flexdashboard 

- เป็นแพ็คเกจที่ช่วยให้สามารถสร้าง dashboards ที่มีการจัดรูปแบบและการตอบสนอง (responsive) ได้ง่ายด้วย R Markdown และสามารถรวม Shiny code เข้าไปเพื่อเพิ่มความสามารถในการโต้ตอบได้

- เหมาะสำหรับการสร้าง dashboards ที่เน้นการแสดงข้อมูลและไม่ต้องการการโต้ตอบที่ซับซ้อนมากนัก

- ใช้ความรู้เกี่ยวกับ Rmarkdown เป็นหลัก และสามารถใช้ shiny เข้ามาช่วยเสริม interactive feature 

### shinydashboard

- เป็นแพ็คเกจที่ใช้สำหรับการสร้าง dashboards ที่มีความสามารถในการโต้ตอบสูงด้วย Shiny

- เหมาะสำหรับการสร้าง dashboards ที่ต้องการความสามารถในการโต้ตอบที่ซับซ้อน และต้องการการควบคุมที่มากขึ้นเกี่ยวกับ UI และ UX

## การพัฒนา Dashboard ด้วย flexdashboard

[![](https://posit.co/wp-content/uploads/2016/05/Untitled-design.jpg)](https://pkgs.rstudio.com/flexdashboard/)

- พัฒนาโดยทีมงาน RStudio ปัจจุบันคือ Posit

- สามารถสร้าง dashboard แบบ responsive 

- ทำงานร่วมกับ shiny เพื่อเสริมความสามารถในด้านการมีปฏิสัมพันธ์กับผู้ใช้ได้


## เครื่องมือที่สามารถนำมาช่วยพัฒนา dashboard

มีเครื่องมือหลายตัวที่สามารถนำมาใช้พัฒนา dashboard รวมทั้ง reproducible reports และ web applications ได้


### Visualizations

- [ggplot2](https://ggplot2.tidyverse.org/)

- [plotly](https://plotly.com/r/)

- [highcharts](https://www.highcharts.com/blog/tutorials/highcharts-for-r-users/)

- [rbokeh](https://hafen.github.io/rbokeh/articles/rbokeh.html)

- [Leaflet](https://rstudio.github.io/leaflet/)

### Tables

- [DT](https://rstudio.github.io/DT/)
- [kableExtra](https://cran.r-project.org/web/packages/kableExtra/vignettes/awesome_table_in_html.html)

### thaipdf document

- [thaipdf](https://lightbridge-ks.github.io/thaipdf/)

### openai

- [openai](https://openai.com/)

## กิจกรรม 2: พัฒนา dashboard



