<img align="right" src="./assets/imgs/logo/logo.png" width="100px" />

# yana - Yet Another Nostr Application

## Motivation
Why yet another client/app when there are so many already being developed?

Current mobile native nostr clients suffer from one of the following:
- UI not responsive enough in older than 1-2 years phones (Amethyst, Plebstr, Nostros, Plasma)
- lack of a true FOSS community with lots of contributors being welcomed and encouraged to participate (Primal)
- not multi-platform (Damus, Nozzle, Amethyst, Nostur)

The objective of this project is neither fame, glory nor financial rewards.\
My main motivator to spend time on this is to have a nostr client which I personally find the most pleasant to use on a everyday case.\
Also to learn more deeply about [Nostr](https://github.com/nostr-protocol/nostr) and FOSS project development.\
Having said that, I will apply for https://opensats.org/ initiative and consider other similar donations initiatives.

## Installation

It will not be constrained to imperialist distributors, such as Apple Store or Google Store.\
The released app will be distributed as standalone packages for each OS and can be included in free Stores ([F-Droid](https://f-droid.org), [Obtainium](https://github.com/ImranR98/Obtainium), etc).\
Or you can just download them from the release's page and install it directly without a third-party distributor.

[<img src="https://github.com/machiav3lli/oandbackupx/blob/034b226cea5c1b30eb4f6a6f313e4dadcbb0ece4/badge_github.png"
alt="Get it on GitHub"
height="80">](https://github.com/frnandu/yana/releases)

### - Android

Install Apk file from releases.\
*I strongly recommend [Obtainium](https://github.com/ImranR98/Obtainium) for keeping up-to-date with new releases.*

### - iOS

*Only by sideloading the **.ipa** file (I haven't tested it because I don't use apple devices, if somebody can confirm that it works would be great, just let me know).*

### - Web

You can run your own web version using docker

    docker run -d --name yana -p 8080:80  fmar/yana

And then go to https://127.0.0.1:8080

You can also check out my hosted version at https://yana.fmar.link \
Don't use your private keys there since it still is missing [NIP-07 login/sign with extension](https://github.com/frnandu/yana/issues/3).\
Generate a new one for testing.\
[Soon](https://github.com/frnandu/yana/issues/5) there will be possibility of login with public key.\
[Planned](https://github.com/frnandu/yana/issues/34) also an Umbrel Store package so it is simple to install and run it for umbrel users 

### - Linux
Run Appimage file
or install deb file from releases:

    sudo dpkg -i <deb-file>

*Snap comming soon*

### - Windows
*Comming later*

### - MacOS
*Comming later*

## Current Features + Roadmap

- [x] Event Builders / WebSocket Subscriptions ([NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md))
- [x] Home Feed
- [x] Notifications Feed
- [x] Global Feed
- [x] Replies and mentions ([NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md))
- [x] Reactions ([NIP-25](https://github.com/nostr-protocol/nips/blob/master/25.md))
- [x] Reposts ([NIP-18](https://github.com/nostr-protocol/nips/blob/master/18.md))
- [x] Image/Url Previews
- [x] View Threads
- [x] Private Messages ([NIP-04](https://github.com/nostr-protocol/nips/blob/master/04.md))
- [x] User Profiles (edit/follow/unfollow - [NIP-02](https://github.com/nostr-protocol/nips/blob/master/02.md))
- [x] Bech Encoding support ([NIP-19](https://github.com/nostr-protocol/nips/blob/master/19.md))
- [x] Reporting ([NIP-56](https://github.com/nostr-protocol/nips/blob/master/56.md))
- [x] Block/Hide User
- [x] User/Note Tagging ([NIP-08](https://github.com/nostr-protocol/nips/blob/master/08.md), [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md))
- [x] Zaps (private, public, anon, non-zap) ([NIP-57](https://github.com/nostr-protocol/nips/blob/master/57.md))
- [x] Created_at Limits ([NIP-22](https://github.com/nostr-protocol/nips/blob/master/22.md))
- [x] Event Deletion ([NIP-09](https://github.com/nostr-protocol/nips/blob/master/09.md))
- [x] Nostr Address ([NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md))
- [x] Internationalization
- [x] Badges ([NIP-58](https://github.com/nostr-protocol/nips/blob/master/58.md))
- [x] Hashtag Following and Custom Hashtags
- [x] Polls ([NIP-69](https://github.com/nostr-protocol/nips/blob/master/69.md))
- [x] Relay Pages ([NIP-11](https://github.com/nostr-protocol/nips/blob/master/11.md))
- [X] Multiple Accounts
- [ ] Video/LnInvoice Previews
- [ ] Public Chats ([NIP-28](https://github.com/nostr-protocol/nips/blob/master/28.md))
- [ ] Automatic Translations
- [ ] Relay Sets (home, dms, public chats, global)
- [ ] URI Support ([NIP-21](https://github.com/nostr-protocol/nips/blob/master/21.md))
- [ ] Long-form Content ([NIP-23](https://github.com/nostr-protocol/nips/blob/master/23.md))
- [ ] Parameterized Replaceable Events ([NIP-33](https://github.com/nostr-protocol/nips/blob/master/33.md))
- [ ] Online Relay Search ([NIP-50](https://github.com/nostr-protocol/nips/blob/master/50.md))
- [ ] Verifiable static content in URLs (NIP-94)
- [ ] Login with QR
- [ ] Wallet Connect API ([NIP-47](https://github.com/nostr-protocol/nips/blob/master/47.md))
- [ ] External Identity Support ([NIP-39](https://github.com/nostr-protocol/nips/blob/master/39.md))
- [ ] Markdown Support
- [ ] Relay Authentication ([NIP-42](https://github.com/nostr-protocol/nips/blob/master/42.md))
- [ ] Content stored in relays themselves ([NIP-95](https://github.com/nostr-protocol/nips/blob/master/95.md))
- [ ] Custom Emoji ([NIP-30](https://github.com/nostr-protocol/nips/blob/master/50.md))
- [ ] Zap Forwarding
- [ ] Text Note References ([NIP-27](https://github.com/nostr-protocol/nips/blob/master/27.md))
- [ ] Audio Tracks (zapstr.live) (Kind:31337)
- [ ] Push Notifications (Zaps and Messages)
- [ ] Generic Tags ([NIP-12](https://github.com/nostr-protocol/nips/blob/master/12.md))
- [ ] Sensitive Content ([NIP-36](https://github.com/nostr-protocol/nips/blob/master/36.md))
- [ ] View Individual Reactions (Like, Boost, Zaps, Reports) per Post
- [ ] Recommended Application Handlers ([NIP-89](https://github.com/nostr-protocol/nips/blob/master/89.md))
- [ ] Events with a Subject ([NIP-14](https://github.com/nostr-protocol/nips/blob/master/14.md))
- [ ] Live Activities & Live Chats ([NIP-53](https://github.com/nostr-protocol/nips/blob/master/50.md))
- [ ] Zapraiser (NIP-TBD)
- [ ] Moderated Communities ([NIP-72](https://github.com/nostr-protocol/nips/blob/master/72.md))
- [ ] Emoji Packs (Kind:30030)
- [ ] Personal Emoji Lists (Kind:10030)
- [ ] Classifieds (Kind:30403)
- [ ] Gift Wraps & Seals ([NIP-59](https://github.com/nostr-protocol/nips/blob/master/59.md))
- [ ] Versioned Encrypted Payloads ([NIP-44](https://github.com/nostr-protocol/nips/blob/master/44.md))
- [ ] Marketplace ([NIP-15](https://github.com/nostr-protocol/nips/blob/master/15.md))
- [ ] Image/Video Capture in the app
- [ ] Bookmarks, Pinned Posts, Muted Events ([NIP-51](https://github.com/nostr-protocol/nips/blob/master/51.md))
- [ ] Proof of Work in the Phone ([NIP-13](https://github.com/nostr-protocol/nips/blob/master/13.md), [NIP-20](https://github.com/nostr-protocol/nips/blob/master/20.md))
- [ ] Expiration Support ([NIP-40](https://github.com/nostr-protocol/nips/blob/master/40.md))
- [ ] Relay List Metadata ([NIP-65](https://github.com/nostr-protocol/nips/blob/master/65.md))
- [ ] Delegated Event Signing ([NIP-26](https://github.com/nostr-protocol/nips/blob/master/26.md))
- [ ] Account Creation / Backup Guidance
- [ ] Mnemonic seed phrase ([NIP-06](https://github.com/nostr-protocol/nips/blob/master/06.md))
- [ ] Message Sent feedback ([NIP-20](https://github.com/nostr-protocol/nips/blob/master/20.md))
- [ ] OpenTimestamps Attestations ([NIP-03](https://github.com/nostr-protocol/nips/blob/master/03.md))
- [ ] User Statuses ([NIP-315](https://github.com/nostr-protocol/nips/pull/737))


## Contributions

Some initial code was used from https://github.com/haorendashu/nostrmo project.

Each amount of funding will be distributed among the contributors according to the amount of contribution. \
This will eventually allow each contributor to spend more time on the project.

Using a [Prism](https://dergigi.com/2023/03/12/lightning-prisms) address at [yana@fmar.link](https://btc.fmar.link/api/v1/invoices?storeId=7yXH2h1LUFXStGM4XPoSUpb43xkMj1riEsrAiYSWAk57&currency=SATS), each sat donation will be split into:

80% - https://nostr.com/npub1xpuz4qerklyck9evtg40wgrthq5rce2mumwuuygnxcg6q02lz9ms275ams (code)\
10% - https://nostr.com/npub1xzeq653ms8wkekfnr49kgnzwrq7ykeljkrsf7fyh7ham9t6sl72q7v4dhh (graphics + UX)\
10% - https://nostr.com/npub14wxtsrj7g2jugh70pfkzjln43vgn4p7655pgky9j9w9d75u465pqvagcye (PR + Marketing)


<a href="https://btc.fmar.link/api/v1/invoices?storeId=7yXH2h1LUFXStGM4XPoSUpb43xkMj1riEsrAiYSWAk57&currency=SATS">
<img src="https://btc.fmar.link/img/paybutton/pay.svg" style="width:209px" alt="Pay with BTCPay Server, a Self-Hosted Bitcoin Payment Processor">
</a>


## Join

I welcome contributors to join the project, specially Designers UI/UX, coders, testers.\
If you're not a coder but would like to see something added/implemented, or you have a great idea for a new feature, just don't hesitate to fill up a issue.
All constructive feedback is welcomed.
