--
--  AppDelegate.applescript
--  TokenRabbit
--
--  Created by Houle, Todd - 1130 - MITLL on 3/1/18.
--  Copyright © 2018 MIT Lincoln Labs. All rights reserved.
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
    
    
	-- IBOutlets
	property theWindow : missing value
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened 
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
        
        set adminSTStatus to do shell script "sysadminctl -adminUser " & adminUser & " -adminPassword " & adminPW &  " -secureTokenStatus " & adminUser & " 2>&1 " & adminUser user name (adminUser as string) password (adminPW as string) with administrator privileges
        --DEBUG set adminSTStatus to "yes its ENABLED"
        --display dialog adminSTStatus
        
        if adminSTStatus contains "ENABLED"
            --display dialog  "Yay! does have SecureToken. "
            set my enabledAdmins to false
            set my adminStatusUser to "✔️"
            set my adminStatusPW to "✔️"
            set my adminSTText to ""
        else if adminSTStatus contains "DISABLED"
            --display dialog "User & Password are correct, but " & adminUser & " does not have SecureToken Enabled."
            set my adminSTText to "SecureToken Not Enabled"
            set my adminStatusUser to "❌"
        else
            display dialog "Couldn't get status of SecureToken for " & adminUser & "."
        end if

        --display dialog "End TestNPW routine"
    end testNamePW_

    on checkDoesUserHaveST_(sender)
        --does user exist
        try
            set userList to do shell script "dscl . -list /Users | grep -i " & targetUser
        on error
            do shell script "/System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n " & targetUser user name (targetUser as string) password (targetPW as string) with administrator privileges
        end try
        
        --DONT CARE IF USER HAS TOKEN - IT MAY BE INVALID. WILL REMOVE TOKEN BEFORE ASSIGNING
        --set xSTStatus to do shell script "sysadminctl -adminUser " & adminUser & " -adminPassword " & adminPW &  " -secureTokenStatus " & targetUser & " 2>&1 " & adminUser user name (adminUser as string) password (adminPW as string) with administrator privileges
        
        --if xSTStatus contains "ENABLED"
        --    set my userStatus to "❌"
        --    set my userSTText to "SecureToken Already Enabled"
        --    set my userEnabled to true
        --else if xSTStatus contains "DISABLED"
        --   display dialog  "Currently, " & targetUser & " does not have SecureToken Enabled."
           set my userStatus to "✔️"
           set my userSTText to ""
        --else
        --    display dialog "Couldn't get status of SecureToken for " & adminUser & ". Does user have an account on this computer?"
        --end if

    end checkDoesUserHaveST_

    on checkUserNamePW_(sender)

        try
            do shell script ("dscl /Local/Default authonly " & targetUser as string & " " & targetPW as string)
            set my userPWStatus to "✔️"
            set my userStatus to "✔️"
            set my userEnabled to false
        on error
            display dialog "User " & targetUser & " password appears incorrect" buttons "OK" default button 1
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
            do shell script "sysadminctl -adminUser " & adminUser & " -adminPassword " & adminPW &  " -secureTokenOff " & targetUser & " -password " &  targetPW & " 2>&1 " & adminUser user name (adminUser as string) password (adminPW as string) with administrator privileges
        end try
        try
            set doSTStatus to do shell script "sysadminctl -adminUser " & adminUser & " -adminPassword " & adminPW &  " -secureTokenOn " & targetUser & " -password " &  targetPW & " 2>&1 " & adminUser user name (adminUser as string) password (adminPW as string) with administrator privileges
            set my userSTText to "SecureToken Enabled"
            try
                do shell script "diskutil apfs updatePreboot /" user name (adminUser as string) password (adminPW as string) with administrator privileges
            end try
            
            display dialog "Secure Token Assigned!" buttons "Quit" default button 1
            tell me to quit
        on error
            display dialog "Error occured assigning SecureToken" buttons "Awwww" default button 1
        end try
    end assignToken_

end script
