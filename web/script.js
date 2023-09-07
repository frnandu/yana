async function getPublicKey() {
    if (window.nostr) {
        return await window.nostr.getPublicKey();
    }
    return "";
}

async function signEvent(event) {
    if (window.nostr) {
        return await window.nostr.signEvent(event);
    }
    return "";
}
