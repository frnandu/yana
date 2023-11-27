# What is the Gossip model, a.k.a. inbox/outbox model?

As [Mike Dilger](https://mikedilger.com/) puts it:\
"The simplest characterization of the gossip model is just this:\
reading the posts of people you follow from the relays that they wrote them to."

If you want to know more in detailed about the original idea from mike please read his good explanation of it [here](https://mikedilger.com/gossip-model/).

More recently, people have been calling it the outbox model, since you go fetch notes from your feed followed contacts declared outbox relays.

There is also the issue of reacting (likes, replies, reposts) to other peoples notes by broadcasting your reaction to their inbox declared relays, which is usually called the inbox model.

A good graphical explanation from Mike is this:

<img src="https://mikedilger.com/gossip-model/gossip-model.png" style="width:400px; height:400px"/>

# Yana
We believe that by using a good gossip model it helps increase nostr decentralization and censorship resistance.

So how does Yana implement specifically these models?

Yana uses https://github.com/relaystr/dart_ndk lib for nostr interaction and relay connectivity management.

The currently implemented features in the lib are:

### Load your followed contacts relay lists
It will try to find each contact relay list using your personal inbox relays merged with a pre-defined bootstrap relays known to have these lists, like for example wss://purplepag.es relay.

Sources are, sorted by priority:
- from [NIP-65](https://github.com/nostr-protocol/nips/blob/master/65.md) write (outbox) marked
- from kind3 content (Contact lists NIP-02).

It doesn't merge lists, if it finds a nip-65 it will not use kind3 list.

(in future will also fetch from NIP-05 list as a fallback)

### Calculate a relay set for outbox feed
- The calculated set will contain the minimal amount of relays for fetching notes for everybody from *at least* a configurable amount (setting "Minimal amount of relays per contact").
- It will consider a relay valid to be included in the set if:
  - It can connect to it (or already connected)
  - It's not on the blocked relay list (NIP-51 kind 10006)
- It will start from the relays that have the most amount of contacts as declared the relay as write (outbox), and go down the list until every contact has at least the minimal amount satisfied.

By changing the minimal amount you are able to better adjust for either less data usage, or more censorship resistance.\
The more relays you load notes from for a given contact, the better the chance you have of avoiding potential censorship by a bad behaving relay.\
A value somewhere between 2-5 is usually a good compromise.

### Profile notes
- It will load notes for a specific profile from their declared relays, both write (outbox for new posts) as well as read (inbox for replies).

### Reactions
- When adding a reaction (likes, replies, reposts) it will calculate a similar relay set as described above for outbox feed, but instead it will take into consideration inbox (read) relays of *all the people* involved in the conversation plus your own personal write (outbox) relays.
- To increase reach and probability of being seen by as much people as possible you can adjust the maximum amount of relays to which to broadcast (setting "Max amount of relays per reaction")
- You can choose precisely which relays to broadcast as a confirmation step on replies. Likes and reposts will use the configured default values.

A value of 5-15 is usually good.

### New posts
- It just uses your configured personal write (outbox) relays

### Notifications
- It uses your configured personal read (inbox) relays

### Thread view
- TODO (still uses personal read relays) 

### Global
- TODO (still uses personal read relays)

