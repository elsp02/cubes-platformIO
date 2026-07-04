# page content
ToDos and next steps, Improvements

IMPROVEMENT:
- sizeof instead of LEN?
- simplify/loop cmd/ack process
- reorganize wait_for_valid_upstream_count

QUESTIONS
- what does the time frame of the program look like? When will the main loop be repeated?
- what if one connection (node) is defective? (e.g. orientation detection is not working) -> does everything freeze up then?


ich darf nicht 1 child 3 mal pollen und dann das andere danach sondern muss 1 child pollen dann warten dann das andere pollen dann wieder das erste pollen etc 

NEXT STEPS
- individual payload/sync for mehscat if error in baseplate 