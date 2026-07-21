# PRD

PRD - Candidate Onboarding with CV Upload

1. Overview

We need a new candidate onboarding flow for a dental recruitment platform. The onboarding should be built in two steps:

1. Upload CV

2. Review and complete profile

The platform should preferably be built in Ruby on Rails preferably, or at least the onboarding module should be designed in a way that fits a Rails application structure.

The main purpose is to reduce manual input for candidates. The candidate uploads a CV, the system extracts as much relevant information as possible, and then the candidate only needs to check, correct, and complete missing fields.


2. User Flow

Step 1 - CV Upload

The candidate lands on the onboarding page and sees a simple upload screen.

Suggested text:

Upload your CV. We will automatically fill in as much of your candidate profile as possible. You can review and edit everything before saving.

Requirements:

* Candidate can upload a CV.

* Supported file types:

    * PDF

    * DOC

    * DOCX

* Maximum file size should be configurable.

* Suggested max size: 25 MB or higher, depending on server/storage setup.

* After upload, the system extracts relevant candidate data from the CV.

* While the CV is being processed, show a loading state.

* If the CV cannot be parsed, the candidate should still be able to continue manually.


Step 2 — Review and Complete Profile

After the CV has been processed, the candidate sees a profile form that is already prefilled as much as possible.

The candidate should be able to:

* Review all prefilled data.

* Edit all data.

* Complete missing fields.

* Add extra education records.

* Add extra work experience records.

* Select skills.

* Save the final profile.

Fields that were not found in the CV should remain empty and be clearly visible as fields that still need input.

Fields that were extracted from the CV but may be uncertain can be marked with a small label such as:

* "Please check"

* "Extracted from CV"

* "Missing"

Keep the interface simple. Do not overbuild the UI.


3. Candidate Profile Fields

The onboarding form should collect the following candidate information.

3.1 Personal Details

Field	Type	Required	Can be extracted from CV

First name	Text	Yes	Yes

Last name	Text	Yes	Yes

Email	Email	Yes	Yes

Phone number	Text	Yes	Yes

City / place of residence	Text	Yes	Yes

Country	Text/select	Should	Yes

Languages	Multi-select	Yes	Yes

Notes:

* Phone number should allow international formatting.

* Languages should ideally support language level if available, for example B2, fluent, native, etc.


3.2 Job Preferences

Field	Type	Required	Can be extracted from CV

Desired job function	Single select	Yes	Partly

Preferred regions	Multi-select	Yes	No / partly

Maximum travel time	Number	Yes	No

Transport type	Multi-select	No	No / partly

Search status	Single select	Yes	No

Reason for looking	Text	No	No / partly

Search status options:

* Active

* Passive

* Inactive

Transport options:

* Bike

* Scooter

* Public transport

* Car

The job function should use the platform’s existing fixed job categories. Do not allow unlimited free-text job titles as the primary job function, because this data is needed for matching.

Example job categories:

* General dentist

* Dental hygienist

* Dental assistant

* Prevention assistant

* Paro-prevention assistant

* Orthodontic assistant

* Front-office / receptionist

* Practice manager

* Dental technician

* Specialist


3.3 Employment and Compensation

Field	Type	Required	Condition

Desired employment type	Multi-select	Yes	Always

Desired gross salary	Number	Conditional	If employed

Desired percentage	Number	Conditional	If self-employed / revenue-based role like column below

Average daily revenue	Number	Conditional	Mainly dentists / hygienists / specialists / prevention assistent

BIG registration status	Select	Conditional	For dentists/specialist only

BIG number	Text/number	Conditional	If BIG registered

Years of combined dental experience	Number	Yes	Always

Employment type options should use the existing platform values.

Suggested BIG registration options:

* BIG registered

* In progress

* Under supervision

* Not applicable

Logic:

* If the candidate chooses an employed role, show salary field.

* If the candidate chooses a self-employed or percentage-based role, show desired percentage.

* If the function is dentist, dental hygienist, or specialist, show BIG registration fields.

* If the function is assistant, receptionist, technician, or practice manager, hide BIG registration by default.


3.4 Education

The candidate must be able to add one or more education records.

Fields per education record:

Field	Type	Required

Institution	Text	No

Study / course	Text	Yes

City and country	Text	No

Level	Select	No

Start date	Date	No

End date	Date	No

Level options:

* MBO

* HBO

* Bachelor

* Master

* Doctor

* Course

The CV parser should try to extract education history and prefill one or more education records.

The candidate must be able to:

* Add education

* Edit education

* Remove education


3.5 Work Experience

The candidate must be able to add one or more work experience records.

Fields per work experience record:

Field	Type	Required

Job title	Text	Yes

Company name	Text	Yes

Responsibilities	Textarea	No

Start date	Date	No

End date	Date	No

Current job	Boolean	No

The CV parser should try to extract work experience history.

Important:

* Do not only support one previous employer.

* CVs often contain multiple jobs.

* Store work experience as separate records if possible.


3.6 Skills

Skills should be shown based on the selected job function.

The platform should support different skill groups, for example:

Function group	Example skills

Dentist	Endodontics, restorative dentistry, pediatric dentistry, surgery, aligners

Dental hygienist	Periodontology, prevention, scaling, patient education

Dental assistant	Chairside assistance, sterilization, orthodontics, prevention

Front-office	Planning, phone handling, invoicing, patient communication

Practice manager	Team management, scheduling, HR, practice operations

Dental technician	Prosthetics, CAD/CAM, crown and bridge work

Requirements:

* Skills must be selectable by the candidate.

* The CV parser should try to detect relevant skills.

* Skills from the CV should be matched to the existing platform skill list where possible.

* Unknown skills may be stored as free-text suggestions for recruiter review.


3.7 Availability

Field	Type	Required

Available working days	Multi-select	Yes

Available from	Date	Yes

Notice period	Number/text	No

Working day options:

* Monday

* Tuesday

* Wednesday

* Thursday

* Friday

* Saturday

* Sunday


3.8 Additional Information

Field	Type	Required

Motivation for employer	Textarea / rich text	No

Internal notes for recruitment team	Textarea	No

Reason for looking for something new	Text	No

The system may generate a short suggested professional summary based on the CV, but the candidate must always be able to edit it before saving.

The internal notes field should only be filled in manually by the candidate.


4. Conditional Form Logic

The form should not show all fields at once if they are not relevant.

Required conditional logic:

Function-based logic

If selected function is dentist, dental hygienist, or specialist:

* Show BIG registration.

* Show average daily revenue.

* Show desired percentage if self-employed or percentage-based.

* Show relevant clinical skills.

If selected function is dental assistant:

* Hide BIG registration.

* Show assistant-related skills.

If selected function is front-office:

* Hide BIG registration.

* Show front-office skills.

If selected function is practice manager:

* Hide BIG registration.

* Show management-related skills.

If selected function is dental technician:

* Hide BIG registration.

* Show dental technology skills.


Employment-based logic

If employment type includes employed:

* Show desired salary.

If employment type includes self-employed / freelance / percentage-based:

* Show desired percentage.


5. CV Parsing Requirements

The CV parser should extract candidate data and prefill the onboarding form.

The developer can choose the technical implementation, but the parsed result must be structured enough to map to the platform’s profile fields.

The parser should try to extract:

* Name

* Email

* Phone number

* City / location

* Country

* Languages

* Current or recent job title

* Relevant dental job function

* Education history

* Work experience history

* Skills

* BIG number or BIG status if present

* Years of experience if clearly available

* Professional summary if useful

Important rules:

* The system should not invent missing information.

* If the CV does not contain a value, leave the field empty.

* The candidate must always review and confirm the data before the profile is saved.

* Uncertain extracted fields should be marked for review.

* The parser should support Dutch and English CVs at minimum.

* Ideally, the parser should also handle common European dental CV formats.

A full technical AI output schema is not required in this PRD. The developer can decide the exact internal format, as long as the result can reliably prefill the form fields.


6. Data Model Suggestion for Ruby on Rails

Preferred implementation: Ruby on Rails.

Suggested models:


User

CandidateProfile

CandidateDocument

Education

WorkExperience

Skill

CandidateSkill

Language

CandidateLanguage


Suggested relationships:


User

  has_one :candidate_profile


CandidateProfile

  belongs_to :user

  has_many :candidate_documents

  has_many :educations

  has_many :work_experiences

  has_many :candidate_skills

  has_many :skills, through: :candidate_skills

  has_many :candidate_languages

  has_many :languages, through: :candidate_languages


Suggested document model:


CandidateDocument

  belongs_to :candidate_profile

  has_one_attached :file

  document_type: cv

  original_filename

  content_type

  file_size

  parsed_at

  parsing_status


Suggested parsing statuses:


pending

processing

completed

failed


The CV should preferably be stored using Active Storage.

CV parsing should preferably run in a background job, for example:


ParseCandidateCvJob


This prevents the form from timing out while the CV is being processed.


7. Main Screens

7.1 CV Upload Screen

Contains:

* Short explanation

* Drag-and-drop upload field

* Supported file type information

* Upload button

* Processing state after upload

* Error message if parsing fails

* Option to continue manually if parsing fails

Suggested button labels:

* “Upload CV”

* “Analyze CV”

* “Continue manually”


7.2 Profile Review Screen

Contains sections:

1. Personal details

2. Job preferences

3. Employment and compensation

4. Education

5. Work experience

6. Skills

7. Availability

8. Additional information

Each section should be editable.

The candidate should be able to save the profile only when the required fields are valid.


8. Validation Rules

Field	Validation

Email	Must be a valid email address

Phone number	Must allow Dutch and international formats

CV	PDF, DOC, DOCX

CV size	Configurable, suggested 25 MB or higher

Desired function	Required

Preferred region	At least one required

City / place of residence	Required

Maximum travel time	Required, numeric

Employment type	At least one required

Years of experience	Numeric, minimum 0

Salary	Numeric, only shown when relevant

Percentage	Numeric, 0–100

Average daily revenue	Numeric

BIG number	Only required if BIG status is registered

Working days	At least one required

Available from	Valid date

9. Privacy and Security

Keep this practical for the first version.

Requirements:

* CV files should not be publicly accessible.

* Only the candidate and authorized admins/recruiters should be able to view the CV.

* The candidate should accept a simple consent checkbox before uploading or saving.

* The developer may choose the most suitable privacy implementation.

* Do not expose raw AI/parser output to candidates.

* Store only the data needed for recruitment and profile matching.

Suggested consent text:

I agree that my CV and profile information may be processed to create and improve my candidate profile.


10. Notifications and Follow-up

After successful profile submission:

* Save the candidate profile.

* Save the uploaded CV.

* Save education records.

* Save work experience records.

* Save selected skills.

* Notify the admin/recruitment team.

* Optionally trigger a webhook for automations.

A webhook is useful but not mandatory for the MVP.