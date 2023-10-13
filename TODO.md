# Roadmap

- ~~auto hide bars when scrolling~~
- ~~click on home icon scroll to top~~
- ~~fix nip05 _@<domain>~~
- ~~on new notes, show icons (like twitter/primal)~~
- ~~add robohash placeholders~~
- ~~reorganize navigation: notifications/search/communities/DM~~
- ~~Dockerfile with web server ready to launch~~
- ~~run web version on https://yana.fmar.link~~
- ~~store private Key in securedStorage~~
- ~~replace relays numbers with search, move numbers to drawer~~
- ~~fix zaps amounts in notes~~
- ~~add theme icon on drawer for quick switching of dark/light theme~~
- ~~get relays list immediately after login~~
- ~~some kind of loader when click Login~~
- ~~linux AppImage build~~
- ~~fix loader on web~~
- ~~filter out new posts from replies~~
- ~~in thread view decrease the tree branches padding to allow more space for content~~
- ~~badges when something new in home/notifications~~
- ~~rephrase keys backup screen~~
- ~~relays icons~~
- ~~relays loose connection and don't reconnect after some time~~
- ~~close images clicking anywhere~~
- ~~DMS from followed should not be on request tab~~
- ~~badges when something new in DMS~~
- ~~remember eventMemBox (timestamps) with badge numbers between app restart~~
- ~~on login screen add get it on github~~
- ~~on fresh start (empty DB), mark all as read.~~
- ~~try to reduce as much as possible apk size~~
- ~~zaps for prism@yana.do (Lnbits)~~
- ~~fix saving pictures to phone~~
- ~~pull notifications / background service~~
- ~~get metadata from not in contact list for notification metadata~~
- ~~info on someones profile if they follow you~~
- ~~fix image/video preview setting (is false / not taken into effect)~~
- ~~notifications/replies of reactions/likes (include post and if a reply the parent)~~
- ~~in thread view handle better zaps instead of some weird bitcoin component~~
- ~~login with npub~~
- ~~login with extension on web~~
- ~~text color on light theme login screen YANA + input is dark~~
- ~~signEvent~~
- ~~Nostr Wallet Connect with balance~~
   ~~input URI (textfield | QR SCANNER)~~
  ~~show balance~~
  ~~alby new nwc -> deep linking~~
  ~~pay_invoice~~
- ~~ZAP loading icon until response/confirmation of zap receipt~~
- ~~mention livesearch editor without popup~~
- ~~STOP followers/zaps events from blocking the relay, when navigate away from that profile~~


v0.12
- gossip
  - blacklist for relays
  - lib 
- ~~try exchange sqflite with isar DB?~~
- isar v4 for web

- user Follow feed relays write to DB to improve startup time in outbox model
- register nostr: in android so that nostr links give yana option as an app to open
- persist notes from feed for faster startup
- better android/ios/linux badges on web version login screen (anchor links to readme.md for IOS/linux)

v0.13

- login by searching some user by name/displayName

- broadcast NIP-65 kind=10002 to as many as possible
- CORS on yana.do using imgproxy (darthsim/imgproxy)
- wallet connect separated to each key/account
- solve floating icon in tablet mode above buttons
- i18n crowdin.com using github actions

- Wallet list of transactions    
- Wallet balance in FIAT (choose currency) from coingecko/kraken?

- Mutiny NWC Wallet
- Current.io NWC Wallet
- LndHub Wallet

- WebLN for web: https://github.com/aniketambore/flutter_webln


- nip19 nprofile
- custom zap amounts
=======================
- reply position on thread when linking from outside is wrong
- fast secp256k1 verify signature for web JS
- NIP-78 preferences and messages read state
- separate posts from replies on profile
- update service check for new release from github
- login with nip05
- login with mnemonic
- 
- remember eventMemBox for Posts/Replies on DB (on just timestamp lastRead) so badge counter persists between app restarts
- 
- get notifications in background for all accounts
- make sure background service starts after device reboot
- floating icon (+) on DMS sends new msg to CHOOSE
- subscription on profile/DMS/notifications should be kept open to receive updates from WS - REFACTOR logic of later loading & caching metadata
- optimize zaps/followed downloading (caching on db) on background 
- relay setting of read/write
- Auto-Translate/detect language note contents using something else than google services 
- https://docs.flutter.dev/ui/navigation/deep-linking
- mark all DMs as read feature
- submit to f-droid
- badges also on drawer when in tablet mode
- add signing keys to google app store using non-KYC method
- not your relay list - improve looks with icons and stuff (not so easy)
- in thread view handle better zaps instead of some weird bitcoin component
- show common followers/followees
- try to load images using Isolate and compute, so that feed scrolling does not freeze while loading images
- add SystemMouseCursors.click to everything that is clickable for web version
- move reposts from replies to posts? maybe new tab only for reposts?
- https://pub.dev/packages/objectbox
- integration with https://github.com/greenart7c3/Amber
- long posts should be cut and have "show more"
- followers/following list more condensed
- Database offline check
- sort following/followers list by most recent
- add search to following/followers
- only use tablet second view if horizontal tablet
- fix zooming of pictures and X position
- umbrel store package with web client
- when new user with no following, suggest jack, fiatjaf and others
- make it work on iOS/MacOS
- try https://pub.dev/packages/flutter_rust_bridge for background loading of new events
