# Literature Support for Improved AI-Assisted Question Generation

## Evidence that AI‑generated questions need quality control

Studies have shown that large‑language‑model (LLM) output must be carefully designed and reviewed when it is used for assessment.  A 2025 psychometric analysis of an emergency‑medicine exam (50 AI‑generated MCQs and 50 clinician‑generated MCQs) found that ChatGPT‑generated questions were easier (mean difficulty index 0.76 vs. 0.65) and produced higher scores, but 36 % of AI‑generated items were classified as “problematic” compared with 24 % of clinician‑designed items, indicating psychometric limitations; the authors concluded that **careful quality control and validation are essential when integrating AI‑generated content**【728939386754298†L121-L126】.

A BMC Medical Education study on AI‑generated single‑best‑answer questions used a prompt containing a style guide and learning outcomes and found that **only 69 % of ChatGPT‑generated questions were usable or usable with minor modifications**; 31 % were rejected due to factual inaccuracies or misalignment with the learning outcomes【727001912901364†L203-L233】.  Similarly, another study comparing AI‑ vs. human‑generated MCQs for medical licensure reported that **AI‑generated questions had more factual inaccuracies and irrelevant content** (6 % vs. 0 %) and were more likely to have inappropriate difficulty levels (14 % vs. 1 %)【391782197472327†L114-L130】.

## Importance of prompt engineering and context injection

A case study on ChatGPT question generation found that **ChatGPT is extremely prompt‑sensitive**; even a single punctuation change led to different outputs【978162859489151†L688-L773】.  Without tuning, the model tended to **generate convoluted questions by combining several questions into one**, highlighting the need for careful prompt design【978162859489151†L246-L249】.  The authors noted that **incrementally adding more specific instructions** improved question quality but that overly specific prompts eventually degraded performance【978162859489151†L784-L807】.  They also reported that providing a **few‑shot example (in‑context demonstration)** sometimes helped for question generation but not always for question evaluation【978162859489151†L784-L807】.

These results align with the recommendation that **effective question generation requires providing context** (learning objectives, style guides, exemplar questions) and **iteratively refining prompts**, while being mindful that the model can hallucinate or produce ambiguous items.  The emergency‑medicine psychometric study demonstrated that context injection also matters: the authors **uploaded emergency‑medicine educational materials into a ChatGPT session to preserve contextual continuity** and then generated all questions within that session【728939386754298†L215-L235】.  Although context injection improved relevance, human validation remained necessary【728939386754298†L121-L126】.

## Why retrieval‑augmented or context‑injection strategies help


LLMs can only generate appropriate questions when they have access to the relevant content.  Retrieval‑augmented generation (RAG) or context injection involves *supplying the model with authoritative course materials or sample questions* as part of the prompt.  This technique reduces hallucinations and aligns the generated questions with the curriculum.  Research on ChatGPT question generation reports that **well‑structured prompts with domain context and learning outcomes improve the alignment and validity of generated questions**, yet factual inaccuracies and contextual limitations persist【728939386754298†L175-L181】.  The case study above emphasises that including context and exemplar questions (few‑shot prompting) can improve QG quality, though effects vary by task【978162859489151†L784-L807】.


## Slide Outline: AI in Intentional Assessment

### Slide title: *Practical AI for Intentional Assessment*

**Objective:** Provide teachers with realistic demonstrations of how AI tools can assist each assessment phase while highlighting quality considerations.  The focus is on *AI competency* rather than on learning new tools.

#### Slide 1 – Recap & Motivation
- Summarise the principles of *Intentional Assessment* and *Data Literacy*: teachers identify learning objectives, gather evidence, interpret data, and adjust instruction.
- Highlight the challenge: the volume of evidence exceeds teachers’ capacity to analyse it in a timely way.
- Introduce the idea that **AI can augment teachers’ capacity** to produce insights but **cannot replace professional judgment**.

#### Slide 2 – Evidence on AI-generated questions (Why caution?)
- Present key findings:
  - AI-generated questions often require review; **about one-third of ChatGPT-generated questions were unusable** due to factual errors or misalignment【727001912901364†L203-L233】.
  - In a psychometric analysis, **36 % of AI-generated items were problematic vs. 24 % for clinician-designed items**【728939386754298†L121-L126】.
  - ChatGPT tends to produce **easier questions** with more factual inaccuracies and irrelevant content【391782197472327†L114-L130】.
- Emphasise that **quality assurance and human validation are essential**.

#### Slide 3 – Why context and examples matter
- Explain that LLMs are **highly prompt‑sensitive**; small changes in a prompt can cause large differences in output【978162859489151†L688-L773】.
- Without prompt tuning, ChatGPT often generates **convoluted or irrelevant questions**【978162859489151†L246-L249】.
- **Incrementally adding specific instructions and providing a few in‑context examples** can improve question generation, but the effectiveness varies by task【978162859489151†L784-L807】.
- Use the emergency‑medicine study to illustrate how **uploading course materials into the GPT session (context injection)** improved relevance but still required expert review【728939386754298†L215-L235】.

#### Slide 4 – Guidelines for generating quality pre‑test questions
- **Start with a vetted test bank** or exemplar questions created by educators.
- Use **few‑shot prompting**: provide 2–3 examples of high‑quality items along with their learning objectives and rationales.
- Include the **course’s learning outcomes or curriculum topics** in the prompt so that AI aligns questions to them.
- Employ **retrieval‑augmented approaches** by linking the model to relevant course documents or uploading the material into a custom GPT; this reduces hallucinations and improves relevance.
- Adjust the **temperature** parameter to balance creativity and consistency; start low (0‑0.3) and increase only after the prompt works well【978162859489151†L215-L229】.
- Always **review and edit** AI‑generated items for factual accuracy, alignment, and cognitive complexity.

#### Slide 5 – Demo 1: Building a Pre‑test with Context
- Show a step‑by‑step demonstration using ChatGPT (or Gemini/Claude) with a *few‑shot* prompt:
  1. Present 3 exemplar questions with learning objectives and rationales.
  2. Ask the model to generate 5 new questions aligned with the same objectives.
  3. Inspect outputs for relevance, difficulty and alignment.
- Discuss how to iterate the prompt to fix problems.

#### Slide 6 – Demo 2: Rapid Diagnostic Analysis
- Upload anonymized pre‑test results (CSV) into ChatGPT or Gemini (Advanced Data Analysis).
- Ask the model to produce:
  - Distribution of scores and identification of low-performing LO’s.
  - List of students needing early support.
  - A high‑level narrative summary for teachers.
- Emphasise that using AI for analysis frees time for interpretation but that teachers must decide interventions.

#### Slide 7 – Demo 3: Responsive Feedback from Open‑Ended Work
- Provide 5‑10 anonymized student reflections or essays.
- Prompt the model to identify common misconceptions and suggest formative activities.
- Highlight that AI can cluster errors and create targeted practice items but **does not grade high‑stakes work**.

#### Slide 8 – Demo 4: Summative Synthesis & Course Improvement
- Upload final exam results and ask the model to:
  - Summarise performance by learning objective.
  - Identify patterns of strength/weakness.
  - Draft a course improvement plan (with human review).
- Reinforce the need to **avoid using LLMs for high-stakes grading**; use AI mainly for synthesis and planning.

#### Slide 9 – Comparing Accessible AI Tools
- **ChatGPT (OpenAI)**: Good at natural language generation and explanation; supports file uploads in advanced data analysis; widely used in education.
- **Claude (Anthropic)**: Strong at handling large context windows and open-ended writing tasks; good for analysing student writing.
- **Gemini (Google)**: Fast and integrated with Google Workspace; useful for quick analyses and summarisation.
- **Custom GPT or RAG**: When alignment is critical, create a custom GPT with uploaded course documents (syllabus, rubrics, test blueprints).  Retrieval‑augmented approaches reduce hallucinations and keep the model on-topic.

#### Slide 10 – Take‑Home Messages
- AI can **augment, not replace, teachers** in intentional assessment.
- For question generation, **context and prompt design are critical**.  Without them, AI often produces irrelevant or low‑quality items.
- Use AI to **speed up analysis and synthesis**, freeing teachers to focus on judgment and instructional decisions.
- **Always maintain human oversight**: verify AI‑generated questions, protect student data, and avoid high‑stakes grading with AI.

# Part 2: Practical Examples of AI-Driven Intentional Assessment

This section illustrates how AI can support the **Intentional Assessment** cycle: *Define Purpose $\rightarrow$ Gather Evidence $\rightarrow$ Analyze Data $\rightarrow$ Implement Intervention*. We present three scenarios: Predictive (before learning), Responsive (during learning), and Summative (after learning).

## Case 1: Predictive Assessment (Diagnostic)
**Goal:** Identify students' readiness and prior knowledge gaps before starting a new unit on *Linear Equations*.

### 1. Intentional Assessment (Design)
The teacher defines the prerequisite skills: *integer operations* and *simplifying algebraic expressions*.
*   **AI Role (Generation):** The teacher prompts AI to generate a 10-item diagnostic test focusing specifically on these common pitfalls, including "distractor" options that reveal specific misconceptions.
    *   *Prompt:* "Create a 10-question multiple-choice diagnostic test for 8th graders starting Linear Equations. Focus on prerequisites: integer arithmetic and combining like terms. For each question, provide a rationale for the correct answer and explain the misconception behind each distractor."

### 2. Data Analysis (Insight)
Students take the quick digital quiz. The teacher exports the results (anonymized) to CSV.
*   **AI Role (Analysis):** The teacher uploads the data to an AI tool (e.g., ChatGPT Advanced Data Analysis or Gemini).
    *   *Prompt:* "Analyze these test results. Group students into 3 tiers based on readiness. Identify the top 2 most common errors across the class."
    *   *Output:* AI reports that 40% of students struggle specifically with *subtracting negative numbers*, while *combining like terms* is generally understood.

### 3. Implement Intervention (Action)
*   **AI Role (Support):** Based on the analysis, the teacher asks AI for targeted materials.
    *   *Prompt:* "Create a 15-minute 'Bridge Activity' for the group struggling with subtracting negatives, using a number line visual approach. For the advanced group, generate a problem-solving task involving real-world linear modeling."
*   **Outcome:** The teacher starts the unit with differentiated support, preventing the "gap" from widening.

---

## Case 2: Responsive Assessment (Formative)
**Goal:** Monitor understanding and correct misconceptions *during* a week-long project on *Persuasive Writing*.

### 1. Intentional Assessment (Design)
Mid-week, students draft their "Thesis Statement and 3 Supporting Arguments." The teacher wants to check if arguments are logical and supported by evidence.
*   **AI Role (Generation):** The teacher uses AI to create a specific, single-point rubric for quick feedback.

### 2. Data Analysis (Insight)
The teacher collects 30 student drafts (digital text). Reading all of them in detail takes too long for immediate feedback.
*   **AI Role (Analysis):** The teacher pastes the drafts (in batches or via file upload) into an AI tool.
    *   *Prompt:* "Review these 30 thesis drafts against the criteria: 'Clear stance' and 'Logical support'. Do not grade them. Instead, summarize the 3 main patterns of weakness found in the class. List 3 examples of weak arguments (anonymized) and why they fail."
    *   *Output:* AI identifies that many students are stating facts rather than arguable opinions.

### 3. Implement Intervention (Action)
*   **AI Role (Support):**
    *   *Prompt:* "Draft a 5-minute 'Reteach Script' to explain the difference between a Fact and an Opinion in a thesis statement. Create a 'Fix-It' activity where students turn 5 factual statements into arguable claims."
*   **Outcome:** The teacher delivers the mini-lesson immediately the next day. Students revise their drafts *before* writing the full essay, saving time and frustration.

---

## Case 3: Summative Assessment (Evaluative)
**Goal:** Evaluate mastery of the *Photosynthesis* unit and improve the course for next year.

### 1. Intentional Assessment (Design)
The teacher administers the final exam, which includes both MCQs and a short explanation diagram.
*   **AI Role (Generation):** AI assists in creating a balanced test blueprint (20% Knowledge, 40% Application, 40% Reasoning) to ensure validity.

### 2. Data Analysis (Insight)
Post-exam, the teacher has raw scores and item-level data.
*   **AI Role (Analysis):**
    *   *Prompt:* "Analyze the item difficulty and discrimination for this exam. Which learning objective had the lowest average score? Is there a correlation between students who completed the optional study guide and their exam scores?"
    *   *Output:* AI highlights that students performed well on "Inputs/Outputs of Photosynthesis" but failed questions related to "Cellular Respiration connection" (LO #4).

### 3. Implement Intervention (Action - Future Focused)
*   **AI Role (Support):**
    *   *Prompt:* "Propose a modification to the lesson plan for LO #4 (Cellular Respiration connection) for next semester. Suggest an analogy or hands-on activity to make this abstract concept clearer."
*   **Outcome:** The teacher updates the curriculum map for the next cycle. The assessment data is used not just to grade students, but to *grade the instruction*.

