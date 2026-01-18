I want you to understand the places list and details of the app and plan how to implement it properly - the shared kotlin logic, firestore fetch (lazily on every app open on background after more important info is fetched and on forced pull-refresh) and iOS-only UI implementation utilizing that kotlin logic.
The inspiration is to be taken from flutter project located in ~/Documents/xcamp_app
The design should be modern, minimalistic, and aligning to latest design standards (ios 26 - liquid glass)
The tab should be visible in full mode only.
Enable it for debugging purposes only for now (override the code, but keep the logic commented out)