# Dental Connect

Dental Connect is a Rails candidate onboarding app for a dental recruitment flow. Candidates can upload a CV, let the app prefill profile fields, review the extracted information, and save a completed candidate profile.

## Tech Stack

- Ruby 3.2.4
- Rails 8.1.3
- PostgreSQL
- Stimulus
- Bootstrap 5
- Active Storage
- RSpec

## Setup

Clone the project and install dependencies:

```bash
cd /Users/sidduhadapad/workspace/Personal_repos/dental_connect
bundle install
yarn install
```

Create and prepare the database:

```bash
bin/rails db:prepare
```

Seed default languages and dental skill options:

```bash
bin/rails db:seed
```

Build Bootstrap CSS:

```bash
yarn build:css
```

## Running The App

Start Rails:

```bash
bin/rails server
```

Open:

```text
http://127.0.0.1:3000
```

The home page has a link to start onboarding. The CV upload page is also available directly at:

```text
http://127.0.0.1:3000/candidate_onboarding/new
```

## Development CSS

When editing Bootstrap or custom styles, run the CSS watcher in a second terminal:

```bash
yarn build:css --watch
```

If `bin/dev` works on your machine, you can use it instead:

```bash
bin/dev
```

## Running Tests

This project uses RSpec.

Run all specs:

```bash
bundle exec rspec
```

Run one spec file:

```bash
bundle exec rspec spec/services/cv_parser_spec.rb
```

Run a specific example by line number:

```bash
bundle exec rspec spec/models/candidate_profile_spec.rb:5
```

## CV Upload Notes

Supported CV upload formats:

- PDF
- DOC
- DOCX

The default max upload size is 25 MB. Override it with:

```bash
CV_MAX_FILE_SIZE_MB=50 bin/rails server
```

Uploaded CV files are stored by Active Storage in local development.

Do not commit uploaded files from `storage/` to git. Only keep `storage/.keep` if present.

## Useful Commands

```bash
bin/rails routes
bin/rails console
bin/rails db:migrate
bin/rails db:seed
bundle exec rspec
yarn build:css
```
