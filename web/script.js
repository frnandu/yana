async function getPublicKey() {
    if (window.nostr) {
        let result = await window.nostr.getPublicKey();
        return result;
    }
    return "";
}

async function signEvent(event) {
    if (window.nostr) {
        return window.nostr.signEvent(event);
    }
}
