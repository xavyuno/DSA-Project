# Changelog:
- Pulled from assignment1_ready(ish) branch
- Reorganized files according to the readme file from the original branch
- Added ' next to certain values within some ballerina files as those were ballerina syntax values used (they conflicted with the ballerina's language)
- Added web/ folder under: root/part-a-rest-api/web/ (along with several html, css and JavaScript files as it's children
- deleted test folder under client/

# Usage:

## STEP 1 HOW TO GET TO THE DIRECTORY

Option 1: (via file explorer)
- When in the file explorer: root/part-a-rest-api/
- click on path within the explorer and replace the location with cmd
- press enter

Option 2: (via command prompt)
- Open command prompt
- enter: cd (path to root/part-a-rest-api/)
- press enter

Option 3: (via file explorer but easier)
- Right click anywhere while in the folder: root/part-a-rest-api
- Click on open with terminaL

## STEP 2 WHILE IN COMMAND PROMPT:
- bal build
- bal run

## STEP 3 OPENING THE COMMAND LINE INTERFACE OR WEB INTERFACE
### refer to step 1 to get to /root/part-a-rest-api/web/
  
OPTION 1: (with ballerina)
- While in command prompt open type
- bal build
- bal run

OPTION 2: (with vs code)
- while in the web directory right click anywhere to open with vs code
- navigate to extension
- search 'live server'
- download the extension
- navigate to index.html
- on the bottom right click on 'Go Live'

OPTION 3: (via python script)
- This is not explicitly part of the project but to make connecting to the web page more easier without the need of third party software like vs code
- open 'server.py'
- open index.html