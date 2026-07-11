# page content
ToDos and next steps, Improvements

IMPROVEMENT:

QUESTIONS
- what does the time frame of the program look like? When will the main loop be repeated?
- what if one connection (node) is defective? (e.g. orientation detection is not working) -> does everything freeze up then?


ich darf nicht 1 child 3 mal pollen und dann das andere danach sondern muss 1 child pollen dann warten dann das andere pollen dann wieder das erste pollen etc 

NEXT STEPS
- individual payload/sync for mehscat if error in baseplate 
- error messages/message window also in browser
- if FFF of child - break feedback polling sequence and return FFF also to parent -> if baseplate receives FFF, knows to restart the feedback sequence again
- threejs buffer error (wenn ein payload kommt und der andere noch nicht verarbeitet ist, gibt es einen error)
- threejs appearance
- threejs maybe error evaluation with serial monitoring window 