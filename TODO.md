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

- ~~proper formating of text / newlines ??~~
- ~~fix bad fonting after some @ mentions~~
- ~~exchange sqflite with isar DB?~~
- ~~use dart_ndk lib~~
- ~~gossip/outbox model for feed~~
- ~~show in which relays a note was loaded from~~
- ~~user Follow feed relays write to DB to improve startup time in outbox model~~
- ~~register nostr: in android so that nostr links give yana option as an app to open~~
  - ~~handle nostr:nevent1 (need to somehow load the event)~~
- ~~check why some replies appear on posts~~
- ~~sign verify~~
- ~~nip05~~
- ~~relay setting of read/write~~
- ~~https://docs.flutter.dev/ui/navigation/deep-linking~~
- ~~subscription on profile/DMS/notifications should be kept open to receive updates from WS - REFACTOR logic of later loading & caching metadata~~
- ~~verify signature ASYNC!?!?!?!~~
- ~~notifications FIX UI/UX~~
- ~~new posts/replies appear in layered popup with avatars~~
- ~~persist notes from feed for faster startup~~
- ~~include tags/communities in feed filter?!~~
- ~~FIX LOGOUT/SWITCH accounts screens~~!
- ~~don't load stuff in tabs that are not visible!!!!~~
- ~~on back from background, reconnect relays + resubscribe to all existing subscriptions~~
- ~~blacklist for relays (NIP-51 PR)~~

===== v0.12
- nip-51 PRIVATE relay lists!
- mute list use nip51
- use inboxForReactions for broadcasting reactions to inbox relays
- show in account list, which ones are read-only
-
- save notification events to cache DB
- FIX SOCKETS CONNECTION PROBLEMS!!!!!!!!!!!!!!!
- NIP07 browser for some web apps!?
- choose to which relays / lists to broadcast on new note (bounty)
- make thread detail subscription of new replies work
- make reactions live again with subscriptions or some other way 
- show progress of broadcasting note on relays
- when blocking make the note disappear
- include relay hints on nevent and stuff (bounty)
- handle event deletions coming from relays, should delete in cache
- don't validate signature for events cached on DB
- when following someone new and gossip=1, ask confirmation for that user's relay list acceptance, and eventual blocking some relays
- too much notifications of reactions to replies of replies of post where you're tagged
- WTF nwc needs fresh relayManager for get_info/get_balance??

- ===== v0.13
- show used data of background service in KBs
- after adding follow, recalculate relaySet for gossip
- better android/ios/linux badges on web version login screen (anchor links to readme.md for IOS/linux)
- garbage collection of webSockets not used since X (for reactions)
- animated screen ASAP after splash
- isar v4 for web
- load more on big posts

- detect new followers by comparing in background previous followers list and generating new notification
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
- greenlight LN NODE

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
- remember eventMemBox for Posts/Replies on DB (on just timestamp lastRead) so badge counter persists between app restarts
- get notifications in background for all accounts
- floating icon (+) on DMS sends new msg to CHOOSE
- optimize zaps/followed downloading (caching on db) on background 
- Auto-Translate/detect language note contents using something else than google services 
- mark all DMs as read feature
- submit to f-droid
- badges also on drawer when in tablet mode
- add signing keys to google app store using non-KYC method
- not your relay list - improve looks with icons and stuff (not so easy)
- in thread view handle better zaps instead of some weird bitcoin component
- show common followers/followees
- try to load images using Isolate and compute, so that feed scrolling does not freeze while loading images
- add SystemMouseCursors.click to everything that is clickable for web version
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


- make promo video:
  - music https://soundcloud.com/ben-murray-smith/spectrum
  - “It's very attractive to the libertarian viewpoint if we can explain it properly. I'm better with code than with words though.” ― Satoshi Nakamoto
  - free Ross
  - "We the Cypherpunks are dedicated to building anonymous systems"
  - free Assange
  - "...but now I work for the public" - Snowden
  - "Is this the official nostr channel? No, nothing is official - Fiatjaf"
  - "WikiLeaks has kicked the hornet’s nest, and the swarm is headed towards us." ― Satoshi Nakamoto
