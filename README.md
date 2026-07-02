# mamo_schedule

## Usage

`flutter run --dart-define-from-file=config.json`


## Planning

UI List:
- Schedule: past, current, future (including icons, colors, room, metadata, etc)
- Day type
- School
- Username
- Date
- Period timings (for that day type)
- Current time (per period basis)
- Current widget: exact timing (per second)

Questions:
- Do classes get assigned a period? or periods assigned a class? What should the UI list use to keep track of rendering?
- How can i store stuff in memory (ex. in a singleton class or an instance or smth) and not have to retrieve from file on re-render?
- For a different schedule, should I have a different instance of the state class (and a different widget?) or should it be treated as the same widget, with a data update. 
- Add free period / no classes scheduled currently for a period.
- Special days? Dept PD
- See questions on the diagram doc? Or other implementation doc? 
- Timers - what widgets have different timers? How do they perform?
- What does current memory requirements / latency requirements look like for the app? 

## ToDo:
- Toggle between schedules / users
- Add error handling (file errors, can't connect errors, etc) and logging / bug reports 
- Break up get_calendar
    - Deal with custom regex?
- What parts of Flutter project to commit to github?
- Utils.dart - fix the "??" thing
- Utils.dart - retry logic
- Calendar stuff - make calendar dates independent of time (ig set minutes to zero)
- Select icon for class. 
- How to add differentiation between years? 
- Add no classes today?
- Debug memory usage
- Add progress bar to currently occuring period. 
- Add iPhone widgets / apple watch compatability
- What happens in between periods?
- Add support for merging periods by saying PE / LAB
- Add an option to track the most recently opened / activated schedule. 
- Add expiry functionality for config & calendar
- Add regex to scheduleconfig thing.
- Probably add something for exception days into config.
- Migrate to singleton pattern for schedule config rather than reading from disk?

Settings page:
- dark mode selector
- developer (urls and stuff)
- refresh schedule