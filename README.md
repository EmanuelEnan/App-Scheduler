# App Scheduler

This is a scheduler app where user can select an app from their device's apps and schedule a date and time with the options of repetations( daily, weekly, once, custom etc.). The app will then launch automatically at the user's selected schedule. 

User can edit the schedule later as they wish and the app will launch on the updated schedule. If user choose two or more apps on the same schedule, a conflict warning will show up but the apps will still launch simultaneously. 

To achieve this functionality, I've used the power of platform channels through WorkManager. Also used local persistance to store the selected schedule and other data seamlessly.
