async function getPublicKey() {
    if (window.nostr) {
        return await window.nostr.getPublicKey();
    }
    return "";
}

async function signEvent(event) {
    console.log("SIGNING EVENT:"+event);
    if (window.nostr) {
        return await window.nostr.signEvent(event);
    }
    return "";
}

async function signSchnorr(msg) {
    console.log("SIGNING MSG: "+msg);
    if (window.nostr) {
        return await window.nostr.signSchnorr(msg);
    }
    return "";
}
