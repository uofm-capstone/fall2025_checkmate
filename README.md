# README

# TAG Team Spring Semester Documents
* Timesheet: https://docs.google.com/spreadsheets/d/1Mp5RXmfIqL2ilEI71O-yjVjz8YulbK6ScH4siZxfafs/edit?usp=sharing
* Team Contract: https://docs.google.com/document/d/1DNdxrKrqxv0f3FG1GDt5yBjK3IdsK1GSwnrV8zVkqxE/edit?usp=sharing
* Client Meeting Notes: https://docs.google.com/document/d/1-AIM5DQK8lllqFsF41cocEPRypCkBmVKW4QHCnBBrK0/edit?usp=sharing
* Sprint 2 Demo Day ppt: 
# Tool-Assisted Grading (TAG)
TAG is a web-based application designed to assist professors and teaching assistants in evaluating and grading students. With this application, you can manage grading student an client survey survey's served by Qualtrics (and more features to come).

This application is built on Ruby on Rails web framework.

## Prerequisites
* Ruby - v3.2.1
* Node.js - v19.8.1
* PostgreSQL - latest
* [Optional] Ruby version manager (rvm or rbenv if using MacOS or Linux)

# Installating Software
## Windows or Linux/macOS
#### NOTE: Be sure to download and install the corresponding operating system supported files.
1. Download and install [Ruby](https://www.ruby-lang.org/en/downloads/releases/)
2. Download and install [Node](https://nodejs.org/en/download/)
3. Download and install [Postgress](https://www.postgresql.org/download/)

## Using the software
1. Create a workspace folder to download your application.
2. Navigate to your new workspace directory.
3. Clone the repository using the following command: ```git clone git@github.com:mrhosier42/tag.git```
4. Enter the Project Directory: ```cd tag```
5. Install Bundler (if not installed): ```gem install bundler```
6. Install Ruby Gems: ```bundle install```
7. Install JS Dependencies: ```yarn install```
   - If Yarn is not installed:
     - Macos: If you have Homebrew installed: ```brew install yarn```
     - Windows (using WSL w/ Ubuntu): ```npm install --global yarn```
     - Linux: ```npm install --global yarn```
8. Install rails: ```gem install rails```
9. Set Up Database: ```rails db:create```
10. Run Migrations: ```rails db:reset db:migrate```
11. Start rails server: ```rails server``` (or ```rails s``` for short)
12. Access the app: Open ```localhost:3000``` into your browser.

## Navigation to survey's:
1. Sign up with a new account.
2. Create a new semester.
3. Load client and student survey data.
4. Select a sprint and semester.
5. View the page team you want to review.


## GitHub Analytics - OctoKit API
This application fetches GitHub commit history on a per-contributor and per-sprint basis, presenting it in an easy-to-digest graphical interface. It's designed to streamline the process of monitoring and analyzing commit activities over specific time periods.
1. #### Obtaining a Personal Access Token (PAT):
   * To utilize the [OctoKit API](https://octokit.github.io/rest.js), you first need to create a Personal Access Token (PAT). This application uses a [fine-grain token](https://github.com/settings/tokens). Please follow the instructions on GitHub to generate your token.

2. #### Configuring the Application:
   * Locate the octokit.js file in your application directory. Replace the placeholder in the file with your newly generated PAT. This setup will allow asynchronous fetching of data.

Note: While there are alternative authentication methods that avoid personal tokens, this implementation currently relies on the PAT system.


## Troubleshooting:
(Linux - Ubuntu)
#### bundle install issue
* If you are seeing this message in your terminal: "An error occurred while installing pg (#.#.#), and Bundler cannot continue.", run the command below:
1. You'll need to install libpq or postgresql client package like so:
   (a) ```sudo apt install libpq-dev```


# History and Progress
This app is a continuation of the development of the previous capstone team and GA's that have worked on this app.
This app was upgraded from an old version of rails framework (6.1) and ruby language (2.7), the reason for the upgrade was to make the app compaitble to run on Mac M1 chips, which were not supported at the time. I've also revamped every single page to make it more modern, removed extra cluttered/unucessary pages and merged those pages functionality into the relevant page for seamless access. I've also fixed countless bugs and overhauled some of the existing features, such as the navbar content (now a dropdown), among other things.

[Previous Repo](https://github.com/amyshannon/capstoneApp)


You can find three different versions, if you would like to see the changes made over time. Documentation will also be provided in this repo if you would instead prefer to read version 1 to 3 changes and improvements.
