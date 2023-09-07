// THIS FILE WILL PREVENT COMPILE TIME ERRORS,
// WHICH OCCURS BECAUSE OF PLATFORM DEPENDENT IMPORTS...

export 'js_helper_mobile.dart' // By default
if (dart.library.js) 'js_helper_web.dart'
if (dart.library.io) 'js_helper_mobile.dart';

/// The compiler will then say something like this:
/// Let’s export 'js_helper_mobile.dart' By default,
/// but if the "dart.library.js" is available, export 'js_helper_web.dart'.
/// But hey, if "dart.library.io" is available, export 'js_helper_mobile.dart'!