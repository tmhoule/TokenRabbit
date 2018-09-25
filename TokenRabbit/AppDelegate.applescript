--
--  AppDelegate.applescript
--  TokenRabbit
--
--  Created by Houle, Todd on 3/1/18.
--

script AppDelegate
	property parent : class "NSObject"
    property adminUser : ""
    property adminPW : ""
    property targetUser : ""
    property targetPW : ""
    property enabledAdmins : true
    property adminStatusUser : ""
    property adminStatusPW : ""
    property userPWStatus : ""
    property userStatus : ""
    property userEnabled : true
    property adminSTText : ""
    property userSTText : ""
    property mySTusers : {"Generating..."}
    
	-- IBOutlets
	property theWindow : missing value
	
    
    --NOTES
    --    bash-3.2# diskutil apfs listCryptoUsers /
    --    No cryptographic users for disk1s1

    
	on applicationWillFinishLaunching_(aNotification)
		-- Create list of users with SecureToken
        set users to (do shell script "dscl . read /Groups/admin GroupMembership")
        set AppleScript's text item delimiters to " "
        set userList1 to every text item of users as list
        set userList to items 2 thru -1 of userList1
        set mySTusers to {}
        repeat with oneUser in userList
            set hasToken to ""
            try
            set hasToken to (do shell script "sysadminctl -secureTokenStatus " & oneUser & " 2>&1|grep ENABLED;exit 0")
            end try
            if hasToken is "" then
                --display dialog oneUser & " does NOT have a token"
                else
                --display dialog oneUser & " does have Token!"
                set my mySTusers to mySTusers & oneUser
            end if
        end repeat
        try
        set my adminUser to item 1 of mySTusers
        on error
            display dialog "No SecureToken users found. (Was this machine upgraded from 10.12? Token status is hidden on those machines) Either any user can enable filevault or no user can." buttons "Quit" default button 1 with icon 2
            tell me to quit
            --set my mySTUsers to userList
        end try

	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
    on quitTime_(sender)
        tell me to quit
    end quitTime_
    
    on testNamePW_(sender)
        try
            do shell script "touch /tmp/test$$" user name (adminUser as string) password (adminPW as string) with administrator privileges
        on error
            set my adminStatusUser to "❌"
            set my adminStatusPW to "❌"
        end try
        
        
            set my enabledAdmins to false
            set my adminStatusUser to "✔️"
            set my adminStatusPW to "✔️"
            set my adminSTText to ""

    end testNamePW_

    on selectSTuserFromPopup_(sender)
        -- display dialog  sender's titleOfSelectedItem() as text
        set my adminUser to sender's titleOfSelectedItem() as text
    end selectSTuserFromPopup_

    on checkDoesUserHaveST_(sender)
        --does user exist
        try
            set userList to do shell script "dscl . -list /Users | grep -i " & targetUser
        on error
            do shell script "/System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n " & targetUser user name (targetUser as string) password (targetPW as string) with administrator privileges
        end try
        
           set my userStatus to "✔️"
           set my userSTText to ""

    end checkDoesUserHaveST_

    on checkUserNamePW_(sender)

        try
            do shell script ("dscl /Local/Default authonly " & targetUser as string & " \"" &  targetPW & "\"")
            set my userPWStatus to "✔️"
            set my userStatus to "✔️"
            set my userEnabled to false
        on error
            display dialog "The password for " & targetUser & " appears incorrect." buttons "OK" default button 1
            set my userPWStatus to "❌"
            set my userStatus to "❌"
        end try
        checkDoesUserHaveST_(1)
    end checkUserNamePW_


    on assignToken_(sender)
        theWindow's makeFirstResponder_(theWindow)

        if enabledAdmins is not false
            display dialog "ERROR: Verify Admin name and password before assigning token." buttons "OK" default button 1
            return
        end if

        if userEnabled is not false
            display dialog "ERROR: Verify Target User's name and password before assigning token." buttons "OK" default button 1
            return
        end if

        try
            do shell script "sysadminctl -adminUser " & adminUser & " -adminPassword \"" & adminPW &  "\" -secureTokenOff " & targetUser & " -password \"" &  targetPW & "\" 2>&1 " & adminUser user name (adminUser as string) password (adminPW as string) with administrator privileges
        end try
        try
            set doSTStatus to do shell script "sysadminctl -adminUser " & adminUser & " -adminPassword \"" & adminPW &  "\" -secureTokenOn " & targetUser & " -password \"" &  targetPW & "\" 2>&1 " & adminUser user name (adminUser as string) password (adminPW as string) with administrator privileges
            set my userSTText to "SecureToken Enabled"
            try
                do shell script "diskutil apfs updatePreboot /" user name (adminUser as string) password (adminPW as string) with administrator privileges
            end try
            
            display dialog "Secure Token Assigned!" buttons "Quit" default button 1
            tell me to quit
        on error
            display dialog "Error occured assigning SecureToken. Status unknown." buttons "Aww, Snap!" default button 1
        end try
    end assignToken_

end script
