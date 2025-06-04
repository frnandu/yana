// DO NOT EDIT. This is code i18n via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "About": MessageLookupByLibrary.simpleMessage("About"),
        "Accounts": MessageLookupByLibrary.simpleMessage("Accounts"),
        "Add_Account": MessageLookupByLibrary.simpleMessage("Add Account"),
        "Add_Custom_Emoji":
            MessageLookupByLibrary.simpleMessage("Add Custom Emoji"),
        "Add_account_and_login":
            MessageLookupByLibrary.simpleMessage("Add account and login?"),
        "Add_now": MessageLookupByLibrary.simpleMessage("Add now"),
        "Add_this_relay_to_local":
            MessageLookupByLibrary.simpleMessage("Add this relay to local?"),
        "Add_to_known_list":
            MessageLookupByLibrary.simpleMessage("Add to known list"),
        "Address_can_t_be_null":
            MessageLookupByLibrary.simpleMessage("Address can\'t be null."),
        "Any": MessageLookupByLibrary.simpleMessage("Any"),
        "Authenticat_need":
            MessageLookupByLibrary.simpleMessage("Authenticat need"),
        "Auto_Open_Sensitive_Content":
            MessageLookupByLibrary.simpleMessage("Auto Open Sensitive Content"),
        "Backup_and_Safety_tips":
            MessageLookupByLibrary.simpleMessage("Backup private key"),
        "Banner": MessageLookupByLibrary.simpleMessage("Banner"),
        "Begin_to_download_translate_model":
            MessageLookupByLibrary.simpleMessage(
                "Begin to download translate model"),
        "Begin_to_load_Contact_History": MessageLookupByLibrary.simpleMessage(
            "Begin to load Contact History"),
        "Block": MessageLookupByLibrary.simpleMessage("Block"),
        "Blocked_Profiles":
            MessageLookupByLibrary.simpleMessage("Blocked Profiles"),
        "Blocked_Words": MessageLookupByLibrary.simpleMessage("Blocked Words"),
        "Boost": MessageLookupByLibrary.simpleMessage("Boost"),
        "Broadcast": MessageLookupByLibrary.simpleMessage("Broadcast"),
        "Broadcast_When_Boost":
            MessageLookupByLibrary.simpleMessage("Broadcast When Boost"),
        "Buy_me_a_coffee":
            MessageLookupByLibrary.simpleMessage("Buy me a coffee!"),
        "Cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "Close_at": MessageLookupByLibrary.simpleMessage("Close at"),
        "Confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "Content": MessageLookupByLibrary.simpleMessage("Content"),
        "Content_warning":
            MessageLookupByLibrary.simpleMessage("Content warning"),
        "Copy_Hex_Key": MessageLookupByLibrary.simpleMessage("Copy Hex Key"),
        "Copy_Key": MessageLookupByLibrary.simpleMessage("Copy Key"),
        "Copy_Note_Id": MessageLookupByLibrary.simpleMessage("Copy Note Id"),
        "Copy_Note_Json":
            MessageLookupByLibrary.simpleMessage("Copy Note Json"),
        "Copy_Note_Pubkey":
            MessageLookupByLibrary.simpleMessage("Copy Note Pubkey"),
        "Copy_current_Url":
            MessageLookupByLibrary.simpleMessage("Copy current Url"),
        "Copy_init_Url": MessageLookupByLibrary.simpleMessage("Copy init Url"),
        "Copy_success": MessageLookupByLibrary.simpleMessage("Copy success!"),
        "Custom": MessageLookupByLibrary.simpleMessage("Custom"),
        "Custom_Color": MessageLookupByLibrary.simpleMessage("Custom Color"),
        "Custom_Font_Family":
            MessageLookupByLibrary.simpleMessage("Custom Font Family"),
        "Dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "Data": MessageLookupByLibrary.simpleMessage("Data"),
        "Default_Color": MessageLookupByLibrary.simpleMessage("Default Color"),
        "Default_Font_Family":
            MessageLookupByLibrary.simpleMessage("Default Font Family"),
        "Default_tab": MessageLookupByLibrary.simpleMessage("Default tab"),
        "Delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "Delete_Account":
            MessageLookupByLibrary.simpleMessage("Delete Account"),
        "Delete_Account_Tips": MessageLookupByLibrary.simpleMessage(
            "We will try to delete you infomation. When you login with this Key again, you will lose your data."),
        "Detail": MessageLookupByLibrary.simpleMessage("Detail"),
        "Developers_will_never_require_a_key_from_you":
            MessageLookupByLibrary.simpleMessage(
                "Developers will never require a key from you."),
        "Display_Name": MessageLookupByLibrary.simpleMessage("Display Name"),
        "Donate": MessageLookupByLibrary.simpleMessage("Donate"),
        "Dont_Compress":
            MessageLookupByLibrary.simpleMessage("Don\'t Compress"),
        "Empty_text_may_be_ban_by_relays": MessageLookupByLibrary.simpleMessage(
            "Empty text may be ban by relays."),
        "Face": MessageLookupByLibrary.simpleMessage("Face"),
        "Filters": MessageLookupByLibrary.simpleMessage("Security Filters"),
        "Find_clouded_relay_list_do_you_want_to_download":
            MessageLookupByLibrary.simpleMessage(
                "Find clouded relay list, do you want to download it?"),
        "Fingerprint": MessageLookupByLibrary.simpleMessage("Fingerprint"),
        "Follow_System": MessageLookupByLibrary.simpleMessage("Follow System"),
        "Followed": MessageLookupByLibrary.simpleMessage("Followed"),
        "Followed_Communities":
            MessageLookupByLibrary.simpleMessage("Followed Communities"),
        "Followed_Tags": MessageLookupByLibrary.simpleMessage("Followed Tags"),
        "Following": MessageLookupByLibrary.simpleMessage("Following"),
        "Font_Family": MessageLookupByLibrary.simpleMessage("Font Family"),
        "Font_Size": MessageLookupByLibrary.simpleMessage("Font Size"),
        "Forbid": MessageLookupByLibrary.simpleMessage("Forbid"),
        "Forbid_image": MessageLookupByLibrary.simpleMessage("Image preview"),
        "Forbid_video": MessageLookupByLibrary.simpleMessage("Forbid video"),
        "From": MessageLookupByLibrary.simpleMessage("From"),
        "Gen_invoice_code_error":
            MessageLookupByLibrary.simpleMessage("Gen invoice code error."),
        "Generate_a_new_private_key":
            MessageLookupByLibrary.simpleMessage("Generate a new private key"),
        "Global": MessageLookupByLibrary.simpleMessage("Global"),
        "Globals": MessageLookupByLibrary.simpleMessage("Globals"),
        "Hide": MessageLookupByLibrary.simpleMessage("Hide"),
        "Home": MessageLookupByLibrary.simpleMessage("Home"),
        "Hour": MessageLookupByLibrary.simpleMessage("Hour"),
        "I_accept_the": MessageLookupByLibrary.simpleMessage("I accept the"),
        "Image_Compress":
            MessageLookupByLibrary.simpleMessage("Image Compress"),
        "Image_save_success":
            MessageLookupByLibrary.simpleMessage("Image saved successfully"),
        "Image_service": MessageLookupByLibrary.simpleMessage("Image service"),
        "Input": MessageLookupByLibrary.simpleMessage("Input"),
        "Input_Comment": MessageLookupByLibrary.simpleMessage("Input Comment"),
        "Input_Custom_Emoji_Name":
            MessageLookupByLibrary.simpleMessage("Input Custom Emoji Name"),
        "Input_Sats_num":
            MessageLookupByLibrary.simpleMessage("Input Sats num"),
        "Input_Sats_num_to_gen_lightning_invoice":
            MessageLookupByLibrary.simpleMessage(
                "Input Sats num to gen lightning invoice"),
        "Input_account_private_key":
            MessageLookupByLibrary.simpleMessage("Input account private key"),
        "Input_can_not_be_null":
            MessageLookupByLibrary.simpleMessage("Input can not be null"),
        "Input_dirtyword":
            MessageLookupByLibrary.simpleMessage("Input dirtyword."),
        "Input_parse_error":
            MessageLookupByLibrary.simpleMessage("Input parse error"),
        "Input_relay_address":
            MessageLookupByLibrary.simpleMessage("Input relay address."),
        "Key_Backup": MessageLookupByLibrary.simpleMessage("Keys"),
        "Language": MessageLookupByLibrary.simpleMessage("Language"),
        "Light": MessageLookupByLibrary.simpleMessage("Light"),
        "Lightning_Invoice":
            MessageLookupByLibrary.simpleMessage("Lightning Invoice"),
        "Link_preview": MessageLookupByLibrary.simpleMessage("Link preview"),
        "Lnurl_and_Lud16_can_t_found": MessageLookupByLibrary.simpleMessage(
            "Lnurl and Lud16 can\'t found."),
        "Login": MessageLookupByLibrary.simpleMessage("Login"),
        "Lud16": MessageLookupByLibrary.simpleMessage("Lud16"),
        "Mentions": MessageLookupByLibrary.simpleMessage("Mentions"),
        "Metadata_can_not_be_found":
            MessageLookupByLibrary.simpleMessage("Metadata can not be found."),
        "Method": MessageLookupByLibrary.simpleMessage("Method"),
        "Minute": MessageLookupByLibrary.simpleMessage("Minute"),
        "More": MessageLookupByLibrary.simpleMessage("More"),
        "Name": MessageLookupByLibrary.simpleMessage("Name"),
        "Network": MessageLookupByLibrary.simpleMessage("Network"),
        "Nip05": MessageLookupByLibrary.simpleMessage("Nip05"),
        "Note_Id": MessageLookupByLibrary.simpleMessage("Note Id"),
        "Note_loading": MessageLookupByLibrary.simpleMessage("Note loading..."),
        "Notes": MessageLookupByLibrary.simpleMessage("Notes"),
        "Notice": MessageLookupByLibrary.simpleMessage("Notice"),
        "Notices": MessageLookupByLibrary.simpleMessage("Notices"),
        "Notify": MessageLookupByLibrary.simpleMessage("Notify"),
        "Number_parse_error":
            MessageLookupByLibrary.simpleMessage("Number parse error"),
        "Open_Event_from_cache":
            MessageLookupByLibrary.simpleMessage("Open Event from cache"),
        "Open_Note_detail":
            MessageLookupByLibrary.simpleMessage("Open Note detail"),
        "Open_User_page":
            MessageLookupByLibrary.simpleMessage("Open User page"),
        "Open_in_browser":
            MessageLookupByLibrary.simpleMessage("Open in browser"),
        "Optional": MessageLookupByLibrary.simpleMessage("Optional"),
        "Password": MessageLookupByLibrary.simpleMessage("Password"),
        "Pay": MessageLookupByLibrary.simpleMessage("Pay"),
        "Picture": MessageLookupByLibrary.simpleMessage("Picture"),
        "Please_authenticate_to_turn_off_the_privacy_lock":
            MessageLookupByLibrary.simpleMessage(
                "Please authenticate to turn off the privacy lock"),
        "Please_authenticate_to_turn_on_the_privacy_lock":
            MessageLookupByLibrary.simpleMessage(
                "Please authenticate to turn on the privacy lock"),
        "Please_authenticate_to_use_app": MessageLookupByLibrary.simpleMessage(
            "Please authenticate to use app"),
        "Please_check_the_tips":
            MessageLookupByLibrary.simpleMessage("Please check the tips."),
        "Please_input": MessageLookupByLibrary.simpleMessage("Please input"),
        "Please_input_Topic_text":
            MessageLookupByLibrary.simpleMessage("Please input Topic text"),
        "Please_input_event_id":
            MessageLookupByLibrary.simpleMessage("Please input event id"),
        "Please_input_lnbc_text":
            MessageLookupByLibrary.simpleMessage("Please input lnbc text"),
        "Please_input_search_content":
            MessageLookupByLibrary.simpleMessage("Please input search content"),
        "Please_input_title":
            MessageLookupByLibrary.simpleMessage("Please input title"),
        "Please_input_user_pubkey":
            MessageLookupByLibrary.simpleMessage("Please input user pubkey"),
        "Please_keep_the_key_properly_for_account_recovery":
            MessageLookupByLibrary.simpleMessage(
                "Please keep the key properly for account recovery."),
        "Posts": MessageLookupByLibrary.simpleMessage("Posts"),
        "Posts_and_replies":
            MessageLookupByLibrary.simpleMessage("Posts & Replies"),
        "Privacy_Lock":
            MessageLookupByLibrary.simpleMessage("Require unlock to use"),
        "Private_key_is_null":
            MessageLookupByLibrary.simpleMessage("Private key is null."),
        "Quote": MessageLookupByLibrary.simpleMessage("Quote"),
        "Read": MessageLookupByLibrary.simpleMessage("Read"),
        "Recovery": MessageLookupByLibrary.simpleMessage("Recovery"),
        "Relays": MessageLookupByLibrary.simpleMessage("Relays"),
        "Replying": MessageLookupByLibrary.simpleMessage("Replying"),
        "Requests": MessageLookupByLibrary.simpleMessage("Requests"),
        "Search": MessageLookupByLibrary.simpleMessage("Search"),
        "Search_User_from_cache":
            MessageLookupByLibrary.simpleMessage("Search User from cache"),
        "Search_note_content":
            MessageLookupByLibrary.simpleMessage("Search note content"),
        "Search_pubkey_event":
            MessageLookupByLibrary.simpleMessage("Search pubkey event"),
        "Send": MessageLookupByLibrary.simpleMessage("Send"),
        "Send_fail": MessageLookupByLibrary.simpleMessage("Send fail"),
        "Setting": MessageLookupByLibrary.simpleMessage("Settings"),
        "Share": MessageLookupByLibrary.simpleMessage("Share"),
        "Show": MessageLookupByLibrary.simpleMessage("Show"),
        "Show_web": MessageLookupByLibrary.simpleMessage("Show web"),
        "Sign_fail": MessageLookupByLibrary.simpleMessage("Sign fail"),
        "Source": MessageLookupByLibrary.simpleMessage("Source"),
        "Submit": MessageLookupByLibrary.simpleMessage("Submit"),
        "Table_Mode": MessageLookupByLibrary.simpleMessage("Table Mode"),
        "Text_can_t_contain_blank_space": MessageLookupByLibrary.simpleMessage(
            "Text can\'t contain blank space"),
        "Text_can_t_contain_new_line": MessageLookupByLibrary.simpleMessage(
            "Text can\'t contain new line"),
        "Theme_Color": MessageLookupByLibrary.simpleMessage("Theme Color"),
        "Theme_Style":
            MessageLookupByLibrary.simpleMessage("Use Theme from System"),
        "This_note_contains_sensitive_content":
            MessageLookupByLibrary.simpleMessage(
                "This note contains sensitive content"),
        "Topic": MessageLookupByLibrary.simpleMessage("Topic"),
        "Topics": MessageLookupByLibrary.simpleMessage("Topics"),
        "Translate": MessageLookupByLibrary.simpleMessage("Translate"),
        "Translate_Source_Language":
            MessageLookupByLibrary.simpleMessage("Translate Source Language"),
        "Translate_Target_Language":
            MessageLookupByLibrary.simpleMessage("Translate Target Language"),
        "Upload_fail": MessageLookupByLibrary.simpleMessage("Upload fail."),
        "Use_lightning_wallet_scan_and_send_sats":
            MessageLookupByLibrary.simpleMessage(
                "Use lightning wallet scan and send sats."),
        "User_Pubkey": MessageLookupByLibrary.simpleMessage("User Pubkey"),
        "Users": MessageLookupByLibrary.simpleMessage("Users"),
        "Verify_error": MessageLookupByLibrary.simpleMessage("Verify error"),
        "Verify_failure":
            MessageLookupByLibrary.simpleMessage("Verify failure"),
        "Video_preview_in_list":
            MessageLookupByLibrary.simpleMessage("Video preview in list"),
        "Web_Appbar": MessageLookupByLibrary.simpleMessage("Web Appbar"),
        "Web_Utils": MessageLookupByLibrary.simpleMessage("Web Utils"),
        "Website": MessageLookupByLibrary.simpleMessage("Website"),
        "What_s_happening":
            MessageLookupByLibrary.simpleMessage("What\'s happening?"),
        "Word_can_t_be_null":
            MessageLookupByLibrary.simpleMessage("Word can\'t be null."),
        "Write": MessageLookupByLibrary.simpleMessage("Write"),
        "Write_a_message":
            MessageLookupByLibrary.simpleMessage("Write a message"),
        "Wrong_Private_Key_format":
            MessageLookupByLibrary.simpleMessage("Wrong Private Key format"),
        "You_had_voted_with":
            MessageLookupByLibrary.simpleMessage("You had voted with"),
        "Zap_num_can_not_bigger_then":
            MessageLookupByLibrary.simpleMessage("Zap num can not bigger then"),
        "Zap_num_can_not_smaller_then": MessageLookupByLibrary.simpleMessage(
            "Zap num can not smaller then"),
        "add_poll_option":
            MessageLookupByLibrary.simpleMessage("add poll option"),
        "always": MessageLookupByLibrary.simpleMessage("Always"),
        "auto": MessageLookupByLibrary.simpleMessage("Auto"),
        "boosted": MessageLookupByLibrary.simpleMessage("boosted"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "key_has_been_copy":
            MessageLookupByLibrary.simpleMessage("key has been copy!"),
        "liked": MessageLookupByLibrary.simpleMessage("liked"),
        "loading": MessageLookupByLibrary.simpleMessage("Loading"),
        "max_zap_num": MessageLookupByLibrary.simpleMessage("max zap num"),
        "min_zap_num": MessageLookupByLibrary.simpleMessage("min zap num"),
        "network_take_effect_tip": MessageLookupByLibrary.simpleMessage(
            "The network will take effect the next time the app is launched"),
        "never": MessageLookupByLibrary.simpleMessage("Never"),
        "not_found": MessageLookupByLibrary.simpleMessage("not found"),
        "open": MessageLookupByLibrary.simpleMessage("Open"),
        "or": MessageLookupByLibrary.simpleMessage("or"),
        "poll_option_info":
            MessageLookupByLibrary.simpleMessage("poll option info"),
        "posted": MessageLookupByLibrary.simpleMessage("posted"),
        "replied": MessageLookupByLibrary.simpleMessage("replied"),
        "terms_of_user": MessageLookupByLibrary.simpleMessage("terms of user"),
        "videoAutoplay": MessageLookupByLibrary.simpleMessage("Video Autoplay"),
        "wifiOnly": MessageLookupByLibrary.simpleMessage("Wi-Fi only")
      };
}
